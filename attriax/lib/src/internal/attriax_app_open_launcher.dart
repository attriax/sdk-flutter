import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_sdk_runtime_config.dart';

typedef AttriaxAppOpenLaunchDidScheduleProvider = bool Function();
typedef AttriaxAppOpenLaunchAllowsAttributionTrackingProvider = bool Function();
typedef AttriaxAppOpenLaunchCurrentSessionIdProvider = String? Function();
typedef AttriaxAppOpenLaunchRuntimeConfigLoader =
    Future<AttriaxSdkRuntimeConfig> Function();
typedef AttriaxAppOpenLaunchDeviceMetadataBuilder =
    Future<Map<String, Object?>> Function({
      required bool allowsAttributionTracking,
    });
typedef AttriaxAppOpenLaunchInstallReferrerOverrideBuilder =
    String? Function({
      required bool clipboardAttributionEnabled,
      required bool allowsAttributionTracking,
    });
typedef AttriaxAppOpenLaunchScheduleCallback =
    Future<void> Function({
      String? installReferrerOverride,
      Map<String, Object?> deviceMetadataOverrides,
      Future<void> Function(AttriaxAppOpenResult? result)? onCompleted,
    });
typedef AttriaxAppOpenLaunchCompletedCallback =
    Future<void> Function(
      AttriaxAppOpenResult? result, {
      String? originSessionId,
    });

class AttriaxAppOpenLauncher {
  AttriaxAppOpenLauncher({
    required AttriaxAppOpenLaunchDidScheduleProvider didSchedule,
    required AttriaxAppOpenLaunchAllowsAttributionTrackingProvider
    allowsAttributionTracking,
    required AttriaxAppOpenLaunchCurrentSessionIdProvider currentSessionId,
    required AttriaxAppOpenLaunchRuntimeConfigLoader ensureRuntimeConfigLoaded,
    required AttriaxAppOpenLaunchDeviceMetadataBuilder
    buildDeviceMetadataOverrides,
    required AttriaxAppOpenLaunchInstallReferrerOverrideBuilder
    installReferrerOverrideForAppOpen,
    required AttriaxAppOpenLaunchScheduleCallback scheduleAppOpen,
    required AttriaxAppOpenLaunchCompletedCallback onCompleted,
  }) : _didSchedule = didSchedule,
       _allowsAttributionTracking = allowsAttributionTracking,
       _currentSessionId = currentSessionId,
       _ensureRuntimeConfigLoaded = ensureRuntimeConfigLoaded,
       _buildDeviceMetadataOverrides = buildDeviceMetadataOverrides,
       _installReferrerOverrideForAppOpen = installReferrerOverrideForAppOpen,
       _scheduleAppOpen = scheduleAppOpen,
       _onCompleted = onCompleted;

  final AttriaxAppOpenLaunchDidScheduleProvider _didSchedule;
  final AttriaxAppOpenLaunchAllowsAttributionTrackingProvider
  _allowsAttributionTracking;
  final AttriaxAppOpenLaunchCurrentSessionIdProvider _currentSessionId;
  final AttriaxAppOpenLaunchRuntimeConfigLoader _ensureRuntimeConfigLoaded;
  final AttriaxAppOpenLaunchDeviceMetadataBuilder _buildDeviceMetadataOverrides;
  final AttriaxAppOpenLaunchInstallReferrerOverrideBuilder
  _installReferrerOverrideForAppOpen;
  final AttriaxAppOpenLaunchScheduleCallback _scheduleAppOpen;
  final AttriaxAppOpenLaunchCompletedCallback _onCompleted;

  Future<void>? _inFlight;

  void reset() {
    _inFlight = null;
  }

  Future<void> scheduleIfNeeded({
    required bool isInitialized,
    required bool isEnabled,
    required bool hasSynchronizer,
  }) {
    if (!isInitialized ||
        !isEnabled ||
        !_allowsAttributionTracking() ||
        !hasSynchronizer ||
        _didSchedule()) {
      return Future<void>.value();
    }

    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final scheduling = _schedule();
    _inFlight = scheduling;
    return scheduling.whenComplete(() {
      if (identical(_inFlight, scheduling)) {
        _inFlight = null;
      }
    });
  }

  Future<void> _schedule() async {
    final originSessionId = _currentSessionId();
    final runtimeConfig = await _ensureRuntimeConfigLoaded();
    final allowsAttributionTracking = _allowsAttributionTracking();
    final deviceMetadataOverrides = await _buildDeviceMetadataOverrides(
      allowsAttributionTracking: allowsAttributionTracking,
    );
    await _scheduleAppOpen(
      installReferrerOverride: _installReferrerOverrideForAppOpen(
        clipboardAttributionEnabled: runtimeConfig.clipboardAttributionEnabled,
        allowsAttributionTracking: allowsAttributionTracking,
      ),
      deviceMetadataOverrides: deviceMetadataOverrides,
      onCompleted: (result) =>
          _onCompleted(result, originSessionId: originSessionId),
    );
  }
}
