import 'dart:async';

import 'package:attriax/src/internal/attriax_api_models.dart';
import 'package:attriax/src/internal/attriax_generated_transport.dart';
import 'package:attriax/src/internal/attriax_logger.dart';
import 'package:attriax/src/internal/attriax_preferences_store.dart';
import 'package:attriax/src/internal/attriax_queue.dart';
import 'package:attriax/src/internal/attriax_request_dispatcher.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
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

    setUp(() async {
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
        createdAt: DateTime.utc(2026, 5, 1),
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
        expect(await queueManager.readAll(), hasLength(1));
        expect(failedError, isNull);
        expect(failedStackTrace, isNull);
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
            startedAt: DateTime.utc(2026, 5, 1),
            lastActivityAt: DateTime.utc(2026, 5, 1, 0, 0, 5),
            heartbeatInterval: const Duration(seconds: 5),
            appVersion: '1.0.0',
            appBuildNumber: '1',
            appPackageName: 'com.attriax.test',
            sdkPackageVersion: '1.0.0',
          ),
          kind: AttriaxSessionLifecycleKind.heartbeat,
        ),
        createdAt: DateTime.utc(2026, 5, 1, 0, 0, 5),
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
        createdAt: DateTime.utc(2026, 5, 1, 0, 0, 5),
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
