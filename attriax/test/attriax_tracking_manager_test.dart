import 'package:attriax/src/attriax_clock.dart';
import 'package:attriax/src/internal/attriax_api_models.dart';
import 'package:attriax/src/internal/attriax_logger.dart';
import 'package:attriax/src/internal/attriax_request_manager.dart';
import 'package:attriax/src/internal/attriax_tracking_manager.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxTrackingManager', () {
    test('recordEvent enqueues session-aware event requests', () async {
      int prepareSessionCalls = 0;
      final occurredAt = DateTime.utc(2026, 5, 3, 12, 0, 7);
      final requestManager = _RecordingRequestManager();
      final session = AttriaxSessionSnapshot(
        id: 'session_1',
        deviceId: 'device_1',
        platform: AttriaxPlatformType.android,
        locale: 'en-US',
        isFirstLaunch: true,
        startedAt: DateTime.utc(2026, 5, 3, 12, 0, 0),
        lastActivityAt: DateTime.utc(2026, 5, 3, 12, 0, 7),
        heartbeatInterval: const Duration(seconds: 5),
        appVersion: '1.0.0',
        appBuildNumber: '1',
        appPackageName: 'com.attriax.test',
        sdkPackageVersion: '1.0.0',
      );
      final manager = AttriaxTrackingManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: AttriaxMutableClock(occurredAt),
        deviceIdProvider: () => 'device_1',
        deviceIdSourceProvider: () => 'android_ssaid',
        isEnabled: () => true,
        areEventsEnabled: () => true,
        requestManager: requestManager,
        prepareSession: (time) async {
          prepareSessionCalls += 1;
          expect(time, occurredAt);
          return session;
        },
      );

      await manager.recordEvent(
        'purchase',
        eventData: const <String, Object?>{'value': 42},
      );

      expect(prepareSessionCalls, 1);
      expect(requestManager.lastRequest, isA<AttriaxTrackEventRequest>());
      final body = requestManager.lastRequest!.toQueueBody();
      expect(body['eventName'], 'purchase');
      expect(body['sessionId'], 'session_1');
      expect(body['sessionRelativeTimeMs'], 7000);
      expect(body['clientOccurredAt'], occurredAt.toIso8601String());
    });

    test(
      'recordPageView normalizes page metadata into an event payload',
      () async {
        final requestManager = _RecordingRequestManager();
        final manager = AttriaxTrackingManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          logger: AttriaxLogger(enableDebugLogs: false),
          clock: AttriaxMutableClock(DateTime.utc(2026, 5, 3, 12, 0, 7)),
          deviceIdProvider: () => 'device_1',
          deviceIdSourceProvider: () => 'android_ssaid',
          isEnabled: () => true,
          areEventsEnabled: () => true,
          requestManager: requestManager,
          prepareSession: (_) async => null,
        );

        await manager.recordPageView(
          ' Checkout ',
          pageClass: ' CheckoutScreen ',
          pageTitle: ' Checkout ',
          previousPageName: ' Cart ',
          parameters: const <String, Object?>{'step': 2},
        );

        final body = requestManager.lastRequest!.toQueueBody();
        final eventData = body['eventData'] as Map<String, Object?>;
        expect(body['eventName'], 'page_view');
        expect(eventData['pageName'], 'Checkout');
        expect(eventData['pageClass'], 'CheckoutScreen');
        expect(eventData['pageTitle'], 'Checkout');
        expect(eventData['previousPageName'], 'Cart');
        expect(eventData['source'], 'manual');
        expect(eventData['step'], 2);
      },
    );

    test('setUser skips request enqueueing while disabled', () async {
      int prepareSessionCalls = 0;
      final requestManager = _RecordingRequestManager();
      final manager = AttriaxTrackingManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: AttriaxMutableClock(DateTime.utc(2026, 5, 3, 12, 0, 7)),
        deviceIdProvider: () => 'device_1',
        deviceIdSourceProvider: () => 'android_ssaid',
        isEnabled: () => false,
        areEventsEnabled: () => true,
        requestManager: requestManager,
        prepareSession: (_) async {
          prepareSessionCalls += 1;
          return null;
        },
      );

      await manager.setUser('user_1', userName: 'User One');

      expect(requestManager.enqueueCalls, 0);
      expect(prepareSessionCalls, 0);
    });
  });
}

class _RecordingRequestManager extends AttriaxRequestManager {
  int enqueueCalls = 0;
  AttriaxApiRequest? lastRequest;

  @override
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
  }) async {
    enqueueCalls += 1;
    lastRequest = request;
  }
}
