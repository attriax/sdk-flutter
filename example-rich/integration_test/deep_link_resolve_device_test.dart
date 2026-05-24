import 'dart:async';
import 'dart:convert';

import 'package:attriax_api_client/attriax_api_client.dart' as sdk;
import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:attriax_flutter/src/internal/attriax_context_collector.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('initial deep links hit the resolve endpoint on device', (
    tester,
  ) async {
    final openRequestCompleter = Completer<_RecordedRequest>();
    final resolveRequestCompleter = Completer<_RecordedRequest>();
    final client = _FakeHttpClient((request) async {
      final typedRequest = request as http.Request;
      final decodedBody =
          (jsonDecode(utf8.decode(typedRequest.bodyBytes)) as Map)
              .cast<String, Object?>();
      final recorded = _RecordedRequest(
        path: request.url.path,
        body: decodedBody,
      );

      switch (request.url.path) {
        case '/api/sdk/v1/open':
          if (!openRequestCompleter.isCompleted) {
            openRequestCompleter.complete(recorded);
          }
          return _jsonResponse(200, _serializeGenerated(_openEnvelope()));
        case '/api/sdk/v1/deep-links/resolve':
          if (!resolveRequestCompleter.isCompleted) {
            resolveRequestCompleter.complete(recorded);
          }
          return _jsonResponse(200, _serializeGenerated(_resolveEnvelope()));
        default:
          return _jsonResponse(404, <String, Object?>{
            'success': false,
            'timestamp': DateTime.utc(2026, 1).toIso8601String(),
            'message': 'Unhandled test path ${request.url.path}',
          });
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final config = AttriaxConfig(
      appToken: 'ax_test_token',
      apiBaseUrl: 'https://api.attriax.test',
      requestTimeout: const Duration(seconds: 5),
      automaticCrashReportingEnabled: false,
      sessionTrackingEnabled: false,
    );
    final attriax = Attriax.test(
      config: config,
      client: client,
      deepLinkSource: _InitialDeepLinkSource(
        Uri.parse('attriaxexample://promo/device?utm_source=device'),
      ),
      connectivity: Connectivity(),
      contextCollector: _StaticContextCollector(config: config),
      prefs: prefs,
      enableDebugLogs: true,
    );

    addTearDown(() async {
      await attriax.reset();
      client.close();
    });

    await attriax.init();

    final initialEvent = await attriax.deepLinks
        .waitForInitialDeepLink()
        .timeout(const Duration(seconds: 10));
    expect(initialEvent, isNotNull);

    final openRequest = await openRequestCompleter.future.timeout(
      const Duration(seconds: 10),
    );
    final resolveRequest = await resolveRequestCompleter.future.timeout(
      const Duration(seconds: 10),
    );

    expect(initialEvent!.found, isTrue);
    expect(openRequest.path, '/api/sdk/v1/open');
    expect(resolveRequest.path, '/api/sdk/v1/deep-links/resolve');
    expect(
      resolveRequest.body['rawUrl'],
      'attriaxexample://promo/device?utm_source=device',
    );
    expect(resolveRequest.body['linkPath'], 'promo/device');

    final metadata =
        resolveRequest.body['metadata'] as Map<String, Object?>? ??
        const <String, Object?>{};
    expect(metadata['isInitialLink'], true);
    expect(metadata['queryParameters'], <String, Object?>{
      'utm_source': <Object?>['device'],
    });
  });
}

sdk.SdkV1OpenResponseEnvelopeDto _openEnvelope() =>
    sdk.SdkV1OpenResponseEnvelopeDto(
      data: sdk.SdkV1OpenResponseDto(
        acceptedAt: DateTime.utc(2026, 1, 1, 0, 0, 0),
        installState: sdk.SdkInstallState.existing,
        isFirstLaunch: true,
        isNewUser: true,
        requestVersion: 'req_v1',
        userId: 'user_1',
      ),
      success: true,
      timestamp: DateTime.utc(2026, 1, 1, 0, 0, 0),
    );

sdk.SdkV1DeepLinkResolveResponseEnvelopeDto _resolveEnvelope() =>
    sdk.SdkV1DeepLinkResolveResponseEnvelopeDto(
      data: sdk.SdkV1DeepLinkResolveResponseDto(
        acceptedAt: DateTime.utc(2026, 1, 1, 0, 0, 0),
        consumedAt: DateTime.utc(2026, 1, 1, 0, 0, 5),
        deepLink: sdk.SdkJsonDeepLinkDto(
          path: '/promo/device',
          uri:
              'https://example-test.attriax.com/promo/device?utm_source=device',
        ),
        isFirstLaunch: true,
        matched: true,
        requestVersion: 'req_v1',
        status: sdk.DeepLinkResolutionStatus.matched,
      ),
      success: true,
      timestamp: DateTime.utc(2026, 1, 1, 0, 0, 0),
    );

Object? _serializeGenerated(Object value) {
  final dynamic serializable = value;
  return serializable.toJson();
}

http.StreamedResponse _jsonResponse(int statusCode, Object? body) =>
    http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
      statusCode,
      headers: const <String, String>{'content-type': 'application/json'},
    );

class _RecordedRequest {
  const _RecordedRequest({required this.path, required this.body});

  final String path;
  final Map<String, Object?> body;
}

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _handler(request);
}

class _InitialDeepLinkSource implements AttriaxDeepLinkSource {
  const _InitialDeepLinkSource(this.initialUri);

  final Uri initialUri;

  @override
  Future<Uri?> getInitialLink() async => initialUri;

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();
}

class _StaticContextCollector extends AttriaxContextCollector {
  _StaticContextCollector({required super.config})
    : super(platformType: AttriaxPlatformType.unknown);

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
  }) async => AttriaxContextSnapshot(
    platform: AttriaxPlatformType.android,
    deviceId: deviceId,
    isFirstLaunch: isFirstLaunch,
    sdk: const AttriaxSdkSnapshot(
      apiVersion: attriaxSdkApiVersion,
      packageVersion: attriaxSdkPackageVersion,
    ),
    app: AttriaxAppSnapshot(
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'com.attriax.example',
    ),
    device: AttriaxDeviceSnapshot(
      model: 'Pixel Test Device',
      osVersion: '14',
      language: 'en-US',
      timezone: 'UTC',
    ),
  );

  @override
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) async => const AttriaxResolvedDeviceId(
    value: 'device_test_android',
    source: 'android_ssaid',
  );
}
