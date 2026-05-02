import 'dart:async';

import 'package:attriax/src/internal/attriax_api_models.dart';
import 'package:attriax/src/internal/attriax_app_open_tracker.dart';
import 'package:attriax/src/internal/attriax_event_hub.dart';
import 'package:attriax/src/internal/attriax_generated_transport.dart';
import 'package:attriax/src/internal/attriax_logger.dart';
import 'package:attriax/src/internal/attriax_synchronizer.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxAppOpenTracker', () {
    late SharedPreferences prefs;
    late Connectivity connectivity;
    late FakeConnectivityPlatform connectivityPlatform;
    late FakeSynchronizer synchronizer;
    late AttriaxEventHub eventHub;
    late AttriaxAppOpenTracker tracker;
    late AttriaxContextSnapshot context;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      connectivityPlatform = FakeConnectivityPlatform();
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      synchronizer = FakeSynchronizer(prefs: prefs, connectivity: connectivity);
      eventHub = AttriaxEventHub();
      tracker = AttriaxAppOpenTracker();
      context = const AttriaxContextSnapshot(
        platform: AttriaxPlatformType.android,
        deviceId: 'device_1',
        isFirstLaunch: true,
        sdk: AttriaxSdkSnapshot(
          apiVersion: attriaxSdkApiVersion,
          packageVersion: attriaxSdkPackageVersion,
        ),
        app: AttriaxAppSnapshot(
          version: '1.0.0',
          buildNumber: '1',
          packageName: 'com.attriax.test',
        ),
        device: AttriaxDeviceSnapshot(model: 'Pixel', osVersion: '14'),
      );
    });

    tearDown(() async {
      await eventHub.dispose();
      await synchronizer.dispose();
      await connectivityPlatform.dispose();
    });

    test('returns null immediately when no app-open was scheduled', () async {
      expect(await tracker.waitForResult(), isNull);
    });

    test(
      'schedules at most one request and reuses the successful result',
      () async {
        await tracker.schedule(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          contextFuture: Future<AttriaxContextSnapshot>.value(context),
          deviceIdSource: 'android_ssaid',
          synchronizer: synchronizer,
          eventHub: eventHub,
          logger: AttriaxLogger(enableDebugLogs: false),
        );
        await tracker.schedule(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          contextFuture: Future<AttriaxContextSnapshot>.value(context),
          deviceIdSource: 'android_ssaid',
          synchronizer: synchronizer,
          eventHub: eventHub,
          logger: AttriaxLogger(enableDebugLogs: false),
        );

        expect(synchronizer.enqueueCalls, 1);

        const result = AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: true,
          isFirstLaunch: true,
        );
        synchronizer.completeSuccess(
          const AttriaxOpenApiResponse(result: result),
        );

        expect(await tracker.waitForResult(), same(result));
        expect(tracker.lastResult, same(result));
        expect(await tracker.waitForResult(), same(result));
      },
    );

    test('emits a deferred deep link when app-open returns one', () async {
      await tracker.schedule(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        contextFuture: Future<AttriaxContextSnapshot>.value(context),
        deviceIdSource: 'android_ssaid',
        synchronizer: synchronizer,
        eventHub: eventHub,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      final emittedEventFuture = eventHub.deepLinks.first;
      const result = AttriaxAppOpenResult(
        userId: 'user_1',
        isNewUser: true,
        isFirstLaunch: true,
        acceptedAt: null,
        deepLink: AttriaxDeepLink(path: 'promo/spring-launch'),
      );
      synchronizer.completeSuccess(
        const AttriaxOpenApiResponse(result: result),
      );

      final emittedEvent = await emittedEventFuture;
      final emittedResult = await emittedEvent.resolve();

      expect(emittedResult.isMatched, isTrue);
      expect(emittedResult.isDeferred, isTrue);
      expect(emittedResult.resolution?.deepLink.path, 'promo/spring-launch');
    });

    test('propagates context resolution errors', () async {
      await tracker.schedule(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        contextFuture: Future<AttriaxContextSnapshot>.error(
          StateError('context failed'),
          StackTrace.empty,
        ),
        deviceIdSource: 'android_ssaid',
        synchronizer: synchronizer,
        eventHub: eventHub,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      await expectLater(tracker.waitForResult(), throwsA(isA<StateError>()));
    });
  });
}

class FakeSynchronizer extends AttriaxSynchronizer {
  FakeSynchronizer({
    required SharedPreferences prefs,
    required Connectivity connectivity,
  }) : super(
         transport: FakeTransport(),
         connectivity: connectivity,
         prefs: prefs,
         maxQueueSize: 10,
         logger: AttriaxLogger(enableDebugLogs: false),
       );

  int enqueueCalls = 0;
  void Function(AttriaxApiResponse response)? _onSuccess;
  void Function(Object error, StackTrace? stackTrace)? _onError;

  @override
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
  }) async {
    enqueueCalls += 1;
    _onSuccess = onSuccess;
    _onError = onError;
  }

  void completeSuccess(AttriaxApiResponse response) {
    _onSuccess?.call(response);
  }

  void completeError(Object error, {StackTrace? stackTrace}) {
    _onError?.call(error, stackTrace);
  }
}

class FakeTransport implements AttriaxGeneratedTransport {
  @override
  Future<AttriaxTransportSuccess> send(AttriaxApiRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink(
    AttriaxCreateDynamicLinkRequest request,
  ) {
    throw UnimplementedError();
  }
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
