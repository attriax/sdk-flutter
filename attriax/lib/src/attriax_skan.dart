part of 'attriax.dart';

/// SKAdNetwork helpers exposed by [Attriax].
///
/// AdAttributionKit note (Epic 8.5): AdAttributionKit (AAK) postbacks flow
/// Apple → server (OS-driven, like SKAdNetwork), so the re-engagement /
/// conversion postback path needs NO new Dart transport in the SDK. AAK
/// re-engagement registration (`AppImpression` / `reengagementURL` handling) is
/// a future `TODO(live)` native seam only; nothing on the Dart side sends AAK
/// postbacks.
class AttriaxSkan {
  AttriaxSkan._(this._runtime);

  final AttriaxRuntimeInterface _runtime;

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
