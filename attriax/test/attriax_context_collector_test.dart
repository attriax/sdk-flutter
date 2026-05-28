import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_context_collector.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'overrides sdk metadata with the Flutter client runtime marker',
    () async {
      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
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
      config: const AttriaxConfig(projectToken: 'ax_test_token'),
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
      config: const AttriaxConfig(projectToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        const AttriaxNativeContext(
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
      config: const AttriaxConfig(projectToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        const AttriaxNativeContext(advertisingId: 'android-gaid'),
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
      config: const AttriaxConfig(projectToken: 'ax_test_token'),
      platform:
          FakeAttriaxPlatform.withNativeContext(
              const AttriaxNativeContext(
                metadata: <String, Object?>{
                  'keychainDeviceId': 'ios-keychain-id',
                  'vendorIdentifier': 'ios-idfv',
                },
              ),
            )
            ..trackingAuthorizationStatus =
                AttriaxTrackingAuthorizationStatus.authorized,
    );

    final resolved = await collector.resolvePreferredDeviceId(
      fallbackDeviceId: 'stored-fallback',
    );

    expect(resolved.value, 'ios-keychain-id');
    expect(resolved.source, 'ios_keychain');
  });

  test('builds iOS app and device snapshots from native metadata', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(projectToken: 'ax_test_token'),
      platform:
          FakeAttriaxPlatform.withNativeContext(
              const AttriaxNativeContext(
                advertisingId: 'ios-idfa',
                metadata: <String, Object?>{
                  'appVersion': '1.2.3',
                  'appBuildNumber': '45',
                  'packageName': 'com.example.attriax.ios',
                  'keychainDeviceId': 'ios-keychain-id',
                  'vendorIdentifier': 'ios-idfv',
                  'applicationIdentifier': 'TEAM123.com.example.attriax.ios',
                  'teamIdentifier': 'TEAM123',
                  'associatedDomains': <String>['applinks:app.attriax.com'],
                  'flutterDeepLinkingEnabled': false,
                  'interfaceIdiom': 'phone',
                  'deviceModel': 'iPhone',
                  'localizedModel': 'iPhone',
                  'hardwareModel': 'iPhone14,5',
                  'systemVersion': '18.4',
                  'timezone': 'Europe/Berlin',
                  'isSimulator': false,
                  'isPhysicalDevice': true,
                },
              ),
            )
            ..trackingAuthorizationStatus =
                AttriaxTrackingAuthorizationStatus.authorized,
    );

    final context = await collector.collectContextSnapshot(
      deviceId: 'ios-device-1',
      isFirstLaunch: true,
    );

    expect(context.app.version, '1.2.3');
    expect(context.app.buildNumber, '45');
    expect(context.app.packageName, 'com.example.attriax.ios');
    expect(context.device.advertisingId, 'ios-idfa');
    expect(context.device.model, 'iPhone14,5');
    expect(context.device.name, 'iPhone');
    expect(context.device.brand, 'Apple');
    expect(context.device.manufacturer, 'Apple');
    expect(context.device.hardware, 'iPhone14,5');
    expect(context.device.osVersion, '18.4');
    expect(context.device.timezone, 'Europe/Berlin');
    expect(context.device.isPhysicalDevice, isTrue);
    expect(
      context.device.metadata['applicationIdentifier'],
      'TEAM123.com.example.attriax.ios',
    );
    expect(context.device.metadata['teamIdentifier'], 'TEAM123');
    expect(context.device.metadata['associatedDomains'], <String>[
      'applinks:app.attriax.com',
    ]);
    expect(context.device.metadata['flutterDeepLinkingEnabled'], isFalse);
    expect(context.device.metadata['interfaceIdiom'], 'phone');
    expect(context.device.metadata['isSimulator'], isFalse);
    expect(context.device.metadata['keychainDeviceId'], 'ios-keychain-id');
    expect(context.device.metadata['vendorIdentifier'], 'ios-idfv');
  });

  test('prefers macOS keychain before storage', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(projectToken: 'ax_test_token'),
      platform: FakeAttriaxPlatform.withNativeContext(
        const AttriaxNativeContext(
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

  test(
    'builds Windows app and device snapshots from native metadata',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(projectToken: 'ax_test_token'),
        platform: FakeAttriaxPlatform.withNativeContext(
          const AttriaxNativeContext(
            metadata: <String, Object?>{
              'appVersion': '2.4.0',
              'appBuildNumber': '2401',
              'packageName': 'Attriax.InternalTester',
              'productName': 'Surface Laptop 7',
              'computerName': 'QA-DESKTOP',
              'manufacturer': 'Microsoft',
              'deviceId': 'machine-guid-123',
              'displayVersion': '24H2',
              'osVersion': 'Windows 11 24H2 (build 26100)',
              'colorDepth': 32,
            },
          ),
        ),
      );

      final context = await collector.collectContextSnapshot(
        deviceId: 'device_test_windows',
        isFirstLaunch: false,
      );
      final resolved = await collector.resolvePreferredDeviceId(
        fallbackDeviceId: 'stored-fallback',
      );

      expect(context.app.version, '2.4.0');
      expect(context.app.buildNumber, '2401');
      expect(context.app.packageName, 'Attriax.InternalTester');
      expect(context.device.model, 'Surface Laptop 7');
      expect(context.device.name, 'QA-DESKTOP');
      expect(context.device.brand, 'Microsoft');
      expect(context.device.manufacturer, 'Microsoft');
      expect(context.device.hardware, 'machine-guid-123');
      expect(context.device.osVersion, 'Windows 11 24H2 (build 26100)');
      expect(context.device.colorDepth, 32);
      expect(resolved.value, 'machine-guid-123');
      expect(resolved.source, 'windows_machine_guid');
    },
  );

  test('builds web app and device snapshots from platform metadata', () async {
    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(projectToken: 'ax_test_token'),
      platformType: AttriaxPlatformType.web,
      platform: FakeAttriaxPlatform.withNativeContext(
        const AttriaxNativeContext(
          metadata: <String, Object?>{
            'appVersion': '3.2.1',
            'appBuildNumber': '88',
            'packageName': 'com.example.attriax.web',
            'browserName': 'Mozilla',
            'appName': 'Netscape',
            'vendor': 'Attriax Browser',
            'platform': 'macOS',
          },
        ),
      ),
    );

    final context = await collector.collectContextSnapshot(
      deviceId: 'web-device-1',
      isFirstLaunch: true,
    );

    expect(context.app.version, '3.2.1');
    expect(context.app.buildNumber, '88');
    expect(context.app.packageName, 'com.example.attriax.web');
    expect(context.device.model, 'Mozilla');
    expect(context.device.name, 'Netscape');
    expect(context.device.brand, 'Attriax Browser');
  });

  test(
    'passes advertising-id preference to the native context collector',
    () async {
      final platform = FakeAttriaxPlatform.withNativeContext(
        const AttriaxNativeContext(advertisingId: 'gaid'),
      );
      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          collectAdvertisingId: false,
        ),
        platform: platform,
      );

      await collector.resolvePreferredDeviceId(fallbackDeviceId: 'stored-id');

      expect(platform.collectAdvertisingIdValues, <bool>[false]);
    },
  );

  test(
    'startup waits for a manual tracking request that begins after init starts',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final requestCompleter = Completer<void>();
      final platform =
          FakeAttriaxPlatform.withNativeContext(const AttriaxNativeContext())
            ..requestTrackingAuthorizationStatus =
                AttriaxTrackingAuthorizationStatus.notDetermined
            ..requestTrackingAuthorizationCompleter = requestCompleter
            ..trackingAuthorizationStatusResponses =
                <AttriaxTrackingAuthorizationStatus>[
                  AttriaxTrackingAuthorizationStatus.notDetermined,
                  AttriaxTrackingAuthorizationStatus.notDetermined,
                  AttriaxTrackingAuthorizationStatus.authorized,
                ];
      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          trackingAuthorizationStatusTimeout: Duration(milliseconds: 100),
        ),
        platform: platform,
      );

      var snapshotCompleted = false;
      final snapshotFuture = collector
          .collectContextSnapshot(deviceId: 'ios-device-1', isFirstLaunch: true)
          .then((snapshot) {
            snapshotCompleted = true;
            return snapshot;
          });

      await Future<void>.delayed(const Duration(milliseconds: 20));

      var requestCompleted = false;
      final requestFuture = collector.requestTrackingAuthorization().then((
        status,
      ) {
        requestCompleted = true;
        return status;
      });

      await Future<void>.delayed(const Duration(milliseconds: 180));

      expect(snapshotCompleted, isFalse);
      expect(requestCompleted, isFalse);

      requestCompleter.complete();

      final status = await requestFuture;
      expect(status, AttriaxTrackingAuthorizationStatus.authorized);

      await snapshotFuture;
      expect(snapshotCompleted, isTrue);
    },
  );
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
  int getTrackingAuthorizationStatusCalls = 0;
  final List<bool> collectAdvertisingIdValues = <bool>[];
  List<AttriaxTrackingAuthorizationStatus>
  trackingAuthorizationStatusResponses = <AttriaxTrackingAuthorizationStatus>[];
  AttriaxTrackingAuthorizationStatus trackingAuthorizationStatus =
      AttriaxTrackingAuthorizationStatus.notDetermined;
  AttriaxTrackingAuthorizationStatus requestTrackingAuthorizationStatus =
      AttriaxTrackingAuthorizationStatus.authorized;
  Completer<void>? requestTrackingAuthorizationCompleter;
  String? clipboardText;
  String? webViewUserAgent;
  int readAttributionClipboardCalls = 0;
  int collectWebViewUserAgentCalls = 0;

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async {
    collectAdvertisingIdValues.add(collectAdvertisingId);
    return nativeContext;
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus>
  getTrackingAuthorizationStatus() async {
    getTrackingAuthorizationStatusCalls += 1;

    if (trackingAuthorizationStatusResponses.isNotEmpty) {
      return trackingAuthorizationStatusResponses.removeAt(0);
    }

    return trackingAuthorizationStatus;
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) async {
    final completer = requestTrackingAuthorizationCompleter;
    if (completer != null) {
      await completer.future;
    }

    return requestTrackingAuthorizationStatus;
  }

  @override
  Future<String?> readAttributionClipboard() async {
    readAttributionClipboardCalls += 1;
    return clipboardText;
  }

  @override
  Future<String?> collectWebViewUserAgent() async {
    collectWebViewUserAgentCalls += 1;
    return webViewUserAgent;
  }

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
