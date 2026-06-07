part of 'attriax.dart';

/// SKAdNetwork helpers exposed by [Attriax].
class AttriaxSkan {
  AttriaxSkan._(this._runtime);

  final AttriaxRuntime _runtime;

  /// Latest locally persisted SKAdNetwork state tracked by the SDK.
  AttriaxSkanState? get state => _runtime.skanState;

  /// Manually updates the current SKAdNetwork conversion value.
  ///
  /// Use this when your app wants to resolve SKAN conversion values itself
  /// instead of relying on Attriax dashboard-managed SKAN rules.
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
