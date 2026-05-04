import 'dart:convert';

import 'package:attriax/src/internal/attriax_api_models.dart';
import 'package:attriax/src/internal/attriax_generated_transport.dart';
import 'package:attriax/src/internal/attriax_queue.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_sdk_client/attriax_sdk_client.dart' as sdk;
import 'package:built_value/serializer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxGeneratedTransport', () {
    test('sends open requests and maps the open response', () async {
      final client = FakeHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/sdk/v1/open');
        expect(_readRequestBody(request), contains('ax_test_token'));

        return _jsonResponse(
          200,
          _serializeGenerated(
            sdk.SdkV1OpenResponseEnvelopeDto.serializer,
            _openEnvelope(),
          ),
        );
      });

      final transport = _createTransport(client);
      final result = await transport.send(_openRequest());

      final response = result.response as AttriaxOpenApiResponse;
      expect(result.statusCode, 200);
      expect(response.result.userId, 'user_123');
      expect(response.result.deepLink?.path, '/offers/spring');
      expect(response.result.isNewUser, isTrue);
    });

    test('sends event requests and maps acknowledge responses', () async {
      final client = FakeHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/sdk/v1/events');

        return _jsonResponse(
          202,
          _serializeGenerated(
            sdk.SdkAcknowledgeResponseEnvelopeDto.serializer,
            _ackEnvelope(),
          ),
        );
      });

      final transport = _createTransport(client);
      final result = await transport.send(_eventRequest());

      final response = result.response as AttriaxAckResponse;
      expect(result.statusCode, 202);
      expect(response.success, isTrue);
    });

    test('sends crash reports and maps acknowledge responses', () async {
      final client = FakeHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/sdk/v1/crashes');

        final body =
            jsonDecode(_readRequestBody(request)) as Map<String, Object?>;
        expect(body['source'], 'flutter_error');
        expect(body['isFatal'], isTrue);
        expect(body['exceptionType'], 'StateError');
        expect(body['appVersion'], '1.0.0');

        return _jsonResponse(202, <String, Object?>{
          'data': <String, Object?>{'success': true},
        });
      });

      final transport = _createTransport(client);
      final result = await transport.send(_crashRequest());

      final response = result.response as AttriaxAckResponse;
      expect(result.statusCode, 202);
      expect(response.success, isTrue);
    });

    test(
      'sends session lifecycle requests and maps acknowledge responses',
      () async {
        final client = FakeHttpClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/sdk/v1/sessions');

          final body = _readRequestBody(request);
          expect(body, contains('"kind":"pause"'));
          expect(body, contains('"sessionId":"session_123"'));

          return _jsonResponse(
            202,
            _serializeGenerated(
              sdk.SdkAcknowledgeResponseEnvelopeDto.serializer,
              _ackEnvelope(),
            ),
          );
        });

        final transport = _createTransport(client);
        final result = await transport.send(_sessionRequest());

        final response = result.response as AttriaxAckResponse;
        expect(result.statusCode, 202);
        expect(response.success, isTrue);
      },
    );

    test(
      'sends batch requests and maps batch responses as acknowledgements',
      () async {
        final client = FakeHttpClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/sdk/v1/batch');

          final body =
              jsonDecode(_readRequestBody(request)) as Map<String, Object?>;
          expect(body['requestId'], 'batch_req_1');
          expect(body['appToken'], 'ax_test_token');
          expect(body['deviceId'], 'device_123');

          final items = body['items'] as List<Object?>;
          expect(items, hasLength(2));
          expect(
            items
                .cast<Map<String, Object?>>()
                .map((item) => item['kind'])
                .toList(growable: false),
            <Object?>['event', 'session'],
          );
          expect(
            items.every(
              (item) =>
                  !(item as Map<String, Object?>).containsKey('requestId'),
            ),
            isTrue,
          );
          expect(
            items.every(
              (item) =>
                  !(((item as Map<String, Object?>)['body']
                          as Map<String, Object?>)
                      .containsKey('appToken')),
            ),
            isTrue,
          );
          expect(
            items.every(
              (item) =>
                  !(((item as Map<String, Object?>)['body']
                          as Map<String, Object?>)
                      .containsKey('deviceId')),
            ),
            isTrue,
          );

          return _jsonResponse(
            202,
            _serializeGenerated(
              sdk.SdkV1BatchResponseEnvelopeDto.serializer,
              _batchEnvelope(),
            ),
          );
        });

        final transport = _createTransport(client);
        final result = await transport.sendBatch(_batchRequests());

        final response = result.response as AttriaxAckResponse;
        expect(result.statusCode, 202);
        expect(response.success, isTrue);
      },
    );

    test(
      'sends deep-link resolution requests and maps the resolution response',
      () async {
        final client = FakeHttpClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/sdk/v1/deep-links/resolve');

          return _jsonResponse(
            200,
            _serializeGenerated(
              sdk.SdkV1DeepLinkResolveResponseEnvelopeDto.serializer,
              _resolveEnvelope(),
            ),
          );
        });

        final transport = _createTransport(client);
        final result = await transport.send(_resolveRequest());

        final response = result.response as AttriaxResolveDeepLinkApiResponse;
        expect(response.result.matched, isTrue);
        expect(response.result.deepLink?.path, '/offers/spring');
        expect(response.result.reason, isNull);
      },
    );

    test('returns dynamic-link results from createDynamicLink', () async {
      final client = FakeHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/sdk/v1/dynamic-links');

        return _jsonResponse(
          200,
          _serializeGenerated(
            sdk.SdkCreateDynamicLinkResponseEnvelopeDto.serializer,
            _dynamicLinkEnvelope(),
          ),
        );
      });

      final transport = _createTransport(client);
      final result = await transport.createDynamicLink(_dynamicLinkRequest());

      expect(result.link.id, 'dl_123');
      expect(result.link.path, '/promo/spring');
      expect(result.link.shortUrl, 'https://ax.example/spring');
    });

    test(
      'surfaces non-success responses as transport HTTP exceptions',
      () async {
        final client = FakeHttpClient(
          (_) async => _jsonResponse(503, <String, Object?>{'message': 'down'}),
        );

        final transport = _createTransport(client);

        await expectLater(
          () => transport.send(_eventRequest()),
          throwsA(
            isA<AttriaxTransportHttpException>().having(
              (error) => error.statusCode,
              'statusCode',
              503,
            ),
          ),
        );
      },
    );

    test(
      'surfaces malformed successful responses as invalid response exceptions',
      () async {
        final client = FakeHttpClient(
          (_) async =>
              _jsonResponse(200, <String, Object?>{'unexpected': 'shape'}),
        );

        final transport = _createTransport(client);

        await expectLater(
          () => transport.send(_eventRequest()),
          throwsA(
            isA<AttriaxTransportInvalidResponseException>().having(
              (error) => error.message,
              'message',
              'Invalid event response body.',
            ),
          ),
        );
      },
    );
  });
}

