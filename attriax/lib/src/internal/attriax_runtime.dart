import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attriax_api_models.dart';
import 'attriax_app_open_tracker.dart';
import 'attriax_conversion_mapper.dart';
import 'attriax_context_collector.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_deep_link_resolver.dart';
import 'attriax_event_hub.dart';
import 'attriax_id_generator.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';
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
       _conversionMapper = const AttriaxConversionMapper(),
       _eventHub = AttriaxEventHub(),
       _appOpenTracker = AttriaxAppOpenTracker();

  final AttriaxConfig config;
  final AttriaxDeepLinkListener _deepLinkListener;
  final AttriaxContextCollector _contextCollector;
  final Connectivity _connectivity;
  final http.Client _client;
  final AttriaxLogger _logger;
  final AttriaxPreferencesStore _preferencesStore;
  final AttriaxConversionMapper _conversionMapper;
  final AttriaxEventHub _eventHub;
  final AttriaxAppOpenTracker _appOpenTracker;

  AttriaxSynchronizer? _synchronizer;
  AttriaxDeepLinkResolver? _resolver;

  String? _deviceId;
  bool _initialized = false;
  bool _isEnabled = true;
  bool _eventsEnabled = true;
  bool _isFirstLaunch = false;
  AttriaxContextSnapshot? _context;
  bool? _requestedEnabledOverride;
  bool? _requestedEventsEnabledOverride;
  Future<void> _enabledTransition = Future<void>.value();
  Future<void> _eventsEnabledTransition = Future<void>.value();

  // ---------- getters ------------------------------------------------------- //

  bool get isInitialized => _initialized;
  bool get isEnabled => _isEnabled;
  bool get areEventsEnabled => _eventsEnabled;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isSynchronized =>
      _synchronizer?.synchronizationState ==
      AttriaxSynchronizationState.synchronized;
  String? get deviceId => _deviceId;
  AttriaxContextSnapshot? get contextSnapshot => _context;
  AttriaxAppOpenResult? get lastAppOpenResult => _appOpenTracker.lastResult;
  AttriaxSynchronizationState get synchronizationState =>
      _synchronizer?.synchronizationState ??
      AttriaxSynchronizationState.initializing;

  // ---------- streams (delegated to hub) ------------------------------------ //

  Stream<AttriaxDeepLinkEvent> get deepLinks => _eventHub.deepLinks;
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _eventHub.synchronizationStates;

  // ---------- init ---------------------------------------------------------- //

  Future<void> init({
    bool? enabled,
    bool? eventsEnabled,
    bool trackAppOpen = true,
  }) async {
    _logger.verbose('Initializing Attriax SDK.');
    _validateConfig();

    final storedPreferences = await _preferencesStore.restore(
      deviceIdFactory: attriaxGenerateId,
      enabledOverride: enabled ?? _requestedEnabledOverride,
      eventsEnabledOverride: eventsEnabled ?? _requestedEventsEnabledOverride,
    );
    final prefs = await _preferencesStore.preferences;

    _deviceId ??= storedPreferences.deviceId;
    _isFirstLaunch = storedPreferences.isFirstLaunch;
    _isEnabled = storedPreferences.isEnabled;
    _eventsEnabled = storedPreferences.areEventsEnabled;
    _requestedEnabledOverride = _isEnabled;
    _requestedEventsEnabledOverride = _eventsEnabled;

    _context = await _contextCollector.collect(
      deviceId: _deviceId!,
      isFirstLaunch: _isFirstLaunch,
    );

    _synchronizer ??= AttriaxSynchronizer(
      apiBaseUrl: config.apiBaseUrl,
      client: _client,
      requestTimeout: config.requestTimeout,
      connectivity: _connectivity,
      prefs: prefs,
      maxQueueSize: config.maxQueueSize,
      logger: _logger,
    );
    _synchronizer!.onStateChanged = _eventHub.emitSynchronizationState;

    _resolver ??= AttriaxDeepLinkResolver(
      config: config,
      deviceId: _deviceId!,
      isFirstLaunch: _isFirstLaunch,
      context: _context!,
      synchronizer: _synchronizer!,
      eventHub: _eventHub,
      conversionMapper: _conversionMapper,
      logger: _logger,
    );

    _initialized = true;

    if (!_isEnabled) {
      _synchronizer!.setState(AttriaxSynchronizationState.disabled);
      _logger.warning('Attriax SDK initialized in disabled mode.');
      return;
    }

    _synchronizer!.startConnectivitySubscription(
      onRestored: _synchronizer!.scheduleFlush,
    );
    await _deepLinkListener.start(_resolver!.handleIncoming);

    if (trackAppOpen) {
      await _appOpenTracker.schedule(
        config: config,
        context: _context!,
        isFirstLaunch: _isFirstLaunch,
        synchronizer: _synchronizer!,
        eventHub: _eventHub,
        logger: _logger,
      );
    }

    _synchronizer!.scheduleFlush();
    _logger.verbose('Attriax SDK initialized.');
  }

  // ---------- tracking ------------------------------------------------------ //

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    String? linkId,
  }) async {
    _assertInitialized();
    if (!_isEnabled || !_eventsEnabled) {
      _logger.verbose(
        'Ignoring trackEvent("$eventName") because SDK or events are disabled.',
      );
      return;
    }

    await _synchronizer!.enqueue(
      AttriaxTrackEventRequest(
        appToken: config.appToken,
        deviceId: _deviceId!,
        eventName: eventName,
        eventData: eventData,
        linkId: linkId,
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
    String externalUserId, {
    String? externalUserName,
  }) async {
    _assertInitialized();
    if (!_isEnabled) {
      _logger.verbose(
        'Ignoring identify("$externalUserId") because SDK is disabled.',
      );
      return;
    }

    await _synchronizer!.enqueue(
      AttriaxIdentifyRequest(
        appToken: config.appToken,
        deviceId: _deviceId!,
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
    Map<String, Object?>? data,
  }) async {
    _assertInitialized();

    final request = AttriaxCreateDynamicLinkRequest(
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
      data: data,
    );

    final response = await _client
        .post(
          Uri.parse('${config.apiBaseUrl}${request.path}'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(config.requestTimeout);

    final payload = _decodeApiPayload(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Attriax API error (${response.statusCode}): ${response.body}',
      );
    }

    final parsed = AttriaxApiResponseCodec.decode(
      AttriaxRequestKind.createDynamicLink,
      payload,
    );

    return (parsed as AttriaxCreateDynamicLinkApiResponse).result;
  }

  Future<AttriaxDeepLinkConversionEvent?> recordDeepLinkConversion({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    _assertInitialized();
    if (!_isEnabled) {
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

  void setEnabled({required bool enabled}) {
    _requestedEnabledOverride = enabled;
    if (_isEnabled == enabled && _initialized) {
      _enabledTransition = _enabledTransition.then(
        (_) => _persistEnabledPreference(enabled),
      );
      return;
    }
    _isEnabled = enabled;

    _enabledTransition = _enabledTransition
        .then((_) => _applyEnabledState(enabled))
        .catchError((Object error, StackTrace stackTrace) {
          _logger.error(
            'Failed to update Attriax enabled state.',
            error: error,
            stackTrace: stackTrace,
          );
        });
  }

  void setEventsEnabled({required bool enabled}) {
    _requestedEventsEnabledOverride = enabled;
    _eventsEnabled = enabled;
    _logger.verbose(
      'Attriax custom events ${enabled ? 'enabled' : 'disabled'}.',
    );
    _eventsEnabledTransition = _eventsEnabledTransition
        .then((_) => _persistEventsEnabledPreference(enabled))
        .catchError((Object error, StackTrace stackTrace) {
          _logger.error(
            'Failed to update Attriax event preference state.',
            error: error,
            stackTrace: stackTrace,
          );
        });
  }

  // ---------- app open ------------------------------------------------------ //

  Future<AttriaxAppOpenResult?> waitForAppOpenTracking() =>
      _appOpenTracker.waitForResult();

  // ---------- dispose ------------------------------------------------------- //

  Future<void> dispose() async {
    _logger.verbose('Disposing Attriax SDK runtime.');
    await _deepLinkListener.stop();
    await _synchronizer?.dispose();
    await _appOpenTracker.dispose();
    await _eventHub.dispose();
    _client.close();
  }

  // ---------- private ------------------------------------------------------- //

  void _validateConfig() {
    if (config.appToken.trim().isEmpty) {
      throw ArgumentError('Attriax appToken must not be empty.');
    }
    final apiUri = Uri.tryParse(config.apiBaseUrl);
    if (apiUri == null || !apiUri.hasScheme || !apiUri.hasAuthority) {
      throw ArgumentError('Attriax apiBaseUrl must be an absolute URL.');
    }
    if (config.maxQueueSize <= 0) {
      throw ArgumentError('Attriax maxQueueSize must be greater than zero.');
    }
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError('Attriax SDK not initialized. Call init() first.');
    }
  }

  Map<String, Object?> _decodeApiPayload(http.Response response) {
    if (response.body.isEmpty) {
      return const <String, Object?>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      return const <String, Object?>{};
    }

    final payload = decoded.map(
      (key, value) => MapEntry(key.toString(), value as Object?),
    );
    final data = payload['data'];
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(key.toString(), value as Object?),
      );
    }

    return payload;
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _applyEnabledState(bool enabled) async {
    await _persistEnabledPreference(enabled);

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
      await _deepLinkListener.start(_resolver!.handleIncoming);
      _synchronizer!.scheduleFlush();
    }
  }

  Future<void> _persistEnabledPreference(bool enabled) async {
    try {
      await _preferencesStore.setSdkEnabled(enabled: enabled);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to persist the Attriax enabled preference.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _persistEventsEnabledPreference(bool enabled) async {
    try {
      await _preferencesStore.setEventsEnabled(enabled: enabled);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to persist the Attriax event preference.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
