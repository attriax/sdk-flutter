import 'package:attriax_flutter/src/internal/attriax_context_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_context_services.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxContextManager', () {
    test(
      'initializes from narrow fake context services and device store',
      () async {
        final contextServices = _FakeContextRuntimeServices(
          resolvedDeviceId: const AttriaxResolvedDeviceId(
            value: 'native_device_id',
            source: 'android_ssaid',
          ),
        );
        final deviceStore = _FakeContextIdentityStore(
          storedDeviceData: const AttriaxStoredDeviceData(
            deviceId: 'stored_device_id',
            hasPersistedDeviceId: false,
            isFirstLaunch: true,
          ),
        );
        final manager = AttriaxContextManager(
          contextCollector: contextServices,
          preferencesStore: deviceStore,
          logger: AttriaxLogger(enableDebugLogs: false),
        );

        await manager.init();

        expect(manager.deviceId, 'native_device_id');
        expect(manager.deviceIdSource, 'android_ssaid');
        expect(manager.isFirstLaunch, isTrue);
        expect(contextServices.collectedDeviceId, 'native_device_id');
        expect(contextServices.collectedIsFirstLaunch, isTrue);
        expect(deviceStore.persistedDeviceId, 'native_device_id');
        expect(deviceStore.persistedDeviceIdSource, 'android_ssaid');
      },
    );

    test(
      'delegates authorization, timezone, and crash settings through context services',
      () async {
        final contextServices = _FakeContextRuntimeServices(
          resolvedDeviceId: const AttriaxResolvedDeviceId(
            value: 'native_device_id',
            source: 'android_ssaid',
          ),
          timezone: 'Europe/Berlin',
          trackingAuthorizationStatus:
              AttriaxTrackingAuthorizationStatus.authorized,
        );
        final manager = AttriaxContextManager(
          contextCollector: contextServices,
          preferencesStore: _FakeContextIdentityStore(
            storedDeviceData: const AttriaxStoredDeviceData(
              deviceId: 'stored_device_id',
              hasPersistedDeviceId: false,
              isFirstLaunch: false,
            ),
          ),
          logger: AttriaxLogger(enableDebugLogs: false),
        );

        final requestStatus = await manager.requestTrackingAuthorization();
        final currentStatus = await manager.getTrackingAuthorizationStatus();
        final timezone = await manager.resolveTimezone();
        await manager.setAutomaticCrashReportingEnabled(enabled: true);

        expect(requestStatus, AttriaxTrackingAuthorizationStatus.authorized);
        expect(currentStatus, AttriaxTrackingAuthorizationStatus.authorized);
        expect(timezone, 'Europe/Berlin');
        expect(contextServices.crashReportingEnabled, isTrue);
        expect(contextServices.requestTrackingAuthorizationCallCount, 1);
        expect(contextServices.getTrackingAuthorizationStatusCallCount, 1);
      },
    );

    test(
      'can initialize anonymous startup context without device identity',
      () async {
        final contextServices = _FakeContextRuntimeServices(
          resolvedDeviceId: const AttriaxResolvedDeviceId(
            value: 'native_device_id',
            source: 'android_ssaid',
          ),
          timezone: 'Europe/Berlin',
        );
        final deviceStore = _FakeContextIdentityStore(
          storedDeviceData: const AttriaxStoredDeviceData(
            deviceId: 'stored_device_id',
            hasPersistedDeviceId: false,
            isFirstLaunch: true,
          ),
        );
        final manager = AttriaxContextManager(
          contextCollector: contextServices,
          preferencesStore: deviceStore,
          logger: AttriaxLogger(enableDebugLogs: false),
        );

        await manager.init(allowDeviceIdentity: false);

        expect(manager.deviceId, isNull);
        expect(manager.deviceIdSource, isNull);
        expect(manager.isFirstLaunch, isTrue);
        expect(manager.snapshot?.deviceId, isNull);
        expect(manager.snapshot?.device.timezone, 'Europe/Berlin');
        expect(contextServices.collectContextSnapshotCallCount, 0);
        expect(contextServices.resolvePreferredDeviceIdCallCount, 0);
        expect(contextServices.anonymousSnapshotBuildCount, 1);
        expect(deviceStore.persistedDeviceId, isNull);
        expect(deviceStore.persistedDeviceIdSource, isNull);
      },
    );
  });
}

