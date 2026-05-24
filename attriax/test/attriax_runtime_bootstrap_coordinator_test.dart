import 'package:attriax_flutter/src/internal/attriax_runtime_bootstrap_coordinator.dart';
import 'package:attriax_flutter/src/internal/attriax_runtime_settings_store.dart';
import 'package:attriax_flutter/src/internal/attriax_session_manager.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support/fake_generated_transport.dart';

void main() {
  group('AttriaxRuntimeBootstrapCoordinator', () {
    test(
      'bootstraps runtime state and creates a synchronizer when missing',
      () async {
        final harness = _BootstrapHarness();

        final synchronizer = await harness.coordinator.bootstrap(
          transport: harness.transport,
          enabledOverride: true,
          eventsEnabledOverride: false,
          sessionTrackingEnabled: true,
          seedRecoveredSessionEnd: true,
          existingSynchronizer: null,
        );

        expect(synchronizer, 'created_sync');
        expect(harness.calls, <String>[
          'bindConsentTransport',
          'initConsent',
          'syncRuntimePersistenceMode',
          'restoreRuntimePreferences:true:false',
          'restoreSettings:false:true',
          'initContext',
          'initSkan:true',
          'initSession:true',
          'initReferrer:false',
          'createSynchronizer',
          'bindRequestSynchronizer:created_sync',
          'bindSynchronizationStateListener:created_sync',
          'seedRecoveredSessionEnd:session_prev',
        ]);
      },
    );

    test(
      'reuses an existing synchronizer without reseeding the recovered session',
      () async {
        final harness = _BootstrapHarness();

        final synchronizer = await harness.coordinator.bootstrap(
          transport: harness.transport,
          enabledOverride: null,
          eventsEnabledOverride: true,
          sessionTrackingEnabled: false,
          seedRecoveredSessionEnd: false,
          existingSynchronizer: 'existing_sync',
        );

        expect(synchronizer, 'existing_sync');
        expect(harness.calls, <String>[
          'bindConsentTransport',
          'initConsent',
          'syncRuntimePersistenceMode',
          'restoreRuntimePreferences:null:true',
          'restoreSettings:false:true',
          'initContext',
          'initSkan:true',
          'initSession:false',
          'initReferrer:false',
          'bindRequestSynchronizer:existing_sync',
          'bindSynchronizationStateListener:existing_sync',
        ]);
      },
    );
  });
}

class _BootstrapHarness {
  _BootstrapHarness() {
    coordinator = AttriaxRuntimeBootstrapCoordinator<String>(
      bindConsentTransport: (transport) => calls.add('bindConsentTransport'),
      initConsent: () async => calls.add('initConsent'),
      syncRuntimePersistenceMode: () async =>
          calls.add('syncRuntimePersistenceMode'),
      restoreRuntimePreferences:
          ({bool? enabledOverride, bool? eventsEnabledOverride}) async {
            calls.add(
              'restoreRuntimePreferences:$enabledOverride:$eventsEnabledOverride',
            );
            return const AttriaxStoredRuntimeSettings(
              isEnabled: false,
              areEventsEnabled: true,
            );
          },
      restoreSettings: ({required bool enabled, required bool eventsEnabled}) =>
          calls.add('restoreSettings:$enabled:$eventsEnabled'),
      initContext: () async => calls.add('initContext'),
      isFirstLaunch: () => true,
      initSkan: ({required bool isFirstLaunch}) async =>
          calls.add('initSkan:$isFirstLaunch'),
      initSession: ({required bool enabled}) async {
        calls.add('initSession:$enabled');
        return AttriaxSessionRestoreResult(
          currentSession: _currentSession,
          startedNewSession: false,
          replacedSession: _replacedSession,
        );
      },
      initReferrer: ({required bool enabled}) async =>
          calls.add('initReferrer:$enabled'),
      createSynchronizer: (transport) {
        calls.add('createSynchronizer');
        return 'created_sync';
      },
      bindRequestSynchronizer: (synchronizer) =>
          calls.add('bindRequestSynchronizer:$synchronizer'),
      bindSynchronizationStateListener: (synchronizer) =>
          calls.add('bindSynchronizationStateListener:$synchronizer'),
      seedRecoveredSessionEnd: (session) =>
          calls.add('seedRecoveredSessionEnd:${session?.id}'),
    );
  }

  final List<String> calls = <String>[];
  final FakeGeneratedTransport transport = FakeGeneratedTransport();
  late final AttriaxRuntimeBootstrapCoordinator<String> coordinator;
}

final AttriaxSessionSnapshot _currentSession = AttriaxSessionSnapshot(
  id: 'session_current',
  deviceId: 'device_123',
  platform: AttriaxPlatformType.android,
  isFirstLaunch: true,
  startedAt: DateTime.utc(2026, 5, 24, 10),
  lastActivityAt: DateTime.utc(2026, 5, 24, 10, 5),
  heartbeatInterval: const Duration(minutes: 1),
);

final AttriaxSessionSnapshot _replacedSession = AttriaxSessionSnapshot(
  id: 'session_prev',
  deviceId: 'device_123',
  platform: AttriaxPlatformType.android,
  isFirstLaunch: false,
  startedAt: DateTime.utc(2026, 5, 24, 9),
  lastActivityAt: DateTime.utc(2026, 5, 24, 9, 55),
  heartbeatInterval: const Duration(minutes: 1),
);
