import 'dart:ui';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_native_context_metadata.dart';

class AttriaxContextSnapshotBuilder {
  AttriaxContextSnapshotBuilder({
    required AttriaxConfig config,
    required AttriaxPlatformType platformType,
    AttriaxNativeContextMetadata metadata =
        const AttriaxNativeContextMetadata(),
  }) : _config = config,
       _platformType = platformType,
       _metadata = metadata;

  final AttriaxConfig _config;
  final AttriaxPlatformType _platformType;
  final AttriaxNativeContextMetadata _metadata;

  AttriaxContextSnapshot buildAnonymousStartupSnapshot({
    required bool isFirstLaunch,
    String? timezone,
  }) {
    final normalizedTimezone =
        _metadata.emptyToNull(timezone) ??
        _metadata.emptyToNull(DateTime.now().timeZoneName);

    return AttriaxContextSnapshot(
      platform: _platformType,
      deviceId: null,
      isFirstLaunch: isFirstLaunch,
      sdk: AttriaxSdkSnapshot(
        apiVersion: attriaxSdkApiVersion,
        packageVersion: attriaxSdkPackageVersion,
        metadata: _collectSdkMetadata(),
      ),
      app: AttriaxAppSnapshot(
        version: _config.appVersion,
        buildNumber: _config.appBuildNumber,
        packageName: _config.appPackageName,
      ),
      device: AttriaxDeviceSnapshot(
        language: PlatformDispatcher.instance.locale.toLanguageTag(),
        timezone: normalizedTimezone,
      ),
    );
  }

  AttriaxContextSnapshot build({
    required AttriaxNativeContext nativeContext,
    required String deviceId,
    required bool isFirstLaunch,
  }) {
    final appSnapshot = _collectAppSnapshot(nativeContext);
    final deviceSnapshot = _collectDeviceSnapshot(nativeContext);

    return AttriaxContextSnapshot(
      platform: _platformType,
      deviceId: deviceId,
      isFirstLaunch: isFirstLaunch,
      sdk: AttriaxSdkSnapshot(
        apiVersion: attriaxSdkApiVersion,
        packageVersion: attriaxSdkPackageVersion,
        metadata: _collectSdkMetadata(),
      ),
      app: appSnapshot,
      device: deviceSnapshot,
    );
  }

  Map<String, Object?> _collectSdkMetadata() => <String, Object?>{
    ..._config.sdkMetadata,
    'clientRuntime': 'flutter',
  };

  AttriaxAppSnapshot _collectAppSnapshot(AttriaxNativeContext nativeContext) {
    final rawData = _metadata.loadRawDeviceData(nativeContext);
    return AttriaxAppSnapshot(
      version:
          _config.appVersion ??
          _metadata.readFirstString(rawData, const <String>[
            'appVersion',
            'versionName',
          ]),
      buildNumber:
          _config.appBuildNumber ??
          _metadata.readFirstString(rawData, const <String>[
            'appBuildNumber',
            'buildNumber',
            'versionCode',
          ]),
      packageName:
          _config.appPackageName ??
          _metadata.readFirstString(rawData, const <String>[
            'packageName',
            'bundleIdentifier',
          ]),
    );
  }

