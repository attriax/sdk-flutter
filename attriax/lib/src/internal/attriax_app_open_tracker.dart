import 'dart:async';

import 'package:attriax_platform_interface/attriax_platform_interface.dart';

import 'attriax_api_models.dart';
import 'attriax_event_hub.dart';
import 'attriax_logger.dart';
import 'attriax_synchronizer.dart';

/// Schedules and tracks the one-time app-open request for the current session.
///
/// A second call to [schedule] is a no-op, ensuring the request is sent at
/// most once per runtime instance.
class AttriaxAppOpenTracker {
  bool _didSchedule = false;
  Completer<AttriaxAppOpenResult?>? _completer;
  AttriaxAppOpenResult? _lastResult;

  bool get didSchedule => _didSchedule;
  AttriaxAppOpenResult? get lastResult => _lastResult;

  /// Queues the app-open request. Subsequent calls are silently ignored.
  Future<void> schedule({
    required AttriaxConfig config,
    required Future<AttriaxContextSnapshot> contextFuture,
    required String deviceIdSource,
    required AttriaxSynchronizer synchronizer,
    required AttriaxEventHub eventHub,
    required AttriaxLogger logger,
  }) async {
    if (_didSchedule) {
      return;
    }
    _didSchedule = true;
    _completer = Completer<AttriaxAppOpenResult?>();

    late final AttriaxContextSnapshot context;
    try {
      context = await contextFuture;
    } catch (error, stackTrace) {
      logger.error(
        'App-open request could not start because context resolution failed.',
        error: error,
        stackTrace: stackTrace,
      );
      _completeError(error, stackTrace: stackTrace);
      return;
    }

    await synchronizer.enqueue(
      attriaxBuildOpenRequest(
        config: config,
        context: context,
        deviceIdSource: deviceIdSource,
      ),
      onSuccess: (response) {
        if (response is! AttriaxOpenApiResponse) {
          _completeError(StateError('Unexpected response type for app open.'));
          logger.error('Unexpected response type for app-open request.');
          return;
        }

        final result = response.result;
        _completeSuccess(result);
        _emitDeferredDeepLink(result, eventHub: eventHub);
      },
      onError: (error, stackTrace) {
        logger.error(
          'App-open request failed.',
          error: error,
          stackTrace: stackTrace,
        );
        _completeError(error, stackTrace: stackTrace);
      },
    );
  }

  /// Returns the [AttriaxAppOpenResult] as soon as it arrives.
  ///
  /// Returns `null` immediately if no app-open was scheduled or if the result
  /// is already known. Propagates any request error to the caller.
  Future<AttriaxAppOpenResult?> waitForResult() {
    if (_lastResult != null) {
      return Future.value(_lastResult);
    }
    if (_completer == null) {
      return Future<AttriaxAppOpenResult?>.value();
    }
    return _completer!.future;
  }

  Future<void> dispose() async {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }
  }

  void _completeSuccess(AttriaxAppOpenResult result) {
    _lastResult = result;
    if (!_completer!.isCompleted) {
      _completer!.complete(result);
    }
  }

  void _completeError(Object error, {StackTrace? stackTrace}) {
    if (!_completer!.isCompleted) {
      _completer!.completeError(error, stackTrace);
    }
  }

  void _emitDeferredDeepLink(
    AttriaxAppOpenResult result, {
    required AttriaxEventHub eventHub,
  }) {
    if (result.deepLink == null) {
      return;
    }

    eventHub.emitResolvedDeepLink(
      resolution: AttriaxDeepLinkResolution(
        deepLink: result.deepLink!,
        isFirstLaunch: result.isFirstLaunch,
        isDeferred: true,
        occurredAt: result.acceptedAt ?? DateTime.now().toUtc(),
      ),
    );
  }
}
