import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_generated_transport.dart';
import 'attriax_runtime_settings_store.dart';
import 'attriax_session_manager.dart';

typedef AttriaxRuntimeBootstrapBindConsentTransport =
    void Function(AttriaxGeneratedTransport transport);
typedef AttriaxRuntimeBootstrapRestoreRuntimePreferences =
  Future<AttriaxStoredRuntimeSettings> Function({
      bool? enabledOverride,
      bool? eventsEnabledOverride,
    });
typedef AttriaxRuntimeBootstrapRestoreSettings =
    void Function({required bool enabled, required bool eventsEnabled});
typedef AttriaxRuntimeBootstrapIsFirstLaunchProvider = bool Function();
typedef AttriaxRuntimeBootstrapInitSkan =
    Future<void> Function({required bool isFirstLaunch});
typedef AttriaxRuntimeBootstrapInitSession =
    Future<AttriaxSessionRestoreResult?> Function({required bool enabled});
typedef AttriaxRuntimeBootstrapInitReferrer =
    Future<void> Function({required bool enabled});
typedef AttriaxRuntimeBootstrapCreateSynchronizer<TSynchronizer> =
    TSynchronizer Function(AttriaxGeneratedTransport transport);
typedef AttriaxRuntimeBootstrapBindRequestSynchronizer<TSynchronizer> =
    void Function(TSynchronizer synchronizer);
typedef AttriaxRuntimeBootstrapBindSynchronizationStateListener<TSynchronizer> =
    void Function(TSynchronizer synchronizer);
typedef AttriaxRuntimeBootstrapSeedRecoveredSessionEnd =
    void Function(AttriaxSessionSnapshot? session);

class AttriaxRuntimeBootstrapCoordinator<TSynchronizer> {
  AttriaxRuntimeBootstrapCoordinator({
    required AttriaxRuntimeBootstrapBindConsentTransport bindConsentTransport,
    required Future<void> Function() initConsent,
    required Future<void> Function() syncRuntimePersistenceMode,
    required AttriaxRuntimeBootstrapRestoreRuntimePreferences
    restoreRuntimePreferences,
    required AttriaxRuntimeBootstrapRestoreSettings restoreSettings,
    required Future<void> Function() initContext,
    required AttriaxRuntimeBootstrapIsFirstLaunchProvider isFirstLaunch,
    required AttriaxRuntimeBootstrapInitSkan initSkan,
    required AttriaxRuntimeBootstrapInitSession initSession,
    required AttriaxRuntimeBootstrapInitReferrer initReferrer,
    required AttriaxRuntimeBootstrapCreateSynchronizer<TSynchronizer>
    createSynchronizer,
    required AttriaxRuntimeBootstrapBindRequestSynchronizer<TSynchronizer>
    bindRequestSynchronizer,
    required AttriaxRuntimeBootstrapBindSynchronizationStateListener<
      TSynchronizer
    >
    bindSynchronizationStateListener,
    required AttriaxRuntimeBootstrapSeedRecoveredSessionEnd
    seedRecoveredSessionEnd,
  }) : _bindConsentTransport = bindConsentTransport,
       _initConsent = initConsent,
       _syncRuntimePersistenceMode = syncRuntimePersistenceMode,
       _restoreRuntimePreferences = restoreRuntimePreferences,
       _restoreSettings = restoreSettings,
       _initContext = initContext,
       _isFirstLaunch = isFirstLaunch,
       _initSkan = initSkan,
       _initSession = initSession,
       _initReferrer = initReferrer,
       _createSynchronizer = createSynchronizer,
       _bindRequestSynchronizer = bindRequestSynchronizer,
       _bindSynchronizationStateListener = bindSynchronizationStateListener,
       _seedRecoveredSessionEnd = seedRecoveredSessionEnd;

  final AttriaxRuntimeBootstrapBindConsentTransport _bindConsentTransport;
  final Future<void> Function() _initConsent;
  final Future<void> Function() _syncRuntimePersistenceMode;
  final AttriaxRuntimeBootstrapRestoreRuntimePreferences
  _restoreRuntimePreferences;
  final AttriaxRuntimeBootstrapRestoreSettings _restoreSettings;
  final Future<void> Function() _initContext;
  final AttriaxRuntimeBootstrapIsFirstLaunchProvider _isFirstLaunch;
  final AttriaxRuntimeBootstrapInitSkan _initSkan;
  final AttriaxRuntimeBootstrapInitSession _initSession;
  final AttriaxRuntimeBootstrapInitReferrer _initReferrer;
  final AttriaxRuntimeBootstrapCreateSynchronizer<TSynchronizer>
  _createSynchronizer;
  final AttriaxRuntimeBootstrapBindRequestSynchronizer<TSynchronizer>
  _bindRequestSynchronizer;
  final AttriaxRuntimeBootstrapBindSynchronizationStateListener<TSynchronizer>
  _bindSynchronizationStateListener;
  final AttriaxRuntimeBootstrapSeedRecoveredSessionEnd _seedRecoveredSessionEnd;

  Future<TSynchronizer> bootstrap({
    required AttriaxGeneratedTransport transport,
    required bool? enabledOverride,
    required bool? eventsEnabledOverride,
    required bool sessionTrackingEnabled,
    required bool seedRecoveredSessionEnd,
    required TSynchronizer? existingSynchronizer,
  }) async {
    _bindConsentTransport(transport);
    await _initConsent();
    await _syncRuntimePersistenceMode();

    final storedRuntimePreferences = await _restoreRuntimePreferences(
      enabledOverride: enabledOverride,
      eventsEnabledOverride: eventsEnabledOverride,
    );
    _restoreSettings(
      enabled: storedRuntimePreferences.isEnabled,
      eventsEnabled: storedRuntimePreferences.areEventsEnabled,
    );

    await _initContext();
    await _initSkan(isFirstLaunch: _isFirstLaunch());
    final sessionRestore = await _initSession(enabled: sessionTrackingEnabled);
    await _initReferrer(enabled: storedRuntimePreferences.isEnabled);

    final synchronizer = existingSynchronizer ?? _createSynchronizer(transport);
    _bindRequestSynchronizer(synchronizer);
    _bindSynchronizationStateListener(synchronizer);

    if (seedRecoveredSessionEnd) {
      _seedRecoveredSessionEnd(sessionRestore?.replacedSession);
    }

    return synchronizer;
  }
}
