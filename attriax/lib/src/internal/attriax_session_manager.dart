import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter/widgets.dart';

import 'attriax_context_manager.dart';
import 'attriax_id_generator.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';
import 'attriax_request_manager.dart';
import 'attriax_runtime_settings_state.dart';
import 'attriax_session_lifecycle_manager.dart';

final class AttriaxSessionRestoreResult {
  const AttriaxSessionRestoreResult({
    required this.currentSession,
    required this.startedNewSession,
    this.replacedSession,
  });

  final AttriaxSessionSnapshot currentSession;
  final bool startedNewSession;
  final AttriaxSessionSnapshot? replacedSession;
}

// ignore: one_member_abstracts
abstract interface class AttriaxTrackedSessionPreparer {
  Future<AttriaxSessionSnapshot?> prepareTrackedSessionAt(DateTime occurredAt);
}

class AttriaxSessionManager implements AttriaxTrackedSessionPreparer {
  AttriaxSessionManager({
    required AttriaxConfig config,
    required AttriaxContextManager contextManager,
    required AttriaxPreferencesStore preferencesStore,
    required AttriaxLogger logger,
    required AttriaxRuntimeSettingsView settingsState,
    required AttriaxRequestManager requestManager,
    AttriaxClock? clock,
  }) : _config = config,
       _contextManager = contextManager,
       _preferencesStore = preferencesStore,
       _logger = logger,
       _clock = clock ?? const AttriaxSystemClock() {
    _lifecycleManager = AttriaxSessionLifecycleManager(
      config: config,
      sessionManager: this,
      clock: _clock,
      settingsState: settingsState,
      requestManager: requestManager,
    );
  }

  final AttriaxConfig _config;
  final AttriaxContextManager _contextManager;
  final AttriaxPreferencesStore _preferencesStore;
  final AttriaxLogger _logger;
  final AttriaxClock _clock;

  late final AttriaxSessionLifecycleManager _lifecycleManager;

  AttriaxSessionSnapshot? _currentSession;
  bool _trackingEnabled = false;

  AttriaxSessionSnapshot? get currentSession => _currentSession;
  AttriaxContextSnapshot? get context => _contextManager.snapshot;
  bool get isTrackingEnabled => _trackingEnabled;

  Future<AttriaxSessionRestoreResult?> init({required bool enabled}) async {
    _trackingEnabled = enabled;
    if (!enabled) {
      await clear();
      return null;
    }

    return restoreOrStart();
  }

  Future<AttriaxSessionRestoreResult> restoreOrStart() async {
    final context = _contextManager.requiredSnapshot;
    final deviceId = _contextManager.requiredDeviceId;
    final now = _clock.now();
    final storedSession = await _preferencesStore.readSessionSnapshot();
    final continuedSession = _shouldContinueSession(
      storedSession,
      deviceId: deviceId,
      context: context,
      now: now,
    );

    final session = continuedSession
        ? storedSession!.copyWith(lastActivityAt: now)
        : _buildSession(deviceId: deviceId, context: context, now: now);

    _currentSession = session;
    await _preferencesStore.setSessionSnapshot(session: session);

    _logger.verbose(
      continuedSession
          ? 'Restored Attriax session ${session.id}.'
          : 'Started Attriax session ${session.id}.',
    );

    return AttriaxSessionRestoreResult(
      currentSession: session,
      startedNewSession: !continuedSession,
      replacedSession: continuedSession ? null : storedSession,
    );
  }

  Future<AttriaxSessionRestoreResult> resumeOrStart({DateTime? at}) async {
    final context = _contextManager.requiredSnapshot;
    final deviceId = _contextManager.requiredDeviceId;
    final now = (at ?? _clock.now()).toUtc();
    final existingSession = _currentSession;
    final continuedSession = _shouldContinueSession(
      existingSession,
      deviceId: deviceId,
      context: context,
      now: now,
    );

    final session = continuedSession
        ? existingSession!.copyWith(lastActivityAt: now)
        : _buildSession(deviceId: deviceId, context: context, now: now);

    _currentSession = session;
    await _preferencesStore.setSessionSnapshot(session: session);

    _logger.verbose(
      continuedSession
          ? 'Resumed Attriax session ${session.id}.'
          : 'Started Attriax session ${session.id} after inactivity.',
    );

    return AttriaxSessionRestoreResult(
      currentSession: session,
      startedNewSession: !continuedSession,
      replacedSession: continuedSession ? null : existingSession,
    );
  }

