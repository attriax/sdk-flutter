import 'dart:convert';
import 'dart:async';

import 'package:attriax/attriax.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:attriax/src/internal/attriax_preferences_store.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/widgets.dart';
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
      await sdk.dispose();
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
        expect(contextCollector.collectContextSnapshotCalls, 1);
        expect(deepLinkSource.getInitialLinkCalls, 1);
      },
    );

    test('treats repeated init calls after success as a no-op', () async {
      await sdk.init(trackAppOpen: false);
      await sdk.init(trackAppOpen: false);

      expect(contextCollector.collectContextSnapshotCalls, 1);
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
        expect(contextCollector.collectedContextDeviceIds, <String>[
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
        expect(contextCollector.collectedContextDeviceIds, <String>[
          'android_ssaid_device',
        ]);
      },
    );

    test('creates and persists a current session snapshot', () async {
      final now = DateTime.utc(2026, 5, 3, 12, 0, 0);
      final clock = AttriaxMutableClock(now);
      sdk = Attriax.test(
        config: AttriaxConfig(appToken: 'ax_test_token', clock: clock),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init(trackAppOpen: false);

      final session = _storedSessionSnapshot(prefs);
      expect(session, isNotNull);
      expect(session!.deviceId, sdk.deviceId);
      expect(session.platform, AttriaxPlatformType.android);
      expect(session.startedAt, now);
      expect(session.lastActivityAt, now);
      expect(session.heartbeatInterval, const Duration(seconds: 5));
    });

    test('restores the current session while it is still active', () async {
      final now = DateTime.utc(2026, 5, 3, 12, 0, 0);
      final firstClock = AttriaxMutableClock(now);
      sdk = Attriax.test(
        config: AttriaxConfig(appToken: 'ax_test_token', clock: firstClock),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init(trackAppOpen: false);
      final initialSession = _storedSessionSnapshot(prefs);
      expect(initialSession, isNotNull);

      final secondDeepLinkSource = FakeDeepLinkSource();
      final secondClient = http.Client();
      final secondContextCollector = CountingContextCollector();
      final secondSdk = Attriax.test(
        config: AttriaxConfig(
          appToken: 'ax_test_token',
          clock: AttriaxMutableClock(now.add(const Duration(seconds: 5))),
        ),
        client: secondClient,
        deepLinkSource: secondDeepLinkSource,
        connectivity: connectivity,
        contextCollector: secondContextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await secondSdk.init(trackAppOpen: false);

      final restoredSession = _storedSessionSnapshot(prefs);
      expect(restoredSession, isNotNull);
      expect(restoredSession!.id, initialSession!.id);
      expect(restoredSession.startedAt, initialSession.startedAt);
      expect(
        restoredSession.lastActivityAt,
        now.add(const Duration(seconds: 5)),
      );

      await secondSdk.dispose();
      await secondDeepLinkSource.dispose();
      secondClient.close();
    });

    test(
      'starts a new session after the continuation window expires',
      () async {
        final now = DateTime.utc(2026, 5, 3, 12, 0, 0);
        final firstClock = AttriaxMutableClock(now);
        sdk = Attriax.test(
          config: AttriaxConfig(appToken: 'ax_test_token', clock: firstClock),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init(trackAppOpen: false);
        final initialSession = _storedSessionSnapshot(prefs);
        expect(initialSession, isNotNull);

        final secondDeepLinkSource = FakeDeepLinkSource();
        final secondClient = http.Client();
        final secondContextCollector = CountingContextCollector();
        final secondSdk = Attriax.test(
          config: AttriaxConfig(
            appToken: 'ax_test_token',
            clock: AttriaxMutableClock(now.add(const Duration(seconds: 11))),
          ),
          client: secondClient,
          deepLinkSource: secondDeepLinkSource,
          connectivity: connectivity,
          contextCollector: secondContextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await secondSdk.init(trackAppOpen: false);

        final newSession = _storedSessionSnapshot(prefs);
        expect(newSession, isNotNull);
        expect(newSession!.id, isNot(initialSession!.id));
        expect(newSession.startedAt, now.add(const Duration(seconds: 11)));

        await secondSdk.dispose();
        await secondDeepLinkSource.dispose();
        secondClient.close();
      },
    );

    test('queues track events with the active session metadata', () async {
      var now = DateTime.utc(2026, 5, 3, 12, 0, 0);
      final clock = AttriaxMutableClock(now);
      connectivityPlatform = FakeConnectivityPlatform(
        currentResults: const <ConnectivityResult>[ConnectivityResult.none],
      );
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      sdk = Attriax.test(
        config: AttriaxConfig(appToken: 'ax_test_token', clock: clock),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init(trackAppOpen: false);
      final session = _storedSessionSnapshot(prefs);
      expect(session, isNotNull);

      now = now.add(const Duration(seconds: 7));
      clock.currentTime = now;
      await sdk.recordEvent(
        'purchase',
        eventData: const <String, Object?>{'value': 42},
      );

      final queuedRaw = prefs.getString('attriax.queue.v1');
      expect(queuedRaw, isNotNull);

      final decoded = jsonDecode(queuedRaw!) as List<Object?>;
      expect(decoded, hasLength(1));

      final queued = decoded.single as Map<String, Object?>;
      final body = queued['body'] as Map<String, Object?>;
      expect(body['eventName'], 'purchase');
      expect(body['sessionId'], session!.id);
      expect(body['sessionRelativeTimeMs'], 7000);
      expect(body['clientOccurredAt'], now.toIso8601String());
    });

    test(
      'queues session heartbeats while the app stays foregrounded',
      () async {
        connectivityPlatform = FakeConnectivityPlatform(
          currentResults: const <ConnectivityResult>[ConnectivityResult.none],
        );
        ConnectivityPlatform.instance = connectivityPlatform;
        connectivity = Connectivity();
        sdk = Attriax.test(
          config: const AttriaxConfig(
            appToken: 'ax_test_token',
            sessionHeartbeatInterval: Duration(milliseconds: 25),
            firstLaunchSessionHeartbeatInterval: Duration(milliseconds: 25),
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init(trackAppOpen: false);
        final session = _storedSessionSnapshot(prefs);
        expect(session, isNotNull);

        await Future<void>.delayed(const Duration(milliseconds: 90));
        await _flushRuntimeTransitions();

        final bodies = _queuedBodiesFromPrefs(prefs);
        expect(bodies, isNotEmpty);
        expect(bodies.every((body) => body['kind'] == 'heartbeat'), isTrue);
        expect(bodies.first['sessionId'], session!.id);
      },
    );

    test(
      'queues pause and resume lifecycle telemetry for the same session',
      () async {
        var now = DateTime.utc(2026, 5, 3, 12, 0, 0);
        final clock = AttriaxMutableClock(now);
        connectivityPlatform = FakeConnectivityPlatform(
          currentResults: const <ConnectivityResult>[ConnectivityResult.none],
        );
        ConnectivityPlatform.instance = connectivityPlatform;
        connectivity = Connectivity();
        sdk = Attriax.test(
          config: AttriaxConfig(appToken: 'ax_test_token', clock: clock),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init(trackAppOpen: false);
        final session = _storedSessionSnapshot(prefs);
        expect(session, isNotNull);

        now = now.add(const Duration(seconds: 3));
        clock.currentTime = now;
        TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
          AppLifecycleState.paused,
        );
        await _flushRuntimeTransitions();

        now = now.add(const Duration(seconds: 3));
        clock.currentTime = now;
        TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await _flushRuntimeTransitions();

        final bodies = _queuedBodiesFromPrefs(prefs);
        expect(bodies.map((body) => body['kind']).toList(), <Object?>[
          'pause',
          'resume',
        ]);
        expect(bodies[0]['sessionId'], session!.id);
        expect(bodies[0]['sessionRelativeTimeMs'], 3000);
        expect(bodies[1]['sessionId'], session.id);
        expect(bodies[1]['sessionRelativeTimeMs'], 6000);
      },
    );
  });
}

AttriaxSessionSnapshot? _storedSessionSnapshot(SharedPreferences prefs) {
  final raw = prefs.getString(
    AttriaxPreferencesStore.sessionSnapshotStorageKey,
  );
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final decoded = jsonDecode(raw) as Map<String, Object?>;
  return AttriaxSessionSnapshot.fromJson(decoded);
}

List<Map<String, Object?>> _queuedBodiesFromPrefs(SharedPreferences prefs) {
  final queuedRaw = prefs.getString('attriax.queue.v1');
  expect(queuedRaw, isNotNull);

  final decoded = jsonDecode(queuedRaw!) as List<Object?>;
  return decoded
      .cast<Map<String, Object?>>()
      .map((entry) => entry['body'] as Map<String, Object?>)
      .toList(growable: false);
}

Future<void> _flushRuntimeTransitions() => pumpEventQueue(times: 20);

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

  FakeConnectivityPlatform({List<ConnectivityResult>? currentResults})
    : _currentResults =
          currentResults ?? const <ConnectivityResult>[ConnectivityResult.wifi];

  List<ConnectivityResult> _currentResults;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _currentResults;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  Future<void> emit(List<ConnectivityResult> results) async {
    _currentResults = results;
    _controller.add(results);
  }

  Future<void> dispose() => _controller.close();
}

class CountingContextCollector extends AttriaxContextCollector {
  CountingContextCollector()
    : super(config: const AttriaxConfig(appToken: 'ax_test_token'));

  int collectContextSnapshotCalls = 0;
  int resolvePreferredDeviceIdCalls = 0;
  final List<String> collectedContextDeviceIds = <String>[];
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
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
  }) async {
    collectContextSnapshotCalls += 1;
    collectedContextDeviceIds.add(deviceId);
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
