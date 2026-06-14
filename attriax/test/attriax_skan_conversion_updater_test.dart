import 'package:attriax_flutter/src/internal/skan/attriax_skan_conversion_updater.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxSkanConversionUpdater', () {
    late _FakeSkanPlatform platform;
    late AttriaxSkanConversionUpdater updater;

    setUp(() {
      platform = _FakeSkanPlatform();
      updater = AttriaxSkanConversionUpdater(
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: _FixedClock(DateTime.utc(2026, 5, 15, 13)),
      );
    });

    test(
      'rejects unsupported platforms before calling native bridge',
      () async {
        final androidUpdater = AttriaxSkanConversionUpdater(
          platform: platform,
          platformType: AttriaxPlatformType.android,
          clock: _FixedClock(DateTime.utc(2026, 5, 15, 13)),
        );

        final update = await androidUpdater.update(
          currentState: const AttriaxSkanState(enabled: true),
          fineValue: 1,
        );

        expect(update.result.status, AttriaxSkanUpdateStatus.notSupported);
        expect(update.result.state, isNull);
        expect(update.nextState, isNull);
        expect(platform.calls, isEmpty);
      },
    );

    test('rejects disabled state and invalid fine values', () async {
      final disabled = await updater.update(
        currentState: const AttriaxSkanState(enabled: false),
        fineValue: 1,
      );
      final invalid = await updater.update(
        currentState: const AttriaxSkanState(enabled: true),
        fineValue: 64,
      );

      expect(disabled.result.status, AttriaxSkanUpdateStatus.disabled);
      expect(invalid.result.status, AttriaxSkanUpdateStatus.invalidValue);
      expect(platform.calls, isEmpty);
    });

    test('preserves monotonic fine value and max coarse value', () async {
      final update = await updater.update(
        currentState: const AttriaxSkanState(
          enabled: true,
          fineValue: 12,
          coarseValue: AttriaxSkanCoarseValue.medium,
        ),
        fineValue: 4,
        coarseValue: AttriaxSkanCoarseValue.high,
      );

      expect(update.result.status, AttriaxSkanUpdateStatus.updated);
      expect(platform.calls.single.fineValue, 12);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.high);
      expect(update.nextState?.fineValue, 12);
      expect(update.nextState?.coarseValue, AttriaxSkanCoarseValue.high);
    });

    test('preserves lock-window and first-launch registration flags', () async {
      final update = await updater.update(
        currentState: const AttriaxSkanState(
          enabled: true,
          fineValue: 0,
          lockWindow: true,
          firstLaunchValueRegistered: true,
        ),
        fineValue: 1,
      );

      expect(update.result.status, AttriaxSkanUpdateStatus.updated);
      expect(platform.calls.single.lockWindow, isTrue);
      expect(update.nextState?.lockWindow, isTrue);
      expect(update.nextState?.firstLaunchValueRegistered, isTrue);
    });

    test('reports no-op when stored values already cover request', () async {
      final update = await updater.update(
        currentState: const AttriaxSkanState(
          enabled: true,
          fineValue: 10,
          coarseValue: AttriaxSkanCoarseValue.medium,
        ),
        fineValue: 8,
        coarseValue: AttriaxSkanCoarseValue.low,
      );

      expect(
        update.result.status,
        AttriaxSkanUpdateStatus.alreadyAtOrAboveValue,
      );
      expect(update.nextState, isNull);
      expect(platform.calls, isEmpty);
    });

    test(
      'does not latch first-launch registration from a resolved fineValue of 0',
      () async {
        // A regular update resolving to fineValue 0 must NOT mark the install
        // as registered; only an explicit first-launch registration does.
        final update = await updater.update(
          currentState: const AttriaxSkanState(enabled: true),
          fineValue: 0,
        );

        expect(update.nextState?.fineValue, 0);
        expect(update.nextState?.firstLaunchValueRegistered, isFalse);
      },
    );

    test(
      'persists the first-launch latch even when the value does not advance',
      () async {
        // fineValue is already 0 but the install was never marked registered;
        // an explicit first-launch registration must persist the latch without
        // a redundant native bridge call.
        final update = await updater.update(
          currentState: const AttriaxSkanState(
            enabled: true,
            fineValue: 0,
            coarseValue: AttriaxSkanCoarseValue.low,
          ),
          fineValue: 0,
          markFirstLaunchValueRegistered: true,
        );

        expect(
          update.result.status,
          AttriaxSkanUpdateStatus.alreadyAtOrAboveValue,
        );
        expect(platform.calls, isEmpty);
        expect(update.nextState, isNotNull);
        expect(update.nextState?.firstLaunchValueRegistered, isTrue);
      },
    );

    test('keeps current state when native bridge fails', () async {
      platform.nextResult = const AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.error,
        message: 'bridge failed',
      );
      const currentState = AttriaxSkanState(enabled: true, fineValue: 1);

      final update = await updater.update(
        currentState: currentState,
        fineValue: 2,
      );

      expect(update.result.status, AttriaxSkanUpdateStatus.error);
      expect(update.result.state, same(currentState));
      expect(update.nextState, isNull);
    });

    test('returns next state for native skipped responses', () async {
      platform.nextResult = const AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.skipped,
        message: 'simulator',
      );

      final update = await updater.update(
        currentState: const AttriaxSkanState(enabled: true),
        fineValue: 3,
      );

      expect(update.result.status, AttriaxSkanUpdateStatus.skipped);
      expect(update.nextState?.fineValue, 3);
      expect(update.result.state, same(update.nextState));
    });
  });
}

class _FakeSkanPlatform extends AttriaxPlatform {
  final List<_SkanCall> calls = <_SkanCall>[];
  AttriaxSkanUpdateResult? nextResult;

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  @override
  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    calls.add(
      _SkanCall(
        fineValue: fineValue,
        coarseValue: coarseValue,
        lockWindow: lockWindow,
      ),
    );

    return nextResult ??
        AttriaxSkanUpdateResult(
          status: AttriaxSkanUpdateStatus.updated,
          fineValue: fineValue,
          coarseValue: coarseValue,
          lockWindow: lockWindow,
        );
  }
}

class _SkanCall {
  const _SkanCall({
    required this.fineValue,
    required this.lockWindow,
    this.coarseValue,
  });

  final int fineValue;
  final AttriaxSkanCoarseValue? coarseValue;
  final bool lockWindow;
}

class _FixedClock implements AttriaxClock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
