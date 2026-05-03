import 'package:attriax_platform_interface/attriax_platform_interface.dart';

import '../attriax_clock.dart';
import 'attriax_api_models.dart';
import 'attriax_logger.dart';
import 'attriax_request_manager.dart';

typedef AttriaxTrackingSessionPreparer =
    Future<AttriaxSessionSnapshot?> Function(DateTime occurredAt);

/// Owns tracking request construction and enqueueing for runtime APIs.
class AttriaxTrackingManager {
  AttriaxTrackingManager({
    required AttriaxConfig config,
    required AttriaxLogger logger,
    required AttriaxClock clock,
    required String Function() deviceIdProvider,
    required String Function() deviceIdSourceProvider,
    required bool Function() isEnabled,
    required bool Function() areEventsEnabled,
    required AttriaxRequestManager requestManager,
    required AttriaxTrackingSessionPreparer prepareSession,
  }) : _config = config,
       _logger = logger,
       _clock = clock,
       _deviceIdProvider = deviceIdProvider,
       _deviceIdSourceProvider = deviceIdSourceProvider,
       _isEnabled = isEnabled,
       _areEventsEnabled = areEventsEnabled,
       _requestManager = requestManager,
       _prepareSession = prepareSession;

  final AttriaxConfig _config;
  final AttriaxLogger _logger;
  final AttriaxClock _clock;
  final String Function() _deviceIdProvider;
  final String Function() _deviceIdSourceProvider;
  final bool Function() _isEnabled;
  final bool Function() _areEventsEnabled;
  final AttriaxRequestManager _requestManager;
  final AttriaxTrackingSessionPreparer _prepareSession;

  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
  }) async {
    if (!_isEnabled() || !_areEventsEnabled()) {
      _logger.verbose(
        'Ignoring recordEvent("$eventName") because SDK or events are disabled.',
      );
      return;
    }

    final occurredAt = _clock.now();
    final currentSession = await _prepareSession(occurredAt);
    await _requestManager.enqueue(
      attriaxBuildTrackEventRequest(
        appToken: _config.appToken,
        clientOccurredAt: occurredAt,
        deviceId: _deviceIdProvider(),
        deviceIdSource: _deviceIdSourceProvider(),
        eventName: eventName,
        eventData: eventData,
        sessionId: currentSession?.id,
        sessionRelativeTimeMs: _sessionRelativeTimeMs(
          session: currentSession,
          occurredAt: occurredAt,
        ),
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

    await recordEvent(
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
    );
  }

  Future<void> setUser(
    String? userId, {
    String? userName,
  }) async {
    if (!_isEnabled()) {
      _logger.verbose(
        'Ignoring setUser("$userId") because SDK is disabled.',
      );
      return;
    }

    await _prepareSession(_clock.now());
    await _requestManager.enqueue(
      attriaxBuildIdentifyRequest(
        appToken: _config.appToken,
        deviceId: _deviceIdProvider(),
        deviceIdSource: _deviceIdSourceProvider(),
        userId: userId,
        userName: userName,
      ),
    );
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
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
}
