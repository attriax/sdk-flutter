import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_generated_transport.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_queue.dart';
import 'package:attriax_flutter/src/internal/attriax_request_dispatcher.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support/fake_generated_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxRequestDispatcher.flush', () {
    late SharedPreferences prefs;
    late AttriaxQueueManager queueManager;
    late FakeConnectivityPlatform connectivityPlatform;
    late Connectivity connectivity;
    late FakeGeneratedTransport transport;
    late AttriaxRequestDispatcher dispatcher;
    late AttriaxQueuedRequest queuedRequest;
    late DateTime now;

    setUp(() async {
      now = DateTime.now().toUtc();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      queueManager = AttriaxQueueManager(
        preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
        maxQueueSize: 10,
      );
      connectivityPlatform = FakeConnectivityPlatform();
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      transport = FakeGeneratedTransport();
      dispatcher = AttriaxRequestDispatcher(
        transport: transport,
        connectivity: connectivity,
        queueManager: queueManager,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      queuedRequest = AttriaxQueuedRequest(
        id: 'req_1',
        request: attriaxBuildTrackEventRequest(
          appToken: 'ax_test_token',
          deviceId: 'device_1',
          deviceIdSource: 'android_ssaid',
          eventName: 'purchase',
          eventData: const <String, Object?>{'value': 42},
        ),
        createdAt: now.subtract(const Duration(days: 1)),
      );
      await queueManager.writeAll(<AttriaxQueuedRequest>[queuedRequest]);
    });

    tearDown(() async {
      await connectivityPlatform.dispose();
    });

    test('delivers queued requests and clears them on success', () async {
      AttriaxApiRequest? deliveredRequest;
      int? deliveredStatus;
      AttriaxApiResponse? successResponse;

      transport.sendBatchResult = const AttriaxTransportSuccess(
        statusCode: 202,
        response: AttriaxAckResponse(success: true),
      );
      dispatcher
        ..onDelivered = (request, statusCode) {
          deliveredRequest = request;
          deliveredStatus = statusCode;
        }
        ..registerHandlers(
          queuedRequest.id,
          onSuccess: (response) => successResponse = response,
        );

      await dispatcher.flush();

      expect(transport.sentBatches, hasLength(1));
      expect(transport.sentBatches.single, hasLength(1));
      expect(deliveredRequest, isA<AttriaxTrackEventRequest>());
      expect(deliveredStatus, 202);
      expect(successResponse, isA<AttriaxAckResponse>());
      expect(await queueManager.readAll(), isEmpty);
    });

    test(
      'keeps the failed request in the queue on retryable HTTP errors',
      () async {
        Object? failedError;
        StackTrace? failedStackTrace;

        transport.batchErrors.add(
          const AttriaxTransportHttpException(statusCode: 503),
        );
        dispatcher.registerHandlers(
          queuedRequest.id,
          onError: (error, stackTrace) {
            failedError = error;
            failedStackTrace = stackTrace;
          },
        );

        await dispatcher.flush();

        expect(transport.sentBatches, hasLength(1));
        expect(failedError, isNull);
        expect(failedStackTrace, isNull);

        final persisted = await queueManager.readAll();
        expect(persisted, hasLength(1));
        expect(persisted.single.attemptCount, 1);
        expect(persisted.single.lastErrorClass, 'http_503');
        expect(persisted.single.lastHttpStatusCode, 503);
        expect(persisted.single.lastAttemptAt, isNotNull);
      },
    );

    test(
      'applies an increasing backoff window when no retry-after is sent',
      () async {
        // A header-less 503 must still produce a future retry window so the
        // synchronizer can self-schedule a re-flush instead of spinning.
        transport.batchErrors.add(
          const AttriaxTransportHttpException(statusCode: 503),
        );
        final beforeFirst = DateTime.now().toUtc();

        await dispatcher.flush();

        final afterFirst = await queueManager.readAll();
        final firstRetryAt = afterFirst.single.nextRetryAt;
        expect(firstRetryAt, isNotNull);
        expect(afterFirst.single.attemptCount, 1);
        expect(firstRetryAt!.isAfter(beforeFirst), isTrue);

        // Move the queued request past its first backoff window and fail again;
        // the second backoff must be strictly longer (exponential).
        await queueManager.writeAll(<AttriaxQueuedRequest>[
          afterFirst.single.copyWith(nextRetryAt: null),
        ]);
        transport.batchErrors.add(
          const AttriaxTransportHttpException(statusCode: 503),
        );
        final beforeSecond = DateTime.now().toUtc();

        await dispatcher.flush();

        final afterSecond = await queueManager.readAll();
        expect(afterSecond.single.attemptCount, 2);
        final secondRetryAt = afterSecond.single.nextRetryAt;
        expect(secondRetryAt, isNotNull);
        expect(
          secondRetryAt!.difference(beforeSecond),
          greaterThan(firstRetryAt.difference(beforeFirst)),
        );
      },
    );

    test(
      'respects retry-after metadata before attempting the next flush',
      () async {
        final beforeFlush = DateTime.now().toUtc();
        final requestOptions = RequestOptions(path: '/api/sdk/v1/batch');
        transport.batchErrors.add(
          AttriaxTransportHttpException(
            statusCode: 429,
            source: DioException(
              requestOptions: requestOptions,
              response: Response<Object?>(
                requestOptions: requestOptions,
                statusCode: 429,
                headers: Headers.fromMap(<String, List<String>>{
                  'retry-after': <String>['60'],
                }),
              ),
            ),
          ),
        );

        await dispatcher.flush();

        final persisted = await queueManager.readAll();
        final nextRetryAt = persisted.single.nextRetryAt;
        expect(nextRetryAt, isNotNull);
        expect(
          nextRetryAt!.isAfter(beforeFlush.add(const Duration(seconds: 59))),
          isTrue,
        );
        expect(transport.sentBatches, hasLength(1));

        await dispatcher.flush();

        expect(transport.sentBatches, hasLength(1));
        expect((await queueManager.readAll()).single.nextRetryAt, nextRetryAt);
      },
    );

    test('supports http-date retry-after headers', () async {
      final retryAt = DateTime.utc(2099, 5, 15, 12, 31, 15);
      final requestOptions = RequestOptions(path: '/api/sdk/v1/batch');
      transport.batchErrors.add(
        AttriaxTransportHttpException(
          statusCode: 429,
          headers: Headers.fromMap(<String, List<String>>{
            'retry-after': <String>['Fri, 15 May 2099 12:31:15 GMT'],
          }),
          source: DioException(
            requestOptions: requestOptions,
            response: Response<Object?>(
              requestOptions: requestOptions,
              statusCode: 429,
            ),
          ),
        ),
      );

      await dispatcher.flush();

      final persisted = await queueManager.readAll();
      expect(persisted.single.nextRetryAt, retryAt);
    });

    test(
      'keeps deferred requests but still drains later deliverable work',
      () async {
        final deferredRequest = queuedRequest.copyWith(
          id: 'req_deferred',
          nextRetryAt: DateTime.now().toUtc().add(const Duration(minutes: 1)),
        );
        final deliverableRequest = AttriaxQueuedRequest(
          id: 'req_2',
          request: attriaxBuildTrackSessionRequest(
            appToken: 'ax_test_token',
            deviceIdSource: 'android_ssaid',
            session: AttriaxSessionSnapshot(
              id: 'session_1',
              deviceId: 'device_1',
              platform: AttriaxPlatformType.android,
              locale: 'en-US',
              isFirstLaunch: false,
              startedAt: now.subtract(const Duration(minutes: 1)),
              lastActivityAt: now.subtract(const Duration(seconds: 30)),
              heartbeatInterval: const Duration(seconds: 5),
              appVersion: '1.0.0',
              appBuildNumber: '1',
              appPackageName: 'com.attriax.test',
              sdkPackageVersion: '1.0.0',
            ),
            kind: AttriaxSessionLifecycleKind.heartbeat,
          ),
          createdAt: now.subtract(const Duration(seconds: 30)),
        );
        await queueManager.writeAll(<AttriaxQueuedRequest>[
          deferredRequest,
          deliverableRequest,
        ]);

        await dispatcher.flush();

        expect(transport.sentBatches, hasLength(1));
        expect(
          transport.sentBatches.single.map((request) => request.id).toList(),
          <String>['req_2'],
        );
        expect(
          (await queueManager.readAll()).map((request) => request.id).toList(),
          <String>['req_deferred'],
        );
      },
    );

    test(
      'appends a current-session heartbeat keepalive to event batches',
      () async {
        final deliveredKeepAlives = <String>[];
        dispatcher = AttriaxRequestDispatcher(
          transport: transport,
          connectivity: connectivity,
          queueManager: queueManager,
          logger: AttriaxLogger(enableDebugLogs: false),
          buildSessionKeepAliveBatchRequest: (_) =>
              attriaxBuildTrackSessionRequest(
                appToken: 'ax_test_token',
                deviceIdSource: 'android_ssaid',
                session: AttriaxSessionSnapshot(
                  id: 'session_1',
                  deviceId: 'device_1',
                  platform: AttriaxPlatformType.android,
                  locale: 'en-US',
                  isFirstLaunch: false,
                  startedAt: now.subtract(const Duration(minutes: 1)),
                  lastActivityAt: now,
                  heartbeatInterval: const Duration(minutes: 5),
                  appVersion: '1.0.0',
                  appBuildNumber: '1',
                  appPackageName: 'com.attriax.test',
                  sdkPackageVersion: '1.0.0',
                ),
                kind: AttriaxSessionLifecycleKind.heartbeat,
                occurredAt: now,
              ),
          onSessionKeepAliveDelivered: (sessionId, occurredAt) {
            deliveredKeepAlives.add(
              '$sessionId@${occurredAt.toUtc().toIso8601String()}',
            );
          },
        );

        await dispatcher.flush();

        expect(transport.sentBatches, hasLength(1));
        expect(
          transport.sentBatches.single.map((request) => request.id).toList(),
          <String>[
            'req_1',
            'keepalive_session_1_${now.microsecondsSinceEpoch}',
          ],
        );
        expect(
          transport.sentBatches.single.last.request,
          isA<AttriaxTrackSessionRequest>(),
        );
        expect(
          (transport.sentBatches.single.last.request
                  as AttriaxTrackSessionRequest)
              .payload
              .kind,
          AttriaxSessionLifecycleKind.heartbeat,
        );
        expect(deliveredKeepAlives, <String>[
          'session_1@${now.toUtc().toIso8601String()}',
        ]);
      },
    );

    test('splits queue batches when device identity changes', () async {
      final secondRequest = AttriaxQueuedRequest(
        id: 'req_2',
        request: attriaxBuildUserRequest(
          appToken: 'ax_test_token',
          deviceId: 'device_2',
          deviceIdSource: 'android_ssaid',
          externalUserId: 'user_2',
        ),
        createdAt: now.subtract(const Duration(seconds: 30)),
      );
      await queueManager.writeAll(<AttriaxQueuedRequest>[
        queuedRequest,
        secondRequest,
      ]);

      await dispatcher.flush();

      expect(transport.sentBatches, hasLength(2));
      expect(
        transport.sentBatches
            .map((batch) => batch.map((request) => request.id).toList())
            .toList(),
        <List<String>>[
          <String>['req_1'],
          <String>['req_2'],
        ],
      );
      expect(await queueManager.readAll(), isEmpty);
    });

    test('splits oversized batches until smaller batches succeed', () async {
      final secondRequest = AttriaxQueuedRequest(
        id: 'req_2',
        request: attriaxBuildUserRequest(
          appToken: 'ax_test_token',
          deviceId: 'device_1',
          deviceIdSource: 'android_ssaid',
          externalUserId: 'user_1',
        ),
        createdAt: DateTime.utc(2026, 5, 1, 0, 0, 5),
      );
      await queueManager.writeAll(<AttriaxQueuedRequest>[
        queuedRequest,
        secondRequest,
      ]);

      transport.batchErrors.add(
        const AttriaxTransportHttpException(statusCode: 413),
      );

      await dispatcher.flush();

      expect(transport.sentBatches.map((batch) => batch.length).toList(), <int>[
        2,
        1,
        1,
      ]);
      expect(await queueManager.readAll(), isEmpty);
    });

    test(
      'caps sendable batches before they exceed item-count limits',
      () async {
        dispatcher = AttriaxRequestDispatcher(
          transport: transport,
          connectivity: connectivity,
          queueManager: queueManager,
          logger: AttriaxLogger(enableDebugLogs: false),
          buildSessionKeepAliveBatchRequest: (_) =>
              attriaxBuildTrackSessionRequest(
                appToken: 'ax_test_token',
                deviceIdSource: 'android_ssaid',
                session: AttriaxSessionSnapshot(
                  id: 'session_1',
                  deviceId: 'device_1',
                  platform: AttriaxPlatformType.android,
                  locale: 'en-US',
                  isFirstLaunch: false,
                  startedAt: now.subtract(const Duration(minutes: 1)),
                  lastActivityAt: now,
                  heartbeatInterval: const Duration(minutes: 5),
                  appVersion: '1.0.0',
                  appBuildNumber: '1',
                  appPackageName: 'com.attriax.test',
                  sdkPackageVersion: '1.0.0',
                ),
                kind: AttriaxSessionLifecycleKind.heartbeat,
                occurredAt: now,
              ),
        );

        final requests = List<AttriaxQueuedRequest>.generate(
          120,
          (index) => AttriaxQueuedRequest(
            id: 'req_${index + 1}',
            request: attriaxBuildTrackEventRequest(
              appToken: 'ax_test_token',
              deviceId: 'device_1',
              deviceIdSource: 'android_ssaid',
              eventName: 'purchase_${index + 1}',
              eventData: const <String, Object?>{'value': 42},
            ),
            createdAt: now.subtract(const Duration(seconds: 30)),
          ),
        );
        await queueManager.writeAll(requests);

        await dispatcher.flush();

        expect(transport.sentBatches, hasLength(2));
        expect(transport.sentBatches[0], hasLength(100));
        expect(transport.sentBatches[1], hasLength(22));
        expect(await queueManager.readAll(), isEmpty);
      },
    );

    AttriaxQueuedRequest buildOpenRequest({required DateTime createdAt}) =>
        AttriaxQueuedRequest(
          id: 'req_open',
          request: attriaxBuildOpenRequest(
            config: const AttriaxConfig(projectToken: 'ax_test_token'),
            context: const AttriaxContextSnapshot(
              platform: AttriaxPlatformType.android,
              deviceId: 'device_1',
              isFirstLaunch: true,
              sdk: AttriaxSdkSnapshot(
                apiVersion: attriaxSdkApiVersion,
                packageVersion: attriaxSdkPackageVersion,
              ),
              app: AttriaxAppSnapshot(
                version: '1.0.0',
                buildNumber: '1',
                packageName: 'com.attriax.test',
              ),
              device: AttriaxDeviceSnapshot(model: 'Pixel', osVersion: '14'),
            ),
            deviceIdSource: 'android_ssaid',
          ),
          createdAt: createdAt,
        );

    test(
      'delivers events without waiting for an app-open to succeed',
      () async {
        // No app-open is queued at all; events must still flow.
        transport.sendBatchResult = const AttriaxTransportSuccess(
          statusCode: 202,
          response: AttriaxAckResponse(success: true),
        );

        await dispatcher.flush();

        expect(transport.sentBatches, hasLength(1));
        expect(
          transport.sentBatches.single.map((request) => request.id).toList(),
          <String>['req_1'],
        );
        expect(await queueManager.readAll(), isEmpty);
      },
    );

    test(
      'delivers events in the same flush even when the app-open fails',
      () async {
        final openRequest = buildOpenRequest(
          createdAt: now.subtract(const Duration(seconds: 31)),
        );

        await queueManager.writeAll(<AttriaxQueuedRequest>[
          openRequest,
          queuedRequest,
        ]);

        // App-open fails with a retryable error; the event must not be blocked.
        transport
          ..sendError = const AttriaxTransportHttpException(statusCode: 500)
          ..sendBatchResult = const AttriaxTransportSuccess(
            statusCode: 202,
            response: AttriaxAckResponse(success: true),
          );

        await dispatcher.flush();

        // The event was delivered despite the failed app-open.
        expect(transport.sentBatches, hasLength(1));
        expect(
          transport.sentBatches.single.map((request) => request.id).toList(),
          <String>['req_1'],
        );

        // Only the failed app-open remains queued, marked for retry with a
        // backoff window.
        final queuedAfterFlush = await queueManager.readAll();
        expect(queuedAfterFlush, hasLength(1));
        expect(queuedAfterFlush.single.request, isA<AttriaxOpenRequest>());
        expect(queuedAfterFlush.single.attemptCount, 1);
        expect(queuedAfterFlush.single.nextRetryAt, isNotNull);
      },
    );

    test(
      'sends deep-link resolution requests regardless of app-open state',
      () async {
        final resolveRequest = AttriaxQueuedRequest(
          id: 'req_resolve',
          request: attriaxBuildResolveDeepLinkRequest(
            projectToken: 'ax_test_token',
            deviceId: 'device_1',
            deviceIdSource: 'android_ssaid',
            platform: AttriaxPlatformType.android,
            source: 'attriax_sdk',
            isFirstLaunch: true,
            rawUrl: 'https://example.com/promo/launch',
            linkPath: 'promo/launch',
          ),
          createdAt: now.subtract(const Duration(seconds: 30)),
        );

        await queueManager.writeAll(<AttriaxQueuedRequest>[resolveRequest]);
        transport.sendResult = const AttriaxTransportSuccess(
          statusCode: 200,
          response: AttriaxResolveDeepLinkApiResponse(
            result: AttriaxDeepLinkResolutionResult(
              matched: true,
              status: AttriaxDeepLinkResolutionStatus.matched,
              isFirstLaunch: true,
              deepLink: AttriaxDeepLink(path: 'promo/launch'),
            ),
          ),
        );

        await dispatcher.flush();

        expect(transport.sentRequests, hasLength(1));
        expect(
          transport.sentRequests.single,
          isA<AttriaxResolveDeepLinkRequest>(),
        );
        expect(transport.sentBatches, isEmpty);
        expect(await queueManager.readAll(), isEmpty);
      },
    );
  });
}

class FakeConnectivityPlatform extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      <ConnectivityResult>[ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();

  Future<void> dispose() async {}
}
