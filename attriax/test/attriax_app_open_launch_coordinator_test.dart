import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_app_open_launch_coordinator.dart';
import 'package:attriax_flutter/src/internal/attriax_sdk_runtime_config.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxAppOpenLaunchCoordinator', () {
    test('skips scheduling when launch gating is not satisfied', () async {
      var runtimeConfigLoads = 0;
      var scheduleCalls = 0;
      var allowsAttributionTracking = false;
      var didSchedule = false;

      final coordinator = _createCoordinator(
        didSchedule: () => didSchedule,
        allowsAttributionTracking: () => allowsAttributionTracking,
        ensureRuntimeConfigLoaded: () async {
          runtimeConfigLoads += 1;
          return const AttriaxSdkRuntimeConfig();
        },
        scheduleAppOpen: ({
          String? installReferrerOverride,
          Map<String, Object?> deviceMetadataOverrides =
              const <String, Object?>{},
          Future<void> Function(AttriaxAppOpenResult? result)? onCompleted,
        }) async {
          scheduleCalls += 1;
        },
      );

      await coordinator.scheduleIfNeeded(
        isInitialized: true,
        isEnabled: true,
        hasSynchronizer: true,
      );

      allowsAttributionTracking = true;
      await coordinator.scheduleIfNeeded(
        isInitialized: false,
        isEnabled: true,
        hasSynchronizer: true,
      );
      await coordinator.scheduleIfNeeded(
        isInitialized: true,
        isEnabled: false,
        hasSynchronizer: true,
      );
      await coordinator.scheduleIfNeeded(
        isInitialized: true,
        isEnabled: true,
        hasSynchronizer: false,
      );

      didSchedule = true;
      await coordinator.scheduleIfNeeded(
        isInitialized: true,
        isEnabled: true,
        hasSynchronizer: true,
      );

      expect(runtimeConfigLoads, 0);
      expect(scheduleCalls, 0);
    });

    test(
      'deduplicates in-flight scheduling and forwards launch-time inputs',
      () async {
        final scheduleCompleter = Completer<void>();
        var runtimeConfigLoads = 0;
        final metadataCalls = <bool>[];
        var overrideSawClipboardAttributionEnabled = false;
        var overrideSawTrackingEnabled = false;
        var scheduleCalls = 0;
        String? capturedInstallReferrerOverride;
        Map<String, Object?>? capturedDeviceMetadataOverrides;
        final completedResults = <AttriaxAppOpenResult?>[];
        final completedOriginSessionIds = <String?>[];

        final coordinator = _createCoordinator(
          didSchedule: () => false,
          allowsAttributionTracking: () => true,
          currentSessionId: () => 'session_123',
          ensureRuntimeConfigLoaded: () async {
            runtimeConfigLoads += 1;
            return const AttriaxSdkRuntimeConfig(
              clipboardAttributionEnabled: true,
            );
          },
          buildDeviceMetadataOverrides: ({
            required bool allowsAttributionTracking,
          }) async {
            metadataCalls.add(allowsAttributionTracking);
            return <String, Object?>{'wkWebViewUserAgent': 'ua'};
          },
          installReferrerOverrideForAppOpen: ({
            required bool clipboardAttributionEnabled,
            required bool allowsAttributionTracking,
          }) {
            overrideSawClipboardAttributionEnabled =
                clipboardAttributionEnabled;
            overrideSawTrackingEnabled = allowsAttributionTracking;
            return 'attriax_click_id=click-123';
          },
          scheduleAppOpen: ({
            String? installReferrerOverride,
            Map<String, Object?> deviceMetadataOverrides =
                const <String, Object?>{},
            Future<void> Function(AttriaxAppOpenResult? result)? onCompleted,
          }) async {
            scheduleCalls += 1;
            capturedInstallReferrerOverride = installReferrerOverride;
            capturedDeviceMetadataOverrides = Map<String, Object?>.from(
              deviceMetadataOverrides,
            );
            await onCompleted?.call(_appOpenResult);
            await scheduleCompleter.future;
          },
          onCompleted: (result, {originSessionId}) async {
            completedResults.add(result);
            completedOriginSessionIds.add(originSessionId);
          },
        );

        final first = coordinator.scheduleIfNeeded(
          isInitialized: true,
          isEnabled: true,
          hasSynchronizer: true,
        );
        final second = coordinator.scheduleIfNeeded(
          isInitialized: true,
          isEnabled: true,
          hasSynchronizer: true,
        );

        await _waitFor(() => scheduleCalls == 1);
        expect(scheduleCalls, 1);

        scheduleCompleter.complete();
        await first;
        await second;

        expect(runtimeConfigLoads, 1);
        expect(metadataCalls, <bool>[true]);
        expect(overrideSawClipboardAttributionEnabled, isTrue);
        expect(overrideSawTrackingEnabled, isTrue);
        expect(capturedInstallReferrerOverride, 'attriax_click_id=click-123');
        expect(capturedDeviceMetadataOverrides, <String, Object?>{
          'wkWebViewUserAgent': 'ua',
        });
        expect(completedResults, <AttriaxAppOpenResult?>[_appOpenResult]);
        expect(completedOriginSessionIds, <String?>['session_123']);
      },
    );
  });
}

AttriaxAppOpenLaunchCoordinator _createCoordinator({
  AttriaxAppOpenLaunchDidScheduleProvider? didSchedule,
  AttriaxAppOpenLaunchAllowsAttributionTrackingProvider?
  allowsAttributionTracking,
  AttriaxAppOpenLaunchCurrentSessionIdProvider? currentSessionId,
  AttriaxAppOpenLaunchRuntimeConfigLoader? ensureRuntimeConfigLoaded,
  AttriaxAppOpenLaunchDeviceMetadataBuilder? buildDeviceMetadataOverrides,
  AttriaxAppOpenLaunchInstallReferrerOverrideBuilder?
  installReferrerOverrideForAppOpen,
  AttriaxAppOpenLaunchScheduleCallback? scheduleAppOpen,
  AttriaxAppOpenLaunchCompletedCallback? onCompleted,
}) => AttriaxAppOpenLaunchCoordinator(
  didSchedule: didSchedule ?? () => false,
  allowsAttributionTracking: allowsAttributionTracking ?? () => true,
  currentSessionId: currentSessionId ?? () => null,
  ensureRuntimeConfigLoaded:
      ensureRuntimeConfigLoaded ?? () async => const AttriaxSdkRuntimeConfig(),
  buildDeviceMetadataOverrides:
      buildDeviceMetadataOverrides ??
      ({required bool allowsAttributionTracking}) async =>
          const <String, Object?>{},
  installReferrerOverrideForAppOpen:
      installReferrerOverrideForAppOpen ??
      ({
        required bool clipboardAttributionEnabled,
        required bool allowsAttributionTracking,
      }) => null,
  scheduleAppOpen:
      scheduleAppOpen ??
      ({
        String? installReferrerOverride,
        Map<String, Object?> deviceMetadataOverrides =
            const <String, Object?>{},
        Future<void> Function(AttriaxAppOpenResult? result)? onCompleted,
      }) async {},
  onCompleted: onCompleted ?? (result, {originSessionId}) async {},
);

const AttriaxAppOpenResult _appOpenResult = AttriaxAppOpenResult(
  userId: 'user_1',
  isNewUser: true,
  isFirstLaunch: true,
);

Future<void> _waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
  Duration step = const Duration(milliseconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(step);
  }

  if (condition()) {
    return;
  }

  throw StateError('Timed out while waiting for async app-open scheduling.');
}