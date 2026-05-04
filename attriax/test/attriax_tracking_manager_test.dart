import 'package:attriax/src/attriax_clock.dart';
import 'package:attriax/src/internal/attriax_api_models.dart';
import 'package:attriax/src/internal/attriax_context_manager.dart';
import 'package:attriax/src/internal/attriax_logger.dart';
import 'package:attriax/src/internal/attriax_request_manager.dart';
import 'package:attriax/src/internal/attriax_runtime_settings_state.dart';
import 'package:attriax/src/internal/attriax_session_manager.dart';
import 'package:attriax/src/internal/attriax_tracking_manager.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxTrackingManager', () {
    test('recordEvent enqueues session-aware event requests', () async {
      int prepareSessionCalls = 0;
      final occurredAt = DateTime.utc(2026, 5, 3, 12, 0, 7);
      final requestManager = _RecordingRequestManager();
      final session = AttriaxSessionSnapshot(
        id: 'session_1',
        deviceId: 'device_1',
        platform: AttriaxPlatformType.android,
        locale: 'en-US',
        isFirstLaunch: true,
        startedAt: DateTime.utc(2026, 5, 3, 12, 0, 0),
        lastActivityAt: DateTime.utc(2026, 5, 3, 12, 0, 7),
        heartbeatInterval: const Duration(seconds: 5),
        appVersion: '1.0.0',
        appBuildNumber: '1',
        appPackageName: 'com.attriax.test',
        sdkPackageVersion: '1.0.0',
      );
      final manager = AttriaxTrackingManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: AttriaxMutableClock(occurredAt),
        contextManager: const _StaticTrackingContext(),
        settingsState: const _FakeRuntimeSettingsView(),
        requestManager: requestManager,
        sessionManager: _FakeTrackedSessionPreparer((time) async {
          prepareSessionCalls += 1;
          expect(time, occurredAt);
          return session;
        }),
      );

      await manager.recordEvent(
        'purchase',
        eventData: const <String, Object?>{'value': 42},
      );

      expect(prepareSessionCalls, 1);
      expect(requestManager.lastRequest, isA<AttriaxTrackEventRequest>());
      final body = requestManager.lastRequest!.toQueueBody();
      expect(body['eventName'], 'purchase');
      expect(body['sessionId'], 'session_1');
      expect(body['sessionRelativeTimeMs'], 7000);
      expect(body['clientOccurredAt'], occurredAt.toIso8601String());
    });

    test(
      'recordPageView normalizes page metadata into an event payload',
      () async {
        final requestManager = _RecordingRequestManager();
        final manager = AttriaxTrackingManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          logger: AttriaxLogger(enableDebugLogs: false),
          clock: AttriaxMutableClock(DateTime.utc(2026, 5, 3, 12, 0, 7)),
          contextManager: const _StaticTrackingContext(),
          settingsState: const _FakeRuntimeSettingsView(),
          requestManager: requestManager,
          sessionManager: _FakeTrackedSessionPreparer((_) async => null),
        );

        await manager.recordPageView(
          ' Checkout ',
          pageClass: ' CheckoutScreen ',
          pageTitle: ' Checkout ',
          previousPageName: ' Cart ',
          parameters: const <String, Object?>{'step': 2},
        );

        final body = requestManager.lastRequest!.toQueueBody();
        final eventData = body['eventData'] as Map<String, Object?>;
        expect(body['eventName'], 'page_view');
        expect(eventData['pageName'], 'Checkout');
        expect(eventData['pageClass'], 'CheckoutScreen');
        expect(eventData['pageTitle'], 'Checkout');
        expect(eventData['previousPageName'], 'Cart');
        expect(eventData['source'], 'manual');
        expect(eventData['step'], 2);
      },
    );

    test('setUser skips request enqueueing while disabled', () async {
      int prepareSessionCalls = 0;
      final requestManager = _RecordingRequestManager();
      final manager = AttriaxTrackingManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: AttriaxMutableClock(DateTime.utc(2026, 5, 3, 12, 0, 7)),
        contextManager: const _StaticTrackingContext(),
        settingsState: const _FakeRuntimeSettingsView(isEnabled: false),
        requestManager: requestManager,
        sessionManager: _FakeTrackedSessionPreparer((_) async {
          prepareSessionCalls += 1;
          return null;
        }),
      );

      await manager.setUser('user_1', userName: 'User One');

      expect(requestManager.enqueueCalls, 0);
      expect(prepareSessionCalls, 0);
    });

    test(
      'setUserProperties splits null values into explicit clear operations',
      () async {
        final requestManager = _RecordingRequestManager();
        final manager = AttriaxTrackingManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          logger: AttriaxLogger(enableDebugLogs: false),
          clock: AttriaxMutableClock(DateTime.utc(2026, 5, 3, 12, 0, 7)),
          contextManager: const _StaticTrackingContext(),
          settingsState: const _FakeRuntimeSettingsView(),
          requestManager: requestManager,
          sessionManager: _FakeTrackedSessionPreparer((_) async => null),
        );

        await manager.setUserProperties(<String, Object?>{
          'plan': 'business',
          'obsolete': null,
        });

        expect(requestManager.lastRequest, isA<AttriaxUserRequest>());
        final body = requestManager.lastRequest!.toQueueBody();
        expect(body['properties'], <String, Object?>{'plan': 'business'});
        expect(body['clearPropertyKeys'], <String>['obsolete']);
      },
    );

    test('recordError enqueues crash reports with context metadata', () async {
      final requestManager = _RecordingRequestManager();
      final manager = AttriaxTrackingManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: AttriaxMutableClock(DateTime.utc(2026, 5, 3, 12, 0, 7)),
        contextManager: const _StaticTrackingContext(),
        settingsState: const _FakeRuntimeSettingsView(),
        requestManager: requestManager,
        sessionManager: _FakeTrackedSessionPreparer(
          (_) async => AttriaxSessionSnapshot(
            id: 'session_1',
            deviceId: 'device_1',
            platform: AttriaxPlatformType.android,
            locale: 'en-US',
            isFirstLaunch: true,
            startedAt: DateTime.utc(2026, 5, 3, 12, 0, 0),
            lastActivityAt: DateTime.utc(2026, 5, 3, 12, 0, 7),
            heartbeatInterval: const Duration(seconds: 5),
            appVersion: '1.0.0',
            appBuildNumber: '1',
            appPackageName: 'com.attriax.test',
            sdkPackageVersion: '1.2.3',
          ),
        ),
      );

      await manager.recordError(
        StateError('boom'),
        StackTrace.fromString('stack line'),
        fatal: true,
        source: 'flutter_error',
        reason: 'Widget build failed',
        metadata: const <String, Object?>{'route': '/checkout'},
      );

      expect(requestManager.lastRequest, isA<AttriaxTrackCrashRequest>());
      final body = requestManager.lastRequest!.toQueueBody();
      expect(body['source'], 'flutter_error');
      expect(body['isFatal'], isTrue);
      expect(body['exceptionType'], 'StateError');
      expect(body['message'], 'Bad state: boom');
      expect(body['stackTrace'], 'stack line');
      expect(body['reason'], 'Widget build failed');
      expect(body['sessionId'], 'session_1');
      expect(body['sessionRelativeTimeMs'], 7000);
      expect(body['platform'], 'android');
      expect(body['appVersion'], '1.0.0');
      expect(body['metadata'], <String, Object?>{'route': '/checkout'});
    });

    test(
      'setUserProperties enforces flat primitive values within the configured caps',
      () async {
        final requestManager = _RecordingRequestManager();
        final manager = AttriaxTrackingManager(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          logger: AttriaxLogger(enableDebugLogs: false),
          clock: AttriaxMutableClock(DateTime.utc(2026, 5, 3, 12, 0, 7)),
          contextManager: const _StaticTrackingContext(),
          settingsState: const _FakeRuntimeSettingsView(),
          requestManager: requestManager,
          sessionManager: _FakeTrackedSessionPreparer((_) async => null),
        );

        await manager.setUserProperties(<String, Object?>{
          ...Map<String, Object?>.fromEntries(
            List.generate(
              29,
              (index) => MapEntry('prop${index + 1}', index + 1),
            ),
          ),
          'tooLong': 'x' * 300,
          'enabled': true,
          'overflow': 'ignored',
          'nested': <String, Object?>{'blocked': true},
          'list': <Object?>['blocked'],
        });

        final body = requestManager.lastRequest!.toQueueBody();
        final properties = body['properties'] as Map<String, Object?>;
        expect(properties.length, 30);
        expect(properties['prop1'], 1);
        expect(properties['prop29'], 29);
        expect((properties['tooLong'] as String).length, 256);
        expect(properties.containsKey('enabled'), isFalse);
        expect(properties.containsKey('overflow'), isFalse);
        expect(properties.containsKey('nested'), isFalse);
        expect(properties.containsKey('list'), isFalse);
      },
    );
  });
}

