import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../attriax_clock.dart';
import 'attriax_api_models.dart';
import 'attriax_api_base_url.dart';
import 'attriax_app_open_manager.dart';
import 'attriax_context_collector.dart';
import 'attriax_context_manager.dart';
import 'attriax_deep_link_manager.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_event_hub.dart';
import 'attriax_generated_transport.dart';
import 'attriax_install_referrer_manager.dart';
import 'attriax_logger.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_preferences_store.dart';
import 'attriax_request_manager.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_session_manager.dart';
import 'attriax_synchronizer.dart';
import 'attriax_tracking_manager.dart';

/// Coordinates the Attriax SDK subsystems.
///
/// This class is intentionally thin — each concern is handled by a dedicated
/// collaborator:
/// - [AttriaxEventHub]          — streams and user callbacks
/// - [AttriaxSynchronizer]      — request queue, flush loop, sync state
/// - [AttriaxDeepLinkManager]   — deep-link listener and resolution flow
/// - [AttriaxAppOpenManager]    — app-open request lifecycle
/// - [AttriaxTrackingManager]   — analytics and user association APIs
/// - [AttriaxSessionManager]    — session state and lifecycle ownership
class AttriaxRuntime {
  AttriaxRuntime({
    required this.config,
    required AttriaxDeepLinkListener deepLinkListener,
    required AttriaxContextCollector contextCollector,
    required Connectivity connectivity,
    required http.Client client,
    required AttriaxLogger logger,
    SharedPreferences? prefsOverride,
  }) : _connectivity = connectivity,
       _client = client,
       _logger = logger,
       _clock = config.clock ?? const AttriaxSystemClock(),
       _preferencesStore = AttriaxPreferencesStore(
         prefsOverride: prefsOverride,
       ),
       _eventHub = AttriaxEventHub(),
       _requestManager = AttriaxRequestManager() {
    _platformInstallReferrerManager =
        contextCollector.platformInstallReferrerManager;
    _contextManager = AttriaxContextManager(
      contextCollector: contextCollector,
      preferencesStore: _preferencesStore,
      logger: _logger,
    );
    _sessionManager = AttriaxSessionManager(
      config: config,
      contextManager: _contextManager,
      preferencesStore: _preferencesStore,
      logger: _logger,
      settingsState: _settingsState,
      requestManager: _requestManager,
      clock: _clock,
    );
    _deepLinkManager = AttriaxDeepLinkManager(
      config: config,
      contextManager: _contextManager,
      listener: deepLinkListener,
      eventHub: _eventHub,
      requestManager: _requestManager,
      logger: _logger,
      clock: _clock,
    );
    _appOpenManager = AttriaxAppOpenManager(
      config: config,
      contextManager: _contextManager,
      platformInstallReferrerManager: _platformInstallReferrerManager,
      sessionManager: _sessionManager,
      requestManager: _requestManager,
      logger: _logger,
    );
    _installReferrerManager = AttriaxInstallReferrerManager(
      preferencesStore: _preferencesStore,
      appOpenManager: _appOpenManager,
    );
    _trackingManager = AttriaxTrackingManager(
      config: config,
      logger: _logger,
      clock: _clock,
      contextManager: _contextManager,
      settingsState: _settingsState,
      requestManager: _requestManager,
      sessionManager: _sessionManager,
    );
  }

  final AttriaxConfig config;
  final Connectivity _connectivity;
  final http.Client _client;
  final AttriaxLogger _logger;
  final AttriaxClock _clock;
  final AttriaxPreferencesStore _preferencesStore;
  final AttriaxEventHub _eventHub;
  final AttriaxRequestManager _requestManager;
  late final AttriaxPlatformInstallReferrerManager
  _platformInstallReferrerManager;
  late final AttriaxContextManager _contextManager;
  late final AttriaxDeepLinkManager _deepLinkManager;
  late final AttriaxAppOpenManager _appOpenManager;
  late final AttriaxInstallReferrerManager _installReferrerManager;
  late final AttriaxTrackingManager _trackingManager;
  late final AttriaxSessionManager _sessionManager;

  AttriaxSynchronizer? _synchronizer;
  AttriaxGeneratedTransport? _transport;

