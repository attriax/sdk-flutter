import 'package:flutter/foundation.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

import 'attriax_default_platform_registration.dart'
    if (dart.library.js_interop) 'attriax_default_platform_registration_web.dart';
import 'attriax_logger.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_preferences_store.dart';
import 'attriax_tracking_authorization_manager.dart';

const attriaxPersistentStorageDeviceIdSource = 'persistent_storage';

class AttriaxResolvedDeviceId {
  const AttriaxResolvedDeviceId({
    required this.value,
    required this.source,
    this.isFallback = false,
  });

  final String value;
  final String source;
  final bool isFallback;
}

class AttriaxContextCollector {
  AttriaxContextCollector({
    required AttriaxConfig config,
    AttriaxLogger? logger,
    AttriaxPlatform? platform,
    AttriaxPlatformType? platformType,
    AttriaxPlatformInstallReferrerManager? platformInstallReferrerManager,
    AttriaxPreferencesStore? preferencesStore,
    Duration installReferrerTimeout = _defaultInstallReferrerTimeout,
    Duration installReferrerRetryDelay = _defaultInstallReferrerRetryDelay,
  }) : _config = config,
       _platform = _resolvePlatform(platform),
       _platformType = platformType ?? _resolveCurrentPlatformType(),
       _trackingAuthorizationManager = AttriaxTrackingAuthorizationManager(
         config: config,
         platform: _resolvePlatform(platform),
         platformType: platformType ?? _resolveCurrentPlatformType(),
       ),
       _platformInstallReferrerManager =
           platformInstallReferrerManager ??
           AttriaxPlatformInstallReferrerManager(
             platformType: platformType ?? _resolveCurrentPlatformType(),
             platform: _resolvePlatform(platform),
             logger: logger ?? AttriaxLogger(enableDebugLogs: false),
             preferencesStore: preferencesStore ?? AttriaxPreferencesStore(),
             installReferrerTimeout: installReferrerTimeout,
             installReferrerRetryDelay: installReferrerRetryDelay,
           );

  static const _defaultInstallReferrerTimeout = Duration(seconds: 10);
  static const _defaultInstallReferrerRetryDelay = Duration(seconds: 2);

  final AttriaxConfig _config;
  final AttriaxPlatform _platform;
  final AttriaxPlatformType _platformType;
  final AttriaxTrackingAuthorizationManager _trackingAuthorizationManager;
  final AttriaxPlatformInstallReferrerManager _platformInstallReferrerManager;

  AttriaxPlatformInstallReferrerManager get platformInstallReferrerManager =>
      _platformInstallReferrerManager;

