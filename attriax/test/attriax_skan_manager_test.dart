import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_context_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_request_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_runtime_settings_state.dart';
import 'package:attriax_flutter/src/internal/attriax_session_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_skan_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_tracking_manager.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxSkanManager', () {
    late SharedPreferences prefs;
    late AttriaxPreferencesStore store;
    late _FakeSkanPlatform platform;
    late _FixedClock clock;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      store = AttriaxPreferencesStore(prefsOverride: prefs);
      platform = _FakeSkanPlatform();
      clock = _FixedClock(DateTime.utc(2026, 5, 15, 13));
    });

    test('registers the first-launch value on iOS', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(template: AttriaxSkanTemplate.game),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      await manager.init(isFirstLaunch: true);

      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 0);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.low);
      expect(manager.state?.fineValue, 0);
      expect(manager.state?.firstLaunchValueRegistered, isTrue);
      expect((await store.readSkanState())?.fineValue, 0);
    });

    test('advances semantic events through the tracking manager', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(
            template: AttriaxSkanTemplate.ecommerce,
            registerFirstLaunchValue: false,
          ),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      await manager.init(isFirstLaunch: false);

      final requestManager = _FakeRequestManager();
      final trackingManager = AttriaxTrackingManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(
            template: AttriaxSkanTemplate.ecommerce,
            registerFirstLaunchValue: false,
          ),
        ),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: clock,
        contextManager: const _FakeTrackingContext(),
        settingsState: const _FakeSettingsState(),
        requestManager: requestManager,
        sessionManager: _FakeSessionManager(),
        skanManager: manager,
      );

      await trackingManager.recordEvent(
        'purchase',
        skanEvent: AttriaxSkanSemanticEvent.purchase,
      );

      expect(requestManager.enqueuedRequests, hasLength(1));
      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 52);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.high);
      expect(manager.state?.resolvedTemplate, AttriaxSkanTemplate.ecommerce);
      expect(manager.state?.fineValue, 52);
    });

    test('does not update SKAN when event tracking is disabled', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(
            template: AttriaxSkanTemplate.ecommerce,
            registerFirstLaunchValue: false,
          ),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      await manager.init(isFirstLaunch: false);

      final requestManager = _FakeRequestManager();
      final trackingManager = AttriaxTrackingManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(
            template: AttriaxSkanTemplate.ecommerce,
            registerFirstLaunchValue: false,
          ),
        ),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: clock,
        contextManager: const _FakeTrackingContext(),
        settingsState: const _FakeSettingsState(areEventsEnabled: false),
        requestManager: requestManager,
        sessionManager: _FakeSessionManager(),
        skanManager: manager,
      );

      await trackingManager.recordEvent(
        'purchase',
        skanEvent: AttriaxSkanSemanticEvent.purchase,
      );

      expect(requestManager.enqueuedRequests, isEmpty);
      expect(platform.calls, isEmpty);
      expect(manager.state?.fineValue, isNull);
    });
  });
}

class _FakeSkanPlatform extends AttriaxPlatform {
  final List<_SkanCall> calls = <_SkanCall>[];

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  @override
  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    calls.add(
      _SkanCall(
        fineValue: fineValue,
        coarseValue: coarseValue,
        lockWindow: lockWindow,
      ),
    );

    return AttriaxSkanUpdateResult(
      status: AttriaxSkanUpdateStatus.updated,
      fineValue: fineValue,
      coarseValue: coarseValue,
      lockWindow: lockWindow,
    );
  }
}

class _SkanCall {
  const _SkanCall({
    required this.fineValue,
    this.coarseValue,
    required this.lockWindow,
  });

  final int fineValue;
  final AttriaxSkanCoarseValue? coarseValue;
  final bool lockWindow;
}

class _FixedClock implements AttriaxClock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

class _FakeTrackingContext implements AttriaxTrackingContext {
  const _FakeTrackingContext();

  @override
  String get requiredDeviceId => 'sdk_device';

  @override
  AttriaxContextSnapshot get requiredSnapshot => const AttriaxContextSnapshot(
    platform: AttriaxPlatformType.ios,
    deviceId: 'sdk_device',
    isFirstLaunch: false,
    sdk: AttriaxSdkSnapshot(
      apiVersion: attriaxSdkApiVersion,
      packageVersion: attriaxSdkPackageVersion,
    ),
    app: AttriaxAppSnapshot(
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'com.attriax.test',
    ),
    device: AttriaxDeviceSnapshot(model: 'Test iPhone', osVersion: '17.5'),
  );

  @override
  String requireDeviceIdSource() => 'test';
}

class _FakeSettingsState implements AttriaxRuntimeSettingsView {
  const _FakeSettingsState({
    this.isEnabled = true,
    this.areEventsEnabled = true,
  });

  @override
  final bool isEnabled;

  @override
  final bool areEventsEnabled;
}

class _FakeRequestManager extends AttriaxRequestManager {
  final List<AttriaxApiRequest> enqueuedRequests = <AttriaxApiRequest>[];

  @override
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool flushImmediately = true,
  }) async {
    enqueuedRequests.add(request);
  }
}

class _FakeSessionManager implements AttriaxTrackedSessionPreparer {
  @override
  Future<AttriaxSessionSnapshot?> prepareTrackedSessionAt(
    DateTime occurredAt,
  ) async => AttriaxSessionSnapshot(
    id: 'session_1',
    deviceId: 'sdk_device',
    platform: AttriaxPlatformType.ios,
    isFirstLaunch: false,
    startedAt: occurredAt.subtract(const Duration(seconds: 1)),
    lastActivityAt: occurredAt,
    heartbeatInterval: const Duration(seconds: 60),
  );
}
