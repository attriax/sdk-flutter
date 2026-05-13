import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_generated_transport.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_queue.dart';
import 'package:attriax_flutter/src/internal/attriax_request_dispatcher.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxRequestDispatcher.flush', () {
    late SharedPreferences prefs;
    late AttriaxQueueManager queueManager;
    late FakeConnectivityPlatform connectivityPlatform;
    late Connectivity connectivity;
    late FakeTransport transport;
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
      transport = FakeTransport();
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
      dispatcher.onDelivered = (request, statusCode) {
        deliveredRequest = request;
        deliveredStatus = statusCode;
      };
      dispatcher.registerHandlers(
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
      final retryAt = DateTime.now().toUtc().add(const Duration(seconds: 75));
      final requestOptions = RequestOptions(path: '/api/sdk/v1/batch');
      transport.batchErrors.add(
        AttriaxTransportHttpException(
          statusCode: 429,
          headers: Headers.fromMap(<String, List<String>>{
            'retry-after': <String>[retryAt.toIso8601String()],
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

    test('drops requests that exceed the retry policy', () async {
      final staleRequest = queuedRequest.copyWith(
        id: 'req_stale',
        createdAt: DateTime.now().toUtc().subtract(const Duration(days: 8)),
        attemptCount: 8,
      );
      await queueManager.writeAll(<AttriaxQueuedRequest>[staleRequest]);

      await dispatcher.flush();

      expect(await queueManager.readAll(), isEmpty);
      expect(transport.sentBatches, isEmpty);
      final diagnostics = await queueManager.readDiagnostics();
      expect(diagnostics.droppedRequestCount, 1);
      expect(diagnostics.lastDroppedReason, 'max_attempts_exceeded');
    });

    test(
      'keeps stale deep-link resolution requests queued until they succeed',
      () async {
        final staleRequest = AttriaxQueuedRequest(
          id: 'req_resolve',
          request: attriaxBuildResolveDeepLinkRequest(
            appToken: 'ax_test_token',
            deviceId: 'device_1',
            deviceIdSource: 'android_ssaid',
            platform: AttriaxPlatformType.android,
            source: 'attriax_sdk',
            isFirstLaunch: false,
            rawUrl: 'https://app.example/promo/deferred',
          ),
          createdAt: DateTime.now().toUtc().subtract(const Duration(days: 8)),
          attemptCount: 8,
        );
        await queueManager.writeAll(<AttriaxQueuedRequest>[staleRequest]);
        transport.sendError = const AttriaxTransportHttpException(
          statusCode: 503,
        );

        await dispatcher.flush();

        expect(transport.sentRequests, hasLength(1));
        final persisted = await queueManager.readAll();
        expect(persisted, hasLength(1));
        expect(persisted.single.id, 'req_resolve');
        expect(persisted.single.attemptCount, 9);
        expect(persisted.single.lastErrorClass, 'http_503');
        expect(persisted.single.lastHttpStatusCode, 503);
        final diagnostics = await queueManager.readDiagnostics();
        expect(diagnostics.droppedRequestCount, 0);
      },
    );

    test(
      'drops the request and calls the error handler on non-retryable HTTP errors',
      () async {
        Object? failedError;

        transport.batchErrors.add(
          const AttriaxTransportHttpException(statusCode: 400),
        );
        dispatcher.registerHandlers(
          queuedRequest.id,
          onError: (error, stackTrace) => failedError = error,
        );

        await dispatcher.flush();

        expect(transport.sentBatches, hasLength(1));
        expect(await queueManager.readAll(), isEmpty);
        expect(failedError, isA<AttriaxTransportHttpException>());
      },
    );

    test('batches consecutive queued requests into one batch call', () async {
      final secondRequest = AttriaxQueuedRequest(
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
        queuedRequest,
        secondRequest,
      ]);

      await dispatcher.flush();

      expect(transport.sentBatches, hasLength(1));
      expect(
        transport.sentBatches.single.map((request) => request.id).toList(),
        <String>['req_1', 'req_2'],
      );
      expect(await queueManager.readAll(), isEmpty);
    });

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
      'waits for app-open scheduling and sends app-open before cached batchable requests',
      () async {
        var isAppOpenScheduled = false;
        dispatcher = AttriaxRequestDispatcher(
          transport: transport,
          connectivity: connectivity,
          queueManager: queueManager,
          logger: AttriaxLogger(enableDebugLogs: false),
          isAppOpenScheduled: () => isAppOpenScheduled,
        );
        final openRequest = AttriaxQueuedRequest(
          id: 'req_open',
          request: attriaxBuildOpenRequest(
            config: const AttriaxConfig(appToken: 'ax_test_token'),
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
          createdAt: now.subtract(const Duration(seconds: 31)),
        );

        await dispatcher.flush();

        expect(transport.sentRequests, isEmpty);
        expect(transport.sentBatches, isEmpty);
        expect(await queueManager.readAll(), hasLength(1));

        await queueManager.enqueue(openRequest);
        isAppOpenScheduled = true;
        transport.sendResult = AttriaxTransportSuccess(
          statusCode: 200,
          response: AttriaxOpenApiResponse(
            result: AttriaxAppOpenResult(
              userId: 'user_1',
              isNewUser: true,
              isFirstLaunch: true,
              requestVersion: 'v1',
              acceptedAt: now,
            ),
          ),
        );
        transport.sendBatchResult = const AttriaxTransportSuccess(
          statusCode: 202,
          response: AttriaxAckResponse(success: true),
        );

        await dispatcher.flush();

        expect(transport.sentRequests, hasLength(1));
        expect(transport.sentRequests.single, isA<AttriaxOpenRequest>());
        expect(transport.sentBatches, hasLength(1));
        expect(
          transport.sentBatches.single.map((request) => request.id).toList(),
          <String>['req_1'],
        );
        expect(await queueManager.readAll(), isEmpty);
      },
    );
  });
}

class FakeTransport implements AttriaxGeneratedTransport {
  final List<AttriaxApiRequest> sentRequests = <AttriaxApiRequest>[];
  final List<List<AttriaxQueuedRequest>> sentBatches =
      <List<AttriaxQueuedRequest>>[];
  AttriaxTransportSuccess? sendResult;
  final List<Object> batchErrors = <Object>[];
  AttriaxTransportSuccess? sendBatchResult;
  Object? sendError;

  @override
  Future<AttriaxTransportSuccess> send(AttriaxApiRequest request) async {
    sentRequests.add(request);
    if (sendError != null) {
      throw sendError!;
    }
    return sendResult ??
        const AttriaxTransportSuccess(
          statusCode: 200,
          response: AttriaxAckResponse(success: true),
        );
  }

  @override
  Future<AttriaxTransportSuccess> sendBatch(
    List<AttriaxQueuedRequest> requests,
  ) async {
    sentBatches.add(List<AttriaxQueuedRequest>.from(requests));
    if (batchErrors.isNotEmpty) {
      throw batchErrors.removeAt(0);
    }
    return sendBatchResult ??
        const AttriaxTransportSuccess(
          statusCode: 200,
          response: AttriaxAckResponse(success: true),
        );
  }

  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink(
    AttriaxCreateDynamicLinkRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> registerUninstallToken(Map<String, Object?> payload) {
    throw UnimplementedError();
  }

  @override
  Future<AttriaxRevenueReceiptValidationResult> validateRevenueReceipt(
    Map<String, Object?> payload,
  ) {
    throw UnimplementedError();
  }
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
