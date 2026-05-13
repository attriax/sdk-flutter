import 'dart:async';

import 'package:attriax_flutter/src/attriax_deep_link_source.dart';
import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_context_collector.dart';
import 'package:attriax_flutter/src/internal/attriax_context_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_deep_link_listener.dart';
import 'package:attriax_flutter/src/internal/attriax_deep_link_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_event_hub.dart';
import 'package:attriax_flutter/src/internal/attriax_generated_transport.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_request_manager.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxDeepLinkManager', () {
    late AttriaxEventHub eventHub;
    late AttriaxContextManager contextManager;
    late _FakeRequestManager requestManager;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AttriaxPreferencesStore.firstLaunchSeenStorageKey: true,
        AttriaxPreferencesStore.deviceIdStorageKey: 'device_1',
        AttriaxPreferencesStore.deviceIdSourceStorageKey: 'android_ssaid',
      });
      prefs = await SharedPreferences.getInstance();
      eventHub = AttriaxEventHub();
      requestManager = _FakeRequestManager();
      contextManager = await _createContextManager(prefs: prefs);
    });

    tearDown(() async {
      await eventHub.dispose();
    });

    test(
      'resolves manual deep-link conversion through the request manager',
      () async {
        final emittedEvents = <Object?>[];
        final manager = AttriaxDeepLinkManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          contextManager: contextManager,
          listener: AttriaxDeepLinkListener(
            deepLinkSource: _FakeDeepLinkSource(),
          ),
          eventHub: eventHub,
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          requestManager: requestManager,
          logger: AttriaxLogger(enableDebugLogs: false),
        );
        final subscription = manager.stream.listen(emittedEvents.add);
        addTearDown(subscription.cancel);

        final resolutionFuture = manager.recordManualConversion(
          uri: Uri.parse('https://example.com/promo/manual'),
          metadata: const <String, Object?>{'source': 'test'},
          source: 'manual_test',
        );

        requestManager.completeSuccess(
          const AttriaxResolveDeepLinkApiResponse(
            result: AttriaxDeepLinkResolutionResult(
              matched: true,
              status: AttriaxDeepLinkResolutionStatus.matched,
              isFirstLaunch: false,
              deepLink: AttriaxDeepLink(path: 'promo/manual'),
            ),
          ),
        );

        final result = await resolutionFuture;
        await pumpEventQueue();

        expect(result, isNotNull);
        expect(result!.found, isTrue);
        expect(result.data, isNull);
        expect(emittedEvents, isEmpty);
        expect(manager.latestDeepLink, isNull);
        expect(
          requestManager.lastRequest,
          isA<AttriaxResolveDeepLinkRequest>(),
        );
        expect(
          requestManager.lastRequest?.toQueueBody()['source'],
          'manual_test',
        );
      },
    );

    test('emits a deferred deep link from app-open results', () async {
      String? currentSessionId = 'session_1';
      final manager = AttriaxDeepLinkManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        contextManager: contextManager,
        listener: AttriaxDeepLinkListener(
          deepLinkSource: _FakeDeepLinkSource(),
        ),
        eventHub: eventHub,
        preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
        currentSessionIdProvider: () => currentSessionId,
        requestManager: requestManager,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      final emittedEventFuture = manager.stream.first;
      await manager.handleDeferredAppOpen(
        const AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: true,
          isFirstLaunch: true,
          deepLink: AttriaxDeepLink(path: 'promo/deferred'),
        ),
      );

      final emittedEvent = await emittedEventFuture;
      final emittedResult = await emittedEvent.resolve();

      expect(emittedEvent.isDeferred, isTrue);
      expect(emittedEvent.uri.path, '/promo/deferred');
      expect(emittedResult.found, isTrue);
      expect(emittedResult.data, isNull);
      expect(manager.latestDeepLink, same(emittedEvent));
    });

    test(
      'suppresses deferred deep links for app-data-clear launches',
      () async {
        String? currentSessionId = 'session_1';
        final manager = AttriaxDeepLinkManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          contextManager: contextManager,
          listener: AttriaxDeepLinkListener(
            deepLinkSource: _FakeDeepLinkSource(),
          ),
          eventHub: eventHub,
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          currentSessionIdProvider: () => currentSessionId,
          requestManager: requestManager,
          logger: AttriaxLogger(enableDebugLogs: false),
        );

        final emittedEvents = <Object?>[];
        final subscription = manager.stream.listen(emittedEvents.add);
        addTearDown(subscription.cancel);

        await manager.handleDeferredAppOpen(
          const AttriaxAppOpenResult(
            userId: 'user_1',
            isNewUser: false,
            isFirstLaunch: true,
            installState: AttriaxInstallState.appDataClear,
            deepLink: AttriaxDeepLink(path: 'promo/deferred'),
          ),
        );
        await pumpEventQueue();

        expect(emittedEvents, isEmpty);
        expect(manager.latestDeepLink, isNull);
        expect(
          await AttriaxPreferencesStore(
            prefsOverride: prefs,
          ).readDeferredAppOpenDeepLinkHandled(),
          isFalse,
        );
      },
    );

    test('emits a deferred app-open deep link only once per install', () async {
      String? currentSessionId = 'session_1';
      final manager = AttriaxDeepLinkManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        contextManager: contextManager,
        listener: AttriaxDeepLinkListener(
          deepLinkSource: _FakeDeepLinkSource(),
        ),
        eventHub: eventHub,
        preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
        currentSessionIdProvider: () => currentSessionId,
        requestManager: requestManager,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      final firstEvents = <Object?>[];
      final firstSubscription = manager.stream.listen(firstEvents.add);
      addTearDown(firstSubscription.cancel);

      await manager.handleDeferredAppOpen(
        const AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: true,
          isFirstLaunch: true,
          deepLink: AttriaxDeepLink(path: 'promo/deferred'),
        ),
      );
      await pumpEventQueue();

      expect(firstEvents, hasLength(1));

      final secondEventHub = AttriaxEventHub();
      addTearDown(secondEventHub.dispose);
      final secondManager = AttriaxDeepLinkManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        contextManager: contextManager,
        listener: AttriaxDeepLinkListener(
          deepLinkSource: _FakeDeepLinkSource(),
        ),
        eventHub: secondEventHub,
        preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
        currentSessionIdProvider: () => currentSessionId,
        requestManager: _FakeRequestManager(),
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      final secondEvents = <Object?>[];
      final secondSubscription = secondManager.stream.listen(secondEvents.add);
      addTearDown(secondSubscription.cancel);

      await secondManager.handleDeferredAppOpen(
        const AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: true,
          isFirstLaunch: false,
          deepLink: AttriaxDeepLink(path: 'promo/deferred'),
        ),
      );
      await pumpEventQueue();

      expect(secondEvents, isEmpty);
    });

    test(
      'fails event resolution on non-retryable http 4xx responses',
      () async {
        final source = _StreamDeepLinkSource();
        addTearDown(source.dispose);
        String? currentSessionId = 'session_1';
        final manager = AttriaxDeepLinkManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          contextManager: contextManager,
          listener: AttriaxDeepLinkListener(deepLinkSource: source),
          eventHub: eventHub,
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          currentSessionIdProvider: () => currentSessionId,
          requestManager: requestManager,
          logger: AttriaxLogger(enableDebugLogs: false),
        );
        addTearDown(manager.stop);

        await manager.start();

        final emittedEventFuture = manager.stream.first;
        source.add(Uri.parse('https://example.com/promo/fail'));
        await pumpEventQueue();
        requestManager.completeError(
          const AttriaxTransportHttpException(statusCode: 400),
        );

        final emittedEvent = await emittedEventFuture;

        await expectLater(
          emittedEvent.resolve(),
          throwsA(isA<AttriaxTransportHttpException>()),
        );
      },
    );

    test(
      'suppresses stale initial deep links after the session changes',
      () async {
        final source = _InitialDeepLinkSource(
          Uri.parse('https://example.com/promo/launch'),
        );
        String? currentSessionId = 'session_1';
        final manager = AttriaxDeepLinkManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          contextManager: contextManager,
          listener: AttriaxDeepLinkListener(deepLinkSource: source),
          eventHub: eventHub,
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          currentSessionIdProvider: () => currentSessionId,
          requestManager: requestManager,
          logger: AttriaxLogger(enableDebugLogs: false),
        );
        addTearDown(manager.stop);

        final emittedEvents = <Object?>[];
        final subscription = manager.stream.listen(emittedEvents.add);
        addTearDown(subscription.cancel);

        await manager.start();
        await pumpEventQueue();

        currentSessionId = 'session_2';
        requestManager.completeSuccess(
          const AttriaxResolveDeepLinkApiResponse(
            result: AttriaxDeepLinkResolutionResult(
              matched: true,
              status: AttriaxDeepLinkResolutionStatus.matched,
              isFirstLaunch: false,
              deepLink: AttriaxDeepLink(path: 'promo/launch'),
            ),
          ),
        );
        await pumpEventQueue();

        expect(emittedEvents, isEmpty);
        expect(manager.initialDeepLink, isNull);
        expect(await manager.waitForInitialDeepLink(), isNull);
        expect(manager.latestDeepLink, isNull);
      },
    );

    test(
      'suppresses stale deferred deep links after the session changes',
      () async {
        String? currentSessionId = 'session_2';
        final manager = AttriaxDeepLinkManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          contextManager: contextManager,
          listener: AttriaxDeepLinkListener(
            deepLinkSource: _FakeDeepLinkSource(),
          ),
          eventHub: eventHub,
          preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
          currentSessionIdProvider: () => currentSessionId,
          requestManager: requestManager,
          logger: AttriaxLogger(enableDebugLogs: false),
        );

        final emittedEvents = <Object?>[];
        final subscription = manager.stream.listen(emittedEvents.add);
        addTearDown(subscription.cancel);

        await manager.handleDeferredAppOpen(
          const AttriaxAppOpenResult(
            userId: 'user_1',
            isNewUser: true,
            isFirstLaunch: true,
            deepLink: AttriaxDeepLink(path: 'promo/deferred'),
          ),
          originSessionId: 'session_1',
        );
        await pumpEventQueue();

        expect(emittedEvents, isEmpty);
        expect(manager.initialDeepLink, isNull);
        expect(manager.latestDeepLink, isNull);
      },
    );
  });
}

