import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'method_channel_attriax.dart';
import 'types.dart';

/// The interface that implementations of attriax must implement.
abstract class AttriaxPlatform extends PlatformInterface {
  AttriaxPlatform() : super(token: _token);

  static final Object _token = Object();

  static AttriaxPlatform _instance = MethodChannelAttriax();

  static AttriaxPlatform get instance => _instance;

  static set instance(AttriaxPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) {
    throw UnimplementedError(
      'collectNativeContext() has not been implemented.',
    );
  }

  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async =>
      const AttriaxInstallReferrerContext();

  Future<void> setAutomaticCrashReportingEnabled({
    required bool enabled,
  }) async {}

  Future<AttriaxTrackingAuthorizationStatus>
  getTrackingAuthorizationStatus() async =>
      AttriaxTrackingAuthorizationStatus.notSupported;

  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) async => AttriaxTrackingAuthorizationStatus.notSupported;

  Future<AttriaxPendingCrashReport?> consumePendingCrashReport() async => null;

  Future<bool> openBrowserUrl({
    required Uri uri,
    required AttriaxResolvedUrlOpenMode openMode,
  }) async => false;

  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async => const AttriaxSkanUpdateResult(
    status: AttriaxSkanUpdateStatus.notSupported,
    message:
        'SKAdNetwork conversion updates are not supported on this platform.',
  );
}