  bool _initialized = false;
  late final AttriaxRuntimeSettingsState _settingsState =
      AttriaxRuntimeSettingsState(
        preferencesStore: _preferencesStore,
        logger: _logger,
      );
  bool _trackAppOpen = true;
  Future<void>? _initializationFuture;
  AttriaxNormalizedApiBaseUrl? _normalizedApiBaseUrl;
  bool _isSchedulingAppOpen = false;
  FlutterExceptionHandler? _previousFlutterErrorHandler;
  FlutterExceptionHandler? _installedFlutterErrorHandler;
  bool Function(Object, StackTrace)? _previousPlatformErrorHandler;
  bool Function(Object, StackTrace)? _installedPlatformErrorHandler;

  // ---------- getters ------------------------------------------------------- //

  bool get isInitialized => _initialized;
  bool get isEnabled => _settingsState.isEnabled;
  bool get areEventsEnabled => _settingsState.areEventsEnabled;
  bool get isFirstLaunch => _contextManager.isFirstLaunch;
  String? get deviceId => _contextManager.deviceId;
  AttriaxSessionSnapshot? get currentSession => _sessionManager.currentSession;
  bool get isSynchronized =>
      _synchronizer?.synchronizationState ==
      AttriaxSynchronizationState.synchronized;
  AttriaxSdkSnapshot? get sdkSnapshot => _contextManager.sdkSnapshot;
  Future<AttriaxInstallReferrerDetails?> get installReferrer =>
      _installReferrerManager.future;
  AttriaxDeepLinkResult? get initialDeepLink =>
      _deepLinkManager.initialDeepLink;
  bool get isInitialDeepLinkResolved =>
      _deepLinkManager.isInitialDeepLinkResolved;
  AttriaxDeepLinkResult? get latestDeepLink => _deepLinkManager.latestDeepLink;
  AttriaxSynchronizationState get synchronizationState =>
      _synchronizer?.synchronizationState ??
      AttriaxSynchronizationState.initializing;

  AttriaxNormalizedApiBaseUrl get _apiBaseUrlConfig =>
      _normalizedApiBaseUrl ??= normalizeAttriaxApiBaseUrl(config.apiBaseUrl);

  bool get _sessionTrackingEnabled => config.sessionTrackingEnabled;

  // ---------- streams (delegated to hub) ------------------------------------ //

  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinkManager.stream;
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _eventHub.synchronizationStates;

  // ---------- init ---------------------------------------------------------- //

  Future<void> init({
    bool? enabled,
    bool? eventsEnabled,
    bool trackAppOpen = true,
  }) {
    if (_initialized) {
      return Future<void>.value();
    }

    final inFlight = _initializationFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final initialization = _runInit(
      enabled: enabled,
      eventsEnabled: eventsEnabled,
      trackAppOpen: trackAppOpen,
    );
    _initializationFuture = initialization;

    return initialization.whenComplete(() {
      if (identical(_initializationFuture, initialization)) {
        _initializationFuture = null;
      }
    });
  }

  Future<void> _runInit({
    required bool trackAppOpen,
    bool? enabled,
    bool? eventsEnabled,
  }) async {
    _logger.verbose('Initializing Attriax SDK.');
    _validateConfig();

    final storedRuntimePreferences = await _preferencesStore
        .restoreRuntimePreferences(
          enabledOverride: enabled ?? _settingsState.requestedEnabledOverride,
          eventsEnabledOverride:
              eventsEnabled ?? _settingsState.requestedEventsEnabledOverride,
        );
    _settingsState.restore(
      enabled: storedRuntimePreferences.isEnabled,
      eventsEnabled: storedRuntimePreferences.areEventsEnabled,
    );
    _trackAppOpen = trackAppOpen;
    await _installReferrerManager.init(
      enabled: isEnabled,
      waitForAppOpen: trackAppOpen,
    );

    await _contextManager.init();
    final sessionRestore = await _sessionManager.init(
      enabled: _sessionTrackingEnabled,
    );

    _transport ??= AttriaxGeneratedTransport(
      apiBaseUrl: _apiBaseUrlConfig.apiBaseUrl,
      requestTimeout: config.requestTimeout,
      httpClient: _client,
    );

    _synchronizer ??= AttriaxSynchronizer(
      transport: _transport!,
      connectivity: _connectivity,
      preferencesStore: _preferencesStore,
      maxQueueSize: config.maxQueueSize,
      eventFlushInterval: config.eventFlushInterval,
      logger: _logger,
    );
    _requestManager.bindSynchronizer(_synchronizer!);
    _synchronizer!.onStateChanged = _eventHub.emitSynchronizationState;

    _initialized = true;

    if (!isEnabled) {
      _installReferrerManager.completeDisabled();
      _deepLinkManager.completeInitialLinkIfAbsent();
      _synchronizer!.setState(AttriaxSynchronizationState.disabled);
      _logger.warning('Attriax SDK initialized in disabled mode.');
      return;
    }

    _sessionManager.seedRecoveredSessionEnd(sessionRestore?.replacedSession);
    _installCrashHandlers();
    await _capturePendingNativeCrashReport();
    await _replayPendingCrashReport();

    _synchronizer!.startConnectivitySubscription(
      onRestored: _synchronizer!.scheduleFlush,
    );
    await _deepLinkManager.start();

    if (trackAppOpen) {
      _scheduleAppOpenIfNeeded();
    }

    _sessionManager.activate();
    _synchronizer!.scheduleFlush();
    _logger.verbose('Attriax SDK initialized.');
  }