AttriaxContextSnapshot _context() => const AttriaxContextSnapshot(
  platform: AttriaxPlatformType.android,
  deviceId: 'device_1',
  isFirstLaunch: true,
  sdk: AttriaxSdkSnapshot(
    apiVersion: attriaxSdkApiVersion,
    packageVersion: '1.2.3',
  ),
  app: AttriaxAppSnapshot(
    version: '1.0.0',
    buildNumber: '1',
    packageName: 'com.attriax.test',
  ),
  device: AttriaxDeviceSnapshot(
    model: 'Pixel',
    osVersion: '14',
    language: 'en-US',
  ),
);

class _FakeTrackedSessionPreparer implements AttriaxTrackedSessionPreparer {
  const _FakeTrackedSessionPreparer(this._prepare);

  final Future<AttriaxSessionSnapshot?> Function(DateTime occurredAt) _prepare;

  @override
  Future<AttriaxSessionSnapshot?> prepareTrackedSessionAt(
    DateTime occurredAt,
  ) => _prepare(occurredAt);
}

class _FakeRuntimeSettingsView implements AttriaxRuntimeSettingsView {
  const _FakeRuntimeSettingsView({
    this.isEnabled = true,
    this.areEventsEnabled = true,
  });

  @override
  final bool isEnabled;

  @override
  final bool areEventsEnabled;
}

class _StaticTrackingContext implements AttriaxTrackingContext {
  const _StaticTrackingContext();

  @override
  String get requiredDeviceId => 'device_1';

  @override
  AttriaxContextSnapshot get requiredSnapshot => _context();

  @override
  String requireDeviceIdSource() => 'android_ssaid';
}

class _RecordingRequestManager extends AttriaxRequestManager {
  int enqueueCalls = 0;
  AttriaxApiRequest? lastRequest;

  @override
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
  }) async {
    enqueueCalls += 1;
    lastRequest = request;
  }
}
