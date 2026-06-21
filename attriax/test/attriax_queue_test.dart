import 'dart:convert';

import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_queue.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxQueuedRequest', () {
    test('round-trips crash report requests through queue JSON', () {
      final queuedRequest = AttriaxQueuedRequest(
        id: 'req_1',
        createdAt: DateTime.utc(2026, 5, 4, 10),
        request: AttriaxTrackCrashRequest(
          AttriaxCrashReportPayload(
            projectToken: 'ax_test_token',
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

    test(
      'records invalid queue payload corruption and clears the payload',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AttriaxPreferencesStore.queueStorageKey: '{"broken":true}',
        });
        final prefs = await SharedPreferences.getInstance();
        final queueManager = AttriaxQueueManager(
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          maxQueueSize: 10,
        );

        final restored = await queueManager.readAll();
        final diagnostics = await queueManager.readDiagnostics();

        expect(restored, isEmpty);
        expect(
          prefs.getString(AttriaxPreferencesStore.queueStorageKey),
          isNull,
        );
        expect(diagnostics.corruptedPayloadCount, 1);
        expect(diagnostics.lastCorruptionReason, 'invalid_queue_payload');
        expect(diagnostics.lastCorruptionAt, isNotNull);
        expect(diagnostics.lastCorruptQueuePayload, '{"broken":true}');
      },
    );

    test(
      'drops malformed entries, keeps valid ones, and records diagnostics',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final validRequest = AttriaxQueuedRequest(
          id: 'req_valid',
          createdAt: DateTime.utc(2026, 5, 4, 10),
          request: attriaxBuildTrackEventRequest(
            projectToken: 'ax_test_token',
            deviceId: 'device_123',
            deviceIdSource: 'android_ssaid',
            eventName: 'purchase',
          ),
        );
        await prefs.setString(
          AttriaxPreferencesStore.queueStorageKey,
          jsonEncode(<Object?>[
            validRequest.toJson(),
            <String, Object?>{'id': 'broken'},
          ]),
        );
        final queueManager = AttriaxQueueManager(
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          maxQueueSize: 10,
        );

        final restored = await queueManager.readAll();
        final diagnostics = await queueManager.readDiagnostics();

        expect(restored, hasLength(1));
        expect(restored.single.id, 'req_valid');
        expect(diagnostics.corruptedPayloadCount, 1);
        expect(diagnostics.lastCorruptionReason, 'invalid_queue_entry');
        expect(diagnostics.lastCorruptedEntryCount, 1);
        expect(diagnostics.lastCorruptQueuePayload, isNotNull);
      },
    );

    test('readStatus does not repair malformed queue payloads', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AttriaxPreferencesStore.queueStorageKey: '{"broken":true}',
      });
      final prefs = await SharedPreferences.getInstance();
      final queueManager = AttriaxQueueManager(
        preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
        maxQueueSize: 10,
      );

      final status = await queueManager.readStatus();

      expect(status.pendingRequestCount, 0);
      expect(
        prefs.getString(AttriaxPreferencesStore.queueStorageKey),
        '{"broken":true}',
      );
    });

    test(
      'preserves unreadable diagnostics payloads for later inspection',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AttriaxPreferencesStore.queueDiagnosticsStorageKey: '{"broken":',
        });
        final prefs = await SharedPreferences.getInstance();
        final queueManager = AttriaxQueueManager(
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          maxQueueSize: 10,
        );

        final diagnostics = await queueManager.readDiagnostics();
        final restoredDiagnostics = await queueManager.readDiagnostics();

        expect(diagnostics.corruptedDiagnosticsPayloadCount, 1);
        expect(diagnostics.lastDiagnosticsCorruptionAt, isNotNull);
        expect(diagnostics.lastCorruptDiagnosticsPayload, '{"broken":');
        expect(restoredDiagnostics.corruptedDiagnosticsPayloadCount, 1);
        expect(restoredDiagnostics.lastCorruptDiagnosticsPayload, '{"broken":');
      },
    );

    test(
      'tracks eviction diagnostics and next retry in queue status',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final queueManager = AttriaxQueueManager(
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          maxQueueSize: 2,
        );
        final retryAt = DateTime.now().toUtc().add(const Duration(minutes: 2));

        await queueManager.enqueue(
          AttriaxQueuedRequest(
            id: 'req_1',
            createdAt: DateTime.utc(2026, 5, 4, 10),
            request: attriaxBuildTrackEventRequest(
              projectToken: 'ax_test_token',
              deviceId: 'device_123',
              deviceIdSource: 'android_ssaid',
              eventName: 'signup',
            ),
          ),
        );
        await queueManager.enqueue(
          AttriaxQueuedRequest(
            id: 'req_2',
            createdAt: DateTime.utc(2026, 5, 4, 10, 1),
            request: attriaxBuildTrackEventRequest(
              projectToken: 'ax_test_token',
              deviceId: 'device_123',
              deviceIdSource: 'android_ssaid',
              eventName: 'purchase',
            ),
          ),
        );
        await queueManager.enqueue(
          AttriaxQueuedRequest(
            id: 'req_3',
            createdAt: DateTime.utc(2026, 5, 4, 10, 2),
            nextRetryAt: retryAt,
            request: attriaxBuildTrackEventRequest(
              projectToken: 'ax_test_token',
              deviceId: 'device_123',
              deviceIdSource: 'android_ssaid',
              eventName: 'checkout',
            ),
          ),
        );

        final queue = await queueManager.readAll();
        final status = await queueManager.readStatus();

        expect(queue.map((request) => request.id).toList(), <String>[
          'req_2',
          'req_3',
        ]);
        expect(status.pendingRequestCount, 2);
        expect(status.oldestQueuedAt, DateTime.utc(2026, 5, 4, 10, 1));
        expect(status.nextRetryAt, retryAt);
        expect(status.diagnostics.evictedRequestCount, 1);
        expect(status.diagnostics.lastEvictedRequestKinds, <String>[
          'trackEvent',
        ]);
      },
    );

    test('records terminal drop diagnostics', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final queueManager = AttriaxQueueManager(
        preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
        maxQueueSize: 10,
      );
      final droppedRequest = AttriaxQueuedRequest(
        id: 'req_drop',
        createdAt: DateTime.utc(2026, 5, 4, 10),
        request: attriaxBuildTrackEventRequest(
          projectToken: 'ax_test_token',
          deviceId: 'device_123',
          deviceIdSource: 'android_ssaid',
          eventName: 'purchase',
        ),
      );

      await queueManager.recordTerminalDrop(<AttriaxQueuedRequest>[
        droppedRequest,
      ], reason: 'max_attempts_exceeded');

      final diagnostics = await queueManager.readDiagnostics();

      expect(diagnostics.droppedRequestCount, 1);
      expect(diagnostics.lastDroppedReason, 'max_attempts_exceeded');
      expect(diagnostics.lastDroppedRequestKinds, <String>['trackEvent']);
      expect(diagnostics.lastDroppedAt, isNotNull);
    });
  });
}
