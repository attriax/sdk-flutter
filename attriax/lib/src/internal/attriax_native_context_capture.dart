import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';

import 'attriax_context_services.dart';
import 'attriax_device_identity_resolver.dart';

typedef AttriaxNativeContextLoader =
    Future<AttriaxNativeContext> Function({required bool collectAdvertisingId});

typedef AttriaxTrackingAuthorizationWaiter = Future<void> Function();

class AttriaxNativeContextCapture {
  AttriaxNativeContextCapture({
    required bool collectAdvertisingId,
    required AttriaxNativeContextLoader collectNativeContext,
    required AttriaxTrackingAuthorizationWaiter
    waitForTrackingAuthorizationIfNeeded,
  }) : _collectAdvertisingId = collectAdvertisingId,
       _collectNativeContext = collectNativeContext,
       _waitForTrackingAuthorizationIfNeeded =
           waitForTrackingAuthorizationIfNeeded;

  final bool _collectAdvertisingId;
  final AttriaxNativeContextLoader _collectNativeContext;
  final AttriaxTrackingAuthorizationWaiter
  _waitForTrackingAuthorizationIfNeeded;

  Future<AttriaxNativeContext> collect({
    bool waitForTrackingAuthorization = true,
  }) async {
    if (waitForTrackingAuthorization) {
      await _waitForTrackingAuthorizationIfNeeded();
    }

    return _collectNativeContext(collectAdvertisingId: _collectAdvertisingId);
  }

  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
    required AttriaxPlatformDeviceIdentityResolver deviceIdentityResolver,
  }) async {
    try {
      final nativeContext = await collect(waitForTrackingAuthorization: false);
      final resolved = deviceIdentityResolver.resolveFromNativeContext(
        nativeContext,
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

  Future<String?> resolveDeviceTimezone({
    required AttriaxPlatformDeviceIdentityResolver deviceIdentityResolver,
  }) async {
    try {
      final nativeContext = await collect(waitForTrackingAuthorization: false);
      return deviceIdentityResolver.resolveTimezoneFromNativeContext(
            nativeContext,
          ) ??
          _emptyToNull(DateTime.now().timeZoneName);
    } catch (_) {
      return _emptyToNull(DateTime.now().timeZoneName);
    }
  }

  String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }
}