  AttriaxDeviceSnapshot _collectDeviceSnapshot(
    AttriaxNativeContext nativeContext,
  ) {
    final locale = PlatformDispatcher.instance.locale.toLanguageTag();
    final timezone =
        _metadata.nativeTimezone(nativeContext) ??
        _metadata.emptyToNull(DateTime.now().timeZoneName);
    final screenResolution = _screenResolution();
    final screenDimensions = _screenDimensions();
    final devicePixelRatio = _devicePixelRatio();
    final screenWidth = screenDimensions?.width;
    final screenHeight = screenDimensions?.height;

    try {
      final rawData = _metadata.loadRawDeviceData(nativeContext);
      final colorDepth = _metadata.readInt(rawData, 'colorDepth');
      final metadata = <String, Object?>{
        ...rawData,
        if (nativeContext.metadata.isNotEmpty)
          'nativeContext': nativeContext.metadata,
      };

      switch (_platformType) {
        case AttriaxPlatformType.android:
          final supportedAbis =
              _metadata.readStringList(rawData, 'supportedAbis').isNotEmpty
              ? _metadata.readStringList(rawData, 'supportedAbis')
              : <String>[
                  ..._metadata.readStringList(rawData, 'supported32BitAbis'),
                  ..._metadata.readStringList(rawData, 'supported64BitAbis'),
                ];
          return AttriaxDeviceSnapshot(
            model: _metadata.readString(rawData, 'model'),
            name:
                _metadata.readString(rawData, 'device') ??
                _metadata.readString(rawData, 'product'),
            brand: _metadata.readString(rawData, 'brand'),
            manufacturer: _metadata.readString(rawData, 'manufacturer'),
            hardware: _metadata.readString(rawData, 'hardware'),
            osVersion:
                _metadata.readString(rawData, 'osVersion') ??
                _metadata.readNestedString(rawData, const <String>[
                  'version',
                  'release',
                ]),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            colorDepth: colorDepth,
            advertisingId: nativeContext.advertisingId,
            androidId: nativeContext.androidId,
            isPhysicalDevice: _metadata.readBool(rawData, 'isPhysicalDevice'),
            supportedAbis: supportedAbis,
            metadata: metadata,
          );
        case AttriaxPlatformType.ios:
          final isSimulator = _metadata.readBool(rawData, 'isSimulator');
          return AttriaxDeviceSnapshot(
            model:
                _metadata.readString(rawData, 'hardwareModel') ??
                _metadata.readString(rawData, 'deviceModel') ??
                _metadata.readString(rawData, 'localizedModel'),
            name:
                _metadata.readString(rawData, 'localizedModel') ??
                _metadata.readString(rawData, 'deviceModel'),
            brand: 'Apple',
            manufacturer: 'Apple',
            hardware: _metadata.readString(rawData, 'hardwareModel'),
            osVersion: _metadata.readString(rawData, 'systemVersion'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            colorDepth: colorDepth,
            advertisingId: nativeContext.advertisingId,
            isPhysicalDevice:
                _metadata.readBool(rawData, 'isPhysicalDevice') ??
                (isSimulator == null ? null : !isSimulator),
            metadata: metadata,
          );
        case AttriaxPlatformType.macos:
          return AttriaxDeviceSnapshot(
            model: _metadata.readString(rawData, 'model'),
            name:
                _metadata.readString(rawData, 'computerName') ??
                _metadata.readString(rawData, 'hostName'),
            brand: 'Apple',
            manufacturer: 'Apple',
            hardware: _metadata.readString(rawData, 'arch'),
            osVersion:
                _metadata.readString(rawData, 'osRelease') ??
                _metadata.readString(rawData, 'operatingSystemVersionString'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            colorDepth: colorDepth,
            isPhysicalDevice: true,
            metadata: metadata,
          );
        case AttriaxPlatformType.windows:
          return AttriaxDeviceSnapshot(
            model: _metadata.readString(rawData, 'productName'),
            name: _metadata.readString(rawData, 'computerName'),
            brand: _metadata.readString(rawData, 'manufacturer'),
            manufacturer: _metadata.readString(rawData, 'manufacturer'),
            hardware: _metadata.readString(rawData, 'deviceId'),
            osVersion:
                _metadata.readString(rawData, 'osVersion') ??
                _metadata.readString(rawData, 'displayVersion') ??
                _metadata.readString(rawData, 'releaseId') ??
                _metadata.readString(rawData, 'currentBuildNumber'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            colorDepth: colorDepth,
            isPhysicalDevice: true,
            metadata: metadata,
          );
        case AttriaxPlatformType.linux:
          return AttriaxDeviceSnapshot(
            model:
                _metadata.readString(rawData, 'prettyName') ??
                _metadata.readString(rawData, 'name'),
            name:
                _metadata.readString(rawData, 'name') ??
                _metadata.readString(rawData, 'prettyName'),
            brand: _metadata.readString(rawData, 'idLike'),
            manufacturer: _metadata.readString(rawData, 'idLike'),
            hardware:
                _metadata.readString(rawData, 'machineId') ??
                _metadata.readString(rawData, 'variant'),
            osVersion:
                _metadata.readString(rawData, 'version') ??
                _metadata.readString(rawData, 'versionId'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            colorDepth: colorDepth,
            isPhysicalDevice: true,
            metadata: metadata,
          );
        case AttriaxPlatformType.web:
          return AttriaxDeviceSnapshot(
            model:
                _metadata.readString(rawData, 'browserName') ??
                _metadata.readString(rawData, 'userAgent'),
            name: _metadata.readString(rawData, 'appName'),
            brand: _metadata.readString(rawData, 'vendor'),
            manufacturer: _metadata.readString(rawData, 'vendor'),
            hardware: _metadata.readString(rawData, 'platform'),
            osVersion: _metadata.readString(rawData, 'platform'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            colorDepth: colorDepth,
            metadata: metadata,
          );
        case AttriaxPlatformType.unknown:
          return AttriaxDeviceSnapshot(
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            colorDepth: colorDepth,
            metadata: <String, Object?>{
              if (nativeContext.metadata.isNotEmpty)
                'nativeContext': nativeContext.metadata,
            },
          );
      }
    } catch (_) {
      return AttriaxDeviceSnapshot(
        language: locale,
        timezone: timezone,
        screenResolution: screenResolution,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        devicePixelRatio: devicePixelRatio,
        advertisingId: nativeContext.advertisingId,
        androidId: nativeContext.androidId,
        metadata: <String, Object?>{
          if (nativeContext.metadata.isNotEmpty)
            'nativeContext': nativeContext.metadata,
        },
      );
    }
  }

  String? _screenResolution() {
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) {
      return null;
    }
    final size = views.first.physicalSize;
    if (size.isEmpty) {
      return null;
    }
    return '${size.width.round()}x${size.height.round()}';
  }

  ({int width, int height})? _screenDimensions() {
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) {
      return null;
    }
    final size = views.first.physicalSize;
    if (size.isEmpty) {
      return null;
    }
    return (width: size.width.round(), height: size.height.round());
  }

  double? _devicePixelRatio() {
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) {
      return null;
    }
    final dpr = views.first.devicePixelRatio;
    if (dpr <= 0 || dpr.isNaN || dpr.isInfinite) {
      return null;
    }
    return dpr;
  }
}
