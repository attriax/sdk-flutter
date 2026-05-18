import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attriax_api_models.dart';
import 'attriax_api_base_url.dart';
import 'attriax_app_open_manager.dart';
import 'attriax_context_collector.dart';
import 'attriax_context_manager.dart';
import 'attriax_deep_link_manager.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_event_hub.dart';
import 'attriax_generated_transport.dart';
import 'attriax_logger.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_preferences_store.dart';
import 'attriax_request_manager.dart';
import 'attriax_referrer_manager.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_session_manager.dart';
import 'attriax_skan_manager.dart';
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
         onPersistenceDegraded: ({required operation, required error}) {
           logger.warning(
             'Attriax persistent storage is unavailable after $operation. The SDK will continue in memory-only mode for this process.',
             error: error,
           );
         },
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
      preferencesStore: _preferencesStore,
      currentSessionIdProvider: () => _sessionManager.currentSession?.id,
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
    _referrerManager = AttriaxReferrerManager(
      preferencesStore: _preferencesStore,
      appOpenMonitor: _appOpenManager,
      deepLinkManager: _deepLinkManager,
      currentSessionIdProvider: () => _sessionManager.currentSession?.id,
    );
    _skanManager = AttriaxSkanManager(
      config: config,
      preferencesStore: _preferencesStore,
      platform: contextCollector.platformInstance,
      platformType: contextCollector.currentPlatformType,
      clock: _clock,
      logger: _logger,
      usdRevenueConverter: _convertSkanRevenueToUsdMicros,
    );
    _trackingManager = AttriaxTrackingManager(
      config: config,
      logger: _logger,
      clock: _clock,
      contextManager: _contextManager,
      settingsState: _settingsState,
      requestManager: _requestManager,
      sessionManager: _sessionManager,
      skanManager: _skanManager,
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
  late final AttriaxReferrerManager _referrerManager;
  late final AttriaxTrackingManager _trackingManager;
  late final AttriaxSessionManager _sessionManager;
  late final AttriaxSkanManager _skanManager;

  AttriaxSynchronizer? _synchronizer;
  AttriaxGeneratedTransport? _transport;

  bool _initialized = false;
  late final AttriaxRuntimeSettingsState _settingsState =
      AttriaxRuntimeSettingsState(
        preferencesStore: _preferencesStore,
        logger: _logger,
      );
  Future<void>? _initializationFuture;
  AttriaxNormalizedApiBaseUrl? _normalizedApiBaseUrl;
  Future<void>? _appOpenSchedulingFuture;
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
  AttriaxRawDeepLinkEvent? get rawInitialDeepLink =>
      _deepLinkManager.rawInitialDeepLink;
  AttriaxSkanState? get skanState => _skanManager.state;
  AttriaxDeepLinkEvent? get initialDeepLink => _deepLinkManager.initialDeepLink;
  bool get isInitialDeepLinkResolved =>
      _deepLinkManager.isInitialDeepLinkResolved;
  AttriaxDeepLinkEvent? get latestDeepLink => _deepLinkManager.latestDeepLink;
  AttriaxSynchronizationState get synchronizationState =>
      _synchronizer?.synchronizationState ??
      AttriaxSynchronizationState.initializing;

  bool get _shouldWarnOnLocalhostApiBaseUrl => !kDebugMode;

  AttriaxNormalizedApiBaseUrl get _apiBaseUrlConfig {
    final cached = _normalizedApiBaseUrl;
    if (cached != null) {
      return cached;
    }

    final shouldWarnOnLocalhost = _shouldWarnOnLocalhostApiBaseUrl;
    final normalized = normalizeAttriaxApiBaseUrl(
      config.apiBaseUrl,
      warnOnLocalhost: shouldWarnOnLocalhost,
      onWarning: shouldWarnOnLocalhost ? _logger.warning : null,
    );
    _normalizedApiBaseUrl = normalized;
    return normalized;
  }

  bool get _sessionTrackingEnabled => config.sessionTrackingEnabled;

  // ---------- streams (delegated to hub) ------------------------------------ //

  Stream<AttriaxRawDeepLinkEvent> get rawDeepLinks =>
      _deepLinkManager.rawStream;
  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinkManager.stream;
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _eventHub.synchronizationStates;

  // ---------- init ---------------------------------------------------------- //

  Future<void> init({bool? enabled, bool? eventsEnabled}) {
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
    );
    _initializationFuture = initialization;

    return initialization.whenComplete(() {
      if (identical(_initializationFuture, initialization)) {
        _initializationFuture = null;
      }
    });
  }

  Future<void> reset() async {
    _logger.warning(
      'Resetting Attriax SDK state. Call init() again before reusing this instance.',
    );

    _restoreCrashHandlers();
    await _contextManager.setAutomaticCrashReportingEnabled(enabled: false);
    _requestManager.synchronizer = null;
    _sessionManager.dispose();
    await _referrerManager.dispose();
    await _deepLinkManager.stop();
    await _synchronizer?.reset(
      error: StateError(
        'Attriax SDK state was reset before queued work completed.',
      ),
    );
    await _appOpenManager.reset();
    await _preferencesStore.clearAll();

    _eventHub.reset();
    _contextManager.reset();
    await _sessionManager.reset();
    await _referrerManager.reset();
    await _skanManager.reset();

    _settingsState.restore(enabled: true, eventsEnabled: true);
    _appOpenSchedulingFuture = null;
    _initializationFuture = null;
    _initialized = false;
  }

  Future<void> _runInit({bool? enabled, bool? eventsEnabled}) async {
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

    await _contextManager.init();
    await _skanManager.init(isFirstLaunch: _contextManager.isFirstLaunch);
    final sessionRestore = await _sessionManager.init(
      enabled: _sessionTrackingEnabled,
    );
    await _referrerManager.init(enabled: isEnabled);

    _transport ??= AttriaxGeneratedTransport(
      apiBaseUrl: _apiBaseUrlConfig.apiBaseUrl,
      requestTimeout: config.requestTimeout,
      httpClient: _client,
    );

    _synchronizer ??= AttriaxSynchronizer(
      transport: _transport!,
      connectivity: _connectivity,
      appOpenMonitor: _appOpenManager,
      preferencesStore: _preferencesStore,
      maxQueueSize: config.maxQueueSize,
      eventFlushInterval: config.eventFlushInterval,
      logger: _logger,
    );
    final synchronizer = _synchronizer!;
    _requestManager.synchronizer = synchronizer;
    synchronizer.onStateChanged = _eventHub.emitSynchronizationState;

    _initialized = true;
    await _contextManager.setAutomaticCrashReportingEnabled(
      enabled: isEnabled && config.automaticCrashReportingEnabled,
    );

    if (!isEnabled) {
      _deepLinkManager.completeInitialLinkIfAbsent();
      _synchronizer!.setState(AttriaxSynchronizationState.disabled);
      _logger.warning('Attriax SDK initialized in disabled mode.');
      return;
    }

    unawaited(_scheduleAppOpenIfNeeded());

    _sessionManager.seedRecoveredSessionEnd(sessionRestore?.replacedSession);
    if (config.automaticCrashReportingEnabled) {
      _installCrashHandlers();
      await _capturePendingNativeCrashReport();
      await _replayPendingCrashReport();
    }

    _synchronizer!.startConnectivitySubscription(
      onRestored: _synchronizer!.scheduleFlush,
    );
    await _deepLinkManager.start();

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

  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    _assertInitialized();
    return _skanManager.updateConversionValue(
      fineValue: fineValue,
      coarseValue: coarseValue,
      lockWindow: lockWindow,
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

  Future<void> registerFirebaseMessagingToken({
    required String? token,
    Map<String, Object?>? metadata,
  }) async {
    await _registerUninstallToken(
      provider: 'fcm',
      token: token,
      metadata: metadata,
    );
  }

  Future<void> registerApplePushToken({
    required String? token,
    Map<String, Object?>? metadata,
  }) async {
    await _registerUninstallToken(
      provider: 'apns',
      token: token,
      metadata: metadata,
    );
  }

  Future<void> _registerUninstallToken({
    required String provider,
    required String? token,
    Map<String, Object?>? metadata,
  }) async {
    _assertInitialized();

    final normalizedToken = _trimOrNull(token);

    final currentDeviceId = deviceId;
    if (currentDeviceId == null) {
      throw StateError('Attriax SDK did not restore a device id.');
    }

    final request = attriaxBuildRegisterUninstallTokenRequest(
      appToken: config.appToken,
      deviceId: currentDeviceId,
      deviceIdSource: _contextManager.requireDeviceIdSource(),
      platform: _contextManager.requiredSnapshot.platform,
      provider: provider,
      token: normalizedToken,
      metadata: metadata,
    );

    await _transport!.registerUninstallToken(request);
  }

  Future<AttriaxDeepLinkEvent?> recordDeepLink({
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

  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() =>
      _deepLinkManager.waitForInitialDeepLink();

  Future<AttriaxDeepLinkEvent> waitForDeepLinkResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) => _deepLinkManager.waitResolution(rawEvent);

  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) => _contextManager.requestTrackingAuthorization(timeout: timeout);

  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus() =>
      _contextManager.getTrackingAuthorizationStatus();

  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    timeout: timeout,
    safe: safe,
    reader: _referrerManager.waitForOriginalInstallReferrer,
  );

  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    timeout: timeout,
    safe: safe,
    reader: _referrerManager.waitForReinstallReferrer,
  );

  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    timeout: timeout,
    safe: safe,
    reader: _referrerManager.waitForSessionReferrer,
  );

  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    timeout: timeout,
    safe: safe,
    reader: _referrerManager.waitForLatestDeepLinkReferrer,
  );

  // ---------- enable / disable ---------------------------------------------- //

  void setEnabled({required bool enabled}) => _settingsState.setEnabled(
    enabled: enabled,
    initialized: _initialized,
    applyState: ({required bool enabled}) => _applyEnabledState(enabled),
    onPreparingToEnable: enabled ? _prepareReferrerWaitersForReenable : null,
  );

  void setEventsEnabled({required bool enabled}) =>
      _settingsState.setEventsEnabled(enabled: enabled);

  // ---------- app open ------------------------------------------------------ //

  // ---------- dispose ------------------------------------------------------- //

  Future<void> dispose() async {
    _logger.verbose('Disposing Attriax SDK runtime.');
    _restoreCrashHandlers();
    await _contextManager.setAutomaticCrashReportingEnabled(enabled: false);
    _requestManager.synchronizer = null;
    _sessionManager.dispose();
    await _referrerManager.dispose();
    await _deepLinkManager.stop();
    await _synchronizer?.dispose();
    await _appOpenManager.dispose();
    await _eventHub.dispose();
    await _skanManager.reset();
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
    if (config.trackingAuthorizationStatusTimeout.isNegative) {
      throw ArgumentError(
        'Attriax trackingAuthorizationStatusTimeout must not be negative.',
      );
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
      _referrerManager.handleDisabled();
      _restoreCrashHandlers();
      await _contextManager.setAutomaticCrashReportingEnabled(enabled: false);
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
      await _contextManager.setAutomaticCrashReportingEnabled(
        enabled: config.automaticCrashReportingEnabled,
      );
      if (config.automaticCrashReportingEnabled) {
        _installCrashHandlers();
        await _capturePendingNativeCrashReport();
        await _replayPendingCrashReport();
      }
      _synchronizer!.startConnectivitySubscription(
        onRestored: _synchronizer!.scheduleFlush,
      );
      await _prepareReferrersForEnabledState();
      unawaited(_scheduleAppOpenIfNeeded());
      await _deepLinkManager.start();
      _sessionManager.activate();
      _synchronizer!.scheduleFlush();
    }
  }

  Future<void> _prepareReferrersForEnabledState() async {
    await _referrerManager.prepareForEnabledState();
  }

  void _prepareReferrerWaitersForReenable() {
    _referrerManager.prepareForReenable();
  }

  Future<void> _scheduleAppOpenIfNeeded() {
    if (!_initialized ||
        !isEnabled ||
        _synchronizer == null ||
        _appOpenManager.didSchedule) {
      return Future<void>.value();
    }

    final inFlight = _appOpenSchedulingFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final scheduling = _scheduleAppOpen();
    _appOpenSchedulingFuture = scheduling;
    return scheduling.whenComplete(() {
      if (identical(_appOpenSchedulingFuture, scheduling)) {
        _appOpenSchedulingFuture = null;
      }
    });
  }

  Future<void> _scheduleAppOpen() async {
    final originSessionId = _sessionManager.currentSession?.id;
    await _appOpenManager.schedule(
      onCompleted: (result) async {
        await _skanManager.applyAppOpenResult(result);
        await _deepLinkManager.handleDeferredAppOpen(
          result,
          originSessionId: originSessionId,
        );
      },
    );
  }

  Future<int?> _convertSkanRevenueToUsdMicros({
    required int amountMicros,
    required String currency,
    required DateTime clientOccurredAt,
  }) async {
    final transport = _transport;
    if (transport == null) {
      return null;
    }

    final result = await transport.convertRevenueToUsd(<String, Object?>{
      'appToken': config.appToken,
      'currency': currency,
      'amountMicros': amountMicros.toString(),
      'clientOccurredAt': clientOccurredAt.toUtc().toIso8601String(),
    });

    return int.tryParse(result.amountUsdMicros);
  }

  Future<T?> _readReferrer<T>({
    required Future<T?> Function() reader,
    required bool safe,
    Duration? timeout,
  }) async {
    if (!_initialized || !isEnabled) {
      return null;
    }

    try {
      final future = reader();
      if (timeout == null) {
        return await future;
      }

      return await future.timeout(timeout);
    } catch (_) {
      if (safe) {
        return null;
      }

      rethrow;
    }
  }

  void _installCrashHandlers() {
    if (!config.automaticCrashReportingEnabled) {
      return;
    }

    if (_installedFlutterErrorHandler == null) {
      _previousFlutterErrorHandler = FlutterError.onError;
      _installedFlutterErrorHandler = (details) {
        _previousFlutterErrorHandler?.call(details);
        final metadata = <String, Object?>{
          if (details.library != null) 'library': details.library,
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

  Future<void> _storePendingCrashReport(AttriaxTrackCrashRequest request) =>
      _preferencesStore.writePendingCrashReportPayload(
        jsonEncode(request.payload.toJson()),
      );

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
