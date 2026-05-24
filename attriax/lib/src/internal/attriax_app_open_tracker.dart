import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_api_models.dart';
import 'attriax_logger.dart';
import 'attriax_request_manager.dart';

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
    required AttriaxContextSnapshot context,
    required AttriaxInstallReferrerContext platformInstallReferrerContext,
    String? installReferrerOverride,
    Map<String, Object?> deviceMetadataOverrides = const <String, Object?>{},
    required String deviceIdSource,
    required AttriaxSessionSnapshot? session,
    required AttriaxRequestManager requestManager,
    required AttriaxLogger logger,
  }) async {
    if (_didSchedule) {
      return;
    }
    _didSchedule = true;
    _completer = Completer<AttriaxAppOpenResult?>();

    await requestManager.enqueue(
      attriaxBuildOpenRequest(
        config: config,
        context: context,
        deviceIdSource: deviceIdSource,
        platformInstallReferrerContext: platformInstallReferrerContext,
        installReferrerOverride: installReferrerOverride,
        deviceMetadataOverrides: deviceMetadataOverrides,
        sessionId: session?.id,
        sessionStartedAt: session?.startedAt,
      ),
      onSuccess: (response) {
        if (response is! AttriaxOpenApiResponse) {
          _completeError(StateError('Unexpected response type for app open.'));
          logger.error('Unexpected response type for app-open request.');
          return;
        }

        final result = response.result;
        _completeSuccess(result);
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

  void reset() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }

    _didSchedule = false;
    _completer = null;
    _lastResult = null;
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
}
