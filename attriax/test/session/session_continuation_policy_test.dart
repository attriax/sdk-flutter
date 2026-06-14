import 'package:attriax_flutter/src/internal/session/attriax_session_continuation_policy.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AttriaxSessionSnapshot sessionWithHeartbeat(Duration heartbeatInterval) {
    final now = DateTime.utc(2026, 5, 3, 12);
    return AttriaxSessionSnapshot(
      id: 'session_1',
      deviceId: 'device_1',
      platform: AttriaxPlatformType.android,
      locale: 'en-US',
      isFirstLaunch: false,
      startedAt: now,
      lastActivityAt: now,
      heartbeatInterval: heartbeatInterval,
      appVersion: '1.0.0',
      appBuildNumber: '1',
      appPackageName: 'com.attriax.test',
      sdkPackageVersion: attriaxSdkPackageVersion,
    );
  }

  group('attriaxSessionContinuationWindow', () {
    test('uses 2x heartbeat within the floor/cap bounds', () {
      expect(
        attriaxSessionContinuationWindow(
          sessionWithHeartbeat(const Duration(minutes: 5)),
        ),
        const Duration(minutes: 10),
      );
    });

    test('floors tiny heartbeat intervals so brief backgrounds do not collapse '
        'attribution-sensitive sessions', () {
      expect(
        attriaxSessionContinuationWindow(
          sessionWithHeartbeat(const Duration(seconds: 1)),
        ),
        attriaxMinSessionContinuationWindow,
      );
    });

    test('leaves the 30s first-launch heartbeat default untouched', () {
      expect(
        attriaxSessionContinuationWindow(
          sessionWithHeartbeat(const Duration(seconds: 30)),
        ),
        const Duration(seconds: 60),
      );
    });

    test('caps very large heartbeat intervals', () {
      expect(
        attriaxSessionContinuationWindow(
          sessionWithHeartbeat(const Duration(hours: 1)),
        ),
        attriaxMaxSessionContinuationWindow,
      );
    });
  });
}
