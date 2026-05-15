import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';

class AttriaxSkanManager {
  AttriaxSkanManager({
    required AttriaxConfig config,
    required AttriaxPreferencesStore preferencesStore,
    required AttriaxPlatform platform,
    required AttriaxPlatformType platformType,
    required AttriaxClock clock,
    required AttriaxLogger logger,
  }) : _config = config,
       _preferencesStore = preferencesStore,
       _platform = platform,
       _platformType = platformType,
       _clock = clock,
       _logger = logger;

  final AttriaxConfig _config;
  final AttriaxPreferencesStore _preferencesStore;
  final AttriaxPlatform _platform;
  final AttriaxPlatformType _platformType;
  final AttriaxClock _clock;
  final AttriaxLogger _logger;

  AttriaxSkanState? _state;

  AttriaxSkanState? get state => _state;

  Future<void> init({required bool isFirstLaunch}) async {
    final config = _config.skan;
    if (config == null) {
      _state = null;
      return;
    }

    final restoredState = await _preferencesStore.readSkanState();
    final configuredTemplate = config.template;
    final resolvedTemplate = configuredTemplate == AttriaxSkanTemplate.auto
        ? restoredState?.resolvedTemplate
        : configuredTemplate;

    _state =
        (restoredState ??
                AttriaxSkanState(
                  enabled: config.enabled,
                  mode: config.mode,
                  configuredTemplate: configuredTemplate,
                ))
            .copyWith(
              enabled: config.enabled,
              mode: config.mode,
              configuredTemplate: configuredTemplate,
              resolvedTemplate: resolvedTemplate,
              clearResolvedTemplate:
                  configuredTemplate == AttriaxSkanTemplate.auto &&
                  resolvedTemplate == null,
            );

    await _persistState();

    if (!config.enabled || !config.registerFirstLaunchValue || !isFirstLaunch) {
      return;
    }

    final currentState = _state;
    if (currentState != null && currentState.firstLaunchValueRegistered) {
      return;
    }

    await updateConversionValue(fineValue: 0);
  }

  Future<void> reset() async {
    _state = null;
    await _preferencesStore.setSkanState(state: null);
  }

