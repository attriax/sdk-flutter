part of 'attriax.dart';

/// Referrer lookups exposed by [Attriax].
///
/// These methods cover startup attribution snapshots and runtime deep-link
/// referrers. All lookups resolve to `null` immediately until [Attriax.init]
/// completes and while the SDK is disabled.
class AttriaxReferrer {
  AttriaxReferrer._(this._runtime);

  final AttriaxRuntime _runtime;

  /// Original install referrer persisted for this installation.
  ///
  /// This resolves from local storage on later launches, or after the first
  /// successful app-open request on a fresh install or reinstall.
  /// If tracking is disabled, or GDPR attribution consent is required but not
  /// granted, Attriax cannot request or persist this attribution result.
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getOriginalInstallReferrer(timeout: timeout, safe: safe);

  /// Reinstall referrer persisted for the current installation, when one exists.
  ///
  /// This resolves after the first successful app-open request that classifies
  /// the launch as a reinstall, or from cached storage on later launches.
  /// If tracking is disabled, or GDPR attribution consent is required but not
  /// granted, Attriax cannot request or persist this attribution result.
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getReinstallReferrer(timeout: timeout, safe: safe);

  /// Raw Android Play Install Referrer string, when the platform exposes one.
  ///
  /// This does not re-enable attribution when attribution consent is denied.
  Future<String?> getRawInstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getRawInstallReferrer(timeout: timeout, safe: safe);

  /// Deep-link referrer that opened the current session.
  ///
  /// This waits for the startup deep-link flow to settle. It resolves to a
  /// cold-start or deferred deep-link referrer, or `null` when the current
  /// session started without one.
  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getSessionReferrer(timeout: timeout, safe: safe);

  /// Most recent deep-link referrer observed in the current session.
  ///
  /// Returns `null` immediately when no deep link has been handled yet.
  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getLatestDeepLinkReferrer(timeout: timeout, safe: safe);
}