  Future<void> setAutomaticCrashReportingEnabled({required bool enabled}) =>
      _platform.setAutomaticCrashReportingEnabled(enabled: enabled);

  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus() =>
      _platform.getTrackingAuthorizationStatus();

  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) => _platform.requestTrackingAuthorization(timeout: timeout);

  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
  }) async {
    await _trackingAuthorizationManager.waitForTrackingAuthorizationIfNeeded();
    final nativeContext = await _platform.collectNativeContext(
      collectAdvertisingId: _config.collectAdvertisingId,
    );
    final appSnapshot = _collectAppSnapshot(nativeContext);
    final deviceSnapshot = await _collectDeviceSnapshot(
      _platformType,
      nativeContext,
    );
    return _buildContextSnapshot(
      platformType: _platformType,
      deviceId: deviceId,
      isFirstLaunch: isFirstLaunch,
      appSnapshot: appSnapshot,
      deviceSnapshot: deviceSnapshot,
    );
  }

  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) async {
    try {
      await _trackingAuthorizationManager
          .waitForTrackingAuthorizationIfNeeded();
      final nativeContext = await _platform.collectNativeContext(
        collectAdvertisingId: _config.collectAdvertisingId,
      );
      final rawData = _loadRawDeviceData(nativeContext);
      final resolved = _resolvePreferredDeviceIdFromSignals(
        platformType: _platformType,
        nativeContext: nativeContext,
        rawData: rawData,
      );

      if (resolved != null) {
        return resolved;
      }
    } catch (_) {
      // Keep the existing SDK-managed identifier when platform signals fail.
    }

    return AttriaxResolvedDeviceId(
      value: fallbackDeviceId,
      source: attriaxPersistentStorageDeviceIdSource,
      isFallback: true,
    );
  }

  static AttriaxPlatformType _resolveCurrentPlatformType() {
    if (kIsWeb) {
      return AttriaxPlatformType.web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AttriaxPlatformType.android;
      case TargetPlatform.iOS:
        return AttriaxPlatformType.ios;
      case TargetPlatform.macOS:
        return AttriaxPlatformType.macos;
      case TargetPlatform.windows:
        return AttriaxPlatformType.windows;
      case TargetPlatform.linux:
        return AttriaxPlatformType.linux;
      case TargetPlatform.fuchsia:
        return AttriaxPlatformType.unknown;
    }
  }

  Map<String, Object?> _collectSdkMetadata() => <String, Object?>{
    ..._config.sdkMetadata,
    'clientRuntime': 'flutter',
  };

  AttriaxAppSnapshot _collectAppSnapshot(AttriaxNativeContext nativeContext) {
    final rawData = _loadRawDeviceData(nativeContext);
    return AttriaxAppSnapshot(
      version:
          _config.appVersion ??
          _readFirstString(rawData, const ['appVersion', 'versionName']),
      buildNumber:
          _config.appBuildNumber ??
          _readFirstString(rawData, const [
            'appBuildNumber',
            'buildNumber',
            'versionCode',
          ]),
      packageName:
          _config.appPackageName ??
          _readFirstString(rawData, const ['packageName', 'bundleIdentifier']),
    );
  }

  static AttriaxPlatform _resolvePlatform(AttriaxPlatform? platform) {
    ensureAttriaxDefaultPlatformRegistered();
    return platform ?? AttriaxPlatform.instance;
  }

  AttriaxContextSnapshot _buildContextSnapshot({
    required AttriaxPlatformType platformType,
    required String deviceId,
    required bool isFirstLaunch,
    required AttriaxAppSnapshot appSnapshot,
    required AttriaxDeviceSnapshot deviceSnapshot,
  }) => AttriaxContextSnapshot(
    platform: platformType,
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

  Future<AttriaxDeviceSnapshot> _collectDeviceSnapshot(
    AttriaxPlatformType platformType,
    AttriaxNativeContext nativeContext,
  ) async {
    final locale = PlatformDispatcher.instance.locale.toLanguageTag();
    final timezone =
        _nativeTimezone(nativeContext) ??
        _emptyToNull(DateTime.now().timeZoneName);
    final screenResolution = _screenResolution();
    final screenDimensions = _screenDimensions();
    final devicePixelRatio = _devicePixelRatio();
    final screenWidth = screenDimensions?.width;
    final screenHeight = screenDimensions?.height;

    try {
      final rawData = _loadRawDeviceData(nativeContext);
      final metadata = <String, Object?>{
        ...rawData,
        if (nativeContext.metadata.isNotEmpty)
          'nativeContext': nativeContext.metadata,
      };

      switch (platformType) {
        case AttriaxPlatformType.android:
          final supportedAbis =
              _readStringList(rawData, 'supportedAbis').isNotEmpty
              ? _readStringList(rawData, 'supportedAbis')
              : [
                  ..._readStringList(rawData, 'supported32BitAbis'),
                  ..._readStringList(rawData, 'supported64BitAbis'),
                ];
          return AttriaxDeviceSnapshot(
            model: _readString(rawData, 'model'),
            name:
                _readString(rawData, 'device') ??
                _readString(rawData, 'product'),
            brand: _readString(rawData, 'brand'),
            manufacturer: _readString(rawData, 'manufacturer'),
            hardware: _readString(rawData, 'hardware'),
            osVersion:
                _readString(rawData, 'osVersion') ??
                _readNestedString(rawData, ['version', 'release']),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            advertisingId: nativeContext.advertisingId,
            androidId: nativeContext.androidId,
            isPhysicalDevice: _readBool(rawData, 'isPhysicalDevice'),
            supportedAbis: supportedAbis,
            metadata: metadata,
          );
        case AttriaxPlatformType.ios:
          final genericModel = _readFirstString(rawData, [
            'model',
            'deviceModel',
          ]);
          final preciseHardwareModel = _readString(rawData, 'hardwareModel');
          return AttriaxDeviceSnapshot(
            model: _preferredIosModel(genericModel, preciseHardwareModel),
            name:
                _readString(rawData, 'name') ??
                _readString(rawData, 'localizedModel'),
            brand: 'Apple',
            manufacturer: 'Apple',
            hardware: _readString(rawData, 'hardwareModel'),
            osVersion: _readString(rawData, 'systemVersion'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            advertisingId: nativeContext.advertisingId,
            isPhysicalDevice: _readBool(rawData, 'isPhysicalDevice'),
            metadata: metadata,
          );
        case AttriaxPlatformType.macos:
          return AttriaxDeviceSnapshot(
            model: _readString(rawData, 'model'),
            name:
                _readString(rawData, 'computerName') ??
                _readString(rawData, 'hostName'),
            brand: 'Apple',
            manufacturer: 'Apple',
            hardware: _readString(rawData, 'arch'),
            osVersion:
                _readString(rawData, 'osRelease') ??
                _readString(rawData, 'operatingSystemVersionString'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            isPhysicalDevice: true,
            metadata: metadata,
          );
        case AttriaxPlatformType.windows:
          return AttriaxDeviceSnapshot(
            model: _readString(rawData, 'productName'),
            name: _readString(rawData, 'computerName'),
            brand: _readString(rawData, 'manufacturer'),
            manufacturer: _readString(rawData, 'manufacturer'),
            hardware: _readString(rawData, 'deviceId'),
            osVersion:
                _readString(rawData, 'displayVersion') ??
                _readString(rawData, 'releaseId'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            isPhysicalDevice: true,
            metadata: metadata,
          );
        case AttriaxPlatformType.linux:
          return AttriaxDeviceSnapshot(
            model:
                _readString(rawData, 'prettyName') ??
                _readString(rawData, 'name'),
            name:
                _readString(rawData, 'name') ??
                _readString(rawData, 'prettyName'),
            brand: _readString(rawData, 'idLike'),
            manufacturer: _readString(rawData, 'idLike'),
            hardware:
                _readString(rawData, 'machineId') ??
                _readString(rawData, 'variant'),
            osVersion:
                _readString(rawData, 'version') ??
                _readString(rawData, 'versionId'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
            isPhysicalDevice: true,
            metadata: metadata,
          );
        case AttriaxPlatformType.web:
          return AttriaxDeviceSnapshot(
            model:
                _readString(rawData, 'browserName') ??
                _readString(rawData, 'userAgent'),
            name: _readString(rawData, 'appName'),
            brand: _readString(rawData, 'vendor'),
            manufacturer: _readString(rawData, 'vendor'),
            hardware: _readString(rawData, 'platform'),
            osVersion: _readString(rawData, 'platform'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            devicePixelRatio: devicePixelRatio,
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
            metadata: {
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
        metadata: {
          if (nativeContext.metadata.isNotEmpty)
            'nativeContext': nativeContext.metadata,
        },
      );
    }
  }

  Map<String, Object?> _loadRawDeviceData(AttriaxNativeContext nativeContext) =>
      _sanitizeDeviceData(Map<Object?, Object?>.from(nativeContext.metadata));

  Map<String, Object?> _sanitizeDeviceData(Map<Object?, Object?> input) => input
      .map((key, value) => MapEntry(key.toString(), _sanitizeValue(value)));

  AttriaxResolvedDeviceId? _resolvePreferredDeviceIdFromSignals({
    required AttriaxPlatformType platformType,
    required AttriaxNativeContext nativeContext,
    required Map<String, Object?> rawData,
  }) {
    switch (platformType) {
      case AttriaxPlatformType.android:
        final androidId = _emptyToNull(nativeContext.androidId);
        if (androidId != null) {
          return AttriaxResolvedDeviceId(
            value: androidId,
            source: 'android_ssaid',
          );
        }

        final advertisingId = _emptyToNull(nativeContext.advertisingId);
        if (advertisingId != null) {
          return AttriaxResolvedDeviceId(
            value: advertisingId,
            source: 'android_gaid',
          );
        }

        return null;
      case AttriaxPlatformType.ios:
        return _resolveFirstAvailable(<({String? value, String source})>[
          (
            value: _readString(nativeContext.metadata, 'keychainDeviceId'),
            source: 'ios_keychain',
          ),
          (
            value: _readString(nativeContext.metadata, 'vendorIdentifier'),
            source: 'ios_idfv',
          ),
        ]);
      case AttriaxPlatformType.windows:
        return _resolveFirstAvailable(<({String? value, String source})>[
          (
            value: _readString(rawData, 'deviceId'),
            source: 'windows_machine_guid',
          ),
        ]);
      case AttriaxPlatformType.linux:
        return _resolveFirstAvailable(<({String? value, String source})>[
          (
            value: _readString(rawData, 'machineId'),
            source: 'linux_machine_id',
          ),
        ]);
      case AttriaxPlatformType.macos:
        return _resolveFirstAvailable(<({String? value, String source})>[
          (
            value: _readString(rawData, 'systemGUID'),
            source: 'macos_platform_uuid',
          ),
          (
            value: _readString(nativeContext.metadata, 'keychainDeviceId'),
            source: 'macos_keychain',
          ),
        ]);
      case AttriaxPlatformType.web:
      case AttriaxPlatformType.unknown:
        return null;
    }
  }

  AttriaxResolvedDeviceId? _resolveFirstAvailable(
    Iterable<({String? value, String source})> candidates,
  ) {
    for (final candidate in candidates) {
      final normalizedValue = _emptyToNull(candidate.value);
      if (normalizedValue == null) {
        continue;
      }

      return AttriaxResolvedDeviceId(
        value: normalizedValue,
        source: candidate.source,
      );
    }

    return null;
  }

  Object? _sanitizeValue(Object? value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is List) {
      return value.map(_sanitizeValue).toList(growable: false);
    }
    if (value is Map) {
      return value.map(
        (key, nestedValue) =>
            MapEntry(key.toString(), _sanitizeValue(nestedValue)),
      );
    }
    return value.toString();
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

  /// Pixel-aligned screen dimensions for attribution matching. Returns null
  /// when no view is attached yet (e.g. very early in startup).
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

  String? _nativeTimezone(AttriaxNativeContext nativeContext) {
    final value = nativeContext.metadata['timezone'];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  String? _readString(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  String? _readFirstString(Map<String, Object?> data, List<String> keys) {
    for (final key in keys) {
      final value = _readString(data, key);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  String? _readNestedString(Map<String, Object?> data, List<String> path) {
    Object? current = data;
    for (final segment in path) {
      if (current is! Map) {
        return null;
      }
      current = current[segment];
    }
    if (current is String && current.trim().isNotEmpty) {
      return current;
    }
    return null;
  }

  bool? _readBool(Map<String, Object?> data, String key) {
    final value = data[key];
    return value is bool ? value : null;
  }

  List<String> _readStringList(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  String? _preferredIosModel(String? model, String? hardwareModel) {
    if (model == null) {
      return hardwareModel;
    }

    if (hardwareModel == null) {
      return model;
    }

    switch (model) {
      case 'iPhone':
      case 'iPad':
      case 'iPod touch':
        return hardwareModel;
    }

    return model;
  }
}
