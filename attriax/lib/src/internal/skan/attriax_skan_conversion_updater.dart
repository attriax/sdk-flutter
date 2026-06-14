import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_skan_rules.dart';

class AttriaxSkanConversionUpdater {
  const AttriaxSkanConversionUpdater({
    required AttriaxPlatform platform,
    required AttriaxPlatformType platformType,
    required AttriaxClock clock,
  }) : _platform = platform,
       _platformType = platformType,
       _clock = clock;

  final AttriaxPlatform _platform;
  final AttriaxPlatformType _platformType;
  final AttriaxClock _clock;

  bool get _supportsSkan => attriaxPlatformSupportsSkan(_platformType);

  Future<AttriaxSkanConversionUpdate> update({
    required AttriaxSkanState? currentState,
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
    bool markFirstLaunchValueRegistered = false,
  }) async {
    if (!_supportsSkan) {
      return const AttriaxSkanConversionUpdate(
        result: AttriaxSkanUpdateResult(
          status: AttriaxSkanUpdateStatus.notSupported,
          message: 'SKAdNetwork updates are only supported on iOS.',
        ),
      );
    }

    final state = currentState ?? const AttriaxSkanState(enabled: false);
    if (!state.enabled) {
      return AttriaxSkanConversionUpdate(
        result: AttriaxSkanUpdateResult(
          status: AttriaxSkanUpdateStatus.disabled,
          message: 'SKAdNetwork is disabled for this SDK instance.',
          state: state,
        ),
      );
    }

    if (fineValue < 0 || fineValue > 63) {
      return AttriaxSkanConversionUpdate(
        result: AttriaxSkanUpdateResult(
          status: AttriaxSkanUpdateStatus.invalidValue,
          message: 'fineValue must be between 0 and 63.',
          state: state,
        ),
      );
    }

    final nextFineValue = state.fineValue == null
        ? fineValue
        : (fineValue > state.fineValue! ? fineValue : state.fineValue!);
    final nextCoarseValue = maxSkanCoarseValue(
      state.coarseValue,
      coarseValue ?? deriveSkanCoarseValue(nextFineValue),
    );
    final nextLockWindow = state.lockWindow || lockWindow;
    // The first-launch latch is a caller intent ("this update registers the
    // install value"), not something to infer from the resolved fine value. A
    // regular event that happens to resolve to fineValue 0 must not flip it.
    final nextFirstLaunchRegistered =
        state.firstLaunchValueRegistered || markFirstLaunchValueRegistered;
    final nextState = state.copyWith(
      fineValue: nextFineValue,
      coarseValue: nextCoarseValue,
      lockWindow: nextLockWindow,
      firstLaunchValueRegistered: nextFirstLaunchRegistered,
      lastUpdatedAt: _clock.now().toUtc(),
    );

    if (state.fineValue == nextState.fineValue &&
        state.coarseValue == nextState.coarseValue &&
        state.lockWindow == nextState.lockWindow) {
      // The conversion value does not advance, so no native bridge call is
      // needed. Still persist a first-launch latch transition so the install
      // registration is not re-attempted on every launch.
      final shouldPersistLatch =
          nextFirstLaunchRegistered != state.firstLaunchValueRegistered;
      return AttriaxSkanConversionUpdate(
        nextState: shouldPersistLatch ? nextState : null,
        result: AttriaxSkanUpdateResult(
          status: AttriaxSkanUpdateStatus.alreadyAtOrAboveValue,
          message:
              'The requested conversion value does not advance the stored SKAN state.',
          fineValue: state.fineValue,
          coarseValue: state.coarseValue,
          lockWindow: state.lockWindow,
          state: shouldPersistLatch ? nextState : state,
        ),
      );
    }

    final bridgeResult = await _platform.updateSkanConversionValue(
      fineValue: nextFineValue,
      coarseValue: nextCoarseValue,
      lockWindow: nextLockWindow,
    );

    if (bridgeResult.status == AttriaxSkanUpdateStatus.updated ||
        bridgeResult.status == AttriaxSkanUpdateStatus.skipped) {
      return AttriaxSkanConversionUpdate(
        nextState: nextState,
        result: AttriaxSkanUpdateResult(
          status: bridgeResult.status,
          message: bridgeResult.message,
          fineValue: nextState.fineValue,
          coarseValue: nextState.coarseValue,
          lockWindow: nextState.lockWindow,
          state: nextState,
        ),
      );
    }

    return AttriaxSkanConversionUpdate(
      result: AttriaxSkanUpdateResult(
        status: bridgeResult.status,
        message: bridgeResult.message,
        fineValue: bridgeResult.fineValue,
        coarseValue: bridgeResult.coarseValue,
        lockWindow: bridgeResult.lockWindow,
        state: state,
      ),
    );
  }
}

class AttriaxSkanConversionUpdate {
  const AttriaxSkanConversionUpdate({required this.result, this.nextState});

  final AttriaxSkanUpdateResult result;
  final AttriaxSkanState? nextState;
}
