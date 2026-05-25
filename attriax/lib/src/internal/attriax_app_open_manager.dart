import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_app_open_monitor.dart';
import 'attriax_app_open_tracker.dart';
import 'attriax_context_manager.dart';
import 'attriax_logger.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_request_manager.dart';
import 'attriax_session_manager.dart';

/// Owns app-open scheduling, result access, and app-open side effects.
class AttriaxAppOpenManager implements AttriaxAppOpenMonitor {
  AttriaxAppOpenManager({
    required AttriaxConfig config,
    required AttriaxContextManager contextManager,
    required AttriaxPlatformInstallReferrerManager
    platformInstallReferrerManager,
    required AttriaxSessionManager sessionManager,
    required AttriaxRequestManager requestManager,
    required AttriaxLogger logger,
    AttriaxAppOpenTracker? tracker,
  }) : _config = config,
       _contextManager = contextManager,
       _platformInstallReferrerManager = platformInstallReferrerManager,
       _sessionManager = sessionManager,
       _requestManager = requestManager,
       _logger = logger,
       _tracker = tracker ?? AttriaxAppOpenTracker();

  final AttriaxConfig _config;
  final AttriaxContextManager _contextManager;
  final AttriaxPlatformInstallReferrerManager _platformInstallReferrerManager;
  final AttriaxSessionManager _sessionManager;
  final AttriaxRequestManager _requestManager;
  final AttriaxLogger _logger;
  final AttriaxAppOpenTracker _tracker;
  Completer<void>? _scheduledCompleter;
  bool _isResultObservationScheduled = false;
  bool _shouldGateRequestsOnSuccessfulAppOpen = true;

  bool get didSchedule => _tracker.didSchedule;
  @override
  bool get hasSuccessfulResult => _tracker.lastResult != null;
  @override
  bool get shouldGateRequestsOnSuccessfulAppOpen =>
      _shouldGateRequestsOnSuccessfulAppOpen;
  AttriaxAppOpenResult? get lastResult => _tracker.lastResult;

  // ignore: use_setters_to_change_properties
  void setDispatchGateEnabled({required bool enabled}) {
    _shouldGateRequestsOnSuccessfulAppOpen = enabled;
  }

  Future<void> schedule({
    String? installReferrerOverride,
    Map<String, Object?> deviceMetadataOverrides = const <String, Object?>{},
    Future<void> Function(AttriaxAppOpenResult? result)? onCompleted,
  }) async {
    final context = await _contextManager.ensureResolvedForAppOpen();
    late final AttriaxInstallReferrerContext platformInstallReferrerContext;
    try {
      platformInstallReferrerContext = await _platformInstallReferrerManager
          .load();
    } catch (error, stackTrace) {
      _logger.error(
        'App-open request could not start because context resolution failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    if (!_requestManager.isBound) {
      return;
    }

    await _tracker.schedule(
      config: _config,
      context: context,
      platformInstallReferrerContext: platformInstallReferrerContext,
      installReferrerOverride: installReferrerOverride,
      deviceMetadataOverrides: deviceMetadataOverrides,
      deviceIdSource: _contextManager.requireDeviceIdSource(),
      session: _sessionManager.currentSession,
      requestManager: _requestManager,
      logger: _logger,
    );
    _completeScheduled();

    if (!_isResultObservationScheduled && onCompleted != null) {
      _isResultObservationScheduled = true;
      unawaited(_observeResult(onCompleted: onCompleted));
    }
  }

  Future<AttriaxAppOpenResult?> waitForResult() => _tracker.waitForResult();

  @override
  Future<AttriaxAppOpenResult?> waitForTrackedResult() async {
    if (!_tracker.didSchedule) {
      final scheduledCompleter = _scheduledCompleter ??= Completer<void>();
      await scheduledCompleter.future;
    }

    if (!_tracker.didSchedule) {
      return null;
    }

    return _tracker.waitForResult();
  }

  Future<AttriaxAppOpenResult?> waitForScheduledResult() =>
      waitForTrackedResult();

  Future<void> reset() async {
    _completeScheduled();
    _scheduledCompleter = null;
    _isResultObservationScheduled = false;
    _tracker.reset();
  }

  Future<void> dispose() async {
    _completeScheduled();
    await _tracker.dispose();
  }

  Future<void> _observeResult({
    Future<void> Function(AttriaxAppOpenResult? result)? onCompleted,
  }) async {
    final result = await _tracker.waitForResult();
    if (onCompleted != null) {
      await onCompleted(result);
    }
  }

  void _completeScheduled() {
    final scheduledCompleter = _scheduledCompleter;
    if (scheduledCompleter == null || scheduledCompleter.isCompleted) {
      return;
    }

    scheduledCompleter.complete();
  }
}
