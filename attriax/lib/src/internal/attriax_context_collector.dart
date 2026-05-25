import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_context_platform_services.dart';
import 'attriax_context_services.dart';
import 'attriax_context_snapshot_builder.dart';
import 'attriax_device_identity_resolver.dart';
import 'attriax_logger.dart';
import 'attriax_native_context_capture.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_preferences_store.dart';
import 'attriax_tracking_authorization_manager.dart';

export 'attriax_context_services.dart'
    show attriaxPersistentStorageDeviceIdSource, AttriaxResolvedDeviceId;

class AttriaxContextCollector implements AttriaxContextRuntimeServices {
  AttriaxContextCollector({
    required AttriaxConfig config,
    AttriaxLogger? logger,
    AttriaxPlatform? platform,
    AttriaxPlatformType? platformType,
    AttriaxPlatformInstallReferrerManager? platformInstallReferrerManager,
    AttriaxPreferencesStore? preferencesStore,
    Duration installReferrerTimeout = _defaultInstallReferrerTimeout,
    Duration installReferrerRetryDelay = _defaultInstallReferrerRetryDelay,
    AttriaxContextPlatformServices? platformServices,
    AttriaxTrackingAuthorizationManager? trackingAuthorizationManager,
    AttriaxNativeContextCapture? nativeContextCapture,
    AttriaxContextSnapshotBuilder? snapshotBuilder,
    AttriaxPlatformDeviceIdentityResolver? deviceIdentityResolver,
  }) {
    final resolvedPlatformServices =
        platformServices ??
        AttriaxContextPlatformServices(
          platform: platform,
          platformType: platformType,
          installReferrerTimeout: installReferrerTimeout,
          installReferrerRetryDelay: installReferrerRetryDelay,
        );
    final resolvedTrackingAuthorizationManager =
        trackingAuthorizationManager ??
        AttriaxTrackingAuthorizationManager(
          config: config,
          platform: resolvedPlatformServices.platformInstance,
          platformType: resolvedPlatformServices.currentPlatformType,
        );

    _platformServices = resolvedPlatformServices;
    _trackingAuthorizationManager = resolvedTrackingAuthorizationManager;
    _nativeContextCapture =
        nativeContextCapture ??
        AttriaxNativeContextCapture(
          collectAdvertisingId: config.collectAdvertisingId,
          collectNativeContext: ({required bool collectAdvertisingId}) =>
              resolvedPlatformServices.platformInstance.collectNativeContext(
                collectAdvertisingId: collectAdvertisingId,
              ),
          waitForTrackingAuthorizationIfNeeded:
              resolvedTrackingAuthorizationManager
                  .waitForTrackingAuthorizationIfNeeded,
        );
    _snapshotBuilder =
        snapshotBuilder ??
        AttriaxContextSnapshotBuilder(
          config: config,
          platformType: resolvedPlatformServices.currentPlatformType,
        );
    _deviceIdentityResolver =
        deviceIdentityResolver ??
        AttriaxPlatformDeviceIdentityResolver(
          platformType: resolvedPlatformServices.currentPlatformType,
        );
    _platformInstallReferrerManager =
        platformInstallReferrerManager ??
        resolvedPlatformServices.buildPlatformInstallReferrerManager(
          logger: logger ?? AttriaxLogger(enableDebugLogs: false),
          preferencesStore: preferencesStore ?? AttriaxPreferencesStore(),
        );
    _hasInjectedPlatformInstallReferrerManager =
        platformInstallReferrerManager != null;
  }

  static const _defaultInstallReferrerTimeout = Duration(seconds: 10);
  static const _defaultInstallReferrerRetryDelay = Duration(seconds: 2);

  late final AttriaxContextPlatformServices _platformServices;
  late final bool _hasInjectedPlatformInstallReferrerManager;
  late final AttriaxTrackingAuthorizationManager _trackingAuthorizationManager;
  late final AttriaxNativeContextCapture _nativeContextCapture;
  late final AttriaxContextSnapshotBuilder _snapshotBuilder;
  late final AttriaxPlatformDeviceIdentityResolver _deviceIdentityResolver;
  late final AttriaxPlatformInstallReferrerManager
  _platformInstallReferrerManager;

  AttriaxPlatform get platformInstance => _platformServices.platformInstance;
  AttriaxPlatformType get currentPlatformType =>
      _platformServices.currentPlatformType;

  AttriaxPlatformInstallReferrerManager get platformInstallReferrerManager =>
      _platformInstallReferrerManager;

  AttriaxPlatformInstallReferrerManager
  buildRuntimePlatformInstallReferrerManager({
    required AttriaxPlatformInstallReferrerStore preferencesStore,
    required AttriaxLogger logger,
  }) {
    if (_hasInjectedPlatformInstallReferrerManager) {
      return _platformInstallReferrerManager;
    }

    return _platformServices.buildPlatformInstallReferrerManager(
      logger: logger,
      preferencesStore: preferencesStore,
    );
  }

  @override
  Future<void> setAutomaticCrashReportingEnabled({required bool enabled}) =>
      _platformServices.setAutomaticCrashReportingEnabled(enabled: enabled);

  @override
  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus() =>
      _platformServices.getTrackingAuthorizationStatus();

  @override
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) => _trackingAuthorizationManager.requestTrackingAuthorization(
    timeout: timeout,
  );

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
    bool waitForTrackingAuthorization = false,
  }) async {
    final nativeContext = await _nativeContextCapture.collect(
      waitForTrackingAuthorization: waitForTrackingAuthorization,
    );
    return _snapshotBuilder.build(
      nativeContext: nativeContext,
      deviceId: deviceId,
      isFirstLaunch: isFirstLaunch,
    );
  }

  @override
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) => _nativeContextCapture.resolvePreferredDeviceId(
    fallbackDeviceId: fallbackDeviceId,
    deviceIdentityResolver: _deviceIdentityResolver,
  );

  @override
  Future<String?> resolveDeviceTimezone() => _nativeContextCapture
      .resolveDeviceTimezone(deviceIdentityResolver: _deviceIdentityResolver);
}
