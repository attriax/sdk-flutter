import 'dart:async';

import 'package:attriax/attriax.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:attriax/src/internal/attriax_preferences_store.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attriax settings transitions', () {
    late SharedPreferences prefs;
    late Connectivity connectivity;
    late FakeConnectivityPlatform connectivityPlatform;
    late http.Client client;
    late Attriax sdk;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      connectivityPlatform = FakeConnectivityPlatform();
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      client = http.Client();

      sdk = Attriax.test(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        client: client,
        deepLinkSource: FakeDeepLinkSource(),
        connectivity: connectivity,
        contextCollector: StaticPreparedContextCollector(),
        prefs: prefs,
        enableDebugLogs: false,
      );
    });

    tearDown(() async {
      await sdk.dispose();
      await connectivityPlatform.dispose();
    });

    test('persists enabled changes after init', () async {
      await sdk.init(trackAppOpen: false);

      sdk.enabled = false;
      await _flushRuntimeTransitions();

      expect(sdk.enabled, isFalse);
      expect(prefs.getBool(AttriaxPreferencesStore.enabledStorageKey), isFalse);

      sdk.enabled = true;
      await _flushRuntimeTransitions();

      expect(sdk.enabled, isTrue);
      expect(prefs.getBool(AttriaxPreferencesStore.enabledStorageKey), isTrue);
    });

    test('persists eventsEnabled changes after init', () async {
      await sdk.init(trackAppOpen: false);

      sdk.eventsEnabled = false;
      await _flushRuntimeTransitions();

      expect(sdk.eventsEnabled, isFalse);
      expect(
        prefs.getBool(AttriaxPreferencesStore.eventsEnabledStorageKey),
        isFalse,
      );

      sdk.eventsEnabled = true;
      await _flushRuntimeTransitions();

      expect(sdk.eventsEnabled, isTrue);
      expect(
        prefs.getBool(AttriaxPreferencesStore.eventsEnabledStorageKey),
        isTrue,
      );
    });

    test(
      'respects a pre-init enabled override during initialization',
      () async {
        sdk.enabled = false;
        await _flushRuntimeTransitions();

        await sdk.init(trackAppOpen: false);

        expect(sdk.enabled, isFalse);
        expect(
          prefs.getBool(AttriaxPreferencesStore.enabledStorageKey),
          isFalse,
        );
      },
    );
  });
}

Future<void> _flushRuntimeTransitions() => pumpEventQueue(times: 20);

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
