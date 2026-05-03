import 'dart:convert';

import 'package:attriax/attriax.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attriax.installReferrer', () {
    late SharedPreferences prefs;
    late Connectivity connectivity;
    late FakeConnectivityPlatform connectivityPlatform;
    late Attriax sdk;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      connectivityPlatform = FakeConnectivityPlatform();
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();

      sdk = Attriax.test(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/api/sdk/v1/open')) {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-04-29T12:00:00.000Z',
                'installReferrer': <String, Object?>{
                  'rawPlatformInstallReferrer':
                      'utm_source=attriax&utm_medium=cpc&utm_campaign=spring&utm_content=link_1',
                  'source': 'attriax',
                  'medium': 'cpc',
                  'campaign': 'spring',
                  'content': 'link_1',
                  'attributionType': 'referrer',
                  'precision': 1,
                },
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            _sdkEnvelope(<String, Object?>{}),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        }),
        deepLinkSource: FakeDeepLinkSource(),
        connectivity: connectivity,
        contextCollector: StaticPreparedContextCollector(),
        prefs: prefs,
        enableDebugLogs: false,
      );
    });

    tearDown(() async {
      await connectivityPlatform.dispose();
    });

    test('resolves from the first successful app-open response', () async {
      await sdk.init();

      final installReferrer = await sdk.installReferrer;

      expect(installReferrer, isNotNull);
      expect(installReferrer!.campaign, 'spring');
      expect(installReferrer.precision, 1);
    });

    test(
      'schedules app-open and referrer resolution after re-enable',
      () async {
        var appOpenRequests = 0;
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: MockClient((request) async {
            if (request.url.path.endsWith('/api/sdk/v1/open')) {
              appOpenRequests += 1;
              return http.Response(
                _sdkEnvelope(<String, Object?>{
                  'userId': 'user_1',
                  'isNewUser': true,
                  'isFirstLaunch': true,
                  'requestVersion': 'v1',
                  'acceptedAt': '2026-04-29T12:00:00.000Z',
                  'installReferrer': <String, Object?>{
                    'rawPlatformInstallReferrer':
                        'utm_source=attriax&utm_campaign=reenabled',
                    'source': 'attriax',
                    'campaign': 'reenabled',
                    'attributionType': 'referrer',
                    'precision': 1,
                  },
                }),
                200,
                headers: const <String, String>{
                  'content-type': 'application/json',
                },
              );
            }

            return http.Response(
              _sdkEnvelope(<String, Object?>{}),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }),
          deepLinkSource: FakeDeepLinkSource(),
          connectivity: connectivity,
          contextCollector: StaticPreparedContextCollector(),
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init(enabled: false);

        expect(await sdk.installReferrer, isNull);
        expect(appOpenRequests, 0);

        sdk.enabled = true;
        final installReferrer = await sdk.installReferrer;

        expect(appOpenRequests, 1);
        expect(installReferrer?.campaign, 'reenabled');

        sdk
          ..enabled = false
          ..enabled = true;
        await pumpEventQueue(times: 20);

        expect(appOpenRequests, 1);
      },
    );
  });
}

class FakeDeepLinkSource implements AttriaxDeepLinkSource {
  @override
  Future<Uri?> getInitialLink() async => null;

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();
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

class StaticPreparedContextCollector extends AttriaxContextCollector {
  StaticPreparedContextCollector()
    : super(config: const AttriaxConfig(appToken: 'ax_test_token'));

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
  }) async {
    return AttriaxContextSnapshot(
      platform: AttriaxPlatformType.android,
      deviceId: deviceId,
      isFirstLaunch: isFirstLaunch,
      sdk: const AttriaxSdkSnapshot(
        apiVersion: attriaxSdkApiVersion,
        packageVersion: attriaxSdkPackageVersion,
      ),
      app: const AttriaxAppSnapshot(
        version: '1.0.0',
        buildNumber: '1',
        packageName: 'com.attriax.test',
      ),
      device: const AttriaxDeviceSnapshot(model: 'Pixel', osVersion: '14'),
    );
  }
}

String _sdkEnvelope(Map<String, Object?> data) => jsonEncode(<String, Object?>{
  'success': true,
  'timestamp': '2026-04-29T12:00:00.000Z',
  'data': data,
});
