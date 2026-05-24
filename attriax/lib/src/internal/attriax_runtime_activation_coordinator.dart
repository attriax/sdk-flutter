import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_logger.dart';

typedef AttriaxRuntimeActivationDispatchGateSetter =
    void Function({required bool enabled});
typedef AttriaxRuntimeActivationAsyncAction = Future<void> Function();
typedef AttriaxRuntimeActivationSyncAction = void Function();
typedef AttriaxRuntimeActivationCrashActivator =
    Future<void> Function({required bool installHandlers});
typedef AttriaxRuntimeActivationSynchronizationStateSetter =
    void Function(AttriaxSynchronizationState state);

class AttriaxRuntimeActivationState {
  const AttriaxRuntimeActivationState({
    required this.shouldDeferNetworkDispatch,
    required this.allowsAttributionTracking,
    required this.shouldTrackAnything,
    required this.shouldActivateSessionTracking,
    required this.shouldInstallCrashHandlers,
    required this.canRunActiveSynchronizationFlow,
  });

  final bool shouldDeferNetworkDispatch;
  final bool allowsAttributionTracking;
  final bool shouldTrackAnything;
  final bool shouldActivateSessionTracking;
  final bool shouldInstallCrashHandlers;
  final bool canRunActiveSynchronizationFlow;
}

class AttriaxRuntimeActivationCoordinator {
  AttriaxRuntimeActivationCoordinator({
    required AttriaxLogger logger,
    required AttriaxRuntimeActivationSyncAction primeLaunchPreparation,
    required AttriaxRuntimeActivationDispatchGateSetter
    setAppOpenDispatchGateEnabled,
    required AttriaxRuntimeActivationSyncAction handleDisabledReferrers,
    required AttriaxRuntimeActivationSyncAction
    prepareReferrerWaitersForReenable,
    required AttriaxRuntimeActivationAsyncAction
    prepareReferrersForEnabledState,
    required AttriaxRuntimeActivationAsyncAction
    prepareForDeniedAttributionState,
    required AttriaxRuntimeActivationCrashActivator activateCrashReporting,
    required AttriaxRuntimeActivationAsyncAction deactivateCrashReporting,
    required AttriaxRuntimeActivationSyncAction activateSessionTracking,
    required AttriaxRuntimeActivationSyncAction deactivateSessionTracking,
    required AttriaxRuntimeActivationSyncAction activateSynchronizer,
    required AttriaxRuntimeActivationSyncAction deactivateSynchronizer,
    required AttriaxRuntimeActivationSynchronizationStateSetter
    setSynchronizationState,
    required AttriaxRuntimeActivationSyncAction startConnectivitySubscription,
    required AttriaxRuntimeActivationAsyncAction stopConnectivitySubscription,
    required AttriaxRuntimeActivationSyncAction scheduleFlush,
    required AttriaxRuntimeActivationSyncAction flushPendingSync,
    required AttriaxRuntimeActivationSyncAction scheduleAppOpenIfNeeded,
    required AttriaxRuntimeActivationAsyncAction startDeepLinks,
    required AttriaxRuntimeActivationAsyncAction stopDeepLinks,
  }) : _logger = logger,
       _primeLaunchPreparation = primeLaunchPreparation,
       _setAppOpenDispatchGateEnabled = setAppOpenDispatchGateEnabled,
       _handleDisabledReferrers = handleDisabledReferrers,
       _prepareReferrerWaitersForReenable = prepareReferrerWaitersForReenable,
       _prepareReferrersForEnabledState = prepareReferrersForEnabledState,
       _prepareForDeniedAttributionState = prepareForDeniedAttributionState,
       _activateCrashReporting = activateCrashReporting,
       _deactivateCrashReporting = deactivateCrashReporting,
       _activateSessionTracking = activateSessionTracking,
       _deactivateSessionTracking = deactivateSessionTracking,
       _activateSynchronizer = activateSynchronizer,
       _deactivateSynchronizer = deactivateSynchronizer,
       _setSynchronizationState = setSynchronizationState,
       _startConnectivitySubscription = startConnectivitySubscription,
       _stopConnectivitySubscription = stopConnectivitySubscription,
       _scheduleFlush = scheduleFlush,
       _flushPendingSync = flushPendingSync,
       _scheduleAppOpenIfNeeded = scheduleAppOpenIfNeeded,
       _startDeepLinks = startDeepLinks,
       _stopDeepLinks = stopDeepLinks;

