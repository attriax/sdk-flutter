import 'dart:async';

import 'package:attriax/src/internal/attriax_api_models.dart';
import 'package:attriax/src/internal/attriax_generated_transport.dart';
import 'package:attriax/src/internal/attriax_logger.dart';
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
      queueManager = AttriaxQueueManager(prefs: prefs, maxQueueSize: 10);
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

      transport.sendResult = const AttriaxTransportSuccess(
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

      expect(transport.sentRequests, hasLength(1));
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

        transport.sendError = const AttriaxTransportHttpException(
          statusCode: 503,
        );
        dispatcher.registerHandlers(
          queuedRequest.id,
          onError: (error, stackTrace) {
            failedError = error;
            failedStackTrace = stackTrace;
          },
        );

        await dispatcher.flush();

        expect(transport.sentRequests, hasLength(1));
        expect(await queueManager.readAll(), hasLength(1));
        expect(failedError, isNull);
        expect(failedStackTrace, isNull);
      },
    );

    test(
      'drops the request and calls the error handler on non-retryable HTTP errors',
      () async {
        Object? failedError;

        transport.sendError = const AttriaxTransportHttpException(
          statusCode: 400,
        );
        dispatcher.registerHandlers(
          queuedRequest.id,
          onError: (error, stackTrace) => failedError = error,
        );

        await dispatcher.flush();

        expect(transport.sentRequests, hasLength(1));
        expect(await queueManager.readAll(), isEmpty);
        expect(failedError, isA<AttriaxTransportHttpException>());
      },
    );
  });
}

class FakeTransport implements AttriaxGeneratedTransport {
  final List<AttriaxApiRequest> sentRequests = <AttriaxApiRequest>[];
  AttriaxTransportSuccess? sendResult;
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
