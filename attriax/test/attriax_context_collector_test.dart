import 'package:attriax/attriax.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxContextCollector install referrer retry', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('uses a persisted install referrer before calling the platform', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'attriax.install_referrer': 'utm_source=cached_play_store',
      });

      final platform = FakeAttriaxPlatform(
        const <AttriaxInstallReferrerContext>[],
      );

      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        installReferrerRetryDelay: Duration.zero,
      );

      final context = await collector.collectInstallReferrerContextForTest(
        platformType: AttriaxPlatformType.android,
      );

      expect(platform.installReferrerCalls, 0);
      expect(context.installReferrer, 'utm_source=cached_play_store');
      expect(context.metadata['source'], 'flutter_cached_install_referrer');
    });

    test('retries once and returns the successful referrer payload', () async {
      final platform = FakeAttriaxPlatform(<AttriaxInstallReferrerContext>[
        const AttriaxInstallReferrerContext(
          metadata: <String, Object?>{
            'installReferrerStatus': 'service_unavailable',
          },
        ),
        const AttriaxInstallReferrerContext(
          installReferrer: 'utm_source=play_store',
          metadata: <String, Object?>{'installReferrerStatus': 'ok'},
        ),
      ]);

      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        installReferrerRetryDelay: Duration.zero,
      );

      final context = await collector.collectInstallReferrerContextForTest(
        platformType: AttriaxPlatformType.android,
      );

      expect(platform.installReferrerCalls, 2);
      expect(context.installReferrer, 'utm_source=play_store');
      expect(context.metadata['installReferrerStatus'], 'ok');
    });

    test(
      'emits degraded metadata after both install referrer attempts fail',
      () async {
        final platform = FakeAttriaxPlatform(<AttriaxInstallReferrerContext>[
          const AttriaxInstallReferrerContext(
            metadata: <String, Object?>{
              'installReferrerStatus': 'service_unavailable',
            },
          ),
          const AttriaxInstallReferrerContext(
            metadata: <String, Object?>{
              'installReferrerStatus': 'timeout_flutter',
            },
          ),
        ]);

        final collector = AttriaxContextCollector(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          platform: platform,
          installReferrerRetryDelay: Duration.zero,
        );

        final context = await collector.collectInstallReferrerContextForTest(
          platformType: AttriaxPlatformType.android,
        );

        expect(platform.installReferrerCalls, 2);
        expect(context.installReferrer, isNull);
        expect(context.metadata['installReferrerStatus'], 'timeout_flutter');
        expect(context.metadata['installReferrerAttempts'], 2);
      },
    );
  });

  test(
    'overrides sdk metadata with the Flutter client runtime marker',
    () async {
      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          sdkMetadata: <String, Object?>{
            'clientRuntime': 'custom',
            'customField': 'kept',
          },
        ),
        platform: FakeAttriaxPlatform(const <AttriaxInstallReferrerContext>[]),
      );

      final preparedContext = await collector.prepare(
        deviceId: 'device_test_1',
        isFirstLaunch: true,
      );
      final context = await preparedContext.resolvedSnapshot;

      expect(context.sdk.metadata['clientRuntime'], 'flutter');
      expect(context.sdk.metadata['customField'], 'kept');
    },
  );

  test('prefers android SSAID before GAID and storage', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(appToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        AttriaxNativeContext(
          androidId: 'android-ssaid',
          advertisingId: 'android-gaid',
        ),
      ),
      deviceInfoPlugin: fakeDeviceInfoPlugin(
        android: AndroidDeviceInfo.setMockInitialValues(
          version: AndroidBuildVersion.setMockInitialValues(
            codename: 'REL',
            incremental: '1',
            previewSdkInt: 0,
            release: '14',
            sdkInt: 34,
          ),
          board: 'board',
          bootloader: 'bootloader',
          brand: 'brand',
          device: 'device',
          display: 'display',
          fingerprint: 'fingerprint',
          hardware: 'hardware',
          host: 'host',
          id: 'id',
          manufacturer: 'manufacturer',
          model: 'model',
          product: 'product',
          name: 'name',
          supported32BitAbis: const <String>[],
          supported64BitAbis: const <String>[],
          supportedAbis: const <String>[],
          tags: 'tags',
          type: 'user',
          isPhysicalDevice: true,
          freeDiskSize: 1,
          totalDiskSize: 1,
          systemFeatures: const <String>[],
          isLowRamDevice: false,
          physicalRamSize: 1,
          availableRamSize: 1,
        ),
      ),
    );

    final resolved = await collector.resolvePreferredDeviceId(
      fallbackDeviceId: 'stored-fallback',
    );

    expect(resolved.value, 'android-ssaid');
    expect(resolved.source, 'android_ssaid');
    expect(resolved.isFallback, isFalse);
  });

  test('falls back to GAID when android SSAID is unavailable', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(appToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        AttriaxNativeContext(advertisingId: 'android-gaid'),
      ),
      deviceInfoPlugin: fakeDeviceInfoPlugin(
        android: AndroidDeviceInfo.setMockInitialValues(
          version: AndroidBuildVersion.setMockInitialValues(
            codename: 'REL',
            incremental: '1',
            previewSdkInt: 0,
            release: '14',
            sdkInt: 34,
          ),
          board: 'board',
          bootloader: 'bootloader',
          brand: 'brand',
          device: 'device',
          display: 'display',
          fingerprint: 'fingerprint',
          hardware: 'hardware',
          host: 'host',
          id: 'id',
          manufacturer: 'manufacturer',
          model: 'model',
          product: 'product',
          name: 'name',
          supported32BitAbis: const <String>[],
          supported64BitAbis: const <String>[],
          supportedAbis: const <String>[],
          tags: 'tags',
          type: 'user',
          isPhysicalDevice: true,
          freeDiskSize: 1,
          totalDiskSize: 1,
          systemFeatures: const <String>[],
          isLowRamDevice: false,
          physicalRamSize: 1,
          availableRamSize: 1,
        ),
      ),
    );

    final resolved = await collector.resolvePreferredDeviceId(
      fallbackDeviceId: 'stored-fallback',
    );

    expect(resolved.value, 'android-gaid');
    expect(resolved.source, 'android_gaid');
    expect(resolved.isFallback, isFalse);
  });

  test('prefers iOS keychain before IDFV and storage', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(appToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        AttriaxNativeContext(
          metadata: <String, Object?>{
            'keychainDeviceId': 'ios-keychain-id',
            'vendorIdentifier': 'ios-idfv',
          },
        ),
      ),
      deviceInfoPlugin: fakeDeviceInfoPlugin(
        ios: IosDeviceInfo.setMockInitialValues(
          name: 'iPhone',
          systemName: 'iOS',
          systemVersion: '18.0',
          model: 'iPhone',
          modelName: 'iPhone Test',
          localizedModel: 'iPhone',
          freeDiskSize: 1,
          totalDiskSize: 1,
          identifierForVendor: 'ios-idfv',
          isPhysicalDevice: true,
          isiOSAppOnMac: false,
          isiOSAppOnVision: false,
          physicalRamSize: 1,
          availableRamSize: 1,
          utsname: IosUtsname.setMockInitialValues(
            sysname: 'Darwin',
            nodename: 'test',
            release: '1',
            version: '1',
            machine: 'iPhone17,1',
          ),
        ),
      ),
    );

    final resolved = await collector.resolvePreferredDeviceId(
      fallbackDeviceId: 'stored-fallback',
    );

    expect(resolved.value, 'ios-keychain-id');
    expect(resolved.source, 'ios_keychain');
  });

  test('prefers macOS IOPlatformUUID before keychain and storage', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(appToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        AttriaxNativeContext(
          metadata: <String, Object?>{'keychainDeviceId': 'macos-keychain-id'},
        ),
      ),
      deviceInfoPlugin: fakeDeviceInfoPlugin(
        macos: MacOsDeviceInfo.setMockInitialValues(
          computerName: 'Mac',
          hostName: 'Mac.local',
          arch: 'arm64',
          model: 'Mac16,2',
          modelName: 'MacBook Pro',
          kernelVersion: 'Darwin 24.0.0',
          osRelease: '15.0',
          majorVersion: 15,
          minorVersion: 0,
          patchVersion: 0,
          activeCPUs: 8,
          memorySize: 16,
          cpuFrequency: 1,
          systemGUID: 'macos-platform-uuid',
        ),
      ),
    );

    final resolved = await collector.resolvePreferredDeviceId(
      fallbackDeviceId: 'stored-fallback',
    );

    expect(resolved.value, 'macos-platform-uuid');
    expect(resolved.source, 'macos_platform_uuid');
  });
}