  // ---------- tracking ------------------------------------------------------ //

  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) async {
    _assertInitialized();
    await _trackingManager.recordEvent(
      eventName,
      eventData: eventData,
      flushImmediately: flushImmediately,
    );
  }

  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) async {
    _assertInitialized();
    await _trackingManager.recordPageView(
      pageName,
      pageClass: pageClass,
      pageTitle: pageTitle,
      previousPageName: previousPageName,
      parameters: parameters,
      source: source,
      flushImmediately: flushImmediately,
    );
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  }) async {
    _assertInitialized();
    await _trackingManager.recordError(
      error,
      stackTrace,
      fatal: fatal,
      source: source,
      reason: reason,
      metadata: metadata,
    );
  }

  Future<void> setUser(String? userId, {String? userName}) async {
    _assertInitialized();
    await _trackingManager.setUser(userId, userName: userName);
  }

  Future<void> setUserProperty(String name, Object? value) async {
    _assertInitialized();
    await _trackingManager.setUserProperty(name, value);
  }

  Future<void> setUserProperties(Map<String, Object?> properties) async {
    _assertInitialized();
    await _trackingManager.setUserProperties(properties);
  }

  Future<void> clearUserProperties({List<String>? propertyNames}) async {
    _assertInitialized();
    await _trackingManager.clearUserProperties(propertyNames: propertyNames);
  }

  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    Map<String, Object?>? data,
  }) async {
    _assertInitialized();

    final request = attriaxBuildCreateDynamicLinkRequest(
      appToken: config.appToken,
      name: _trimOrNull(name),
      destinationUrl: _trimOrNull(destinationUrl),
      group: _trimOrNull(group),
      prefix: _trimOrNull(prefix),
      redirects: redirects == null
          ? null
          : AttriaxDynamicLinkRedirects(
              ios: redirects.ios,
              android: redirects.android,
            ),
      socialPreview: socialPreview == null
          ? null
          : AttriaxDynamicLinkSocialPreview(
              title: _trimOrNull(socialPreview.title),
              description: _trimOrNull(socialPreview.description),
              imagePath: _trimOrNull(socialPreview.imagePath),
            ),
      utms: utms == null
          ? null
          : AttriaxDynamicLinkUtms(
              source: _trimOrNull(utms.source),
              medium: _trimOrNull(utms.medium),
              campaign: _trimOrNull(utms.campaign),
              term: _trimOrNull(utms.term),
              content: _trimOrNull(utms.content),
            ),
      data: data,
    );

    return _transport!.createDynamicLink(request);
  }

  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    String? provider,
    String? environment,
    String? transactionId,
    String? originalTransactionId,
    String? productId,
    String? store,
    String? packageName,
    String? purchaseToken,
    String? receiptData,
    String? signedPayload,
    String? receiptSignature,
    bool? test,
  }) async {
    _assertInitialized();

    final currentDeviceId = deviceId;
    if (currentDeviceId == null) {
      throw StateError('Attriax SDK did not restore a device id.');
    }

    final request = attriaxBuildValidateRevenueReceiptRequest(
      appToken: config.appToken,
      deviceId: currentDeviceId,
      clientOccurredAt: _clock.now(),
      provider: _trimOrNull(provider),
      environment: _trimOrNull(environment),
      transactionId: _trimOrNull(transactionId),
      originalTransactionId: _trimOrNull(originalTransactionId),
      productId: _trimOrNull(productId),
      store: _trimOrNull(store),
      packageName:
          _trimOrNull(packageName) ?? _trimOrNull(config.appPackageName),
      purchaseToken: _trimOrNull(purchaseToken),
      receiptData: _trimOrNull(receiptData),
      signedPayload: _trimOrNull(signedPayload),
      receiptSignature: _trimOrNull(receiptSignature),
      test: test,
    );

    return _transport!.validateRevenueReceipt(request);
  }

  Future<AttriaxDeepLinkResolution?> recordDeepLink({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    _assertInitialized();
    if (!isEnabled) {
      _logger.verbose('Ignoring recordDeepLink because SDK is disabled.');
      return null;
    }

    if (_sessionTrackingEnabled) {
      await _sessionManager.prepareTrackedSessionAt(_clock.now());
    }

    return _deepLinkManager.recordManualConversion(
      uri: uri,
      linkPath: linkPath,
      metadata: metadata,
      source: source,
    );
  }

  Future<AttriaxDeepLinkResult?> waitForInitialDeepLink() =>
      _deepLinkManager.waitForInitialDeepLink();

  // ---------- enable / disable ---------------------------------------------- //

  void setEnabled({required bool enabled}) => _settingsState.setEnabled(
    enabled: enabled,
    initialized: _initialized,
    applyState: _applyEnabledState,
    onPreparingToEnable: enabled
        ? _prepareInstallReferrerCompleterForReenable
        : null,
  );

  void setEventsEnabled({required bool enabled}) =>
      _settingsState.setEventsEnabled(enabled: enabled);

  // ---------- app open ------------------------------------------------------ //

  // ---------- dispose ------------------------------------------------------- //

  Future<void> dispose() async {
    _logger.verbose('Disposing Attriax SDK runtime.');
    _restoreCrashHandlers();
    _sessionManager.dispose();
    _installReferrerManager.dispose();
    await _deepLinkManager.stop();
    await _synchronizer?.dispose();
    await _appOpenManager.dispose();
    await _eventHub.dispose();
    _client.close();
  }

  // ---------- private ------------------------------------------------------- //

  void _validateConfig() {
    if (config.appToken.trim().isEmpty) {
      throw ArgumentError('Attriax appToken must not be empty.');
    }
    _apiBaseUrlConfig;
    if (config.maxQueueSize <= 0) {
      throw ArgumentError('Attriax maxQueueSize must be greater than zero.');
    }
    if (config.eventFlushInterval.isNegative) {
      throw ArgumentError('Attriax eventFlushInterval must not be negative.');
    }
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError('Attriax SDK not initialized. Call init() first.');
    }
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String _requireDeviceIdSource() => _contextManager.requireDeviceIdSource();

  Future<void> _applyEnabledState(bool enabled) async {
    if (!enabled) {
      _sessionManager.deactivate();
      _synchronizer?.deactivate();
      _synchronizer?.setState(AttriaxSynchronizationState.disabled);
      _logger.warning('Attriax SDK disabled.');
      await _deepLinkManager.stop();
      await _synchronizer?.stopConnectivitySubscription();
      return;
    }

    _synchronizer?.activate();
    _synchronizer?.setState(AttriaxSynchronizationState.synchronizing);
    _logger.verbose('Attriax SDK enabled.');
    if (_initialized && _synchronizer != null) {
      _synchronizer!.startConnectivitySubscription(
        onRestored: _synchronizer!.scheduleFlush,
      );
      await _deepLinkManager.start();
      await _prepareInstallReferrerFutureForEnabledState();
      _scheduleAppOpenIfNeeded();
      _sessionManager.activate();
      _synchronizer!.scheduleFlush();
    }
  }

  Future<void> _prepareInstallReferrerFutureForEnabledState() async {
    await _installReferrerManager.prepareForEnabledState(
      waitForAppOpen: _trackAppOpen,
    );
  }

  void _prepareInstallReferrerCompleterForReenable() {
    _installReferrerManager.prepareForReenable(waitForAppOpen: _trackAppOpen);
  }

  void _scheduleAppOpenIfNeeded() {
    if (!_initialized ||
        !isEnabled ||
        !_trackAppOpen ||
        _synchronizer == null ||
        _isSchedulingAppOpen ||
        _appOpenManager.didSchedule) {
      return;
    }

    _isSchedulingAppOpen = true;
    unawaited(_scheduleAppOpen());
  }

  Future<void> _scheduleAppOpen() async {
    try {
      await _appOpenManager.schedule(
        onCompleted: (result) async {
          _deepLinkManager.handleDeferredAppOpen(result);
        },
      );
    } finally {
      _isSchedulingAppOpen = false;
    }
  }

  void _installCrashHandlers() {
    if (_installedFlutterErrorHandler == null) {
      _previousFlutterErrorHandler = FlutterError.onError;
      _installedFlutterErrorHandler = (details) {
        _previousFlutterErrorHandler?.call(details);
        final metadata = <String, Object?>{
          if (details.library != null) 'library': details.library!,
          if (details.silent) 'silent': true,
        };
        unawaited(
          _recordAutomaticFrameworkError(
            details.exception,
            details.stack ?? StackTrace.current,
            reason: details.context?.toDescription(),
            metadata: metadata.isEmpty ? null : metadata,
          ),
        );
      };
      FlutterError.onError = _installedFlutterErrorHandler;
    }

    if (_installedPlatformErrorHandler == null) {
      _previousPlatformErrorHandler = ui.PlatformDispatcher.instance.onError;
      _installedPlatformErrorHandler = (error, stackTrace) {
        unawaited(
          _persistFatalCrashForRetry(
            error,
            stackTrace,
            source: 'platform_dispatcher',
            reason: 'Unhandled root isolate error',
          ),
        );

        final previous = _previousPlatformErrorHandler;
        if (previous != null) {
          return previous(error, stackTrace);
        }

        return false;
      };
      ui.PlatformDispatcher.instance.onError = _installedPlatformErrorHandler;
    }
  }

  void _restoreCrashHandlers() {
    if (identical(FlutterError.onError, _installedFlutterErrorHandler)) {
      FlutterError.onError = _previousFlutterErrorHandler;
    }
    if (identical(
      ui.PlatformDispatcher.instance.onError,
      _installedPlatformErrorHandler,
    )) {
      ui.PlatformDispatcher.instance.onError = _previousPlatformErrorHandler;
    }

    _installedFlutterErrorHandler = null;
    _previousFlutterErrorHandler = null;
    _installedPlatformErrorHandler = null;
    _previousPlatformErrorHandler = null;
  }

  Future<void> _recordAutomaticFrameworkError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, Object?>? metadata,
  }) async {
    if (!_initialized || !isEnabled) {
      return;
    }

    await _trackingManager.recordError(
      error,
      stackTrace,
      fatal: false,
      source: 'flutter_error',
      reason: reason,
      metadata: metadata,
    );
  }

  Future<void> _persistFatalCrashForRetry(
    Object error,
    StackTrace stackTrace, {
    required String source,
    String? reason,
    Map<String, Object?>? metadata,
  }) async {
    if (!_initialized || !isEnabled) {
      return;
    }

    await _storePendingCrashReport(
      attriaxBuildTrackCrashRequest(
        appToken: config.appToken,
        clientOccurredAt: _clock.now(),
        context: _contextManager.requiredSnapshot,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _requireDeviceIdSource(),
        source: source,
        isFatal: true,
        exceptionType: error.runtimeType.toString(),
        message: error.toString(),
        metadata: metadata,
        reason: reason,
        stackTrace: stackTrace.toString(),
      ),
    );
  }

  Future<void> _capturePendingNativeCrashReport() async {
    final nativeReport = await AttriaxPlatform.instance
        .consumePendingCrashReport();
    if (nativeReport == null) {
      return;
    }

    await _storePendingCrashReport(
      attriaxBuildTrackCrashRequest(
        appToken: config.appToken,
        clientOccurredAt: nativeReport.occurredAt,
        context: _contextManager.requiredSnapshot,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _requireDeviceIdSource(),
        source: nativeReport.source,
        isFatal: nativeReport.isFatal,
        exceptionType: nativeReport.exceptionType,
        message: nativeReport.message,
        metadata: nativeReport.metadata,
        reason: nativeReport.reason,
        stackTrace: nativeReport.stackTrace,
      ),
    );
  }

  Future<void> _replayPendingCrashReport() async {
    final payload = await _readPendingCrashReport();
    if (payload == null) {
      return;
    }

    await _requestManager.enqueue(
      AttriaxTrackCrashRequest(payload),
      onSuccess: (_) {
        unawaited(_preferencesStore.writePendingCrashReportPayload(null));
      },
    );
  }

  Future<void> _storePendingCrashReport(AttriaxTrackCrashRequest request) {
    return _preferencesStore.writePendingCrashReportPayload(
      jsonEncode(request.payload.toJson()),
    );
  }

  Future<AttriaxCrashReportPayload?> _readPendingCrashReport() async {
    final raw = await _preferencesStore.readPendingCrashReportPayload();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        await _preferencesStore.writePendingCrashReportPayload(null);
        return null;
      }

      return AttriaxCrashReportPayload.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value as Object?)),
      );
    } catch (_) {
      await _preferencesStore.writePendingCrashReportPayload(null);
      return null;
    }
  }
}
