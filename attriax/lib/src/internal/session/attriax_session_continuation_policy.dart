import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

bool shouldContinueAttriaxSession(
  AttriaxSessionSnapshot? session, {
  required String? deviceId,
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
      attriaxSessionContinuationWindow(session);
}

/// Lower bound for the continuation window. A small heartbeat interval (the
/// 30s first-launch default, or a misconfigured tiny value) must not let a
/// brief background collapse the most attribution-sensitive sessions.
const Duration attriaxMinSessionContinuationWindow = Duration(seconds: 60);

/// Upper bound so an unusually large heartbeat interval cannot keep a session
/// continuable for an unbounded time after the app was backgrounded.
const Duration attriaxMaxSessionContinuationWindow = Duration(minutes: 30);

Duration attriaxSessionContinuationWindow(AttriaxSessionSnapshot session) {
  final raw = Duration(
    milliseconds: session.heartbeatInterval.inMilliseconds * 2,
  );
  if (raw < attriaxMinSessionContinuationWindow) {
    return attriaxMinSessionContinuationWindow;
  }
  if (raw > attriaxMaxSessionContinuationWindow) {
    return attriaxMaxSessionContinuationWindow;
  }
  return raw;
}
