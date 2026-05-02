import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attriax_api_models.dart';
import 'attriax_api_base_url.dart';
import 'attriax_app_open_tracker.dart';
import 'attriax_context_collector.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_deep_link_resolver.dart';
import 'attriax_event_hub.dart';
import 'attriax_generated_transport.dart';
import 'attriax_id_generator.dart';
import 'attriax_install_referrer_state.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_synchronizer.dart';

/// Coordinates the Attriax SDK subsystems.
///
/// This class is intentionally thin — each concern is handled by a dedicated
/// collaborator:
/// - [AttriaxEventHub]          — streams and user callbacks
/// - [AttriaxSynchronizer]      — request queue, flush loop, sync state
/// - [AttriaxDeepLinkResolver]  — incoming and manual deep-link resolution
/// - [AttriaxAppOpenTracker]    — app-open request lifecycle
class AttriaxRuntime {
  AttriaxRuntime({
    required this.config,
    required AttriaxDeepLinkListener deepLinkListener,
    required AttriaxContextCollector contextCollector,
    required Connectivity connectivity,
    required http.Client client,
    required AttriaxLogger logger,
    SharedPreferences? prefsOverride,
  }) : _deepLinkListener = deepLinkListener,
       _contextCollector = contextCollector,
       _connectivity = connectivity,
       _client = client,
       _logger = logger,
       _preferencesStore = AttriaxPreferencesStore(
         prefsOverride: prefsOverride,
       ),
       _eventHub = AttriaxEventHub(),
       _appOpenTracker = AttriaxAppOpenTracker();

  final AttriaxConfig config;
  final AttriaxDeepLinkListener _deepLinkListener;
  final AttriaxContextCollector _contextCollector;
  final Connectivity _connectivity;
  final http.Client _client;
  final AttriaxLogger _logger;
  final AttriaxPreferencesStore _preferencesStore;
  final AttriaxEventHub _eventHub;
  final AttriaxAppOpenTracker _appOpenTracker;

  AttriaxSynchronizer? _synchronizer;
  AttriaxDeepLinkResolver? _resolver;
  AttriaxGeneratedTransport? _transport;

  String? _deviceId;
  String? _deviceIdSource;
  bool _initialized = false;
  bool _isFirstLaunch = false;
  AttriaxContextSnapshot? _context;
  Future<AttriaxContextSnapshot>? _resolvedContextFuture;
  bool _resolvedContextIncludesInstallReferrer = false;
  final AttriaxInstallReferrerState _installReferrerState =
      AttriaxInstallReferrerState();
  late final AttriaxRuntimeSettingsState _settingsState =
      AttriaxRuntimeSettingsState(
        preferencesStore: _preferencesStore,
        logger: _logger,
      );
  bool _trackAppOpen = true;
  Future<void>? _initializationFuture;
  AttriaxNormalizedApiBaseUrl? _normalizedApiBaseUrl;

  // ---------- getters ------------------------------------------------------- //

  bool get isInitialized => _initialized;
  bool get isEnabled => _settingsState.isEnabled;
  bool get areEventsEnabled => _settingsState.areEventsEnabled;
  bool get isFirstLaunch => _isFirstLaunch;
  String? get deviceId => _deviceId;
  bool get isSynchronized =>
      _synchronizer?.synchronizationState ==
      AttriaxSynchronizationState.synchronized;
  AttriaxSdkSnapshot? get sdkSnapshot => _context?.sdk;
  AttriaxAppOpen? get lastAppOpenResult =>
      _toPublicAppOpen(_appOpenTracker.lastResult);
  Future<AttriaxInstallReferrerDetails?> get installReferrer =>
      _installReferrerState.future;
  AttriaxDeepLinkResult? get initialDeepLink => _eventHub.initialDeepLinkValue;
  bool get isInitialDeepLinkResolved => _eventHub.isInitialDeepLinkResolved;
  Future<AttriaxDeepLinkResult?> get waitForInitialDeepLink =>
      _eventHub.initialDeepLink;
  AttriaxDeepLinkResult? get latestDeepLink => _eventHub.latestDeepLink;
  AttriaxSynchronizationState get synchronizationState =>
      _synchronizer?.synchronizationState ??
      AttriaxSynchronizationState.initializing;

  AttriaxNormalizedApiBaseUrl get _apiBaseUrlConfig =>
      _normalizedApiBaseUrl ??= normalizeAttriaxApiBaseUrl(config.apiBaseUrl);

  // ---------- streams (delegated to hub) ------------------------------------ //

  Stream<AttriaxDeepLinkEvent> get deepLinks => _eventHub.deepLinks;
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

