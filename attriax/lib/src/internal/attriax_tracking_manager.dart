import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import '../attriax_ad_event_type.dart';
import '../attriax_analytics_keys.dart';
import '../attriax_notification_event.dart';
import 'attriax_api_models.dart';
import 'attriax_consent_manager.dart';
import 'attriax_context_manager.dart';
import 'attriax_logger.dart';
import 'attriax_page_title_stub.dart'
    if (dart.library.js_interop) 'attriax_page_title_web.dart'
    as page_title;
import 'attriax_request_manager.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_skan_manager.dart';
import 'attriax_session_manager.dart';
import 'attriax_user_properties.dart';

/// Owns tracking request construction and enqueueing for runtime APIs.
class AttriaxTrackingManager {
  AttriaxTrackingManager({
    required AttriaxConfig config,
    required AttriaxLogger logger,
    required AttriaxClock clock,
    required AttriaxTrackingContext contextManager,
    required AttriaxConsentReadView consentState,
    required AttriaxRuntimeSettingsView settingsState,
    required AttriaxRequestManager requestManager,
    required AttriaxTrackedSessionPreparer sessionManager,
    AttriaxSkanManager? skanManager,
    String? Function()? documentTitleProvider,
  }) : _config = config,
       _logger = logger,
       _clock = clock,
       _contextManager = contextManager,
       _consentState = consentState,
       _settingsState = settingsState,
       _requestManager = requestManager,
       _sessionManager = sessionManager,
       _skanManager = skanManager,
       _documentTitleProvider =
           documentTitleProvider ?? page_title.currentAttriaxDocumentTitle;

