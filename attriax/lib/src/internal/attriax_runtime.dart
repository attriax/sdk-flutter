import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../attriax_consent.dart';
import '../attriax_notification_event.dart';
import 'attriax_api_models.dart';
import 'attriax_api_base_url.dart';
import 'attriax_app_open_launcher.dart';
import 'attriax_app_open_manager.dart';
import 'attriax_consent_manager.dart';
import 'attriax_context_collector.dart';
import 'attriax_context_manager.dart';
import 'attriax_crash_reporting_manager.dart';
import 'attriax_deep_link_manager.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_direct_api_client.dart';
import 'attriax_event_hub.dart';
import 'attriax_generated_transport.dart';
import 'attriax_ios_app_open_enrichment_manager.dart';
import 'attriax_logger.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_preferences_store.dart';
import 'attriax_queue.dart';
import 'attriax_request_manager.dart';
import 'attriax_referrer_manager.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_runtime_settings_store.dart';
import 'attriax_runtime_config_validator.dart';
import 'attriax_runtime_config_manager.dart';
import 'attriax_sdk_runtime_config.dart';
import 'attriax_session_manager.dart';
import 'attriax_skan_manager.dart';
import 'attriax_synchronizer.dart';
import 'attriax_tracking_manager.dart';
import 'attriax_uninstall_token_registrar.dart';
import 'consent/attriax_consent_queue_policy.dart';

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
       _requestManager = AttriaxRequestManager(),
       _platform = contextCollector.platformInstance,
       _platformType = contextCollector.currentPlatformType {
    _platformInstallReferrerManager = contextCollector
        .buildRuntimePlatformInstallReferrerManager(
          preferencesStore: _preferencesStore,
          logger: _logger,
        );
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
      trackingDecision: () => _sessionTrackingDecision,
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
      directSend: (request) => _ensureTransport().send(request),
      trackingDecision: () =>
          _trackingDecisionFor(AttriaxTrackingSignal.deepLink),
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
      platformInstallReferrerManager: _platformInstallReferrerManager,
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
      consentState: _consentManager,
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
  final AttriaxPlatform _platform;
  final AttriaxPlatformType _platformType;
  late final AttriaxIosAppOpenEnrichmentManager _iosAppOpenEnrichmentManager =
      AttriaxIosAppOpenEnrichmentManager(
        platform: _platform,
        platformType: _platformType,
      );
  late final AttriaxPlatformInstallReferrerManager
  _platformInstallReferrerManager;
  late final AttriaxContextManager _contextManager;
  late final AttriaxConsentManager _consentManager = AttriaxConsentManager(
    config: config,
    clock: _clock,
    contextManager: _contextManager,
    preferencesStore: _preferencesStore,
    logger: _logger,
  )..onStateChanged = _handleConsentStateChanged;
  late final AttriaxUninstallTokenRegistrar _uninstallTokenRegistrar =
      AttriaxUninstallTokenRegistrar(
        config: config,
        contextManager: _contextManager,
        requestManager: _requestManager,
        consent: _consentManager,
        logger: _logger,
      );
  late final AttriaxDeepLinkManager _deepLinkManager;
  late final AttriaxAppOpenManager _appOpenManager;
  late final AttriaxReferrerManager _referrerManager;
  late final AttriaxTrackingManager _trackingManager;
  late final AttriaxSessionManager _sessionManager;
  late final AttriaxSkanManager _skanManager;
  late final AttriaxCrashReportingManager _crashReportingManager =
      AttriaxCrashReportingManager(
        config: config,
        clock: _clock,
        platform: _platform,
        contextManager: _contextManager,
        trackingManager: _trackingManager,
        requestManager: _requestManager,
        preferencesStore: _preferencesStore,
        isRuntimeActive: () => _initialized && isEnabled,
        analyticsTrackingDecision: () => _analyticsTrackingDecision,
      );
  late final AttriaxAppOpenLauncher _appOpenLauncher = AttriaxAppOpenLauncher(
    didSchedule: () => _appOpenManager.didSchedule,
    allowsAttributionTracking: () => _allowsAttributionTracking,
    currentSessionId: () => _sessionManager.currentSession?.id,
    ensureRuntimeConfigLoaded: _ensureSdkRuntimeConfigLoaded,
    buildDeviceMetadataOverrides: ({required allowsAttributionTracking}) =>
        _iosAppOpenEnrichmentManager.buildDeviceMetadataOverridesForAppOpen(
          allowsAttributionTracking: allowsAttributionTracking,
        ),
    installReferrerOverrideForAppOpen:
        ({
          required clipboardAttributionEnabled,
          required allowsAttributionTracking,
        }) => _iosAppOpenEnrichmentManager.installReferrerOverrideForAppOpen(
          clipboardAttributionEnabled: clipboardAttributionEnabled,
          allowsAttributionTracking: allowsAttributionTracking,
        ),
    scheduleAppOpen:
        ({
          String? installReferrerOverride,
          Map<String, Object?> deviceMetadataOverrides =
              const <String, Object?>{},
          Future<void> Function(AttriaxAppOpenResult? result)? onCompleted,
        }) => _appOpenManager.schedule(
          installReferrerOverride: installReferrerOverride,
          deviceMetadataOverrides: deviceMetadataOverrides,
          onCompleted: onCompleted,
        ),
    onCompleted: _handleScheduledAppOpen,
  );
  late final AttriaxRuntimeConfigManager _runtimeConfigManager =
      AttriaxRuntimeConfigManager(
        config: config,
        contextSnapshot: () => _contextManager.snapshot,
        fetchRuntimeConfig: (payload) =>
            _ensureTransport().fetchSdkRuntimeConfig(payload),
        logger: _logger,
        onLoaded: _handleSdkRuntimeConfigLoaded,
      );
  late final AttriaxConsentQueuePolicy _consentQueuePolicy =
      AttriaxConsentQueuePolicy(
        isWaitingForGdprConsent: () => _isWaitingForGdprConsent,
        anonymousTrackingEnabled: () =>
            _consentManager.anonymousTrackingEnabled,
        allowsAttributionTracking: () => _allowsAttributionTracking,
        trackingDecisionFor: _trackingDecisionFor,
      );
  late final AttriaxDirectApiClient _directApiClient = AttriaxDirectApiClient(
    config: config,
    clock: _clock,
    deviceId: () => deviceId,
    transport: _ensureTransport,
  );
  AttriaxSynchronizer? _synchronizer;
  AttriaxGeneratedTransport? _transport;

  bool _initialized = false;
  late final AttriaxRuntimeSettingsStore _runtimeSettingsStore =
      AttriaxPreferencesRuntimeSettingsStore(
        preferencesStore: _preferencesStore,
      );
  late final AttriaxRuntimeSettingsState _settingsState =
      AttriaxRuntimeSettingsState(
        settingsStore: _runtimeSettingsStore,
        logger: _logger,
      );
  Future<void>? _initializationFuture;
  AttriaxNormalizedApiBaseUrl? _normalizedApiBaseUrl;

  // ---------- getters ------------------------------------------------------- //

  bool get isInitialized => _initialized;
  bool get isEnabled => _settingsState.isEnabled;
  bool get areEventsEnabled => _settingsState.areEventsEnabled;
  bool get anonymousTrackingEnabled => _consentManager.anonymousTrackingEnabled;
  bool get isFirstLaunch => _contextManager.isFirstLaunch;
  String? get deviceId => _contextManager.deviceId;
  AttriaxGdprConsentState get gdprConsentState =>
      _consentManager.gdprConsentState;
  AttriaxGdprConsentValues? get gdprConsentValues =>
      _consentManager.gdprConsentValues;
  bool get isWaitingForGdprConsent => _consentManager.isWaitingForGdprConsent;
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

  bool get _canCaptureAttribution =>
      _trackingDecisionFor(AttriaxTrackingSignal.attribution).capture;

  bool get _canCaptureAnalytics =>
      _trackingDecisionFor(AttriaxTrackingSignal.analytics).capture;

  bool get _canCaptureAdEvents =>
      _trackingDecisionFor(AttriaxTrackingSignal.adEvents).capture;

  bool get _canCaptureUninstallTracking =>
      _trackingDecisionFor(AttriaxTrackingSignal.uninstallTracking).capture;

  bool get _shouldDeferNetworkDispatch =>
      _consentManager.shouldDeferNetworkDispatch;

  bool get _shouldMaterializeIdentifiedContext =>
      !config.gdprEnabled ||
      _consentManager.gdprConsentState == AttriaxGdprConsentState.notRequired ||
      (_consentManager.gdprConsentState == AttriaxGdprConsentState.granted &&
          (_allowsAnalyticsTracking ||
              _allowsAdEventsTracking ||
              _allowsAttributionTracking));

  bool get _allowsAttributionTracking =>
      _consentManager.allowsAttributionTracking;

  bool get _allowsAnalyticsTracking => _consentManager.allowsAnalyticsTracking;

  bool get _allowsAdEventsTracking => _consentManager.allowsAdEventsTracking;

  bool get _isWaitingForGdprConsent => _consentManager.isWaitingForGdprConsent;

  AttriaxTrackingDecision get _analyticsTrackingDecision =>
      _trackingDecisionFor(AttriaxTrackingSignal.analytics);

  AttriaxTrackingDecision get _sessionTrackingDecision =>
      _trackingDecisionFor(AttriaxTrackingSignal.session);

  AttriaxTrackingDecision _trackingDecisionFor(AttriaxTrackingSignal signal) =>
      _consentManager.trackingDecisionFor(signal);

  bool get _shouldActivateSessionTracking =>
      _sessionTrackingEnabled && (_canCaptureAnalytics || _canCaptureAdEvents);

  bool get _shouldInstallCrashHandlers =>
      config.automaticCrashReportingEnabled && _canCaptureAnalytics;

  bool get _shouldTrackAnything =>
      _canCaptureAttribution ||
      _canCaptureAnalytics ||
      _canCaptureAdEvents ||
      _canCaptureUninstallTracking;

  bool get _canRunActiveSynchronizationFlow =>
      _initialized && _synchronizer != null;

  // ---------- streams (delegated to hub) ------------------------------------ //

  Stream<AttriaxRawDeepLinkEvent> get rawDeepLinks =>
      _deepLinkManager.rawStream;
  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinkManager.stream;
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _eventHub.synchronizationStates;

  // ---------- init ---------------------------------------------------------- //

  Future<void> init() {
    if (_initialized) {
      return Future<void>.value();
    }

    final inFlight = _initializationFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final initialization = _runInit();
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

    await _crashReportingManager.deactivate();
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
    _consentManager.clearMemory();
    await _sessionManager.reset();
    await _referrerManager.reset();
    await _skanManager.reset();
    _iosAppOpenEnrichmentManager.reset();

    _settingsState.restore(enabled: true, eventsEnabled: true);
    _appOpenLauncher.reset();
    _runtimeConfigManager.reset();
    _initializationFuture = null;
    _initialized = false;
  }

  Future<void> requestGdprDataErasure() async {
    _assertInitialized();

    final deviceId = _trimOrNull(_contextManager.deviceId);
    if (deviceId == null) {
      throw StateError(
        'Attriax SDK device identity is unavailable. Call init() first.',
      );
    }

    await _ensureTransport().eraseGdprData(
      projectToken: config.projectToken,
      deviceId: deviceId,
    );

    await reset();
  }

  Future<void> _runInit() async {
    _logger.verbose('Initializing Attriax SDK.');
    _validateConfig();

    _synchronizer = await _bootstrapRuntime();

    _initialized = true;
    await _applyRuntimeState(enabled: isEnabled);
    if (!isEnabled) {
      _logger.warning('Attriax SDK initialized in disabled mode.');
      return;
    }

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

  Future<void> recordNotification({
    required AttriaxNotificationEventType type,
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    AttriaxNotificationEventSource? source,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) async {
    _assertInitialized();
    await _trackingManager.recordNotification(
      type: type,
      notificationId: notificationId,
      linkId: linkId,
      campaignId: campaignId,
      title: title,
      source: source,
      metadata: metadata,
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

  Future<bool> needsGdprConsent({bool localOnly = false}) {
    _consentManager.bindTransport(_ensureTransport());
    return _consentManager.needsConsent(
      projectToken: config.projectToken,
      localOnly: localOnly,
    );
  }

  void setGdprConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) {
    _consentManager
      ..bindTransport(_ensureTransport())
      ..setConsent(
        projectToken: config.projectToken,
        analytics: analytics,
        attribution: attribution,
        adEvents: adEvents,
      );
  }

  void setGdprConsentNotRequired() {
    _consentManager
      ..bindTransport(_ensureTransport())
      ..setNotRequired(projectToken: config.projectToken);
  }

  void resetGdprConsent() {
    _consentManager
      ..bindTransport(_ensureTransport())
      ..reset(projectToken: config.projectToken);
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
    return _directApiClient.createDynamicLink(
      name: name,
      destinationUrl: destinationUrl,
      group: group,
      prefix: prefix,
      socialPreview: socialPreview,
      utms: utms,
      redirects: redirects,
      data: data,
    );
  }

  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    required String receipt,
    bool test = false,
    String? provider,
    String? environment,
    String? productId,
    String? transactionId,
  }) async {
    _assertInitialized();
    return _directApiClient.validateReceipt(
      receipt: receipt,
      provider: provider,
      environment: environment,
      productId: productId,
      transactionId: transactionId,
      test: test,
    );
  }

  Future<void> registerFirebaseMessagingToken({
    required String? token,
    Map<String, Object?>? metadata,
  }) async {
    _assertInitialized();
    await _uninstallTokenRegistrar.register(
      provider: 'fcm',
      token: token,
      metadata: metadata,
    );
  }

  Future<void> registerApplePushToken({
    required String? token,
    Map<String, Object?>? metadata,
  }) async {
    _assertInitialized();
    await _uninstallTokenRegistrar.register(
      provider: 'apns',
      token: token,
      metadata: metadata,
    );
  }

  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    _assertInitialized();
    if (!isEnabled) {
      _logger.verbose('Ignoring recordDeepLink because SDK is disabled.');
      return null;
    }

    if (_shouldActivateSessionTracking) {
      await _sessionManager.prepareTrackedSessionAt(_clock.now());
    }

    return _deepLinkManager.recordManualConversion(
      uri: uri,
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

  Future<String?> getRawInstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    timeout: timeout,
    safe: safe,
    reader: _referrerManager.waitForRawInstallReferrer,
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
    applyState: _applyRuntimeState,
    onPreparingToEnable: enabled ? _referrerManager.prepareForReenable : null,
  );

  void setEventsEnabled({required bool enabled}) =>
      _settingsState.setEventsEnabled(enabled: enabled);

  void setAnonymousTrackingEnabled({required bool enabled}) =>
      _consentManager.setAnonymousTrackingEnabled(enabled: enabled);

  // ---------- app open ------------------------------------------------------ //

  // ---------- dispose ------------------------------------------------------- //

  Future<void> dispose() async {
    _logger.verbose('Disposing Attriax SDK runtime.');
    await _crashReportingManager.deactivate();
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
    validateAttriaxRuntimeConfig(
      config: config,
      normalizeApiBaseUrl: () => _apiBaseUrlConfig,
    );
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

  Future<AttriaxSynchronizer> _bootstrapRuntime() async {
    final transport = _ensureTransport();
    _consentManager.bindTransport(transport);
    await _consentManager.init();
    await _syncRuntimePersistenceMode();

    final storedRuntimePreferences = await _runtimeSettingsStore.restore(
      enabledOverride: _settingsState.requestedEnabledOverride,
      eventsEnabledOverride: _settingsState.requestedEventsEnabledOverride,
    );
    _settingsState.restore(
      enabled: storedRuntimePreferences.isEnabled,
      eventsEnabled: storedRuntimePreferences.areEventsEnabled,
    );

    await _contextManager.init(
      allowDeviceIdentity: _shouldMaterializeIdentifiedContext,
    );
    await _skanManager.init(isFirstLaunch: _contextManager.isFirstLaunch);
    final sessionRestore = await _sessionManager.init(
      enabled: _sessionTrackingEnabled,
    );
    await _referrerManager.init(enabled: storedRuntimePreferences.isEnabled);

    final synchronizer =
        _synchronizer ??
        AttriaxSynchronizer(
          transport: transport,
          connectivity: _connectivity,
          preferencesStore: _preferencesStore,
          maxQueueSize: config.maxQueueSize,
          eventFlushInterval: config.eventFlushInterval,
          logger: _logger,
          buildSessionKeepAliveBatchRequest: _buildSessionKeepAliveBatchRequest,
          onSessionKeepAliveDelivered: _handleSessionKeepAliveDelivered,
        );
    _requestManager.synchronizer = synchronizer;
    synchronizer.onStateChanged = _eventHub.emitSynchronizationState;

    if (_shouldActivateSessionTracking) {
      _sessionManager.seedRecoveredSessionEnd(sessionRestore?.replacedSession);
    }

    return synchronizer;
  }

  Future<void> _applyRuntimeState({required bool enabled}) async {
    if (!enabled) {
      await _applyDisabledRuntimeState();
      return;
    }

    _primeSdkRuntimeConfigForLaunch();

    if (_shouldDeferNetworkDispatch) {
      await _applyDeferredRuntimeState();
      return;
    }

    if (!_shouldTrackAnything) {
      await _applyNoTrackingRuntimeState();
      return;
    }

    await _applyActiveRuntimeState();
  }

  Future<void> _applyDisabledRuntimeState() async {
    _referrerManager.handleDisabled();
    await _crashReportingManager.deactivate();
    _sessionManager.deactivate();
    _synchronizer?.deactivate();
    _synchronizer?.setState(AttriaxSynchronizationState.disabled);
    _logger.warning('Attriax SDK disabled.');
    await _deepLinkManager.stop();
    await _synchronizer?.stopConnectivitySubscription();
  }

  Future<void> _applyDeferredRuntimeState() async {
    _referrerManager.handleDisabled();
    await _crashReportingManager.activate(
      installHandlers: _shouldInstallCrashHandlers,
    );
    if (_shouldActivateSessionTracking) {
      _sessionManager.activate();
    } else {
      _sessionManager.deactivate();
    }
    _synchronizer?.deactivate();
    _synchronizer?.setState(AttriaxSynchronizationState.deferred);
    _logger.warning(
      'Attriax SDK is capturing locally and waiting for GDPR consent before sending network requests.',
    );
    await _deepLinkManager.start();
    await _synchronizer?.stopConnectivitySubscription();
  }

  Future<void> _applyNoTrackingRuntimeState() async {
    await _crashReportingManager.deactivate();
    _sessionManager.deactivate();
    _synchronizer?.deactivate();
    _synchronizer?.setState(AttriaxSynchronizationState.disabled);
    _logger.warning(
      'Attriax SDK initialized without any GDPR tracking categories enabled.',
    );
    await _deepLinkManager.stop();
    await _synchronizer?.stopConnectivitySubscription();
  }

  Future<void> _applyActiveRuntimeState() async {
    _synchronizer?.activate();
    _synchronizer?.setState(AttriaxSynchronizationState.synchronizing);
    _logger.verbose('Attriax SDK enabled.');

    if (!_canRunActiveSynchronizationFlow) {
      return;
    }

    await _crashReportingManager.activate(
      installHandlers: _shouldInstallCrashHandlers,
    );
    _startConnectivitySubscription();
    await _deepLinkManager.start();
    if (_allowsAttributionTracking) {
      await _referrerManager.prepareForEnabledState();
      unawaited(_scheduleAppOpenIfNeeded());
    } else {
      await _referrerManager.prepareForDeniedAttributionState();
    }
    if (_shouldActivateSessionTracking) {
      _sessionManager.activate();
    } else {
      _sessionManager.deactivate();
    }
    unawaited(
      _consentManager.flushPendingSync(projectToken: config.projectToken),
    );
    _synchronizer?.scheduleFlush();
  }

  void _startConnectivitySubscription() {
    final synchronizer = _synchronizer;
    if (synchronizer == null) {
      return;
    }

    synchronizer.startConnectivitySubscription(
      onRestored: synchronizer.scheduleFlush,
    );
  }

  AttriaxTrackSessionRequest? _buildSessionKeepAliveBatchRequest(
    List<AttriaxQueuedRequest> requests,
  ) {
    final currentSession = _sessionManager.currentSession;
    if (currentSession == null || _sessionManager.isInBackground) {
      return null;
    }

    final includesCurrentSessionEvent = requests.any((queuedRequest) {
      final request = queuedRequest.request;
      return request is AttriaxTrackEventRequest &&
          request.payload.sessionId == currentSession.id;
    });
    if (!includesCurrentSessionEvent) {
      return null;
    }

    return _sessionManager.buildHeartbeatKeepAliveRequest(
      session: currentSession,
      occurredAt: _clock.now(),
    );
  }

  Future<void> _handleSessionKeepAliveDelivered(
    String sessionId,
    DateTime occurredAt,
  ) => _sessionManager.handleSuccessfulForegroundFlush(sessionId, occurredAt);

  AttriaxGeneratedTransport _ensureTransport() {
    final existing = _transport;
    if (existing != null) {
      return existing;
    }

    final created = AttriaxGeneratedTransport(
      apiBaseUrl: _apiBaseUrlConfig.apiBaseUrl,
      requestTimeout: config.requestTimeout,
      httpClient: _client,
    );
    _transport = created;
    return created;
  }

  Future<void> _consentReconciliation = Future<void>.value();

  void _handleConsentStateChanged() {
    if (!_initialized || !isEnabled) {
      return;
    }

    // Serialize reconciliations so two rapid consent changes cannot interleave
    // their queue identify/anonymize/drop passes against a half-rewritten queue.
    _consentReconciliation = _consentReconciliation
        .then((_) => _applyConsentStateChange())
        .catchError((Object error, StackTrace stackTrace) {
          _logger.warning(
            'Failed to reconcile runtime state after a GDPR consent change.',
            error: error,
            stackTrace: stackTrace,
          );
        });
  }

  Future<void> _applyConsentStateChange() async {
    await _syncRuntimePersistenceMode();
    await _ensureIdentifiedContextForCurrentConsent();

    final synchronizer = _synchronizer;
    if (config.gdprEnabled &&
        !_consentManager.isWaitingForGdprConsent &&
        synchronizer != null) {
      final deviceId = _contextManager.deviceId;
      if (deviceId != null) {
        final deviceIdSource = _requireDeviceIdSource();
        final identifiedCount = await synchronizer.rewriteQueuedRequestsWhere(
          (queuedRequest) =>
              _consentQueuePolicy.shouldIdentifyQueuedRequestForResolvedConsent(
                queuedRequest.request,
              )
              ? attriaxIdentifyRequestForConsentNotRequired(
                  queuedRequest.request,
                  deviceId: deviceId,
                  deviceIdSource: deviceIdSource,
                )
              : null,
        );
        if (identifiedCount > 0) {
          _logger.verbose(
            'Attached device identity to $identifiedCount queued request(s) after GDPR resolved to identified tracking.',
          );
        }
      }

      final rewrittenCount = await synchronizer.rewriteQueuedRequestsWhere(
        (queuedRequest) =>
            _consentQueuePolicy.shouldAnonymizeQueuedRequest(
              queuedRequest.request,
            )
            ? attriaxAnonymizeRequestForConsent(queuedRequest.request)
            : null,
      );
      if (rewrittenCount > 0) {
        _logger.verbose(
          'Anonymized $rewrittenCount queued request(s) after GDPR consent denied one or more categories.',
        );
      }

      final droppedCount = await synchronizer.discardQueuedRequestsWhere(
        (queuedRequest) => !_consentQueuePolicy
            .isRequestAllowedByResolvedConsent(queuedRequest.request),
        reason: 'gdpr_consent_denied',
      );
      if (droppedCount > 0) {
        _logger.warning(
          'Dropped $droppedCount queued request(s) after GDPR consent denied one or more categories.',
        );
      }
    }

    if (!_shouldDeferNetworkDispatch) {
      unawaited(
        _consentManager.flushPendingSync(projectToken: config.projectToken),
      );
    }

    await _applyRuntimeState(enabled: true);

    await _enqueueIdentifiedSessionHeartbeatIfNeeded();
  }

  Future<void> _enqueueIdentifiedSessionHeartbeatIfNeeded() async {
    if (_isWaitingForGdprConsent || !_shouldActivateSessionTracking) {
      return;
    }

    final decision = _sessionTrackingDecision;
    if (!decision.capture || !decision.attachDeviceIdentity) {
      return;
    }

    final currentSession = _sessionManager.currentSession;
    if (currentSession == null) {
      return;
    }

    if (currentSession.deviceId == null) {
      return;
    }

    try {
      await _ensureTransport().send(
        _sessionManager.buildHeartbeatKeepAliveRequest(
          session: currentSession,
          occurredAt: _clock.now(),
        ),
      );
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to send the consent-upgrade session heartbeat. Attriax will retry promotion on the next identified request.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _ensureIdentifiedContextForCurrentConsent() async {
    if (!_shouldMaterializeIdentifiedContext) {
      return;
    }

    await _contextManager.ensureIdentifiedContext();
    await _sessionManager.syncCurrentSessionContext();
  }

  Future<void> _syncRuntimePersistenceMode() {
    return _preferencesStore.setRuntimePersistenceMode(
      mode: _consentManager.allowsRuntimePersistence
          ? AttriaxRuntimePersistenceMode.fullRuntime
          : AttriaxRuntimePersistenceMode.consentOnly,
    );
  }

  Future<void> _handleSdkRuntimeConfigLoaded(
    AttriaxSdkRuntimeConfig runtimeConfig,
  ) => _iosAppOpenEnrichmentManager.primeForConsentState(
    clipboardAttributionEnabled: runtimeConfig.clipboardAttributionEnabled,
    isWaitingForGdprConsent: _isWaitingForGdprConsent,
    allowsAttributionTracking: _allowsAttributionTracking,
  );

  Future<void> _handleScheduledAppOpen(
    AttriaxAppOpenResult? result, {
    String? originSessionId,
  }) async {
    await _skanManager.applyAppOpenResult(result);
    await _deepLinkManager.handleDeferredAppOpen(
      result,
      originSessionId: originSessionId,
    );
  }

  void _primeSdkRuntimeConfigForLaunch() {
    _runtimeConfigManager.primeForLaunch(
      isInitialized: _initialized,
      isEnabled: isEnabled,
    );
  }

  Future<AttriaxSdkRuntimeConfig> _ensureSdkRuntimeConfigLoaded() =>
      _runtimeConfigManager.ensureLoaded();

  Future<void> _scheduleAppOpenIfNeeded() => _appOpenLauncher.scheduleIfNeeded(
    isInitialized: _initialized,
    isEnabled: isEnabled,
    hasSynchronizer: _synchronizer != null,
  );

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
      'projectToken': config.projectToken,
      'currency': currency,
      'amountMicros': amountMicros.toString(),
      'clientOccurredAt': clientOccurredAt.toUtc().toIso8601String(),
    });

    return _parseUsdMicros(result.amountUsdMicros);
  }

  /// Parses a server-provided micros amount that may arrive as an integer or a
  /// decimal/scientific string. `int.tryParse` rejects any fractional form and
  /// would silently drop revenue, so fall back to a rounded double parse.
  static int? _parseUsdMicros(String rawAmountUsdMicros) {
    final trimmed = rawAmountUsdMicros.trim();
    return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.round();
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
}
