import 'dart:convert';

import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_generated_transport.dart';
import 'package:attriax_flutter/src/internal/attriax_queue.dart';
import 'package:attriax_flutter/src/internal/attriax_sdk_runtime_config.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:attriax_api_client/attriax_api_client.dart' as sdk;
import 'package:dio/dio.dart';
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

        return _jsonResponse(200, _serializeGenerated(_openEnvelope()));
      });

      final transport = _createTransport(client);
      final result = await transport.send(_openRequest());

      final response = result.response as AttriaxOpenApiResponse;
      expect(result.statusCode, 200);
      expect(response.result.userId, 'user_123');
      expect(response.result.deepLink?.path, '/offers/spring');
      expect(response.result.isNewUser, isTrue);
    });

    test('omits null metadata values from generated open requests', () async {
      final request = attriaxBuildOpenRequest(
        config: const AttriaxConfig(projectToken: 'ax_test_token'),
        context: const AttriaxContextSnapshot(
          platform: AttriaxPlatformType.android,
          deviceId: 'device_123',
          isFirstLaunch: true,
          sdk: AttriaxSdkSnapshot(
            apiVersion: '2025-01-01',
            packageVersion: '1.2.3',
            metadata: <String, Object?>{
              'clientRuntime': 'flutter',
              'optionalField': null,
            },
          ),
          app: AttriaxAppSnapshot(
            version: '1.0.0',
            buildNumber: '1',
            packageName: 'com.attriax.test',
          ),
          device: AttriaxDeviceSnapshot(
            model: 'Pixel 9',
            metadata: <String, Object?>{
              'appVersion': '1.0.0',
              'installerPackageName': null,
              'nested': <String, Object?>{'child': null},
              'tags': <Object?>['one', null, 'two'],
            },
          ),
        ),
        deviceIdSource: 'android_ssaid',
      );

      final client = FakeHttpClient((request) async {
        final body =
            jsonDecode(_readRequestBody(request)) as Map<String, Object?>;
        final sdkBody = body['sdk']! as Map<String, Object?>;
        final sdkMetadata = sdkBody['metadata']! as Map<String, Object?>;
        final deviceBody = body['device']! as Map<String, Object?>;
        final deviceMetadata = deviceBody['metadata']! as Map<String, Object?>;
        final nestedMetadata =
            deviceMetadata['nested']! as Map<String, Object?>;

        expect(sdkMetadata.containsKey('optionalField'), isFalse);
        expect(deviceMetadata.containsKey('installerPackageName'), isFalse);
        expect(nestedMetadata.containsKey('child'), isFalse);
        expect(deviceMetadata['tags'], <Object?>['one', 'two']);

        return _jsonResponse(200, _serializeGenerated(_openEnvelope()));
      });

      final transport = _createTransport(client);
      await expectLater(() => transport.send(request), returnsNormally);
    });

    test('serializes typed device metrics in open requests', () async {
      final request = attriaxBuildOpenRequest(
        config: const AttriaxConfig(projectToken: 'ax_test_token'),
        context: const AttriaxContextSnapshot(
          platform: AttriaxPlatformType.windows,
          deviceId: 'device_windows_1',
          isFirstLaunch: false,
          sdk: AttriaxSdkSnapshot(
            apiVersion: '2025-01-01',
            packageVersion: '1.2.3',
          ),
          app: AttriaxAppSnapshot(
            version: '2.4.0',
            buildNumber: '2401',
            packageName: 'Attriax.InternalTester',
          ),
          device: AttriaxDeviceSnapshot(
            model: 'Surface Laptop 7',
            name: 'QA-DESKTOP',
            manufacturer: 'Microsoft',
            brand: 'Microsoft',
            hardware: 'machine-guid-123',
            osVersion: 'Windows 11 24H2 (build 26100)',
            screenResolution: '1920x1080',
            screenWidth: 1920,
            screenHeight: 1080,
            devicePixelRatio: 1.25,
            colorDepth: 32,
          ),
        ),
        deviceIdSource: 'windows_machine_guid',
      );

      final client = FakeHttpClient((request) async {
        final body =
            jsonDecode(_readRequestBody(request)) as Map<String, Object?>;
        final deviceBody = body['device']! as Map<String, Object?>;

        expect(deviceBody['screenWidth'], 1920);
        expect(deviceBody['screenHeight'], 1080);
        expect(deviceBody['devicePixelRatio'], 1.25);
        expect(deviceBody['colorDepth'], 32);
        expect(deviceBody['osVersion'], 'Windows 11 24H2 (build 26100)');

        return _jsonResponse(200, _serializeGenerated(_openEnvelope()));
      });

      final transport = _createTransport(client);
      await expectLater(() => transport.send(request), returnsNormally);
    });

    test('fetches launch-time runtime config over the JSON endpoint', () async {
      final request = attriaxBuildSdkRuntimeConfigRequest(
        config: const AttriaxConfig(projectToken: 'ax_test_token'),
        context: const AttriaxContextSnapshot(
          platform: AttriaxPlatformType.android,
          deviceId: 'device_123',
          isFirstLaunch: true,
          sdk: AttriaxSdkSnapshot(
            apiVersion: '2025-01-01',
            packageVersion: '1.2.3',
          ),
          app: AttriaxAppSnapshot(
            version: '1.0.0',
            buildNumber: '1',
            packageName: 'com.attriax.test',
          ),
          device: AttriaxDeviceSnapshot(
            model: 'Pixel 9',
            metadata: <String, Object?>{
              'signingSha256Fingerprints': <String>['AA:BB', 'CC:DD'],
            },
          ),
        ),
      );

      final client = FakeHttpClient((requestMessage) async {
        expect(requestMessage.method, 'POST');
        expect(requestMessage.url.path, '/api/sdk/v1/config');

        final body =
            jsonDecode(_readRequestBody(requestMessage))
                as Map<String, Object?>;
        expect(body['appToken'], 'ax_test_token');
        expect(body['platform'], 'android');
        expect(body['packageName'], 'com.attriax.test');
        expect(body['signatureHashes'], <Object?>['AA:BB', 'CC:DD']);

        return _jsonResponse(200, <String, Object?>{
          'data': <String, Object?>{
            'requestVersion': 'v1',
            'acceptedAt': '2026-05-24T10:00:00.000Z',
            'clipboardAttributionEnabled': true,
          },
        });
      });

      final transport = _createTransport(client);
      final result = await transport.fetchSdkRuntimeConfig(request);

      expect(result.requestVersion, 'v1');
      expect(result.clipboardAttributionEnabled, isTrue);
      expect(result.acceptedAt, DateTime.parse('2026-05-24T10:00:00.000Z'));
    });

    test('sends event requests and maps acknowledge responses', () async {
      final client = FakeHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/sdk/v1/events');

        return _jsonResponse(202, _serializeGenerated(_ackEnvelope()));
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

          return _jsonResponse(202, _serializeGenerated(_ackEnvelope()));
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

          final items = body['items']! as List<Object?>;
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
                  !(item! as Map<String, Object?>).containsKey('requestId'),
            ),
            isTrue,
          );
          expect(
            items.every(
              (item) =>
                  !((item! as Map<String, Object?>)['body']!
                          as Map<String, Object?>)
                      .containsKey('appToken'),
            ),
            isTrue,
          );
          expect(
            items.every(
              (item) =>
                  !((item! as Map<String, Object?>)['body']!
                          as Map<String, Object?>)
                      .containsKey('deviceId'),
            ),
            isTrue,
          );

          return _jsonResponse(202, _serializeGenerated(_batchEnvelope()));
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

          return _jsonResponse(200, _serializeGenerated(_resolveEnvelope()));
        });

        final transport = _createTransport(client);
        final result = await transport.send(_resolveRequest());

        final response = result.response as AttriaxResolveDeepLinkApiResponse;
        expect(response.result.matched, isTrue);
        expect(response.result.deepLink?.path, '/offers/spring');
        expect(
          response.result.browserAction?.uri,
          Uri.parse('https://example.com/account'),
        );
        expect(
          response.result.browserAction?.openMode,
          AttriaxResolvedUrlOpenMode.external,
        );
        expect(response.result.reason, isNull);
      },
    );

    test(
      'surfaces browser fetch failures with a CORS hint for web SDK requests',
      () async {
        final client = FakeHttpClient((request) async {
          throw http.ClientException('Failed to fetch', request.url);
        });

        final transport = _createTransport(client);

        await expectLater(
          () => transport.send(_resolveRequest()),
          throwsA(
            isA<DioException>()
                .having(
                  (error) => error.message,
                  'message',
                  contains('/api/sdk/v1/deep-links/resolve'),
                )
                .having(
                  (error) => error.message,
                  'message',
                  contains('allowedWebOrigins'),
                )
                .having(
                  (error) => error.message,
                  'message',
                  contains('OPTIONS request returned 403'),
                ),
          ),
        );
      },
    );

    test('returns dynamic-link results from createDynamicLink', () async {
      final client = FakeHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/sdk/v1/dynamic-links');

        return _jsonResponse(200, _serializeGenerated(_dynamicLinkEnvelope()));
      });

      final transport = _createTransport(client);
      final result = await transport.createDynamicLink(_dynamicLinkRequest());

      expect(result.link.id, 'dl_123');
      expect(result.link.path, '/promo/spring');
      expect(result.link.shortUrl, 'https://ax.example/spring');
    });

    test('sends GDPR erasure requests as acknowledge-only calls', () async {
      final client = FakeHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/sdk/v1/privacy/gdpr/erase');

        final body =
            jsonDecode(_readRequestBody(request)) as Map<String, Object?>;
        expect(body['appToken'], 'ax_test_token');
        expect(body['deviceId'], 'device_123');
        expect(body.containsKey('consentId'), isFalse);

        return _jsonResponse(200, <String, Object?>{
          'success': true,
          'timestamp': '2026-05-24T10:00:00.000Z',
          'data': <String, Object?>{'success': true},
        });
      });

      final transport = _createTransport(client);
      await transport.eraseGdprData(
        projectToken: 'ax_test_token',
        deviceId: 'device_123',
      );
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
            isA<AttriaxTransportHttpException>()
                .having((error) => error.statusCode, 'statusCode', 503)
                .having(
                  (error) => error.toString(),
                  'toString()',
                  contains('HTTP 503'),
                )
                .having(
                  (error) => error.toString(),
                  'toString()',
                  contains('down'),
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
    app: sdk.AppVersionContextDto(version: '1.0.0'),
    appToken: 'ax_test_token',
    device: sdk.DeviceContextDto(),
    deviceId: 'device_123',
    deviceIdSource: 'android_ssaid',
    isFirstLaunch: true,
    platform: sdk.Platform.android,
    sdk: sdk.SdkVersionContextDto(
      apiVersion: '2025-01-01',
      packageVersion: '1.2.3',
    ),
  ),
);

