part of 'attriax.dart';

/// SKAdNetwork helpers exposed by [Attriax].
class AttriaxSkan {
  AttriaxSkan._(this._runtime);

  final AttriaxRuntime _runtime;

  /// Latest locally persisted SKAdNetwork state tracked by the SDK.
  AttriaxSkanState? get state => _runtime.skanState;

  /// Updates the current SKAdNetwork conversion value on supported iOS versions.
  Future<AttriaxSkanUpdateResult> updateConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) => _runtime.updateSkanConversionValue(
    fineValue: fineValue,
    coarseValue: coarseValue,
    lockWindow: lockWindow,
  );
}
