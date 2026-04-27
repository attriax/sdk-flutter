import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttriaxContextCollector {
  AttriaxContextCollector({
    required AttriaxConfig config,
    AttriaxPlatform? platform,
    DeviceInfoPlugin? deviceInfoPlugin,
    Duration installReferrerTimeout = _defaultInstallReferrerTimeout,
    Duration installReferrerRetryDelay = _defaultInstallReferrerRetryDelay,
  }) : _config = config,
       _platform = platform ?? AttriaxPlatform.instance,
       _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin(),
       _installReferrerTimeout = installReferrerTimeout,
       _installReferrerRetryDelay = installReferrerRetryDelay;

  static const _installReferrerStorageKey = 'attriax.install_referrer';
  static const _defaultInstallReferrerTimeout = Duration(seconds: 10);
  static const _defaultInstallReferrerRetryDelay = Duration(seconds: 2);

  final AttriaxConfig _config;
  final AttriaxPlatform _platform;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final Duration _installReferrerTimeout;
  final Duration _installReferrerRetryDelay;
  String? _cachedInstallReferrer;
  bool _loadedInstallReferrerCache = false;

  Future<AttriaxContextSnapshot> collect({
    required String deviceId,
    required bool isFirstLaunch,
  }) async {
    final platformType = _currentPlatform();
    final nativeContextFuture = _platform.collectNativeContext();
    final installReferrerFuture = _collectInstallReferrerContext(platformType);
    final nativeContext = await nativeContextFuture;
    final installReferrerContext = await installReferrerFuture;
    final installReferrer =
        _emptyToNull(installReferrerContext.installReferrer) ??
        _emptyToNull(nativeContext.installReferrer);
    if (installReferrer != null) {
      await _persistInstallReferrer(installReferrer);
    }
    final appSnapshot = await _collectAppSnapshot();
    final deviceSnapshot = await _collectDeviceSnapshot(
      platformType,
      nativeContext,
      installReferrerContext,
    );

    return AttriaxContextSnapshot(
      platform: platformType,
      deviceId: deviceId,
      isFirstLaunch: isFirstLaunch,
      installReferrer: installReferrer,
      sdk: AttriaxSdkSnapshot(
        apiVersion: attriaxSdkApiVersion,
        packageVersion: attriaxSdkPackageVersion,
        metadata: _collectSdkMetadata(),
      ),
      app: appSnapshot,
      device: deviceSnapshot,
    );
  }

  AttriaxPlatformType _currentPlatform() {
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

  Map<String, Object?> _collectSdkMetadata() {
    return <String, Object?>{
      ..._config.sdkMetadata,
      'clientRuntime': 'flutter',
    };
  }

  Future<AttriaxAppSnapshot> _collectAppSnapshot() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return AttriaxAppSnapshot(
        version: _config.appVersion ?? _emptyToNull(packageInfo.version),
        buildNumber:
            _config.appBuildNumber ?? _emptyToNull(packageInfo.buildNumber),
        packageName:
            _config.appPackageName ?? _emptyToNull(packageInfo.packageName),
      );
    } catch (_) {
      return AttriaxAppSnapshot(
        version: _config.appVersion,
        buildNumber: _config.appBuildNumber,
        packageName: _config.appPackageName,
      );
    }
  }

  Future<AttriaxInstallReferrerContext> _collectInstallReferrerContext(
    AttriaxPlatformType platformType,
  ) async {
    if (platformType != AttriaxPlatformType.android) {
      return const AttriaxInstallReferrerContext();
    }

    final cachedReferrer = await _readPersistedInstallReferrer();
    if (cachedReferrer != null) {
      return AttriaxInstallReferrerContext(
        installReferrer: cachedReferrer,
        metadata: const {'source': 'flutter_cached_install_referrer'},
      );
    }

    // First attempt.
    final first = await _fetchInstallReferrerOnce(attempt: 1);
    if (first.installReferrer != null && first.installReferrer!.isNotEmpty) {
      return first;
    }

    // Single retry with a short delay. The Play Install Referrer API can
    // briefly return empty on cold start before Play services finish binding.
    await Future<void>.delayed(_installReferrerRetryDelay);
    final second = await _fetchInstallReferrerOnce(attempt: 2);
    if (second.installReferrer != null && second.installReferrer!.isNotEmpty) {
      return second;
    }

    // Surface the degraded state to the backend so it knows attribution
    // had to fall back instead of pretending we got a clean empty referrer.
    final mergedMetadata = <String, dynamic>{
      ...first.metadata,
      ...second.metadata,
      'installReferrerStatus':
          (second.metadata['installReferrerStatus'] ??
                  first.metadata['installReferrerStatus'] ??
                  'empty')
              .toString(),
      'installReferrerAttempts': 2,
    };
    return AttriaxInstallReferrerContext(metadata: mergedMetadata);
  }

  @visibleForTesting
  Future<AttriaxInstallReferrerContext> collectInstallReferrerContextForTest({
    required AttriaxPlatformType platformType,
  }) {
    return _collectInstallReferrerContext(platformType);
  }

  Future<AttriaxInstallReferrerContext> _fetchInstallReferrerOnce({
    required int attempt,
  }) async {
    try {
      return await _platform.collectInstallReferrer().timeout(
        _installReferrerTimeout,
        onTimeout: () => AttriaxInstallReferrerContext(
          metadata: {
            'installReferrerStatus': 'timeout_flutter',
            'installReferrerAttempt': attempt,
          },
        ),
      );
    } catch (error) {
      return AttriaxInstallReferrerContext(
        metadata: {
          'installReferrerStatus': 'error_flutter',
          'installReferrerAttempt': attempt,
          'installReferrerError': error.toString(),
        },
      );
    }
  }

  Future<String?> _readPersistedInstallReferrer() async {
    if (_loadedInstallReferrerCache) {
      return _cachedInstallReferrer;
    }

    _loadedInstallReferrerCache = true;
    try {
      final preferences = await SharedPreferences.getInstance();
      _cachedInstallReferrer = _emptyToNull(
        preferences.getString(_installReferrerStorageKey),
      );
      return _cachedInstallReferrer;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistInstallReferrer(String installReferrer) async {
    if (_cachedInstallReferrer == installReferrer) {
      return;
    }

    _cachedInstallReferrer = installReferrer;
    _loadedInstallReferrerCache = true;

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_installReferrerStorageKey, installReferrer);
    } catch (_) {
      // Ignore persistence failures and continue with in-memory cache.
    }
  }

  Future<AttriaxDeviceSnapshot> _collectDeviceSnapshot(
    AttriaxPlatformType platformType,
    AttriaxNativeContext nativeContext,
    AttriaxInstallReferrerContext installReferrerContext,
  ) async {
    final locale = PlatformDispatcher.instance.locale.toLanguageTag();
    final timezone =
        _nativeTimezone(nativeContext) ??
        _emptyToNull(DateTime.now().timeZoneName);
    final screenResolution = _screenResolution();

    try {
      final rawData = await _loadRawDeviceData(platformType);
      final metadata = <String, Object?>{
        ...rawData,
        if (nativeContext.metadata.isNotEmpty)
          'nativeContext': nativeContext.metadata,
        if (installReferrerContext.metadata.isNotEmpty)
          'installReferrerContext': installReferrerContext.metadata,
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
            osVersion: _readNestedString(rawData, ['version', 'release']),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            advertisingId: nativeContext.advertisingId,
            androidId: nativeContext.androidId,
            isPhysicalDevice: _readBool(rawData, 'isPhysicalDevice'),
            supportedAbis: supportedAbis,
            metadata: metadata,
          );
        case AttriaxPlatformType.ios:
          final utsname = _readNestedString(rawData, ['utsname', 'machine']);
          return AttriaxDeviceSnapshot(
            model: _readString(rawData, 'model') ?? utsname,
            name:
                _readString(rawData, 'name') ??
                _readString(rawData, 'localizedModel'),
            brand: 'Apple',
            manufacturer: 'Apple',
            hardware: utsname,
            osVersion: _readString(rawData, 'systemVersion'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
            advertisingId: nativeContext.advertisingId,
            isPhysicalDevice: _readBool(rawData, 'isPhysicalDevice'),
            metadata: metadata,
          );
        case AttriaxPlatformType.macos:
          return AttriaxDeviceSnapshot(
            model: _readString(rawData, 'model'),
            name: _readString(rawData, 'computerName'),
            brand: 'Apple',
            manufacturer: 'Apple',
            hardware: _readString(rawData, 'arch'),
            osVersion: _readString(rawData, 'osRelease'),
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
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
            metadata: metadata,
          );
        case AttriaxPlatformType.unknown:
          return AttriaxDeviceSnapshot(
            language: locale,
            timezone: timezone,
            screenResolution: screenResolution,
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
        advertisingId: nativeContext.advertisingId,
        androidId: nativeContext.androidId,
        metadata: {
          if (nativeContext.metadata.isNotEmpty)
            'nativeContext': nativeContext.metadata,
        },
      );
    }
  }

  Future<Map<String, Object?>> _loadRawDeviceData(
    AttriaxPlatformType platformType,
  ) async {
    switch (platformType) {
      case AttriaxPlatformType.android:
        return _sanitizeDeviceData((await _deviceInfoPlugin.androidInfo).data);
      case AttriaxPlatformType.ios:
        return _sanitizeDeviceData((await _deviceInfoPlugin.iosInfo).data);
      case AttriaxPlatformType.macos:
        return _sanitizeDeviceData((await _deviceInfoPlugin.macOsInfo).data);
      case AttriaxPlatformType.windows:
        return _sanitizeDeviceData((await _deviceInfoPlugin.windowsInfo).data);
      case AttriaxPlatformType.linux:
        return _sanitizeDeviceData((await _deviceInfoPlugin.linuxInfo).data);
      case AttriaxPlatformType.web:
        return _sanitizeDeviceData(
          (await _deviceInfoPlugin.webBrowserInfo).data,
        );
      case AttriaxPlatformType.unknown:
        return const {};
    }
  }

  Map<String, Object?> _sanitizeDeviceData(Map<Object?, Object?> input) => input
      .map((key, value) => MapEntry(key.toString(), _sanitizeValue(value)));

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
}