AttriaxGeneratedTransport _createTransport(http.Client client) =>
    AttriaxGeneratedTransport(
      apiBaseUrl: 'https://api.attriax.test',
      requestTimeout: const Duration(seconds: 1),
      httpClient: client,
    );

AttriaxOpenRequest _openRequest() => AttriaxOpenRequest(
  sdk.SdkV1OpenDto(
    (builder) => builder
      ..app.replace(
        sdk.AppVersionContextDto((builder) => builder..version = '1.0.0'),
      )
      ..appToken = 'ax_test_token'
      ..device.replace(sdk.DeviceContextDto())
      ..deviceId = 'device_123'
      ..deviceIdSource = 'android_ssaid'
      ..isFirstLaunch = true
      ..platform = sdk.Platform.android
      ..sdk.replace(
        sdk.SdkVersionContextDto(
          (builder) => builder
            ..apiVersion = '2025-01-01'
            ..packageVersion = '1.2.3',
        ),
      ),
  ),
);

AttriaxTrackEventRequest _eventRequest() => AttriaxTrackEventRequest(
  sdk.SdkEventDto(
    (builder) => builder
      ..appToken = 'ax_test_token'
      ..deviceId = 'device_123'
      ..deviceIdSource = 'android_ssaid'
      ..eventName = 'purchase',
  ),
);

AttriaxTrackCrashRequest _crashRequest() => AttriaxTrackCrashRequest(
  AttriaxCrashReportPayload(
    appToken: 'ax_test_token',
    deviceId: 'device_123',
    deviceIdSource: 'android_ssaid',
    source: 'flutter_error',
    clientOccurredAt: DateTime.utc(2026, 1, 1, 12, 0, 15),
    platform: AttriaxPlatformType.android,
    isFatal: true,
    exceptionType: 'StateError',
    message: 'Bad state: boom',
    stackTrace: 'stack line',
    isFirstLaunch: false,
    reason: 'Widget build failed',
    appVersion: '1.0.0',
    appBuildNumber: '1',
    appPackageName: 'com.attriax.test',
    sdkApiVersion: 'v1',
    sdkPackageVersion: '1.2.3',
  ),
);

AttriaxTrackSessionRequest _sessionRequest() => AttriaxTrackSessionRequest(
  AttriaxSessionLifecyclePayload(
    appToken: 'ax_test_token',
    deviceId: 'device_123',
    deviceIdSource: 'android_ssaid',
    kind: AttriaxSessionLifecycleKind.pause,
    sessionId: 'session_123',
    sessionRelativeTimeMs: 15000,
    clientOccurredAt: DateTime.utc(2026, 1, 1, 12, 0, 15),
    platform: AttriaxPlatformType.android,
    locale: 'en-US',
    isFirstLaunch: false,
    appVersion: '1.0.0',
    appBuildNumber: '1',
    appPackageName: 'com.attriax.test',
    sdkApiVersion: 'v1',
    sdkPackageVersion: '1.2.3',
  ),
);

List<AttriaxQueuedRequest> _batchRequests() => <AttriaxQueuedRequest>[
  AttriaxQueuedRequest(
    id: 'req_1',
    request: _eventRequest(),
    createdAt: DateTime.utc(2026, 1, 1),
  ),
  AttriaxQueuedRequest(
    id: 'req_2',
    request: _sessionRequest(),
    createdAt: DateTime.utc(2026, 1, 1, 0, 0, 5),
  ),
];

