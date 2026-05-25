// ignore_for_file: one_member_abstracts

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

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

abstract interface class AttriaxContextSnapshotSource {
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
    bool waitForTrackingAuthorization,
  });
}

abstract interface class AttriaxContextDeviceIdentityResolver {
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  });

  Future<String?> resolveDeviceTimezone();
}

abstract interface class AttriaxTrackingAuthorizationController {
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  });

  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus();
}

abstract interface class AttriaxCrashReportingSettingsController {
  Future<void> setAutomaticCrashReportingEnabled({required bool enabled});
}

abstract interface class AttriaxContextRuntimeServices
    implements
        AttriaxContextSnapshotSource,
        AttriaxContextDeviceIdentityResolver,
        AttriaxTrackingAuthorizationController,
        AttriaxCrashReportingSettingsController {}
