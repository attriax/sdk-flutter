export 'src/attriax_platform_interface.dart';
export 'src/method_channel_attriax.dart';
// The expanded interface references the full shared model surface in its command
// and event signatures. Consumers that need those richer types import
// `attriax_platform_types.dart` (or `attriax_runtime_types.dart`) directly; this
// umbrella keeps re-exporting only the historical signal-surface subset so the
// app facade's existing imports do not become redundant.
export 'attriax_platform_types.dart'
    show
        AttriaxInstallReferrerContext,
        AttriaxNativeContext,
        AttriaxPendingCrashReport,
        AttriaxResolvedUrlOpenMode,
        AttriaxSkanCoarseValue,
        AttriaxSkanUpdateResult,
        AttriaxSkanUpdateStatus,
        AttriaxTrackingAuthorizationStatus;
