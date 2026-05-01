import 'dart:async';

import 'package:attriax/attriax.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:attriax/src/internal/attriax_preferences_store.dart';
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
        expect(contextCollector.prepareCalls, 1);
        expect(deepLinkSource.getInitialLinkCalls, 1);
      },
    );

    test('treats repeated init calls after success as a no-op', () async {
      await sdk.init(trackAppOpen: false);
      await sdk.init(trackAppOpen: false);

      expect(contextCollector.prepareCalls, 1);
      expect(deepLinkSource.getInitialLinkCalls, 1);
    });

    test(
      'treats a legacy stored device id as persistent storage and does not re-resolve',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AttriaxPreferencesStore.deviceIdStorageKey: 'sdk_fallback_device',
        });
        prefs = await SharedPreferences.getInstance();
        contextCollector = CountingContextCollector();
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init(trackAppOpen: false);

        expect(sdk.sdkSnapshot, isNotNull);
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
          'sdk_fallback_device',
        );
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdSourceStorageKey),
          attriaxPersistentStorageDeviceIdSource,
        );
        expect(contextCollector.resolvePreferredDeviceIdCalls, 0);
        expect(contextCollector.prepareDeviceIds, <String>[
          'sdk_fallback_device',
        ]);
      },
    );

    test(
      'persists the resolved platform-derived device id and source',
      () async {
        contextCollector = CountingContextCollector()
          ..resolvedDeviceId = const AttriaxResolvedDeviceId(
            value: 'android_ssaid_device',
            source: 'android_ssaid',
          );
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init(trackAppOpen: false);

        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
          'android_ssaid_device',
        );
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdSourceStorageKey),
          'android_ssaid',
        );
        expect(contextCollector.resolvePreferredDeviceIdCalls, 1);
        expect(contextCollector.prepareDeviceIds, <String>[
          'android_ssaid_device',
        ]);
      },
    );

    test('does not await background context resolution during init', () async {
      final blockingContextCollector = BlockingContextCollector();
      sdk = Attriax.test(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: blockingContextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init(trackAppOpen: false);

      expect(sdk.isInitialized, isTrue);
      expect(blockingContextCollector.prepareCalls, 1);
      expect(blockingContextCollector.hasResolvedSnapshot, isFalse);

      blockingContextCollector.completeResolvedSnapshot();
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

  int prepareCalls = 0;
  int resolvePreferredDeviceIdCalls = 0;
  final List<String> prepareDeviceIds = <String>[];
  AttriaxResolvedDeviceId? resolvedDeviceId;

  @override
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) async {
    resolvePreferredDeviceIdCalls += 1;
    return resolvedDeviceId ??
        AttriaxResolvedDeviceId(
          value: fallbackDeviceId,
          source: attriaxPersistentStorageDeviceIdSource,
          isFallback: true,
        );
  }

  @override
  Future<AttriaxPreparedContext> prepare({
    required String deviceId,
    required bool isFirstLaunch,
    bool resolveInstallReferrer = true,
  }) async {
    prepareCalls += 1;
    prepareDeviceIds.add(deviceId);
    final snapshot = AttriaxContextSnapshot(
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

    return AttriaxPreparedContext(
      initialSnapshot: snapshot,
      resolvedSnapshot: Future<AttriaxContextSnapshot>.value(snapshot),
    );
  }
}

class BlockingContextCollector extends AttriaxContextCollector {
  BlockingContextCollector()
    : super(config: const AttriaxConfig(appToken: 'ax_test_token'));

  int prepareCalls = 0;
  final Completer<AttriaxContextSnapshot> _resolvedSnapshotCompleter =
      Completer<AttriaxContextSnapshot>();
  AttriaxContextSnapshot? _snapshot;

  bool get hasResolvedSnapshot => _resolvedSnapshotCompleter.isCompleted;

  @override
  Future<AttriaxPreparedContext> prepare({
    required String deviceId,
    required bool isFirstLaunch,
    bool resolveInstallReferrer = true,
  }) async {
    prepareCalls += 1;
    _snapshot = AttriaxContextSnapshot(
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

    return AttriaxPreparedContext(
      initialSnapshot: _snapshot!,
      resolvedSnapshot: _resolvedSnapshotCompleter.future,
    );
  }

  void completeResolvedSnapshot() {
    if (_snapshot != null && !_resolvedSnapshotCompleter.isCompleted) {
      _resolvedSnapshotCompleter.complete(_snapshot!);
    }
  }
}