    final storedPreferences = await _preferencesStore.restore(
      deviceIdFactory: attriaxGenerateId,
      enabledOverride: enabled ?? _settingsState.requestedEnabledOverride,
      eventsEnabledOverride:
          eventsEnabled ?? _settingsState.requestedEventsEnabledOverride,
    );
    final prefs = await _preferencesStore.preferences;

    _deviceId ??= storedPreferences.deviceId;
    _deviceIdSource ??= storedPreferences.deviceIdSource;

    late final AttriaxResolvedDeviceId resolvedDeviceId;
    if (_deviceIdSource != null) {
      resolvedDeviceId = AttriaxResolvedDeviceId(
        value: _deviceId!,
        source: _deviceIdSource!,
        isFallback:
            _deviceIdSource == attriaxPersistentStorageDeviceIdSource,
      );
    } else if (storedPreferences.hasPersistedDeviceId) {
      resolvedDeviceId = AttriaxResolvedDeviceId(
        value: _deviceId!,
        source: attriaxPersistentStorageDeviceIdSource,
        isFallback: true,
      );
    } else {
      resolvedDeviceId = await _contextCollector.resolvePreferredDeviceId(
        fallbackDeviceId: _deviceId!,
      );
    }

    if (_deviceId != resolvedDeviceId.value) {
      _deviceId = resolvedDeviceId.value;
    }
    _deviceIdSource = resolvedDeviceId.source;
    await _preferencesStore.setResolvedDeviceIdentity(
      deviceId: _deviceId!,
      deviceIdSource: _deviceIdSource,
    );
    _logger.verbose('Using device ID (${resolvedDeviceId.source}): $_deviceId');
    _isFirstLaunch = storedPreferences.isFirstLaunch;
    _settingsState.restore(
      enabled: storedPreferences.isEnabled,
      eventsEnabled: storedPreferences.areEventsEnabled,
    );
    _trackAppOpen = trackAppOpen;
    _installReferrerState.ensureCompleter();

    _installReferrerState.loadCached(
      await _preferencesStore.readInstallReferrerDetails(),
    );
    _installReferrerState.completeCachedIfEnabled(enabled: isEnabled);

    final preparedContext = await _contextCollector.prepare(
      deviceId: _deviceId!,
      isFirstLaunch: _isFirstLaunch,
      resolveInstallReferrer: isEnabled && trackAppOpen,
    );
    _context = preparedContext.initialSnapshot;
    _setResolvedContextFuture(
      preparedContext.resolvedSnapshot,
      includesInstallReferrer: isEnabled && trackAppOpen,
    );

    _transport ??= AttriaxGeneratedTransport(
      apiBaseUrl: _apiBaseUrlConfig.apiBaseUrl,
      requestTimeout: config.requestTimeout,
      httpClient: _client,
    );

    _synchronizer ??= AttriaxSynchronizer(
      transport: _transport!,
      connectivity: _connectivity,
      prefs: prefs,
      maxQueueSize: config.maxQueueSize,
      logger: _logger,
    );
    _synchronizer!.onStateChanged = _eventHub.emitSynchronizationState;

    _resolver ??= AttriaxDeepLinkResolver(
      config: config,
      deviceId: _deviceId!,
      deviceIdSource: _requireDeviceIdSource(),
      isFirstLaunch: _isFirstLaunch,
      context: _context!,
      synchronizer: _synchronizer!,
      eventHub: _eventHub,
      logger: _logger,
    );

    _initialized = true;

    if (!isEnabled) {
      _completeInstallReferrer(null, disabledResult: true);
      _eventHub.completeInitialDeepLinkIfAbsent();
      _synchronizer!.setState(AttriaxSynchronizationState.disabled);
      _logger.warning('Attriax SDK initialized in disabled mode.');
      return;
    }

    _synchronizer!.startConnectivitySubscription(
      onRestored: _synchronizer!.scheduleFlush,
    );
    await _deepLinkListener.start(
      _resolver!.handleIncoming,
      onInitialLinkProbeCompleted: _eventHub.completeInitialDeepLinkIfAbsent,
    );

    if (trackAppOpen) {
      _scheduleAppOpenIfNeeded();
    } else if (_installReferrerState.hasPendingCompletion) {
      _completeInstallReferrer(null);
    }

