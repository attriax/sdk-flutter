import 'package:flutter/foundation.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_default_platform_registration.dart'
    if (dart.library.js_interop) 'attriax_default_platform_registration_web.dart';
import 'attriax_logger.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_preferences_store.dart';

class AttriaxContextPlatformServices {
  AttriaxContextPlatformServices({
    required Duration installReferrerTimeout,
    required Duration installReferrerRetryDelay,
    AttriaxPlatform? platform,
    AttriaxPlatformType? platformType,
  }) : _platform = _resolvePlatform(platform),
       _platformType = platformType ?? _resolveCurrentPlatformType(),
       _installReferrerTimeout = installReferrerTimeout,
       _installReferrerRetryDelay = installReferrerRetryDelay;

  final AttriaxPlatform _platform;
  final AttriaxPlatformType _platformType;
  final Duration _installReferrerTimeout;
  final Duration _installReferrerRetryDelay;

  AttriaxPlatform get platformInstance => _platform;
  AttriaxPlatformType get currentPlatformType => _platformType;

  AttriaxPlatformInstallReferrerManager buildPlatformInstallReferrerManager({
    required AttriaxLogger logger,
    required AttriaxPlatformInstallReferrerStore preferencesStore,
  }) => AttriaxPlatformInstallReferrerManager(
    platformType: _platformType,
    platform: _platform,
    logger: logger,
    preferencesStore: preferencesStore,
    installReferrerTimeout: _installReferrerTimeout,
    installReferrerRetryDelay: _installReferrerRetryDelay,
  );

  Future<void> setAutomaticCrashReportingEnabled({required bool enabled}) =>
      _platform.setAutomaticCrashReportingEnabled(enabled: enabled);

  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus() =>
      _platform.getTrackingAuthorizationStatus();

  static AttriaxPlatform _resolvePlatform(AttriaxPlatform? platform) {
    ensureAttriaxDefaultPlatformRegistered();
    return platform ?? AttriaxPlatform.instance;
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
}