  Future<AttriaxSkanUpdateResult> updateConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
    AttriaxSkanTemplate? resolvedTemplate,
  }) async {
    final config = _config.skan;
    final currentState = _ensureState();

    if (config == null || !config.enabled) {
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.disabled,
        message: 'SKAdNetwork is disabled for this SDK instance.',
        state: currentState,
      );
    }

    if (fineValue < 0 || fineValue > 63) {
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.invalidValue,
        message: 'fineValue must be between 0 and 63.',
        state: currentState,
      );
    }

    if (_platformType != AttriaxPlatformType.ios) {
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.notSupported,
        message: 'SKAdNetwork updates are only supported on iOS.',
        state: currentState,
      );
    }

    final nextFineValue = currentState.fineValue == null
        ? fineValue
        : (fineValue > currentState.fineValue!
              ? fineValue
              : currentState.fineValue!);
    final nextCoarseValue = _maxCoarseValue(
      currentState.coarseValue,
      coarseValue ?? _deriveCoarseValue(nextFineValue),
    );
    final nextLockWindow = currentState.lockWindow || lockWindow;
    final nextResolvedTemplate =
        resolvedTemplate ??
        currentState.resolvedTemplate ??
        (config.template == AttriaxSkanTemplate.auto ? null : config.template);

    final nextState = currentState.copyWith(
      fineValue: nextFineValue,
      coarseValue: nextCoarseValue,
      lockWindow: nextLockWindow,
      resolvedTemplate: nextResolvedTemplate,
      firstLaunchValueRegistered:
          currentState.firstLaunchValueRegistered || nextFineValue == 0,
      lastUpdatedAt: _clock.now(),
    );

    if (_statesEqual(currentState, nextState)) {
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.alreadyAtOrAboveValue,
        message:
            'The requested conversion value does not advance the stored SKAN state.',
        fineValue: currentState.fineValue,
        coarseValue: currentState.coarseValue,
        lockWindow: currentState.lockWindow,
        state: currentState,
      );
    }

    final bridgeResult = await _platform.updateSkanConversionValue(
      fineValue: nextFineValue,
      coarseValue: nextCoarseValue,
      lockWindow: nextLockWindow,
    );

    if (bridgeResult.status == AttriaxSkanUpdateStatus.updated ||
        bridgeResult.status == AttriaxSkanUpdateStatus.skipped) {
      _state = nextState;
      await _persistState();
      return AttriaxSkanUpdateResult(
        status: bridgeResult.status,
        message: bridgeResult.message,
        fineValue: nextState.fineValue,
        coarseValue: nextState.coarseValue,
        lockWindow: nextState.lockWindow,
        state: nextState,
      );
    }

    return AttriaxSkanUpdateResult(
      status: bridgeResult.status,
      message: bridgeResult.message,
      fineValue: bridgeResult.fineValue,
      coarseValue: bridgeResult.coarseValue,
      lockWindow: bridgeResult.lockWindow,
      state: currentState,
    );
  }

  Future<AttriaxSkanUpdateResult?> handleSemanticEvent(
    AttriaxSkanSemanticEvent? event,
  ) async {
    final config = _config.skan;
    if (event == null || config == null || !config.enabled) {
      return null;
    }

    if (config.mode != AttriaxSkanMode.auto) {
      return null;
    }

    final resolvedTemplate = _resolveTemplate(event);
    final candidate = _candidateFor(
      template: resolvedTemplate,
      event: event,
      lockWindowEnabled: config.lockWindowEnabled,
    );
    if (candidate == null) {
      return null;
    }

    return updateConversionValue(
      fineValue: candidate.fineValue,
      coarseValue: candidate.coarseValue,
      lockWindow: candidate.lockWindow,
      resolvedTemplate: resolvedTemplate,
    );
  }

  AttriaxSkanState _ensureState() {
    final existingState = _state;
    if (existingState != null) {
      return existingState;
    }

    final config = _config.skan;
    return AttriaxSkanState(
      enabled: config?.enabled ?? false,
      mode: config?.mode ?? AttriaxSkanMode.auto,
      configuredTemplate: config?.template ?? AttriaxSkanTemplate.auto,
      resolvedTemplate:
          config?.template == null ||
              config?.template == AttriaxSkanTemplate.auto
          ? null
          : config?.template,
    );
  }

  AttriaxSkanTemplate _resolveTemplate(AttriaxSkanSemanticEvent event) {
    final config = _config.skan;
    if (config == null) {
      return AttriaxSkanTemplate.auto;
    }

    if (config.template != AttriaxSkanTemplate.auto) {
      return config.template;
    }

    final currentResolved = _state?.resolvedTemplate;
    if (currentResolved != null) {
      return currentResolved;
    }

    return switch (event) {
      AttriaxSkanSemanticEvent.purchase ||
      AttriaxSkanSemanticEvent.addToCart ||
      AttriaxSkanSemanticEvent.checkoutStarted => AttriaxSkanTemplate.ecommerce,
      AttriaxSkanSemanticEvent.subscriptionStarted ||
      AttriaxSkanSemanticEvent.subscriptionRenewed ||
      AttriaxSkanSemanticEvent.trialStarted => AttriaxSkanTemplate.subscription,
      AttriaxSkanSemanticEvent.tutorialComplete ||
      AttriaxSkanSemanticEvent.levelAchieved => AttriaxSkanTemplate.game,
      AttriaxSkanSemanticEvent.adImpression ||
      AttriaxSkanSemanticEvent.adRevenue => AttriaxSkanTemplate.adMonetization,
      AttriaxSkanSemanticEvent.signUp ||
      AttriaxSkanSemanticEvent.login => AttriaxSkanTemplate.utility,
      AttriaxSkanSemanticEvent.sessionQualified =>
        AttriaxSkanTemplate.retentionPurchaseAds,
    };
  }

  _SkanCandidate? _candidateFor({
    required AttriaxSkanTemplate template,
    required AttriaxSkanSemanticEvent event,
    required bool lockWindowEnabled,
  }) {
    final candidate = switch (template) {
      AttriaxSkanTemplate.game => switch (event) {
        AttriaxSkanSemanticEvent.signUp => const _SkanCandidate(8),
        AttriaxSkanSemanticEvent.tutorialComplete => const _SkanCandidate(12),
        AttriaxSkanSemanticEvent.sessionQualified => const _SkanCandidate(18),
        AttriaxSkanSemanticEvent.levelAchieved => const _SkanCandidate(24),
        AttriaxSkanSemanticEvent.adRevenue => const _SkanCandidate(32),
        AttriaxSkanSemanticEvent.purchase => const _SkanCandidate(48),
        _ => null,
      },
      AttriaxSkanTemplate.ecommerce => switch (event) {
        AttriaxSkanSemanticEvent.signUp => const _SkanCandidate(8),
        AttriaxSkanSemanticEvent.sessionQualified => const _SkanCandidate(14),
        AttriaxSkanSemanticEvent.addToCart => const _SkanCandidate(18),
        AttriaxSkanSemanticEvent.checkoutStarted => const _SkanCandidate(28),
        AttriaxSkanSemanticEvent.purchase => const _SkanCandidate(52),
        _ => null,
      },
      AttriaxSkanTemplate.subscription => switch (event) {
        AttriaxSkanSemanticEvent.signUp => const _SkanCandidate(8),
        AttriaxSkanSemanticEvent.trialStarted => const _SkanCandidate(24),
        AttriaxSkanSemanticEvent.purchase => const _SkanCandidate(44),
        AttriaxSkanSemanticEvent.subscriptionStarted => const _SkanCandidate(
          48,
        ),
        AttriaxSkanSemanticEvent.subscriptionRenewed => const _SkanCandidate(
          56,
        ),
        _ => null,
      },
      AttriaxSkanTemplate.adMonetization => switch (event) {
        AttriaxSkanSemanticEvent.signUp => const _SkanCandidate(6),
        AttriaxSkanSemanticEvent.adImpression => const _SkanCandidate(12),
        AttriaxSkanSemanticEvent.sessionQualified => const _SkanCandidate(18),
        AttriaxSkanSemanticEvent.adRevenue => const _SkanCandidate(28),
        AttriaxSkanSemanticEvent.purchase => const _SkanCandidate(40),
        _ => null,
      },
      AttriaxSkanTemplate.utility => switch (event) {
        AttriaxSkanSemanticEvent.signUp => const _SkanCandidate(10),
        AttriaxSkanSemanticEvent.login => const _SkanCandidate(14),
        AttriaxSkanSemanticEvent.sessionQualified => const _SkanCandidate(24),
        AttriaxSkanSemanticEvent.purchase => const _SkanCandidate(40),
        _ => null,
      },
      AttriaxSkanTemplate.retentionPurchaseAds => switch (event) {
        AttriaxSkanSemanticEvent.signUp => const _SkanCandidate(8),
        AttriaxSkanSemanticEvent.sessionQualified => const _SkanCandidate(18),
        AttriaxSkanSemanticEvent.adImpression => const _SkanCandidate(22),
        AttriaxSkanSemanticEvent.checkoutStarted => const _SkanCandidate(26),
        AttriaxSkanSemanticEvent.adRevenue => const _SkanCandidate(30),
        AttriaxSkanSemanticEvent.purchase => const _SkanCandidate(48),
        _ => null,
      },
      AttriaxSkanTemplate.auto => null,
    };

    if (candidate == null) {
      return null;
    }

    return _SkanCandidate(
      candidate.fineValue,
      coarseValue: candidate.coarseValue,
      lockWindow:
          lockWindowEnabled &&
          (candidate.lockWindow || candidate.fineValue >= 56),
    );
  }

  AttriaxSkanCoarseValue _deriveCoarseValue(int fineValue) {
    if (fineValue >= 40) {
      return AttriaxSkanCoarseValue.high;
    }
    if (fineValue >= 20) {
      return AttriaxSkanCoarseValue.medium;
    }

    return AttriaxSkanCoarseValue.low;
  }

  AttriaxSkanCoarseValue? _maxCoarseValue(
    AttriaxSkanCoarseValue? current,
    AttriaxSkanCoarseValue? next,
  ) {
    if (current == null) {
      return next;
    }
    if (next == null) {
      return current;
    }

    return current.index >= next.index ? current : next;
  }

  bool _statesEqual(AttriaxSkanState left, AttriaxSkanState right) {
    return left.enabled == right.enabled &&
        left.mode == right.mode &&
        left.configuredTemplate == right.configuredTemplate &&
        left.resolvedTemplate == right.resolvedTemplate &&
        left.fineValue == right.fineValue &&
        left.coarseValue == right.coarseValue &&
        left.lockWindow == right.lockWindow &&
        left.firstLaunchValueRegistered == right.firstLaunchValueRegistered;
  }

  Future<void> _persistState() async {
    await _preferencesStore.setSkanState(state: _state);
    _logger.verbose('Updated local SKAN state: ${_state?.toJson()}');
  }
}

class _SkanCandidate {
  const _SkanCandidate(
    this.fineValue, {
    this.coarseValue,
    this.lockWindow = false,
  });

  final int fineValue;
  final AttriaxSkanCoarseValue? coarseValue;
  final bool lockWindow;
}
