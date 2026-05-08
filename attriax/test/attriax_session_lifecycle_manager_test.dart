import 'package:attriax_flutter/src/attriax_clock.dart';
import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_context_collector.dart';
import 'package:attriax_flutter/src/internal/attriax_context_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_request_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_runtime_settings_state.dart';
import 'package:attriax_flutter/src/internal/attriax_session_manager.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxSessionManager lifecycle ownership', () {
    test(
      'flushes pending recovered sessions during tracked activity',
      () async {
        var now = DateTime.utc(2026, 5, 3, 12, 0);
        final requests = <AttriaxApiRequest>[];
        final clock = AttriaxMutableClock(now);
        final sessionManager = await _createSessionManager(
          clock: clock,
          requestManager: _RecordingRequestManager(requests),
        );

        final pendingSession = AttriaxSessionSnapshot(
          id: 'session_old',
          deviceId: 'device_1',
          platform: AttriaxPlatformType.android,
          locale: 'en-US',
          isFirstLaunch: false,
          startedAt: now.subtract(const Duration(minutes: 1)),
          lastActivityAt: now.subtract(const Duration(seconds: 5)),
          heartbeatInterval: const Duration(seconds: 5),
          appVersion: '1.0.0',
          appBuildNumber: '1',
          appPackageName: 'com.attriax.test',
          sdkPackageVersion: attriaxSdkPackageVersion,
        );
        sessionManager.seedRecoveredSessionEnd(pendingSession);

        now = now.add(const Duration(seconds: 3));
        clock.currentTime = now;
        final activeSession = await sessionManager.prepareTrackedSessionAt(now);

        expect(activeSession, isNotNull);
        expect(requests, hasLength(1));

        final body = requests.single.toQueueBody();
        expect(body['kind'], 'end');
        expect(body['sessionId'], 'session_old');
        expect(
          body['clientOccurredAt'],
          DateTime.utc(2026, 5, 3, 12, 0, 5).toIso8601String(),
        );

        final metadata = body['metadata']! as Map<String, Object?>;
        expect(metadata['recovered'], true);
      },
    );

    test(
      'emits pause and resume lifecycle telemetry for the current session',
      () async {
        var now = DateTime.utc(2026, 5, 3, 12, 0);
        final requests = <AttriaxApiRequest>[];
        final clock = AttriaxMutableClock(now);
        final sessionManager = await _createSessionManager(
          clock: clock,
          requestManager: _RecordingRequestManager(requests),
        );

        sessionManager.syncLifecycleState(AppLifecycleState.resumed);

        now = now.add(const Duration(seconds: 3));
        clock.currentTime = now;
        sessionManager.handleLifecycleState(AppLifecycleState.paused);
        await pumpEventQueue();

        now = now.add(const Duration(seconds: 3));
        clock.currentTime = now;
        sessionManager.handleLifecycleState(AppLifecycleState.resumed);
        await pumpEventQueue();

        expect(
          requests.map((request) => request.toQueueBody()['kind']).toList(),
          <Object?>['pause', 'resume'],
        );

        expect(requests[0].toQueueBody()['sessionRelativeTimeMs'], 3000);
        expect(requests[1].toQueueBody()['sessionRelativeTimeMs'], 6000);

        sessionManager.dispose();
      },
    );
  });
}

Future<AttriaxSessionManager> _createSessionManager({
  required AttriaxClock clock,
  required AttriaxRequestManager requestManager,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AttriaxPreferencesStore.firstLaunchSeenStorageKey: true,
    AttriaxPreferencesStore.deviceIdStorageKey: 'device_1',
    AttriaxPreferencesStore.deviceIdSourceStorageKey: 'android_ssaid',
  });
  final prefs = await SharedPreferences.getInstance();
  final preferencesStore = AttriaxPreferencesStore(prefsOverride: prefs);
  final logger = AttriaxLogger(enableDebugLogs: false);
  final contextManager = AttriaxContextManager(
    contextCollector: _StaticContextCollector(),
    preferencesStore: preferencesStore,
    logger: logger,
  );
  await contextManager.init();

  final sessionManager = AttriaxSessionManager(
    config: const AttriaxConfig(appToken: 'ax_test_token'),
    contextManager: contextManager,
    preferencesStore: preferencesStore,
    logger: logger,
    settingsState: const _FakeRuntimeSettingsView(),
    requestManager: requestManager,
    clock: clock,
  );
  await sessionManager.init(enabled: true);
  return sessionManager;
}

class _RecordingRequestManager extends AttriaxRequestManager {
  _RecordingRequestManager(this._requests);

  final List<AttriaxApiRequest> _requests;

  @override
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool flushImmediately = true,
  }) async {
    _requests.add(request);
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

class _FakeRuntimeSettingsView implements AttriaxRuntimeSettingsView {
  const _FakeRuntimeSettingsView();

  @override
  bool get isEnabled => true;

  @override
  bool get areEventsEnabled => true;
}