AttriaxTrackEventRequest _eventRequest() => AttriaxTrackEventRequest(
  sdk.SdkEventDto(
    appToken: 'ax_test_token',
    deviceId: 'device_123',
    deviceIdSource: 'android_ssaid',
    eventName: 'purchase',
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
    createdAt: DateTime.utc(2026),
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
        projectToken: 'ax_test_token',
        deviceId: 'device_123',
        deviceIdSource: 'android_ssaid',
        isFirstLaunch: true,
        linkPath: '/offers/spring',
        platform: sdk.Platform.android,
        rawUrl: 'https://ax.example/offers/spring',
        source_: 'app_link',
      ),
    );

AttriaxCreateDynamicLinkRequest _dynamicLinkRequest() =>
    AttriaxCreateDynamicLinkRequest(
      sdk.SdkCreateDynamicLinkDto(
        projectToken: 'ax_test_token',
        name: 'Spring promo',
        destinationUrl: 'https://example.com/spring',
      ),
    );

sdk.SdkV1OpenResponseEnvelopeDto _openEnvelope() =>
    sdk.SdkV1OpenResponseEnvelopeDto(
      data: sdk.SdkV1OpenResponseDto(
        acceptedAt: DateTime.utc(2026),
        deepLink: sdk.SdkJsonDeepLinkDto(path: '/offers/spring'),
        installState: sdk.SdkInstallState.newInstall,
        isFirstLaunch: true,
        isNewUser: true,
        requestVersion: 'req_v1',
        userId: 'user_123',
      ),
      success: true,
      timestamp: DateTime.utc(2026),
    );