Future<AttriaxContextManager> _createContextManager({
  required SharedPreferences prefs,
}) async {
  final logger = AttriaxLogger(enableDebugLogs: false);
  final contextManager = AttriaxContextManager(
    contextCollector: _StaticContextCollector(),
    preferencesStore: AttriaxPreferencesStore(prefsOverride: prefs),
    logger: logger,
  );
  await contextManager.init();
  return contextManager;
}

class _FakeRequestManager extends AttriaxRequestManager {
  AttriaxApiRequest? lastRequest;
  void Function(AttriaxApiResponse response)? _onSuccess;
  void Function(Object error, StackTrace? stackTrace)? _onError;

  @override
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool flushImmediately = true,
  }) async {
    lastRequest = request;
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

class _StaticContextCollector extends AttriaxContextCollector {
  _StaticContextCollector()
    : super(config: const AttriaxConfig(appToken: 'ax_test_token'));

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
    app: const AttriaxAppSnapshot(
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'com.attriax.test',
    ),
    device: const AttriaxDeviceSnapshot(
      model: 'Pixel',
      osVersion: '14',
      language: 'en-US',
    ),
  );
}

class _FakeDeepLinkSource implements AttriaxDeepLinkSource {
  @override
  Future<Uri?> getInitialLink() async => null;

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();
}

class _StreamDeepLinkSource implements AttriaxDeepLinkSource {
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  @override
  Future<Uri?> getInitialLink() async => null;

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  void add(Uri uri) {
    _controller.add(uri);
  }

  Future<void> dispose() => _controller.close();
}

class _InitialDeepLinkSource implements AttriaxDeepLinkSource {
  const _InitialDeepLinkSource(this._initialUri);

  final Uri _initialUri;

  @override
  Future<Uri?> getInitialLink() async => _initialUri;

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();
}
