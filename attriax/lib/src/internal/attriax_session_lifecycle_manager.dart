import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter/widgets.dart';

import 'attriax_api_models.dart';
import 'attriax_request_manager.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_session_manager.dart';

/// Owns session lifecycle telemetry, heartbeat scheduling, and lifecycle
/// transition handling for the runtime.
class AttriaxSessionLifecycleManager with WidgetsBindingObserver {
  AttriaxSessionLifecycleManager({
    required AttriaxConfig config,
    required AttriaxSessionManager sessionManager,
    required AttriaxClock clock,
    required AttriaxRuntimeSettingsView settingsState,
    required AttriaxRequestManager requestManager,
  }) : _config = config,
       _sessionManager = sessionManager,
       _clock = clock,
       _settingsState = settingsState,
       _requestManager = requestManager;

  final AttriaxConfig _config;
  final AttriaxSessionManager _sessionManager;
  final AttriaxClock _clock;
  final AttriaxRuntimeSettingsView _settingsState;
  final AttriaxRequestManager _requestManager;

  Timer? _heartbeatTimer;
  bool _isInBackground = false;
  bool _isObserverRegistered = false;
  AttriaxSessionSnapshot? _pendingRecoveredSessionEnd;

  AttriaxSessionSnapshot? get currentSession => _sessionManager.currentSession;

  void syncLifecycleState(AppLifecycleState? state) {
    _isInBackground = _isBackgroundLifecycleState(state);
  }

  // ignore: use_setters_to_change_properties
  void seedRecoveredSessionEnd(AttriaxSessionSnapshot? session) {
    _pendingRecoveredSessionEnd = session;
  }

  void activate() {
    _registerObserver();
    syncLifecycleState(WidgetsBinding.instance.lifecycleState);
    _restartHeartbeatTimer();
  }

  void deactivate() {
    _stopHeartbeatTimer();
    _unregisterObserver();
  }

  void dispose() {
    deactivate();
  }

  void reset() {
    deactivate();
    _isInBackground = false;
    _pendingRecoveredSessionEnd = null;
  }