class FakeAttriaxPlatform extends AttriaxPlatform {
  FakeAttriaxPlatform(
    this._responses, {
    this.nativeContext = const AttriaxNativeContext(),
  });

  FakeAttriaxPlatform.withNativeContext(this.nativeContext)
    : _responses = const <AttriaxInstallReferrerContext>[];

  final List<AttriaxInstallReferrerContext> _responses;
  final AttriaxNativeContext nativeContext;
  int installReferrerCalls = 0;

  @override
  Future<AttriaxNativeContext> collectNativeContext() async => nativeContext;

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async {
    final index = installReferrerCalls;
    installReferrerCalls += 1;

    if (index < _responses.length) {
      return _responses[index];
    }

    return const AttriaxInstallReferrerContext();
  }
}

DeviceInfoPlugin fakeDeviceInfoPlugin({
  AndroidDeviceInfo? android,
  IosDeviceInfo? ios,
  LinuxDeviceInfo? linux,
  MacOsDeviceInfo? macos,
  WindowsDeviceInfo? windows,
}) => DeviceInfoPlugin.setMockInitialValues(
  androidDeviceInfo: android,
  iosDeviceInfo: ios,
  linuxDeviceInfo: linux,
  macOsDeviceInfo: macos,
  windowsDeviceInfo: windows,
);