  final AttriaxConfig _config;
  final AttriaxLogger _logger;
  final AttriaxClock _clock;
  final AttriaxTrackingContext _contextManager;
  final AttriaxConsentReadView _consentState;
  final AttriaxRuntimeSettingsView _settingsState;
  final AttriaxRequestManager _requestManager;
  final AttriaxTrackedSessionPreparer _sessionManager;
  final AttriaxSkanManager? _skanManager;
  final String? Function() _documentTitleProvider;

  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) async {
    if (!_settingsState.isEnabled || !_settingsState.areEventsEnabled) {
      _logger.verbose(
        'Ignoring recordEvent("$eventName") because SDK or events are disabled.',
      );
      return;
    }

    if (_isAdEventName(eventName)) {
      if (!_trackingDecisionFor(AttriaxTrackingSignal.adEvents).capture) {
        _logger.verbose(
          'Ignoring recordEvent("$eventName") because GDPR ad-events consent is not granted.',
        );
        return;
      }
    } else if (!_trackingDecisionFor(AttriaxTrackingSignal.analytics).capture) {
      _logger.verbose(
        'Ignoring recordEvent("$eventName") because GDPR analytics consent is not granted.',
      );
      return;
    }

    await _queueEvent(
      eventName,
      eventData: eventData,
      flushImmediately: _shouldFlushEventImmediately(
        flushImmediately: flushImmediately,
      ),
    );

    await _skanManager?.handleTrackedEvent(eventName, eventData: eventData);
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
    if (!_settingsState.isEnabled || !_settingsState.areEventsEnabled) {
      _logger.verbose(
        'Ignoring recordNotification(${type.value}) because SDK or events are disabled.',
      );
      return;
    }

    final decision = _trackingDecisionFor(AttriaxTrackingSignal.analytics);
    if (!decision.capture) {
      _logger.verbose(
        'Ignoring recordNotification(${type.value}) because GDPR analytics consent is not granted.',
      );
      return;
    }

    final normalizedNotificationId = notificationId.trim();
    if (normalizedNotificationId.isEmpty) {
      throw ArgumentError.value(
        notificationId,
        'notificationId',
        'notificationId must not be empty.',
      );
    }

    final occurredAt = _clock.now();
    final currentSession = await _sessionManager.prepareTrackedSessionAt(
      occurredAt,
    );

    await _requestManager.enqueue(
      attriaxBuildTrackNotificationRequest(
        projectToken: _config.projectToken,
        type: type,
        notificationId: normalizedNotificationId,
        platform: _contextManager.requiredSnapshot.platform,
        deviceId: decision.attachDeviceIdentity
            ? _contextManager.requiredDeviceId
            : null,
        deviceIdSource: decision.attachDeviceIdentity
            ? _contextManager.requireDeviceIdSource()
            : null,
        linkId: _trimOrNull(linkId),
        campaignId: _trimOrNull(campaignId),
        title: _trimOrNull(title),
        source: source,
        sessionId: currentSession?.id,
        clientOccurredAt: occurredAt,
        metadata: metadata,
      ),
      flushImmediately: _shouldFlushEventImmediately(
        flushImmediately: flushImmediately,
      ),
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
    if (!_trackingDecisionFor(AttriaxTrackingSignal.analytics).capture) {
      _logger.verbose(
        'Ignoring recordPageView("$pageName") because GDPR analytics consent is not granted.',
      );
      return;
    }

    final normalizedPageName = pageName.trim();
    if (normalizedPageName.isEmpty) {
      throw ArgumentError.value(
        pageName,
        'pageName',
        'pageName must not be empty.',
      );
    }

    final normalizedPageClass = _trimOrNull(pageClass);
    final normalizedPageTitle =
        _trimOrNull(pageTitle) ?? _trimOrNull(_documentTitleProvider());
    final normalizedPreviousPageName = _trimOrNull(previousPageName);

    final pageViewEventData = <String, Object?>{
      ...?parameters,
      AttriaxAnalyticsParamKeys.pageName: normalizedPageName,
      AttriaxAnalyticsParamKeys.pageClass: ?normalizedPageClass,
      AttriaxAnalyticsParamKeys.pageTitle: ?normalizedPageTitle,
      AttriaxAnalyticsParamKeys.previousPageName: ?normalizedPreviousPageName,
      AttriaxAnalyticsParamKeys.source: source,
    };

    await _queueEvent(
      AttriaxAnalyticsEventKeys.pageView,
      eventData: pageViewEventData,
      flushImmediately: _shouldFlushEventImmediately(
        flushImmediately: flushImmediately,
      ),
    );

    await _skanManager?.handleTrackedEvent(
      AttriaxAnalyticsEventKeys.pageView,
      eventData: pageViewEventData,
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

    final decision = _trackingDecisionFor(AttriaxTrackingSignal.analytics);
    if (!decision.capture) {
      _logger.verbose(
        'Ignoring recordError() because GDPR analytics consent is not granted.',
      );
      return;
    }

    final occurredAt = _clock.now();
    final currentSession = await _sessionManager.prepareTrackedSessionAt(
      occurredAt,
    );
    await _requestManager.enqueue(
      attriaxBuildTrackCrashRequest(
        appToken: _config.projectToken,
        clientOccurredAt: occurredAt,
        context: _contextManager.requiredSnapshot,
        deviceId: decision.attachDeviceIdentity
            ? _contextManager.requiredDeviceId
            : null,
        deviceIdSource: decision.attachDeviceIdentity
            ? _contextManager.requireDeviceIdSource()
            : null,
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

    if (!_trackingDecisionFor(AttriaxTrackingSignal.attribution).capture) {
      _logger.verbose(
        'Ignoring setUser("$userId") because GDPR attribution consent is not granted.',
      );
      return;
    }

    await _sessionManager.prepareTrackedSessionAt(_clock.now());
    await _requestManager.enqueue(
      attriaxBuildUserRequest(
        appToken: _config.projectToken,
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

    if (!_trackingDecisionFor(AttriaxTrackingSignal.attribution).capture) {
      _logger.verbose(
        'Ignoring setUserProperties() because GDPR attribution consent is not granted.',
      );
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

    if (!_trackingDecisionFor(AttriaxTrackingSignal.attribution).capture) {
      _logger.verbose(
        'Ignoring clearUserProperties() because GDPR attribution consent is not granted.',
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

  bool _isAdEventName(String eventName) =>
      eventName == AttriaxAnalyticsEventKeys.adRevenue ||
      AttriaxAdEventType.values.any((value) => value.eventName == eventName);

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
    required bool flushImmediately,
    Map<String, Object?>? eventData,
  }) async {
    final occurredAt = _clock.now();
    final currentSession = await _sessionManager.prepareTrackedSessionAt(
      occurredAt,
    );
    final decision = _trackingDecisionFor(
      _isAdEventName(eventName)
          ? AttriaxTrackingSignal.adEvents
          : AttriaxTrackingSignal.analytics,
    );
    await _requestManager.enqueue(
      attriaxBuildTrackEventRequest(
        appToken: _config.projectToken,
        clientOccurredAt: occurredAt,
        deviceId: decision.attachDeviceIdentity
            ? _contextManager.requiredDeviceId
            : null,
        deviceIdSource: decision.attachDeviceIdentity
            ? _contextManager.requireDeviceIdSource()
            : null,
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

  AttriaxTrackingDecision _trackingDecisionFor(AttriaxTrackingSignal signal) =>
      _consentState.trackingDecisionFor(signal);

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
        appToken: _config.projectToken,
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