  void handleLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_handleLifecycleResumed());
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        unawaited(_handleLifecyclePaused());
        break;
      case AppLifecycleState.detached:
        unawaited(_handleLifecycleDetached());
        break;
    }
  }

  Future<AttriaxSessionSnapshot?> prepareTrackedSessionAt(
    DateTime occurredAt,
  ) async {
    if (!_sessionManager.isTrackingEnabled) {
      return null;
    }

    final session =
        await _sessionManager.recordActivity(at: occurredAt) ??
        _sessionManager.currentSession;
    await _flushPendingRecoveredSessionEnd();
    return session;
  }

  bool _isBackgroundLifecycleState(AppLifecycleState? state) =>
      state == AppLifecycleState.paused ||
      state == AppLifecycleState.hidden ||
      state == AppLifecycleState.detached;

  void _restartHeartbeatTimer() {
    _stopHeartbeatTimer();

    final session = _sessionManager.currentSession;
    if (!_sessionManager.isTrackingEnabled ||
        !_settingsState.isEnabled ||
        _isInBackground ||
        session == null) {
      return;
    }

    _heartbeatTimer = Timer.periodic(session.heartbeatInterval, (_) {
      unawaited(_sendSessionHeartbeat());
    });
  }

  void _stopHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendSessionHeartbeat() async {
    if (!_sessionManager.isTrackingEnabled || !_settingsState.isEnabled) {
      return;
    }

    final occurredAt = _clock.now();
    final session = await _sessionManager.recordActivity(at: occurredAt);
    if (session == null) {
      return;
    }

    await _flushPendingRecoveredSessionEnd();
    await _enqueueSessionLifecycle(
      kind: AttriaxSessionLifecycleKind.heartbeat,
      session: session,
      occurredAt: occurredAt,
    );
  }

  Future<void> _handleLifecyclePaused() async {
    final wasInBackground = _isInBackground;
    _isInBackground = true;
    _stopHeartbeatTimer();
    if (wasInBackground ||
        !_sessionManager.isTrackingEnabled ||
        !_settingsState.isEnabled) {
      return;
    }

    final occurredAt = _clock.now();
    final session = await _sessionManager.recordActivity(at: occurredAt);
    if (session == null) {
      return;
    }

    await _flushPendingRecoveredSessionEnd();
    await _enqueueSessionLifecycle(
      kind: AttriaxSessionLifecycleKind.pause,
      session: session,
      occurredAt: occurredAt,
    );
  }

  Future<void> _handleLifecycleResumed() async {
    final wasInBackground = _isInBackground;
    _isInBackground = false;
    final context = _sessionManager.context;
    if (!_sessionManager.isTrackingEnabled ||
        !_settingsState.isEnabled ||
        context == null) {
      _restartHeartbeatTimer();
      return;
    }
    if (!wasInBackground) {
      _restartHeartbeatTimer();
      return;
    }

    final occurredAt = _clock.now();
    final sessionResult = await _sessionManager.resumeOrStart(at: occurredAt);

    if (sessionResult.replacedSession != null) {
      await _enqueueRecoveredSessionEnd(sessionResult.replacedSession!);
    }

    await _enqueueSessionLifecycle(
      kind: sessionResult.startedNewSession
          ? AttriaxSessionLifecycleKind.start
          : AttriaxSessionLifecycleKind.resume,
      session: sessionResult.currentSession,
      occurredAt: sessionResult.startedNewSession
          ? sessionResult.currentSession.startedAt
          : occurredAt,
    );

    _restartHeartbeatTimer();
  }

  Future<void> _handleLifecycleDetached() async {
    _isInBackground = true;
    _stopHeartbeatTimer();
    if (!_sessionManager.isTrackingEnabled || !_settingsState.isEnabled) {
      return;
    }

    final occurredAt = _clock.now();
    final session = await _sessionManager.end(at: occurredAt);
    if (session == null) {
      return;
    }

    await _enqueueSessionLifecycle(
      kind: AttriaxSessionLifecycleKind.end,
      session: session,
      occurredAt: occurredAt,
    );
  }

  Future<void> _enqueueRecoveredSessionEnd(
    AttriaxSessionSnapshot session,
  ) async {
    if (!_sessionManager.isTrackingEnabled) {
      return;
    }

    await _enqueueSessionLifecycle(
      kind: AttriaxSessionLifecycleKind.end,
      session: session,
      occurredAt: _sessionManager.inferredEndAt(session),
      metadata: const <String, Object?>{'recovered': true},
    );
  }

  Future<void> _flushPendingRecoveredSessionEnd() async {
    final pendingSession = _pendingRecoveredSessionEnd;
    if (!_sessionManager.isTrackingEnabled ||
        pendingSession == null ||
        !_settingsState.isEnabled) {
      return;
    }

    _pendingRecoveredSessionEnd = null;
    await _enqueueSessionLifecycle(
      kind: AttriaxSessionLifecycleKind.end,
      session: pendingSession,
      occurredAt: _sessionManager.inferredEndAt(pendingSession),
      metadata: const <String, Object?>{'recovered': true},
    );
  }

  Future<void> _enqueueSessionLifecycle({
    required AttriaxSessionLifecycleKind kind,
    required AttriaxSessionSnapshot session,
    required DateTime occurredAt,
    Map<String, Object?>? metadata,
  }) async {
    if (!_sessionManager.isTrackingEnabled || !_settingsState.isEnabled) {
      return;
    }

    await _requestManager.enqueue(
      attriaxBuildTrackSessionRequest(
        appToken: _config.appToken,
        deviceIdSource: _sessionManager.requireDeviceIdSource(),
        session: session,
        kind: kind,
        occurredAt: occurredAt,
        metadata: metadata,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    handleLifecycleState(state);
  }

  void _registerObserver() {
    if (_isObserverRegistered) {
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    _isObserverRegistered = true;
  }

  void _unregisterObserver() {
    if (!_isObserverRegistered) {
      return;
    }

    WidgetsBinding.instance.removeObserver(this);
    _isObserverRegistered = false;
  }
}