  Future<AttriaxSessionSnapshot?> recordActivity({DateTime? at}) async {
    final session = _currentSession;
    if (session == null) {
      return null;
    }

    final activityAt = (at ?? _clock.now()).toUtc();
    if (activityAt.isBefore(session.lastActivityAt)) {
      return session;
    }

    final updatedSession = session.copyWith(lastActivityAt: activityAt);
    _currentSession = updatedSession;
    await _preferencesStore.setSessionSnapshot(session: updatedSession);
    return updatedSession;
  }

  Future<AttriaxSessionSnapshot?> end({DateTime? at}) async {
    final session = _currentSession;
    if (session == null) {
      return null;
    }

    final endedAt = (at ?? _clock.now()).toUtc();
    final finalSession = endedAt.isBefore(session.lastActivityAt)
        ? session
        : session.copyWith(lastActivityAt: endedAt);

    _currentSession = null;
    await _preferencesStore.setSessionSnapshot(session: null);
    return finalSession;
  }

  Future<void> clear() async {
    _currentSession = null;
    await _preferencesStore.setSessionSnapshot(session: null);
  }

  Future<void> reset() async {
    _trackingEnabled = false;
    await clear();
    _lifecycleManager.reset();
  }

  DateTime inferredEndAt(AttriaxSessionSnapshot session) =>
      session.lastActivityAt.add(_continuationWindowFor(session));

  String requireDeviceIdSource() => _contextManager.requireDeviceIdSource();

  void syncLifecycleState(AppLifecycleState? state) =>
      _lifecycleManager.syncLifecycleState(state);

  // ignore: use_setters_to_change_properties
  void seedRecoveredSessionEnd(AttriaxSessionSnapshot? session) =>
      _lifecycleManager.seedRecoveredSessionEnd(session);

  void activate() => _lifecycleManager.activate();

  void deactivate() => _lifecycleManager.deactivate();

  void dispose() => _lifecycleManager.dispose();

  void handleLifecycleState(AppLifecycleState state) =>
      _lifecycleManager.handleLifecycleState(state);

  @override
  Future<AttriaxSessionSnapshot?> prepareTrackedSessionAt(
    DateTime occurredAt,
  ) => _lifecycleManager.prepareTrackedSessionAt(occurredAt);

  AttriaxSessionSnapshot _buildSession({
    required String deviceId,
    required AttriaxContextSnapshot context,
    required DateTime now,
  }) => AttriaxSessionSnapshot(
    id: attriaxGenerateId(),
    deviceId: deviceId,
    platform: context.platform,
    locale: context.device.language,
    isFirstLaunch: context.isFirstLaunch,
    startedAt: now,
    lastActivityAt: now,
    heartbeatInterval: _heartbeatIntervalFor(context.isFirstLaunch),
    appVersion: context.app.version,
    appBuildNumber: context.app.buildNumber,
    appPackageName: context.app.packageName,
    sdkPackageVersion: context.sdk.packageVersion,
  );

  bool _shouldContinueSession(
    AttriaxSessionSnapshot? session, {
    required String deviceId,
    required AttriaxContextSnapshot context,
    required DateTime now,
  }) {
    if (session == null) {
      return false;
    }
    if (session.deviceId != deviceId) {
      return false;
    }
    if (session.platform != context.platform) {
      return false;
    }
    if (session.appPackageName != context.app.packageName) {
      return false;
    }
    if (session.appVersion != context.app.version) {
      return false;
    }
    if (session.appBuildNumber != context.app.buildNumber) {
      return false;
    }
    if (session.startedAt.isAfter(now)) {
      return false;
    }

    return now.difference(session.lastActivityAt) <=
        _continuationWindowFor(session);
  }

  Duration _continuationWindowFor(AttriaxSessionSnapshot session) =>
      Duration(milliseconds: session.heartbeatInterval.inMilliseconds * 2);

  Duration _heartbeatIntervalFor(bool isFirstLaunch) => isFirstLaunch
      ? _config.firstLaunchSessionHeartbeatInterval
      : _config.sessionHeartbeatInterval;
}