    _synchronizer!.scheduleFlush();
    _logger.verbose('Attriax SDK initialized.');
  }

  // ---------- tracking ------------------------------------------------------ //

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? eventData,
  }) async {
    _assertInitialized();
    if (!isEnabled || !areEventsEnabled) {
      _logger.verbose(
        'Ignoring trackEvent("$eventName") because SDK or events are disabled.',
      );
      return;
    }

    await _synchronizer!.enqueue(
      attriaxBuildTrackEventRequest(
        appToken: config.appToken,
        deviceId: _deviceId!,
        deviceIdSource: _requireDeviceIdSource(),
        eventName: eventName,
        eventData: eventData,
      ),
    );
  }

  Future<void> trackPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
  }) async {
    final normalizedPageName = pageName.trim();
    if (normalizedPageName.isEmpty) {
      throw ArgumentError.value(
        pageName,
        'pageName',
        'pageName must not be empty.',
      );
    }

    final normalizedPageClass = pageClass?.trim();
    final normalizedPageTitle = pageTitle?.trim();
    final normalizedPreviousPageName = previousPageName?.trim();

    await trackEvent(
      'page_view',
      eventData: <String, Object?>{
        ...?parameters,
        'pageName': normalizedPageName,
        if (normalizedPageClass != null && normalizedPageClass.isNotEmpty)
          'pageClass': normalizedPageClass,
        if (normalizedPageTitle != null && normalizedPageTitle.isNotEmpty)
          'pageTitle': normalizedPageTitle,
        if (normalizedPreviousPageName != null &&
            normalizedPreviousPageName.isNotEmpty)
          'previousPageName': normalizedPreviousPageName,
        'source': source,
      },
    );
  }

  Future<void> identify(
    String? externalUserId, {
    String? externalUserName,
  }) async {
    _assertInitialized();
    if (!isEnabled) {
      _logger.verbose(
        'Ignoring identify("$externalUserId") because SDK is disabled.',
      );
      return;
    }

    await _synchronizer!.enqueue(
      attriaxBuildIdentifyRequest(
        appToken: config.appToken,
        deviceId: _deviceId!,
        deviceIdSource: _requireDeviceIdSource(),
        externalUserId: externalUserId,
        externalUserName: externalUserName,
      ),
    );
  }

  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    bool? iosRedirect,
    bool? androidRedirect,
    String? previewTitle,
    String? previewDescription,
    String? previewImagePath,
    String? utmSource,
    String? utmMedium,
    String? utmCampaign,
    String? utmTerm,
    String? utmContent,
    Map<String, Object?>? data,
  }) async {
    _assertInitialized();

    final request = attriaxBuildCreateDynamicLinkRequest(
      appToken: config.appToken,
      name: _trimOrNull(name),
      destinationUrl: _trimOrNull(destinationUrl),
      group: _trimOrNull(group),
      prefix: _trimOrNull(prefix),
      iosRedirect: iosRedirect,
      androidRedirect: androidRedirect,
      previewTitle: _trimOrNull(previewTitle),
      previewDescription: _trimOrNull(previewDescription),
      previewImagePath: _trimOrNull(previewImagePath),
      utmSource: _trimOrNull(utmSource),
      utmMedium: _trimOrNull(utmMedium),
      utmCampaign: _trimOrNull(utmCampaign),
      utmTerm: _trimOrNull(utmTerm),
      utmContent: _trimOrNull(utmContent),
      data: data,
    );

    return _transport!.createDynamicLink(request);
  }

  Future<AttriaxDeepLinkResolution?> recordDeepLinkConversion({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    _assertInitialized();
    if (!isEnabled) {
      _logger.verbose(
        'Ignoring recordDeepLinkConversion because SDK is disabled.',
      );
      return null;
    }

    return _resolver!.recordManualConversion(
      uri: uri,
      linkPath: linkPath,
      metadata: metadata,
      source: source,
    );
  }

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

    Future<AttriaxAppOpen?> waitForAppOpenTracking() async =>
      _toPublicAppOpen(await _appOpenTracker.waitForResult());

  // ---------- dispose ------------------------------------------------------- //

  Future<void> dispose() async {
    _logger.verbose('Disposing Attriax SDK runtime.');
    if (_installReferrerState.hasPendingCompletion) {
      _completeInstallReferrer(null);
    }
    await _deepLinkListener.stop();
    await _synchronizer?.dispose();
    await _appOpenTracker.dispose();
    await _eventHub.dispose();
    _client.close();
  }

  // ---------- private ------------------------------------------------------- //

  AttriaxAppOpen? _toPublicAppOpen(AttriaxAppOpenResult? result) {
    if (result == null) {
      return null;
    }

    return AttriaxAppOpen(
      isNewUser: result.isNewUser,
      isFirstLaunch: result.isFirstLaunch,
      deepLink: result.deepLink,
    );
  }

  void _validateConfig() {
    if (config.appToken.trim().isEmpty) {
      throw ArgumentError('Attriax appToken must not be empty.');
    }
    _apiBaseUrlConfig;
    if (config.maxQueueSize <= 0) {
      throw ArgumentError('Attriax maxQueueSize must be greater than zero.');
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

  String _requireDeviceIdSource() {
    final source = _deviceIdSource?.trim();
    if (source == null || source.isEmpty) {
      return attriaxPersistentStorageDeviceIdSource;
    }

    return source;
  }

  Future<void> _applyEnabledState(bool enabled) async {
    if (!enabled) {
      _synchronizer?.deactivate();
      _synchronizer?.setState(AttriaxSynchronizationState.disabled);
      _logger.warning('Attriax SDK disabled.');
      await _deepLinkListener.stop();
      await _synchronizer?.stopConnectivitySubscription();
      return;
    }

    _synchronizer?.activate();
    _synchronizer?.setState(AttriaxSynchronizationState.synchronizing);
    _logger.verbose('Attriax SDK enabled.');
    if (_initialized && _resolver != null && _synchronizer != null) {
      _synchronizer!.startConnectivitySubscription(
        onRestored: _synchronizer!.scheduleFlush,
      );
      await _deepLinkListener.start(
        _resolver!.handleIncoming,
        onInitialLinkProbeCompleted: _eventHub.completeInitialDeepLinkIfAbsent,
      );
      await _prepareInstallReferrerFutureForEnabledState();
      _scheduleAppOpenIfNeeded();
      _synchronizer!.scheduleFlush();
    }
  }

  void _setResolvedContextFuture(
    Future<AttriaxContextSnapshot> future, {
    required bool includesInstallReferrer,
  }) {
    _resolvedContextIncludesInstallReferrer = includesInstallReferrer;
    _resolvedContextFuture = future
        .then((resolvedContext) {
          _context = resolvedContext;
          return resolvedContext;
        })
        .catchError((Object error, StackTrace stackTrace) {
          _logger.warning(
            'Failed to resolve the background install referrer context.',
            error: error,
            stackTrace: stackTrace,
          );
          return _context!;
        });
  }

  Future<AttriaxContextSnapshot> _ensureResolvedContextForAppOpen() {
    final currentFuture = _resolvedContextFuture;
    if (currentFuture != null && _resolvedContextIncludesInstallReferrer) {
      return currentFuture;
    }

    final refreshedFuture = _contextCollector
        .prepare(deviceId: _deviceId!, isFirstLaunch: _isFirstLaunch)
        .then((preparedContext) {
          _context = preparedContext.initialSnapshot;
          return preparedContext.resolvedSnapshot;
        })
        .then((resolvedContext) {
          _context = resolvedContext;
          return resolvedContext;
        })
        .catchError((Object error, StackTrace stackTrace) {
          _logger.warning(
            'Failed to refresh install-referrer context for app-open tracking.',
            error: error,
            stackTrace: stackTrace,
          );
          return _context!;
        });

    _resolvedContextIncludesInstallReferrer = true;
    _resolvedContextFuture = refreshedFuture;
    return refreshedFuture;
  }

  Future<void> _prepareInstallReferrerFutureForEnabledState() async {
    _installReferrerState.loadCached(
      await _preferencesStore.readInstallReferrerDetails(),
    );
    _installReferrerState.prepareForEnabledState();
  }

  void _prepareInstallReferrerCompleterForReenable() {
    _installReferrerState.prepareForReenable();
  }

  void _scheduleAppOpenIfNeeded() {
    if (!_initialized ||
        !isEnabled ||
        !_trackAppOpen ||
        _synchronizer == null ||
        _appOpenTracker.didSchedule) {
      return;
    }

    unawaited(
      _appOpenTracker.schedule(
        config: config,
        contextFuture: _ensureResolvedContextForAppOpen(),
        deviceIdSource: _requireDeviceIdSource(),
        synchronizer: _synchronizer!,
        eventHub: _eventHub,
        logger: _logger,
      ),
    );

    if (_installReferrerState.markResolutionStarted()) {
      unawaited(_resolveInstallReferrerFromAppOpenTracking());
    }
  }

  Future<void> _resolveInstallReferrerFromAppOpenTracking() async {
    try {
      final result = await _appOpenTracker.waitForResult();
      final installReferrerDetails = result?.installReferrer;
      if (installReferrerDetails != null) {
        await _preferencesStore.setInstallReferrerDetails(
          details: installReferrerDetails,
        );
        _installReferrerState.cache(installReferrerDetails);
      }
      _completeInstallReferrer(installReferrerDetails);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to resolve the install referrer result from app-open tracking.',
        error: error,
        stackTrace: stackTrace,
      );
      _completeInstallReferrer(null);
    }
  }

  void _completeInstallReferrer(
    AttriaxInstallReferrerDetails? details, {
    bool disabledResult = false,
  }) => _installReferrerState.complete(
    details,
    disabledResult: disabledResult,
  );
}