  final AttriaxLogger _logger;
  final AttriaxRuntimeActivationSyncAction _primeLaunchPreparation;
  final AttriaxRuntimeActivationDispatchGateSetter
  _setAppOpenDispatchGateEnabled;
  final AttriaxRuntimeActivationSyncAction _handleDisabledReferrers;
  final AttriaxRuntimeActivationSyncAction _prepareReferrerWaitersForReenable;
  final AttriaxRuntimeActivationAsyncAction _prepareReferrersForEnabledState;
  final AttriaxRuntimeActivationAsyncAction _prepareForDeniedAttributionState;
  final AttriaxRuntimeActivationCrashActivator _activateCrashReporting;
  final AttriaxRuntimeActivationAsyncAction _deactivateCrashReporting;
  final AttriaxRuntimeActivationSyncAction _activateSessionTracking;
  final AttriaxRuntimeActivationSyncAction _deactivateSessionTracking;
  final AttriaxRuntimeActivationSyncAction _activateSynchronizer;
  final AttriaxRuntimeActivationSyncAction _deactivateSynchronizer;
  final AttriaxRuntimeActivationSynchronizationStateSetter
  _setSynchronizationState;
  final AttriaxRuntimeActivationSyncAction _startConnectivitySubscription;
  final AttriaxRuntimeActivationAsyncAction _stopConnectivitySubscription;
  final AttriaxRuntimeActivationSyncAction _scheduleFlush;
  final AttriaxRuntimeActivationSyncAction _flushPendingSync;
  final AttriaxRuntimeActivationSyncAction _scheduleAppOpenIfNeeded;
  final AttriaxRuntimeActivationAsyncAction _startDeepLinks;
  final AttriaxRuntimeActivationAsyncAction _stopDeepLinks;

  void prepareForReenable() {
    _prepareReferrerWaitersForReenable();
  }

  Future<void> apply({
    required bool enabled,
    required AttriaxRuntimeActivationState state,
  }) async {
    if (!enabled) {
      await _applyDisabledState();
      return;
    }

    _primeLaunchPreparation();

    if (state.shouldDeferNetworkDispatch) {
      await _applyDeferredState(state: state);
      return;
    }

    if (!state.shouldTrackAnything) {
      await _applyNoTrackingState();
      return;
    }

    await _applyActiveState(state: state);
  }

  Future<void> _applyDisabledState() async {
    _setAppOpenDispatchGateEnabled(enabled: false);
    _handleDisabledReferrers();
    await _deactivateCrashReporting();
    _deactivateSessionTracking();
    _deactivateSynchronizer();
    _setSynchronizationState(AttriaxSynchronizationState.disabled);
    _logger.warning('Attriax SDK disabled.');
    await _stopDeepLinks();
    await _stopConnectivitySubscription();
  }

  Future<void> _applyDeferredState({
    required AttriaxRuntimeActivationState state,
  }) async {
    _setAppOpenDispatchGateEnabled(enabled: false);
    _handleDisabledReferrers();
    await _activateCrashReporting(
      installHandlers: state.shouldInstallCrashHandlers,
    );
    if (state.shouldActivateSessionTracking) {
      _activateSessionTracking();
    } else {
      _deactivateSessionTracking();
    }
    _deactivateSynchronizer();
    _setSynchronizationState(AttriaxSynchronizationState.deferred);
    _logger.warning(
      'Attriax SDK is capturing locally and waiting for GDPR consent before sending network requests.',
    );
    await _startDeepLinks();
    await _stopConnectivitySubscription();
  }

  Future<void> _applyNoTrackingState() async {
    _setAppOpenDispatchGateEnabled(enabled: false);
    await _deactivateCrashReporting();
    _deactivateSessionTracking();
    _deactivateSynchronizer();
    _setSynchronizationState(AttriaxSynchronizationState.disabled);
    _logger.warning(
      'Attriax SDK initialized without any GDPR tracking categories enabled.',
    );
    await _stopDeepLinks();
    await _stopConnectivitySubscription();
  }

  Future<void> _applyActiveState({
    required AttriaxRuntimeActivationState state,
  }) async {
    _setAppOpenDispatchGateEnabled(enabled: state.allowsAttributionTracking);
    _activateSynchronizer();
    _setSynchronizationState(AttriaxSynchronizationState.synchronizing);
    _logger.verbose('Attriax SDK enabled.');

    if (!state.canRunActiveSynchronizationFlow) {
      return;
    }

    await _activateCrashReporting(
      installHandlers: state.shouldInstallCrashHandlers,
    );
    _startConnectivitySubscription();
    await _startDeepLinks();
    if (state.allowsAttributionTracking) {
      await _prepareReferrersForEnabledState();
      _scheduleAppOpenIfNeeded();
    } else {
      await _prepareForDeniedAttributionState();
    }
    if (state.shouldActivateSessionTracking) {
      _activateSessionTracking();
    } else {
      _deactivateSessionTracking();
    }
    _flushPendingSync();
    _scheduleFlush();
  }
}
