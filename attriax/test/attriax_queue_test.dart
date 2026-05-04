import 'package:attriax/src/internal/attriax_api_models.dart';
import 'package:attriax/src/internal/attriax_queue.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxQueuedRequest', () {
    test('round-trips crash report requests through queue JSON', () {
      final queuedRequest = AttriaxQueuedRequest(
        id: 'req_1',
        createdAt: DateTime.utc(2026, 5, 4, 10, 0, 0),
        request: AttriaxTrackCrashRequest(
          AttriaxCrashReportPayload(
            appToken: 'ax_test_token',
            deviceId: 'device_123',
            deviceIdSource: 'android_ssaid',
            source: 'flutter_error',
            clientOccurredAt: DateTime.utc(2026, 5, 4, 9, 59, 59),
            platform: AttriaxPlatformType.android,
            isFatal: true,
            exceptionType: 'StateError',
            message: 'Bad state: boom',
            stackTrace: 'stack line',
            isFirstLaunch: false,
            reason: 'Widget build failed',
            sessionId: 'session_1',
            sessionRelativeTimeMs: 1234,
            locale: 'en-US',
            appVersion: '1.0.0',
            appBuildNumber: '1',
            appPackageName: 'com.attriax.test',
            sdkApiVersion: 'v1',
            sdkPackageVersion: '1.2.3',
            metadata: <String, Object?>{'route': '/checkout'},
          ),
        ),
      );

      final restored = AttriaxQueuedRequest.fromJson(queuedRequest.toJson());

      expect(restored.request, isA<AttriaxTrackCrashRequest>());
      final body = restored.request.toQueueBody();
      expect(body['source'], 'flutter_error');
      expect(body['isFatal'], isTrue);
      expect(body['exceptionType'], 'StateError');
      expect(body['sessionId'], 'session_1');
      expect(body['metadata'], <String, Object?>{'route': '/checkout'});
    });
  });
}
