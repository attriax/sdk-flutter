import 'dart:convert';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:attriax_flutter/src/internal/attriax_context_collector.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attriax.referrer', () {
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
        config: const AttriaxConfig(projectToken: 'ax_test_token'),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/api/sdk/v1/open')) {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'installState': 'new_install',
                'requestVersion': 'v1',
                'acceptedAt': '2026-04-29T12:00:00.000Z',
                'originalInstallReferrer': <String, Object?>{
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

      final installReferrer = await sdk.referrer.getOriginalInstallReferrer();
      final reinstallReferrer = await sdk.referrer.getReinstallReferrer();

      expect(installReferrer, isNotNull);
      expect(installReferrer!.campaign, 'spring');
      expect(installReferrer.precision, 1);
      expect(reinstallReferrer, isNull);
    });

    test(
      'schedules app-open and referrer resolution after re-enable',
      () async {
        var appOpenRequests = 0;
        sdk = Attriax.test(
          config: const AttriaxConfig(projectToken: 'ax_test_token'),
          client: MockClient((request) async {
            if (request.url.path.endsWith('/api/sdk/v1/open')) {
              appOpenRequests += 1;
              return http.Response(
                _sdkEnvelope(<String, Object?>{
                  'userId': 'user_1',
                  'isNewUser': true,
                  'isFirstLaunch': true,
                  'installState': 'new_install',
                  'requestVersion': 'v1',
                  'acceptedAt': '2026-04-29T12:00:00.000Z',
                  'originalInstallReferrer': <String, Object?>{
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

        expect(await sdk.referrer.getOriginalInstallReferrer(), isNull);
        expect(appOpenRequests, 0);

        sdk.enabled = true;
        final installReferrer = await sdk.referrer.getOriginalInstallReferrer();

        expect(appOpenRequests, 1);
        expect(installReferrer?.campaign, 'reenabled');

        sdk
          ..enabled = false
          ..enabled = true;
        await pumpEventQueue();

        expect(appOpenRequests, 1);
      },
    );

    test(
      'returns only the raw install referrer when attribution consent is denied',
      () async {
        var consentRequests = 0;
        var openRequests = 0;
        final platform = _FakePlatform(
          installReferrerResponses:
              <Future<AttriaxInstallReferrerContext> Function()>[
                () async => const AttriaxInstallReferrerContext(
                  installReferrer: 'utm_source=play_store&utm_campaign=privacy',
                  metadata: <String, Object?>{'installReferrerStatus': 'ok'},
                ),
              ],
        );

        sdk = Attriax.test(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
            gdprAutoDetect: false,
          ),
          client: MockClient((request) async {
            if (request.url.path.endsWith('/api/sdk/v1/consent/gdpr')) {
              consentRequests += 1;
              return http.Response(
                _gdprEnvelope(<String, Object?>{
                  'checkedAt': '2026-05-20T12:00:00.000Z',
                  'countryCode': 'DE',
                  'needsConsent': false,
                  'regionSource': 'manual',
                  'state': 'granted',
                  'values': <String, Object?>{
                    'analytics': true,
                    'attribution': false,
                    'adEvents': false,
                  },
                }),
                200,
                headers: const <String, String>{
                  'content-type': 'application/json',
                },
              );
            }

            if (request.url.path.endsWith('/api/sdk/v1/open')) {
              openRequests += 1;
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
          contextCollector: AndroidPreparedContextCollector(platform: platform),
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: false,
          adEvents: false,
        );
        await _waitFor(() => consentRequests == 1);

        expect(await sdk.referrer.getOriginalInstallReferrer(), isNull);
        expect(await sdk.referrer.getReinstallReferrer(), isNull);
        expect(
          await sdk.referrer.getRawInstallReferrer(),
          'utm_source=play_store&utm_campaign=privacy',
        );
        expect(openRequests, 0);
        expect(platform.installReferrerCalls, 1);
        expect(
          prefs.getString(
            AttriaxPreferencesStore.platformInstallReferrerStorageKey,
          ),
          isNull,
        );
        expect(
          prefs.getString(
            AttriaxPreferencesStore.installReferrerDetailsStorageKey,
          ),
          isNull,
        );
      },
    );

    test(
      'captures iOS clipboard attribution once and sends WKWebView user agent on app open',
      () async {
        Map<String, Object?>? openPayload;
        var configRequests = 0;
        final platform =
            _FakePlatform(
                installReferrerResponses:
                    <Future<AttriaxInstallReferrerContext> Function()>[],
              )
              ..clipboardText = 'click-123'
              ..webViewUserAgent =
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15';

        sdk = Attriax.test(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
            gdprAutoDetect: false,
          ),
          client: MockClient((request) async {
            if (request.url.path.endsWith('/api/sdk/v1/consent/gdpr')) {
              return http.Response(
                _gdprEnvelope(<String, Object?>{
                  'checkedAt': '2026-05-20T12:00:00.000Z',
                  'countryCode': 'DE',
                  'needsConsent': true,
                  'regionSource': 'manual',
                  'state': 'granted',
                  'values': <String, Object?>{
                    'analytics': true,
                    'attribution': true,
                    'adEvents': false,
                  },
                }),
                200,
                headers: const <String, String>{
                  'content-type': 'application/json',
                },
              );
            }

            if (request.url.path.endsWith('/api/sdk/v1/config')) {
              configRequests += 1;
              return http.Response(
                _sdkEnvelope(<String, Object?>{
                  'requestVersion': 'v1',
                  'acceptedAt': '2026-05-20T11:59:59.000Z',
                  'clipboardAttributionEnabled': true,
                }),
                200,
                headers: const <String, String>{
                  'content-type': 'application/json',
                },
              );
            }

            if (request.url.path.endsWith('/api/sdk/v1/open')) {
              openPayload = Map<String, Object?>.from(
                jsonDecode(request.body) as Map<String, Object?>,
              );

              return http.Response(
                _sdkEnvelope(<String, Object?>{
                  'userId': 'user_1',
                  'isNewUser': true,
                  'isFirstLaunch': true,
                  'installState': 'new_install',
                  'requestVersion': 'v1',
                  'acceptedAt': '2026-05-20T12:00:00.000Z',
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
          contextCollector: AttriaxContextCollector(
            config: const AttriaxConfig(
              projectToken: 'ax_test_token',
              gdprEnabled: true,
              gdprAutoDetect: false,
            ),
            platform: platform,
            platformType: AttriaxPlatformType.ios,
          ),
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();

        await _waitFor(() => configRequests == 1);
        await _waitFor(() => platform.readAttributionClipboardCalls == 1);
        expect(openPayload, isNull);
        expect(configRequests, 1);
        expect(platform.readAttributionClipboardCalls, 1);
        expect(platform.collectWebViewUserAgentCalls, 0);

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: true,
          adEvents: false,
        );

        await _waitFor(() => openPayload != null);

        final device = openPayload!['device'] as Map<Object?, Object?>;
        final metadata = device['metadata'] as Map<Object?, Object?>;

        expect(openPayload!['installReferrer'], 'attriax_click_id=click-123');
        expect(metadata['wkWebViewUserAgent'], platform.webViewUserAgent);
        expect(device['advertisingId'], isNull);
        expect(device['model'], isNull);
        expect(device['screenWidth'], isA<num>());
        expect(platform.readAttributionClipboardCalls, 1);
        expect(platform.collectWebViewUserAgentCalls, 1);
      },
    );

    test(
      'retains captured iOS clipboard attribution in memory until attribution is granted',
      () async {
        Map<String, Object?>? openPayload;
        var consentRequests = 0;
        var configRequests = 0;
        final platform =
            _FakePlatform(
                installReferrerResponses:
                    <Future<AttriaxInstallReferrerContext> Function()>[],
              )
              ..clipboardText = 'click-denied-then-granted'
              ..webViewUserAgent = 'Mozilla/5.0 Attriax WKWebView';

        sdk = Attriax.test(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
            gdprAutoDetect: false,
          ),
          client: MockClient((request) async {
            if (request.url.path.endsWith('/api/sdk/v1/consent/gdpr')) {
              consentRequests += 1;
              final body = jsonDecode(request.body) as Map<String, Object?>;
              final values =
                  body['values'] as Map<String, Object?>? ??
                  const <String, Object?>{};
              final attribution = values['attribution'] == true;

              return http.Response(
                _gdprEnvelope(<String, Object?>{
                  'checkedAt': '2026-05-20T12:00:00.000Z',
                  'countryCode': 'DE',
                  'needsConsent': false,
                  'regionSource': 'manual',
                  'state': 'granted',
                  'values': <String, Object?>{
                    'analytics': true,
                    'attribution': attribution,
                    'adEvents': false,
                  },
                }),
                200,
                headers: const <String, String>{
                  'content-type': 'application/json',
                },
              );
            }

            if (request.url.path.endsWith('/api/sdk/v1/config')) {
              configRequests += 1;
              return http.Response(
                _sdkEnvelope(<String, Object?>{
                  'requestVersion': 'v1',
                  'acceptedAt': '2026-05-20T11:59:59.000Z',
                  'clipboardAttributionEnabled': true,
                }),
                200,
                headers: const <String, String>{
                  'content-type': 'application/json',
                },
              );
            }

            if (request.url.path.endsWith('/api/sdk/v1/open')) {
              openPayload = Map<String, Object?>.from(
                jsonDecode(request.body) as Map<String, Object?>,
              );

              return http.Response(
                _sdkEnvelope(<String, Object?>{
                  'userId': 'user_1',
                  'isNewUser': true,
                  'isFirstLaunch': true,
                  'installState': 'new_install',
                  'requestVersion': 'v1',
                  'acceptedAt': '2026-05-20T12:00:00.000Z',
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
          contextCollector: AttriaxContextCollector(
            config: const AttriaxConfig(
              projectToken: 'ax_test_token',
              gdprEnabled: true,
              gdprAutoDetect: false,
            ),
            platform: platform,
            platformType: AttriaxPlatformType.ios,
          ),
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        await _waitFor(() => configRequests == 1);
        await _waitFor(() => platform.readAttributionClipboardCalls == 1);

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: false,
          adEvents: false,
        );
        await _waitFor(() => consentRequests == 1);

        expect(openPayload, isNull);
        expect(configRequests, 1);
        expect(platform.readAttributionClipboardCalls, 1);
        expect(platform.collectWebViewUserAgentCalls, 0);

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: true,
          adEvents: false,
        );

        await _waitFor(() => openPayload != null);

        expect(
          openPayload!['installReferrer'],
          'attriax_click_id=click-denied-then-granted',
        );
        expect(platform.readAttributionClipboardCalls, 1);
        expect(platform.collectWebViewUserAgentCalls, 1);
      },
    );

    test(
      'defaults clipboard attribution to false when the config request fails',
      () async {
        Map<String, Object?>? openPayload;
        var configRequests = 0;
        final platform =
            _FakePlatform(
                installReferrerResponses:
                    <Future<AttriaxInstallReferrerContext> Function()>[],
              )
              ..clipboardText = 'click-config-failure'
              ..webViewUserAgent = 'Mozilla/5.0 Attriax WKWebView';

        sdk = Attriax.test(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
            gdprAutoDetect: false,
          ),
          client: MockClient((request) async {
            if (request.url.path.endsWith('/api/sdk/v1/consent/gdpr')) {
              return http.Response(
                _gdprEnvelope(<String, Object?>{
                  'checkedAt': '2026-05-20T12:00:00.000Z',
                  'countryCode': 'DE',
                  'needsConsent': true,
                  'regionSource': 'manual',
                  'state': 'granted',
                  'values': <String, Object?>{
                    'analytics': true,
                    'attribution': true,
                    'adEvents': false,
                  },
                }),
                200,
                headers: const <String, String>{
                  'content-type': 'application/json',
                },
              );
            }

            if (request.url.path.endsWith('/api/sdk/v1/config')) {
              configRequests += 1;
              return http.Response(
                'server error',
                500,
                headers: const <String, String>{'content-type': 'text/plain'},
              );
            }

            if (request.url.path.endsWith('/api/sdk/v1/open')) {
              openPayload = Map<String, Object?>.from(
                jsonDecode(request.body) as Map<String, Object?>,
              );

              return http.Response(
                _sdkEnvelope(<String, Object?>{
                  'userId': 'user_1',
                  'isNewUser': true,
                  'isFirstLaunch': true,
                  'installState': 'new_install',
                  'requestVersion': 'v1',
                  'acceptedAt': '2026-05-20T12:00:00.000Z',
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
          contextCollector: AttriaxContextCollector(
            config: const AttriaxConfig(
              projectToken: 'ax_test_token',
              gdprEnabled: true,
              gdprAutoDetect: false,
            ),
            platform: platform,
            platformType: AttriaxPlatformType.ios,
          ),
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();

        await _waitFor(() => configRequests == 1);
        expect(configRequests, 1);
        expect(platform.readAttributionClipboardCalls, 0);

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: true,
          adEvents: false,
        );

        await _waitFor(() => openPayload != null);

        final device = openPayload!['device'] as Map<Object?, Object?>;
        final metadata = device['metadata'] as Map<Object?, Object?>;

        expect(openPayload!.containsKey('installReferrer'), isFalse);
        expect(metadata['wkWebViewUserAgent'], platform.webViewUserAgent);
        expect(platform.collectWebViewUserAgentCalls, 1);
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
    : super(config: const AttriaxConfig(projectToken: 'ax_test_token'));

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
    bool waitForTrackingAuthorization = false,
  }) async => AttriaxContextSnapshot(
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

class AndroidPreparedContextCollector extends AttriaxContextCollector {
  AndroidPreparedContextCollector({required AttriaxPlatform platform})
    : super(
        config: const AttriaxConfig(projectToken: 'ax_test_token'),
        platform: platform,
        platformType: AttriaxPlatformType.android,
      );

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
    bool waitForTrackingAuthorization = false,
  }) async => AttriaxContextSnapshot(
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

class _FakePlatform extends AttriaxPlatform {
  _FakePlatform({required this.installReferrerResponses});

  final List<Future<AttriaxInstallReferrerContext> Function()>
  installReferrerResponses;
  int installReferrerCalls = 0;
  int readAttributionClipboardCalls = 0;
  int collectWebViewUserAgentCalls = 0;
  String? clipboardText;
  String? webViewUserAgent;

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async {
    final callIndex = installReferrerCalls;
    installReferrerCalls += 1;
    if (callIndex >= installReferrerResponses.length) {
      return const AttriaxInstallReferrerContext();
    }

    return installReferrerResponses[callIndex]();
  }

  @override
  Future<String?> readAttributionClipboard() async {
    readAttributionClipboardCalls += 1;
    return clipboardText;
  }

  @override
  Future<String?> collectWebViewUserAgent() async {
    collectWebViewUserAgentCalls += 1;
    return webViewUserAgent;
  }
}

String _sdkEnvelope(Map<String, Object?> data) => jsonEncode(<String, Object?>{
  'success': true,
  'timestamp': '2026-04-29T12:00:00.000Z',
  'data': data,
});

String _gdprEnvelope(Map<String, Object?> data) => jsonEncode(<String, Object?>{
  'success': true,
  'timestamp': '2026-05-20T12:00:00.000Z',
  'data': data,
});

Future<void> _waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
  Duration step = const Duration(milliseconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(step);
  }

  if (condition()) {
    return;
  }

  throw StateError('Timed out while waiting for asynchronous referrer work.');
}
