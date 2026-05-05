import 'package:attriax/attriax.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

      final context = await collector.collectContextSnapshot(
        deviceId: 'device_test_1',
        isFirstLaunch: true,
      );

      expect(context.sdk.metadata['clientRuntime'], 'flutter');
      expect(context.sdk.metadata['customField'], 'kept');
    },
  );

  test('builds app and device snapshots from native metadata', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(appToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        const AttriaxNativeContext(
          androidId: 'android-ssaid',
          metadata: <String, Object?>{
            'appVersion': '1.2.3',
            'appBuildNumber': '45',
            'packageName': 'com.example.attriax',
            'model': 'Pixel 9',
            'device': 'tokay',
            'brand': 'Google',
            'manufacturer': 'Google',
            'hardware': 'tensor-g4',
            'osVersion': '14',
            'isPhysicalDevice': true,
            'supportedAbis': <String>['arm64-v8a'],
            'timezone': 'UTC',
          },
        ),
      ),
    );

    final context = await collector.collectContextSnapshot(
      deviceId: 'device_test_1',
      isFirstLaunch: true,
    );

    expect(context.app.version, '1.2.3');
    expect(context.app.buildNumber, '45');
    expect(context.app.packageName, 'com.example.attriax');
    expect(context.device.model, 'Pixel 9');
    expect(context.device.name, 'tokay');
    expect(context.device.supportedAbis, <String>['arm64-v8a']);
    expect(context.device.androidId, 'android-ssaid');
  });

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
    );

    final resolved = await collector.resolvePreferredDeviceId(
      fallbackDeviceId: 'stored-fallback',
    );

    expect(resolved.value, 'ios-keychain-id');
    expect(resolved.source, 'ios_keychain');
  });

  test('prefers macOS keychain before storage', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(appToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        AttriaxNativeContext(
          metadata: <String, Object?>{'keychainDeviceId': 'macos-keychain-id'},
        ),
      ),
    );

    final resolved = await collector.resolvePreferredDeviceId(
      fallbackDeviceId: 'stored-fallback',
    );

    expect(resolved.value, 'macos-keychain-id');
    expect(resolved.source, 'macos_keychain');
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
