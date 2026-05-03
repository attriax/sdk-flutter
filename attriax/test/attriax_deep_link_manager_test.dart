import 'dart:async';

import 'package:attriax/src/attriax_deep_link_source.dart';
import 'package:attriax/src/internal/attriax_api_models.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:attriax/src/internal/attriax_context_manager.dart';
import 'package:attriax/src/internal/attriax_deep_link_listener.dart';
import 'package:attriax/src/internal/attriax_deep_link_manager.dart';
import 'package:attriax/src/internal/attriax_event_hub.dart';
import 'package:attriax/src/internal/attriax_logger.dart';
import 'package:attriax/src/internal/attriax_preferences_store.dart';
import 'package:attriax/src/internal/attriax_request_manager.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxDeepLinkManager', () {
    late AttriaxEventHub eventHub;
    late AttriaxContextManager contextManager;
    late _FakeRequestManager requestManager;

    setUp(() async {
      eventHub = AttriaxEventHub();
      requestManager = _FakeRequestManager();
      contextManager = await _createContextManager();
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
        expect(result!.deepLink.path, 'promo/manual');
        expect(result.rawEvent, isNotNull);
        expect(result.rawEvent!.uri.path, '/promo/manual');
        expect(result.rawEvent!.linkPath, 'promo/manual');
        expect(result.rawEvent!.isInitialLink, isFalse);
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
      final manager = AttriaxDeepLinkManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        contextManager: contextManager,
        listener: AttriaxDeepLinkListener(
          deepLinkSource: _FakeDeepLinkSource(),
        ),
        eventHub: eventHub,
        requestManager: requestManager,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      final emittedEventFuture = manager.stream.first;
      manager.handleDeferredAppOpen(
        const AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: true,
          isFirstLaunch: true,
          deepLink: AttriaxDeepLink(path: 'promo/deferred'),
        ),
      );

      final emittedEvent = await emittedEventFuture;
      final emittedResult = await emittedEvent.resolve();

      expect(emittedResult.isMatched, isTrue);
      expect(emittedResult.isDeferred, isTrue);
      expect(emittedResult.resolution?.deepLink.path, 'promo/deferred');
      expect(
        manager.latestDeepLink?.resolution?.deepLink.path,
        'promo/deferred',
      );
    });
  });
}

Future<AttriaxContextManager> _createContextManager() async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AttriaxPreferencesStore.firstLaunchSeenStorageKey: true,
    AttriaxPreferencesStore.deviceIdStorageKey: 'device_1',
    AttriaxPreferencesStore.deviceIdSourceStorageKey: 'android_ssaid',
  });
  final prefs = await SharedPreferences.getInstance();
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
      device: const AttriaxDeviceSnapshot(
        model: 'Pixel',
        osVersion: '14',
        language: 'en-US',
      ),
    );
  }
}

class _FakeDeepLinkSource implements AttriaxDeepLinkSource {
  @override
  Future<Uri?> getInitialLink() async => null;

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();
}
