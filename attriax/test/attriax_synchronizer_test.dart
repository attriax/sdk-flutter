import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_synchronizer.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support/fake_generated_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxSynchronizer', () {
    late FakeConnectivityPlatform connectivityPlatform;
    late Connectivity connectivity;
    late AttriaxPreferencesStore preferencesStore;
    late FakeGeneratedTransport transport;
    late AttriaxSynchronizer synchronizer;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      preferencesStore = AttriaxPreferencesStore(prefsOverride: prefs);
      connectivityPlatform = FakeConnectivityPlatform();
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      transport = FakeGeneratedTransport();
      synchronizer = AttriaxSynchronizer(
        transport: transport,
        connectivity: connectivity,
        preferencesStore: preferencesStore,
        maxQueueSize: 10,
        eventFlushInterval: const Duration(milliseconds: 40),
        logger: AttriaxLogger(enableDebugLogs: false),
      );
    });

    tearDown(() async {
      await synchronizer.dispose();
      await connectivityPlatform.dispose();
    });

    test(
      'defers regular event flushes until the configured interval',
      () async {
        await synchronizer.enqueue(
          _eventRequest('signup_started'),
          flushImmediately: false,
        );

        expect(
          synchronizer.synchronizationState,
          AttriaxSynchronizationState.deferred,
        );
        await Future<void>.delayed(const Duration(milliseconds: 15));
        expect(transport.sentBatches, isEmpty);
        expect(
          synchronizer.synchronizationState,
          AttriaxSynchronizationState.deferred,
        );

        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(transport.sentBatches, hasLength(1));
        expect(
          synchronizer.synchronizationState,
          AttriaxSynchronizationState.synchronized,
        );
        expect(
          transport.sentBatches.single
              .map((request) => request.request.toQueueBody()['eventName'])
              .toList(),
          <Object?>['signup_started'],
        );
      },
    );

    test(
      'immediate flushes drain the current deferred batch right away',
      () async {
        await synchronizer.enqueue(
          _eventRequest('signup_started'),
          flushImmediately: false,
        );

        await Future<void>.delayed(const Duration(milliseconds: 15));
        expect(transport.sentBatches, isEmpty);

        await synchronizer.enqueue(_eventRequest('purchase'));
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(transport.sentBatches, hasLength(1));
        expect(
          transport.sentBatches.single
              .map((request) => request.request.toQueueBody()['eventName'])
              .toList(),
          <Object?>['signup_started', 'purchase'],
        );

        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(transport.sentBatches, hasLength(1));
      },
    );

    test(
      'dispose completes pending request callbacks instead of hanging',
      () async {
        Object? failedError;
        await synchronizer.enqueue(
          _eventRequest('signup_started'),
          onError: (error, _) => failedError = error,
          flushImmediately: false,
        );

        await synchronizer.dispose();

        // A still-pending callback (e.g. an awaited manual deep-link
        // resolution) must be released on dispose, not left hanging forever.
        expect(failedError, isNotNull);
      },
    );
  });
}

AttriaxTrackEventRequest _eventRequest(String eventName) =>
    attriaxBuildTrackEventRequest(
      projectToken: 'ax_test_token',
      deviceId: 'device_1',
      deviceIdSource: 'android_ssaid',
      eventName: eventName,
      eventData: const <String, Object?>{'value': 42},
    );

class FakeConnectivityPlatform extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      <ConnectivityResult>[ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();

  Future<void> dispose() async {}
}
