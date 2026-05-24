import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../attriax_ad_event_type.dart';
import '../attriax_analytics_keys.dart';
import '../attriax_consent.dart';
import 'attriax_api_models.dart';
import 'attriax_api_base_url.dart';
import 'attriax_app_open_launch_coordinator.dart';
import 'attriax_app_open_manager.dart';
import 'attriax_consent_manager.dart';
import 'attriax_context_collector.dart';
import 'attriax_context_manager.dart';
import 'attriax_crash_reporting_coordinator.dart';
import 'attriax_deep_link_manager.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_event_hub.dart';
import 'attriax_generated_transport.dart';
import 'attriax_ios_app_open_enrichment_manager.dart';
import 'attriax_logger.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_preferences_store.dart';
import 'attriax_queue.dart';
import 'attriax_request_manager.dart';
import 'attriax_referrer_manager.dart';
import 'attriax_runtime_activation_coordinator.dart';
import 'attriax_runtime_bootstrap_coordinator.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_runtime_settings_store.dart';
import 'attriax_sdk_runtime_config.dart';
import 'attriax_sdk_runtime_config_coordinator.dart';
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
  late final AttriaxDeepLinkManager _deepLinkManager;
  late final AttriaxAppOpenManager _appOpenManager;
  late final AttriaxReferrerManager _referrerManager;
  late final AttriaxTrackingManager _trackingManager;
  late final AttriaxSessionManager _sessionManager;
  late final AttriaxSkanManager _skanManager;
  late final AttriaxCrashReportingCoordinator _crashReportingCoordinator =
      AttriaxCrashReportingCoordinator(
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
  late final AttriaxAppOpenLaunchCoordinator _appOpenLaunchCoordinator =
      AttriaxAppOpenLaunchCoordinator(
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
            }) =>
                _iosAppOpenEnrichmentManager.installReferrerOverrideForAppOpen(
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
  late final AttriaxSdkRuntimeConfigCoordinator _sdkRuntimeConfigCoordinator =
      AttriaxSdkRuntimeConfigCoordinator(
        config: config,
        contextSnapshot: () => _contextManager.snapshot,
        fetchRuntimeConfig: (payload) =>
            _ensureTransport().fetchSdkRuntimeConfig(payload),
        logger: _logger,
        onLoaded: _handleSdkRuntimeConfigLoaded,
      );
  late final AttriaxRuntimeBootstrapCoordinator<AttriaxSynchronizer>
  _runtimeBootstrapCoordinator =
      AttriaxRuntimeBootstrapCoordinator<AttriaxSynchronizer>(
        bindConsentTransport: _consentManager.bindTransport,
        initConsent: _consentManager.init,
        syncRuntimePersistenceMode: _syncRuntimePersistenceMode,
        restoreRuntimePreferences: _runtimeSettingsStore.restore,
        restoreSettings: _settingsState.restore,
        initContext: _contextManager.init,
        isFirstLaunch: () => _contextManager.isFirstLaunch,
        initSkan: ({required bool isFirstLaunch}) =>
            _skanManager.init(isFirstLaunch: isFirstLaunch),
        initSession: ({required bool enabled}) =>
            _sessionManager.init(enabled: enabled),
        initReferrer: ({required bool enabled}) =>
            _referrerManager.init(enabled: enabled),
        createSynchronizer: (transport) => AttriaxSynchronizer(
          transport: transport,
          connectivity: _connectivity,
          appOpenMonitor: _appOpenManager,
          preferencesStore: _preferencesStore,
          maxQueueSize: config.maxQueueSize,
          eventFlushInterval: config.eventFlushInterval,
          logger: _logger,
          buildSessionKeepAliveBatchRequest: _buildSessionKeepAliveBatchRequest,
          onSessionKeepAliveDelivered: _handleSessionKeepAliveDelivered,
        ),
        bindRequestSynchronizer: (synchronizer) =>
            _requestManager.synchronizer = synchronizer,
        bindSynchronizationStateListener: (synchronizer) =>
            synchronizer.onStateChanged = _eventHub.emitSynchronizationState,
        seedRecoveredSessionEnd: _sessionManager.seedRecoveredSessionEnd,
      );
  late final AttriaxRuntimeActivationCoordinator
  _runtimeActivationCoordinator = AttriaxRuntimeActivationCoordinator(
    logger: _logger,
    primeLaunchPreparation: _primeSdkRuntimeConfigForLaunch,
    setAppOpenDispatchGateEnabled: ({required bool enabled}) =>
        _appOpenManager.setDispatchGateEnabled(enabled: enabled),
    handleDisabledReferrers: _referrerManager.handleDisabled,
    prepareReferrerWaitersForReenable: _referrerManager.prepareForReenable,
    prepareReferrersForEnabledState: _referrerManager.prepareForEnabledState,
    prepareForDeniedAttributionState:
        _referrerManager.prepareForDeniedAttributionState,
    activateCrashReporting: ({required bool installHandlers}) =>
        _crashReportingCoordinator.activate(installHandlers: installHandlers),
    deactivateCrashReporting: _crashReportingCoordinator.deactivate,
    activateSessionTracking: _sessionManager.activate,
    deactivateSessionTracking: _sessionManager.deactivate,
    activateSynchronizer: () => _synchronizer?.activate(),
    deactivateSynchronizer: () => _synchronizer?.deactivate(),
    setSynchronizationState: (state) => _synchronizer?.setState(state),
    startConnectivitySubscription: () {
      final synchronizer = _synchronizer;
      if (synchronizer == null) {
        return;
      }

      synchronizer.startConnectivitySubscription(
        onRestored: synchronizer.scheduleFlush,
      );
    },
    stopConnectivitySubscription: () async {
      await _synchronizer?.stopConnectivitySubscription();
    },
    scheduleFlush: () => _synchronizer?.scheduleFlush(),
    flushPendingSync: () {
      unawaited(_consentManager.flushPendingSync(appToken: config.appToken));
    },
    scheduleAppOpenIfNeeded: () {
      unawaited(_scheduleAppOpenIfNeeded());
    },
    startDeepLinks: _deepLinkManager.start,
    stopDeepLinks: _deepLinkManager.stop,
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

  AttriaxRuntimeActivationState get _runtimeActivationState =>
      AttriaxRuntimeActivationState(
        shouldDeferNetworkDispatch: _shouldDeferNetworkDispatch,
        allowsAttributionTracking: _allowsAttributionTracking,
        shouldTrackAnything: _shouldTrackAnything,
        shouldActivateSessionTracking: _shouldActivateSessionTracking,
        shouldInstallCrashHandlers: _shouldInstallCrashHandlers,
        canRunActiveSynchronizationFlow: _initialized && _synchronizer != null,
      );

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

    await _crashReportingCoordinator.deactivate();
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
    _appOpenLaunchCoordinator.reset();
    _sdkRuntimeConfigCoordinator.reset();
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
      appToken: config.appToken,
      deviceId: deviceId,
    );

    await reset();
  }

  Future<void> _runInit({bool? enabled, bool? eventsEnabled}) async {
    _logger.verbose('Initializing Attriax SDK.');
    _validateConfig();

    _synchronizer = await _runtimeBootstrapCoordinator.bootstrap(
      transport: _ensureTransport(),
      enabledOverride: enabled ?? _settingsState.requestedEnabledOverride,
      eventsEnabledOverride:
          eventsEnabled ?? _settingsState.requestedEventsEnabledOverride,
      sessionTrackingEnabled: _sessionTrackingEnabled,
      seedRecoveredSessionEnd: _shouldActivateSessionTracking,
      existingSynchronizer: _synchronizer,
    );

    _initialized = true;
    await _runtimeActivationCoordinator.apply(
      enabled: isEnabled,
      state: _runtimeActivationState,
    );
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
      appToken: config.appToken,
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
        appToken: config.appToken,
        analytics: analytics,
        attribution: attribution,
        adEvents: adEvents,
      );
  }

  void setGdprConsentNotRequired() {
    _consentManager
      ..bindTransport(_ensureTransport())
      ..setNotRequired(appToken: config.appToken);
  }

  void resetGdprConsent() {
    _consentManager
      ..bindTransport(_ensureTransport())
      ..reset(appToken: config.appToken);
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

    if (!_canCaptureUninstallTracking) {
      _logger.verbose(
        'Ignoring uninstall-token registration because GDPR attribution consent is not granted.',
      );
      return;
    }

    final normalizedToken = _trimOrNull(token);

    final currentDeviceId = deviceId;
    if (currentDeviceId == null) {
      throw StateError('Attriax SDK did not restore a device id.');
    }

    final request = attriaxBuildRegisterUninstallTokenQueueRequest(
      appToken: config.appToken,
      deviceId: currentDeviceId,
      deviceIdSource: _contextManager.requireDeviceIdSource(),
      platform: _contextManager.requiredSnapshot.platform,
      provider: provider,
      token: normalizedToken,
      metadata: metadata,
    );

    await _requestManager.enqueue(request);
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

    if (_shouldActivateSessionTracking) {
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
    applyState: ({required bool enabled}) => _runtimeActivationCoordinator
        .apply(enabled: enabled, state: _runtimeActivationState),
    onPreparingToEnable: enabled
        ? _runtimeActivationCoordinator.prepareForReenable
        : null,
  );

  void setEventsEnabled({required bool enabled}) =>
      _settingsState.setEventsEnabled(enabled: enabled);

  // ---------- app open ------------------------------------------------------ //

  // ---------- dispose ------------------------------------------------------- //

  Future<void> dispose() async {
    _logger.verbose('Disposing Attriax SDK runtime.');
    await _crashReportingCoordinator.deactivate();
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

  void _handleConsentStateChanged() {
    if (!_initialized || !isEnabled) {
      return;
    }

    unawaited(_applyConsentStateChange());
  }

  Future<void> _applyConsentStateChange() async {
    await _syncRuntimePersistenceMode();

    final synchronizer = _synchronizer;
    if (config.gdprEnabled &&
        !_consentManager.isWaitingForGdprConsent &&
        synchronizer != null) {
      if (_consentManager.gdprConsentState ==
          AttriaxGdprConsentState.notRequired) {
        final deviceId = _contextManager.deviceId;
        if (deviceId != null) {
          final deviceIdSource = _requireDeviceIdSource();
          final identifiedCount = await synchronizer.rewriteQueuedRequestsWhere(
            (queuedRequest) => attriaxIdentifyRequestForConsentNotRequired(
              queuedRequest.request,
              deviceId: deviceId,
              deviceIdSource: deviceIdSource,
            ),
          );
          if (identifiedCount > 0) {
            _logger.verbose(
              'Attached device identity to $identifiedCount queued request(s) after GDPR resolved as not required.',
            );
          }
        }
      }

      final rewrittenCount = await synchronizer.rewriteQueuedRequestsWhere(
        (queuedRequest) => _shouldAnonymizeQueuedRequest(queuedRequest.request)
            ? attriaxAnonymizeRequestForConsent(queuedRequest.request)
            : null,
      );
      if (rewrittenCount > 0) {
        _logger.verbose(
          'Anonymized $rewrittenCount queued request(s) after GDPR consent denied one or more categories.',
        );
      }

      final droppedCount = await synchronizer.discardQueuedRequestsWhere(
        (queuedRequest) =>
            !_isRequestAllowedByResolvedConsent(queuedRequest.request),
        reason: 'gdpr_consent_denied',
      );
      if (droppedCount > 0) {
        _logger.warning(
          'Dropped $droppedCount queued request(s) after GDPR consent denied one or more categories.',
        );
      }
    }

    if (!_shouldDeferNetworkDispatch) {
      unawaited(_consentManager.flushPendingSync(appToken: config.appToken));
    }

    await _runtimeActivationCoordinator.apply(
      enabled: true,
      state: _runtimeActivationState,
    );
  }

  bool _isRequestAllowedByResolvedConsent(AttriaxApiRequest request) =>
      switch (request) {
        AttriaxTrackEventRequest() => !_isWaitingForGdprConsent,
        AttriaxTrackCrashRequest() => !_isWaitingForGdprConsent,
        AttriaxTrackSessionRequest() => !_isWaitingForGdprConsent,
        AttriaxUserRequest() => _allowsAttributionTracking,
        AttriaxOpenRequest() => _allowsAttributionTracking,
        AttriaxResolveDeepLinkRequest() => true,
        AttriaxRegisterUninstallTokenRequest() => _allowsAttributionTracking,
        AttriaxCreateDynamicLinkRequest() => true,
      };

  bool _shouldAnonymizeQueuedRequest(AttriaxApiRequest request) {
    if (_isWaitingForGdprConsent) {
      return false;
    }

    return switch (request) {
      AttriaxTrackEventRequest(:final payload) =>
        _isAdEventName(payload.eventName)
            ? !_allowsAdEventsTracking
            : !_allowsAnalyticsTracking,
      AttriaxTrackCrashRequest() => !_allowsAnalyticsTracking,
      AttriaxTrackSessionRequest() =>
        !(_allowsAnalyticsTracking || _allowsAdEventsTracking),
      AttriaxResolveDeepLinkRequest() => !_allowsAttributionTracking,
      _ => false,
    };
  }

  bool _isAdEventName(String eventName) =>
      eventName == AttriaxAnalyticsEventKeys.adRevenue ||
      AttriaxAdEventType.values.any((value) => value.eventName == eventName);

  Future<void> _syncRuntimePersistenceMode() {
    final values = _consentManager.gdprConsentValues;
    final allowsRuntimePersistence =
        !config.gdprEnabled ||
        _consentManager.gdprConsentState ==
            AttriaxGdprConsentState.notRequired ||
        (_consentManager.gdprConsentState == AttriaxGdprConsentState.granted &&
            values != null &&
            (values.analytics || values.attribution || values.adEvents));

    return _preferencesStore.setRuntimePersistenceMode(
      mode: allowsRuntimePersistence
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
    _sdkRuntimeConfigCoordinator.primeForLaunch(
      isInitialized: _initialized,
      isEnabled: isEnabled,
    );
  }

  Future<AttriaxSdkRuntimeConfig> _ensureSdkRuntimeConfigLoaded() =>
      _sdkRuntimeConfigCoordinator.ensureLoaded();

  Future<void> _scheduleAppOpenIfNeeded() =>
      _appOpenLaunchCoordinator.scheduleIfNeeded(
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
}
