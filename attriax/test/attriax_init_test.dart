import 'dart:async';

import 'package:attriax/attriax.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attriax.init', () {
    late FakeDeepLinkSource deepLinkSource;
    late Connectivity connectivity;
    late FakeConnectivityPlatform connectivityPlatform;
    late CountingContextCollector contextCollector;
    late SharedPreferences prefs;
    late http.Client client;
    late Attriax sdk;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      deepLinkSource = FakeDeepLinkSource();
      connectivityPlatform = FakeConnectivityPlatform();
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      contextCollector = CountingContextCollector();
      client = http.Client();
      sdk = Attriax.test(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );
    });

    tearDown(() async {
      await deepLinkSource.dispose();
      await connectivityPlatform.dispose();
      client.close();
    });

    test(
      'shares a single initialization pass across concurrent callers',
      () async {
        await Future.wait(<Future<void>>[
          sdk.init(trackAppOpen: false),
          sdk.init(trackAppOpen: false),
          sdk.init(trackAppOpen: false),
        ]);

        expect(sdk.isInitialized, isTrue);
        expect(contextCollector.collectCalls, 1);
        expect(deepLinkSource.getInitialLinkCalls, 1);
      },
    );

    test('treats repeated init calls after success as a no-op', () async {
      await sdk.init(trackAppOpen: false);
      await sdk.init(trackAppOpen: false);

      expect(contextCollector.collectCalls, 1);
      expect(deepLinkSource.getInitialLinkCalls, 1);
    });
  });
}

class FakeDeepLinkSource implements AttriaxDeepLinkSource {
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();
  int getInitialLinkCalls = 0;

  @override
  Future<Uri?> getInitialLink() async {
    getInitialLinkCalls += 1;
    return null;
  }

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  Future<void> dispose() => _controller.close();
}

class FakeConnectivityPlatform extends ConnectivityPlatform {
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      <ConnectivityResult>[ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  Future<void> dispose() => _controller.close();
}

class CountingContextCollector extends AttriaxContextCollector {
  CountingContextCollector()
    : super(config: const AttriaxConfig(appToken: 'ax_test_token'));

  int collectCalls = 0;

  @override
  Future<AttriaxContextSnapshot> collect({
    required String deviceId,
    required bool isFirstLaunch,
  }) async {
    collectCalls += 1;
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
      device: const AttriaxDeviceSnapshot(model: 'Test Device', osVersion: '1'),
    );
  }
}