AttriaxResolveDeepLinkRequest _resolveRequest() =>
    AttriaxResolveDeepLinkRequest(
      sdk.SdkV1DeepLinkResolveDto(
        (builder) => builder
          ..appToken = 'ax_test_token'
          ..deviceId = 'device_123'
          ..deviceIdSource = 'android_ssaid'
          ..isFirstLaunch = true
          ..linkPath = '/offers/spring'
          ..platform = sdk.Platform.android
          ..rawUrl = 'https://ax.example/offers/spring'
          ..source_ = 'app_link',
      ),
    );

AttriaxCreateDynamicLinkRequest _dynamicLinkRequest() =>
    AttriaxCreateDynamicLinkRequest(
      sdk.SdkCreateDynamicLinkDto(
        (builder) => builder
          ..appToken = 'ax_test_token'
          ..name = 'Spring promo'
          ..destinationUrl = 'https://example.com/spring',
      ),
    );

sdk.SdkV1OpenResponseEnvelopeDto _openEnvelope() =>
    sdk.SdkV1OpenResponseEnvelopeDto(
      (builder) => builder
        ..data.replace(
          sdk.SdkV1OpenResponseDto(
            (builder) => builder
              ..acceptedAt = DateTime.utc(2026, 1, 1)
              ..deepLink.replace(
                sdk.SdkJsonDeepLinkDto(
                  (builder) => builder..path = '/offers/spring',
                ),
              )
              ..isFirstLaunch = true
              ..isNewUser = true
              ..requestVersion = 'req_v1'
              ..userId = 'user_123',
          ),
        )
        ..success = true
        ..timestamp = DateTime.utc(2026, 1, 1),
    );

sdk.SdkAcknowledgeResponseEnvelopeDto _ackEnvelope() =>
    sdk.SdkAcknowledgeResponseEnvelopeDto(
      (builder) => builder
        ..data.replace(
          sdk.SdkAcknowledgeResponseDto((builder) => builder..success = true),
        )
        ..success = true
        ..timestamp = DateTime.utc(2026, 1, 1),
    );

sdk.SdkV1BatchResponseEnvelopeDto _batchEnvelope() =>
    sdk.SdkV1BatchResponseEnvelopeDto(
      (builder) => builder
        ..data.replace(
          sdk.SdkV1BatchResponseDto(
            (builder) => builder
              ..acceptedAt = DateTime.utc(2026, 1, 1)
              ..duplicateCount = 0
              ..itemCount = 2
              ..processedCount = 2
              ..requestVersion = 'v1',
          ),
        )
        ..success = true
        ..timestamp = DateTime.utc(2026, 1, 1),
    );

sdk.SdkV1DeepLinkResolveResponseEnvelopeDto _resolveEnvelope() =>
    sdk.SdkV1DeepLinkResolveResponseEnvelopeDto(
      (builder) => builder
        ..data.replace(
          sdk.SdkV1DeepLinkResolveResponseDto(
            (builder) => builder
              ..acceptedAt = DateTime.utc(2026, 1, 1)
              ..deepLink.replace(
                sdk.SdkJsonDeepLinkDto(
                  (builder) => builder..path = '/offers/spring',
                ),
              )
              ..isFirstLaunch = true
              ..matched = true
              ..requestVersion = 'req_v1'
              ..status = sdk.DeepLinkResolutionStatus.matched,
          ),
        )
        ..success = true
        ..timestamp = DateTime.utc(2026, 1, 1),
    );

sdk.SdkCreateDynamicLinkResponseEnvelopeDto _dynamicLinkEnvelope() =>
    sdk.SdkCreateDynamicLinkResponseEnvelopeDto(
      (builder) => builder
        ..data.replace(
          sdk.SdkCreateDynamicLinkResponseDto(
            (builder) => builder
              ..acceptedAt = DateTime.utc(2026, 1, 1)
              ..link.replace(
                sdk.SdkDynamicLinkRecordDto(
                  (builder) => builder
                    ..createdAt = DateTime.utc(2026, 1, 1)
                    ..id = 'dl_123'
                    ..path = '/promo/spring'
                    ..shortUrl = 'https://ax.example/spring',
                ),
              )
              ..requestVersion = 'req_v1',
          ),
        )
        ..success = true
        ..timestamp = DateTime.utc(2026, 1, 1),
    );

Object? _serializeGenerated<T>(Serializer<T> serializer, T value) =>
    sdk.standardSerializers.serializeWith(serializer, value);

String _readRequestBody(http.BaseRequest request) {
  if (request case final http.Request typedRequest) {
    return utf8.decode(typedRequest.bodyBytes);
  }

  return '';
}

http.StreamedResponse _jsonResponse(int statusCode, Object? body) =>
    http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
      statusCode,
      headers: const <String, String>{'content-type': 'application/json'},
    );

class FakeHttpClient extends http.BaseClient {
  FakeHttpClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;

  final List<http.BaseRequest> requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests.add(request);
    return _handler(request);
  }
}