class _FakeContextRuntimeServices implements AttriaxContextRuntimeServices {
  _FakeContextRuntimeServices({
    required this.resolvedDeviceId,
    this.timezone,
    this.trackingAuthorizationStatus =
        AttriaxTrackingAuthorizationStatus.notDetermined,
  });

  final AttriaxResolvedDeviceId resolvedDeviceId;
  final String? timezone;
  final AttriaxTrackingAuthorizationStatus trackingAuthorizationStatus;

  String? collectedDeviceId;
  bool? collectedIsFirstLaunch;
  int collectContextSnapshotCallCount = 0;
  int resolvePreferredDeviceIdCallCount = 0;
  int anonymousSnapshotBuildCount = 0;
  bool crashReportingEnabled = false;
  int requestTrackingAuthorizationCallCount = 0;
  int getTrackingAuthorizationStatusCallCount = 0;

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
    bool waitForTrackingAuthorization = false,
  }) async {
    collectContextSnapshotCallCount += 1;
    collectedDeviceId = deviceId;
    collectedIsFirstLaunch = isFirstLaunch;
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
      device: const AttriaxDeviceSnapshot(model: 'Pixel 9'),
    );
  }

  @override
  AttriaxContextSnapshot buildAnonymousStartupSnapshot({
    required bool isFirstLaunch,
    String? timezone,
  }) {
    anonymousSnapshotBuildCount += 1;
    return AttriaxContextSnapshot(
      platform: AttriaxPlatformType.android,
      deviceId: null,
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
      device: AttriaxDeviceSnapshot(timezone: timezone),
    );
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus>
  getTrackingAuthorizationStatus() async {
    getTrackingAuthorizationStatusCallCount += 1;
    return trackingAuthorizationStatus;
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) async {
    requestTrackingAuthorizationCallCount += 1;
    return trackingAuthorizationStatus;
  }

  @override
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) async {
    resolvePreferredDeviceIdCallCount += 1;
    return resolvedDeviceId;
  }

  @override
  Future<String?> resolveDeviceTimezone() async => timezone;

  @override
  Future<void> setAutomaticCrashReportingEnabled({
    required bool enabled,
  }) async {
    crashReportingEnabled = enabled;
  }
}

class _FakeContextIdentityStore implements AttriaxContextIdentityStore {
  _FakeContextIdentityStore({required this.storedDeviceData});

  final AttriaxStoredDeviceData storedDeviceData;
  String? persistedDeviceId;
  String? persistedDeviceIdSource;

  @override
  Future<bool> restoreFirstLaunchState() async =>
      storedDeviceData.isFirstLaunch;

  @override
  Future<AttriaxStoredDeviceIdentity> ensureDeviceIdentity({
    required String Function() deviceIdFactory,
  }) async => AttriaxStoredDeviceIdentity(
    deviceId: storedDeviceData.deviceId,
    hasPersistedDeviceId: storedDeviceData.hasPersistedDeviceId,
    deviceIdSource: storedDeviceData.deviceIdSource,
  );

  @override
  Future<AttriaxStoredDeviceData> restoreDeviceData({
    required String Function() deviceIdFactory,
  }) async => storedDeviceData;

  @override
  Future<void> setResolvedDeviceIdentity({
    required String deviceId,
    required String? deviceIdSource,
  }) async {
    persistedDeviceId = deviceId;
    persistedDeviceIdSource = deviceIdSource;
  }
}
