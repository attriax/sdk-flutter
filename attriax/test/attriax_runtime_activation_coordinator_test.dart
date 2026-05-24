import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_runtime_activation_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxRuntimeActivationCoordinator', () {
    test('disables runtime collaborators when the SDK is disabled', () async {
      final harness = _ActivationHarness();

      await harness.coordinator.apply(
        enabled: false,
        state: const AttriaxRuntimeActivationState(
          shouldDeferNetworkDispatch: false,
          allowsAttributionTracking: true,
          shouldTrackAnything: true,
          shouldActivateSessionTracking: true,
          shouldInstallCrashHandlers: true,
          canRunActiveSynchronizationFlow: true,
        ),
      );

      expect(harness.calls, <String>[
        'setDispatch:false',
        'handleDisabledReferrers',
        'deactivateCrashReporting',
        'deactivateSessionTracking',
        'deactivateSynchronizer',
        'setSynchronizationState:disabled',
        'stopDeepLinks',
        'stopConnectivitySubscription',
      ]);
    });

    test('enters deferred mode while GDPR consent is still pending', () async {
      final harness = _ActivationHarness();

      await harness.coordinator.apply(
        enabled: true,
        state: const AttriaxRuntimeActivationState(
          shouldDeferNetworkDispatch: true,
          allowsAttributionTracking: false,
          shouldTrackAnything: true,
          shouldActivateSessionTracking: true,
          shouldInstallCrashHandlers: true,
          canRunActiveSynchronizationFlow: true,
        ),
      );

      expect(harness.calls, <String>[
        'primeLaunchPreparation',
        'setDispatch:false',
        'handleDisabledReferrers',
        'activateCrashReporting:true',
        'activateSessionTracking',
        'deactivateSynchronizer',
        'setSynchronizationState:deferred',
        'startDeepLinks',
        'stopConnectivitySubscription',
      ]);
    });

    test(
      'stays disabled when consent removes every tracking category',
      () async {
        final harness = _ActivationHarness();

        await harness.coordinator.apply(
          enabled: true,
          state: const AttriaxRuntimeActivationState(
            shouldDeferNetworkDispatch: false,
            allowsAttributionTracking: false,
            shouldTrackAnything: false,
            shouldActivateSessionTracking: false,
            shouldInstallCrashHandlers: false,
            canRunActiveSynchronizationFlow: true,
          ),
        );

        expect(harness.calls, <String>[
          'primeLaunchPreparation',
          'setDispatch:false',
          'deactivateCrashReporting',
          'deactivateSessionTracking',
          'deactivateSynchronizer',
          'setSynchronizationState:disabled',
          'stopDeepLinks',
          'stopConnectivitySubscription',
        ]);
      },
    );

    test('activates runtime collaborators when tracking is allowed', () async {
      final harness = _ActivationHarness();

      await harness.coordinator.apply(
        enabled: true,
        state: const AttriaxRuntimeActivationState(
          shouldDeferNetworkDispatch: false,
          allowsAttributionTracking: true,
          shouldTrackAnything: true,
          shouldActivateSessionTracking: true,
          shouldInstallCrashHandlers: false,
          canRunActiveSynchronizationFlow: true,
        ),
      );

      expect(harness.calls, <String>[
        'primeLaunchPreparation',
        'setDispatch:true',
        'activateSynchronizer',
        'setSynchronizationState:synchronizing',
        'activateCrashReporting:false',
        'startConnectivitySubscription',
        'startDeepLinks',
        'prepareReferrersForEnabledState',
        'scheduleAppOpenIfNeeded',
        'activateSessionTracking',
        'flushPendingSync',
        'scheduleFlush',
      ]);
    });
  });
}

class _ActivationHarness {
  _ActivationHarness() {
    coordinator = AttriaxRuntimeActivationCoordinator(
      logger: AttriaxLogger(enableDebugLogs: false),
      primeLaunchPreparation: () => calls.add('primeLaunchPreparation'),
      setAppOpenDispatchGateEnabled: ({required bool enabled}) =>
          calls.add('setDispatch:$enabled'),
      handleDisabledReferrers: () => calls.add('handleDisabledReferrers'),
      prepareReferrerWaitersForReenable: () =>
          calls.add('prepareReferrerWaitersForReenable'),
      prepareReferrersForEnabledState: () async =>
          calls.add('prepareReferrersForEnabledState'),
      prepareForDeniedAttributionState: () async =>
          calls.add('prepareForDeniedAttributionState'),
      activateCrashReporting: ({required bool installHandlers}) async =>
          calls.add('activateCrashReporting:$installHandlers'),
      deactivateCrashReporting: () async =>
          calls.add('deactivateCrashReporting'),
      activateSessionTracking: () => calls.add('activateSessionTracking'),
      deactivateSessionTracking: () => calls.add('deactivateSessionTracking'),
      activateSynchronizer: () => calls.add('activateSynchronizer'),
      deactivateSynchronizer: () => calls.add('deactivateSynchronizer'),
      setSynchronizationState: (state) =>
          calls.add('setSynchronizationState:${state.name}'),
      startConnectivitySubscription: () =>
          calls.add('startConnectivitySubscription'),
      stopConnectivitySubscription: () async =>
          calls.add('stopConnectivitySubscription'),
      scheduleFlush: () => calls.add('scheduleFlush'),
      flushPendingSync: () => calls.add('flushPendingSync'),
      scheduleAppOpenIfNeeded: () => calls.add('scheduleAppOpenIfNeeded'),
      startDeepLinks: () async => calls.add('startDeepLinks'),
      stopDeepLinks: () async => calls.add('stopDeepLinks'),
    );
  }

  final List<String> calls = <String>[];
  late final AttriaxRuntimeActivationCoordinator coordinator;
}