sdk.SdkAcknowledgeResponseEnvelopeDto _ackEnvelope() =>
    sdk.SdkAcknowledgeResponseEnvelopeDto(
      data: sdk.SdkAcknowledgeResponseDto(success: true),
      success: true,
      timestamp: DateTime.utc(2026),
    );

sdk.SdkV1BatchResponseEnvelopeDto _batchEnvelope() =>
    sdk.SdkV1BatchResponseEnvelopeDto(
      data: sdk.SdkV1BatchResponseDto(
        acceptedAt: DateTime.utc(2026),
        duplicateCount: 0,
        itemCount: 2,
        processedCount: 2,
        requestVersion: 'v1',
      ),
      success: true,
      timestamp: DateTime.utc(2026),
    );

sdk.SdkV1DeepLinkResolveResponseEnvelopeDto _resolveEnvelope() =>
    sdk.SdkV1DeepLinkResolveResponseEnvelopeDto(
      data: sdk.SdkV1DeepLinkResolveResponseDto(
        acceptedAt: DateTime.utc(2026),
        browserAction: sdk.SdkBrowserActionDto(
          openMode: sdk.RouteUrlOpenMode.external_,
          url: 'https://example.com/account',
        ),
        consumedAt: DateTime.utc(2026, 1, 1, 0, 0, 5),
        deepLink: sdk.SdkJsonDeepLinkDto(path: '/offers/spring'),
        isFirstLaunch: true,
        matched: true,
        requestVersion: 'req_v1',
        status: sdk.DeepLinkResolutionStatus.matched,
      ),
      success: true,
      timestamp: DateTime.utc(2026),
    );

sdk.SdkCreateDynamicLinkResponseEnvelopeDto _dynamicLinkEnvelope() =>
    sdk.SdkCreateDynamicLinkResponseEnvelopeDto(
      data: sdk.SdkCreateDynamicLinkResponseDto(
        acceptedAt: DateTime.utc(2026),
        link: sdk.SdkDynamicLinkRecordDto(
          createdAt: DateTime.utc(2026),
          id: 'dl_123',
          path: '/promo/spring',
          shortUrl: 'https://ax.example/spring',
        ),
        requestVersion: 'req_v1',
      ),
      success: true,
      timestamp: DateTime.utc(2026),
    );

Object? _serializeGenerated(Object value) {
  final dynamic serializable = value;
  return serializable.toJson();
}

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
