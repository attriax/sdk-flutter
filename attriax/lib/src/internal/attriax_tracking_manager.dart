import 'package:attriax_platform_interface/attriax_platform_interface.dart';

import '../attriax_clock.dart';
import 'attriax_api_models.dart';
import 'attriax_context_manager.dart';
import 'attriax_logger.dart';
import 'attriax_request_manager.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_session_manager.dart';
import 'attriax_user_properties.dart';

/// Owns tracking request construction and enqueueing for runtime APIs.
class AttriaxTrackingManager {
  AttriaxTrackingManager({
    required AttriaxConfig config,
    required AttriaxLogger logger,
    required AttriaxClock clock,
    required AttriaxTrackingContext contextManager,
    required AttriaxRuntimeSettingsView settingsState,
    required AttriaxRequestManager requestManager,
    required AttriaxTrackedSessionPreparer sessionManager,
  }) : _config = config,
       _logger = logger,
       _clock = clock,
       _contextManager = contextManager,
       _settingsState = settingsState,
       _requestManager = requestManager,
       _sessionManager = sessionManager;

  final AttriaxConfig _config;
  final AttriaxLogger _logger;
  final AttriaxClock _clock;
  final AttriaxTrackingContext _contextManager;
  final AttriaxRuntimeSettingsView _settingsState;
  final AttriaxRequestManager _requestManager;
  final AttriaxTrackedSessionPreparer _sessionManager;

  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) => _queueEvent(
    eventName,
    eventData: eventData,
    flushImmediately: _shouldFlushEventImmediately(
      flushImmediately: flushImmediately,
    ),
  );

  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) async {
    final normalizedPageName = pageName.trim();
    if (normalizedPageName.isEmpty) {
      throw ArgumentError.value(
        pageName,
        'pageName',
        'pageName must not be empty.',
      );
    }

    final normalizedPageClass = _trimOrNull(pageClass);
    final normalizedPageTitle = _trimOrNull(pageTitle);
    final normalizedPreviousPageName = _trimOrNull(previousPageName);

    await _queueEvent(
      'page_view',
      eventData: <String, Object?>{
        ...?parameters,
        'pageName': normalizedPageName,
        if (normalizedPageClass != null) 'pageClass': normalizedPageClass,
        if (normalizedPageTitle != null) 'pageTitle': normalizedPageTitle,
        if (normalizedPreviousPageName != null)
          'previousPageName': normalizedPreviousPageName,
        'source': source,
      },
      flushImmediately: _shouldFlushEventImmediately(
        flushImmediately: flushImmediately,
      ),
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
    if (!_settingsState.isEnabled) {
      _logger.verbose('Ignoring recordError() because SDK is disabled.');
      return;
    }

    final occurredAt = _clock.now();
    final currentSession = await _sessionManager.prepareTrackedSessionAt(
      occurredAt,
    );
    await _requestManager.enqueue(
      attriaxBuildTrackCrashRequest(
        appToken: _config.appToken,
        clientOccurredAt: occurredAt,
        context: _contextManager.requiredSnapshot,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _contextManager.requireDeviceIdSource(),
        source: _trimOrNull(source) ?? 'manual',
        isFatal: fatal,
        exceptionType: error.runtimeType.toString(),
        message: error.toString(),
        metadata: metadata,
        reason: _trimOrNull(reason),
        session: currentSession,
        stackTrace: stackTrace.toString(),
      ),
    );
  }

  Future<void> setUser(String? userId, {String? userName}) async {
    if (!_settingsState.isEnabled) {
      _logger.verbose('Ignoring setUser("$userId") because SDK is disabled.');
      return;
    }

    await _sessionManager.prepareTrackedSessionAt(_clock.now());
    await _requestManager.enqueue(
      attriaxBuildUserRequest(
        appToken: _config.appToken,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _contextManager.requireDeviceIdSource(),
        externalUserId: userId,
        externalUserName: userName,
        clearExternalUser: userId == null,
      ),
    );
  }

  Future<void> setUserProperty(String name, Object? value) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    if (value == null) {
      await clearUserProperties(propertyNames: <String>[trimmedName]);
      return;
    }

    await setUserProperties(<String, Object?>{trimmedName: value});
  }

  Future<void> setUserProperties(Map<String, Object?> properties) async {
    if (!_settingsState.isEnabled) {
      _logger.verbose('Ignoring setUserProperties() because SDK is disabled.');
      return;
    }

    final sanitizedUpdate = attriaxSanitizeUserPropertyUpdate(properties);
    if (sanitizedUpdate.isEmpty) {
      return;
    }

    await _queueUserUpdate(
      properties: sanitizedUpdate.properties.isEmpty
          ? null
          : sanitizedUpdate.properties,
      clearPropertyKeys: sanitizedUpdate.clearPropertyKeys.isEmpty
          ? null
          : sanitizedUpdate.clearPropertyKeys,
    );
  }

  Future<void> clearUserProperties({List<String>? propertyNames}) async {
    if (!_settingsState.isEnabled) {
      _logger.verbose(
        'Ignoring clearUserProperties() because SDK is disabled.',
      );
      return;
    }

    final normalizedPropertyNames = propertyNames
        ?.map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    await _queueUserUpdate(
      clearPropertyKeys:
          normalizedPropertyNames == null || normalizedPropertyNames.isEmpty
          ? null
          : normalizedPropertyNames,
      clearAllProperties:
          normalizedPropertyNames == null || normalizedPropertyNames.isEmpty,
    );
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  bool _shouldFlushEventImmediately({
    required bool flushImmediately,
    bool allowFirstLaunchEagerFlush = true,
  }) {
    if (flushImmediately) {
      return true;
    }

    return allowFirstLaunchEagerFlush &&
        _config.flushEventsImmediatelyOnFirstLaunch &&
        _contextManager.requiredSnapshot.isFirstLaunch;
  }

  int? _sessionRelativeTimeMs({
    required AttriaxSessionSnapshot? session,
    required DateTime occurredAt,
  }) {
    if (session == null) {
      return null;
    }

    return occurredAt
        .difference(session.startedAt)
        .inMilliseconds
        .clamp(0, 0x7fffffff);
  }

  Future<void> _queueEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    required bool flushImmediately,
  }) async {
    if (!_settingsState.isEnabled || !_settingsState.areEventsEnabled) {
      _logger.verbose(
        'Ignoring recordEvent("$eventName") because SDK or events are disabled.',
      );
      return;
    }

    final occurredAt = _clock.now();
    final currentSession = await _sessionManager.prepareTrackedSessionAt(
      occurredAt,
    );
    await _requestManager.enqueue(
      attriaxBuildTrackEventRequest(
        appToken: _config.appToken,
        clientOccurredAt: occurredAt,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _contextManager.requireDeviceIdSource(),
        eventName: eventName,
        eventData: eventData,
        sessionId: currentSession?.id,
        sessionRelativeTimeMs: _sessionRelativeTimeMs(
          session: currentSession,
          occurredAt: occurredAt,
        ),
      ),
      flushImmediately: flushImmediately,
    );
  }

  Future<void> _queueUserUpdate({
    String? externalUserId,
    String? externalUserName,
    bool clearExternalUser = false,
    Map<String, Object?>? properties,
    List<String>? clearPropertyKeys,
    bool clearAllProperties = false,
  }) async {
    await _sessionManager.prepareTrackedSessionAt(_clock.now());
    await _requestManager.enqueue(
      attriaxBuildUserRequest(
        appToken: _config.appToken,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _contextManager.requireDeviceIdSource(),
        externalUserId: externalUserId,
        externalUserName: externalUserName,
        clearExternalUser: clearExternalUser,
        properties: properties,
        clearPropertyKeys: clearPropertyKeys,
        clearAllProperties: clearAllProperties,
      ),
    );
  }
}
