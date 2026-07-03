export 'src/types.dart'
    show
        attriaxSdkApiVersion,
        attriaxSdkPackageVersion,
        AttributionType,
        AttriaxClock,
        AttriaxSystemClock,
        AttriaxMutableClock,
        AttriaxPlatformType,
        AttriaxDeepLinkTrigger,
        AttriaxResolvedUrlOpenMode,
        AttriaxSynchronizationState,
        AttriaxTrackingAuthorizationStatus,
        AttriaxRevenueReceiptValidationStatus,
        AttriaxSkanCoarseValue,
        AttriaxSkanRuleOperator,
        AttriaxSkanUpdateStatus,
        AttriaxSkanConfig,
        AttriaxSkanCondition,
        AttriaxSkanEvent,
        AttriaxSkanWindow1Group,
        AttriaxSkanCoarseWindowEvent,
        AttriaxSkanWindow1,
        AttriaxSkanCoarseWindow,
        AttriaxSkanSchema,
        AttriaxSkanRuntimeConfiguration,
        AttriaxSkanState,
        AttriaxSkanUpdateResult,
        AttriaxNativeContext,
        AttriaxInstallReferrerContext,
        AttriaxPendingCrashReport,
        AttriaxSdkSnapshot,
        AttriaxDeepLink,
        AttriaxInstallReferrerDetails,
        AttriaxDynamicLinkRecord,
        AttriaxDynamicLinkSocialPreview,
        AttriaxDynamicLinkRedirects,
        AttriaxDynamicLinkUtms,
        AttriaxCreateDynamicLinkResult,
        AttriaxRevenueReceiptValidationResult,
        AttriaxRawDeepLinkEvent,
        AttriaxDeepLinkReferrerDetails,
        AttriaxDeepLinkEvent,
        AttriaxAppOpen,
        AttriaxInitResult,
        AttriaxSessionSnapshot,
        AttriaxAttestationEnvelope,
        AttriaxAttestationProvider,
        AttriaxNoopAttestationProvider,
        AttriaxAttestationProviderSlug,
        attriaxAttestationProviderSlugForPlatform,
        AttriaxConfig;

// The channel-backed provider lives in its own library so the pure-model type
// surface above stays free of a `flutter/services` dependency. Integrations and
// the runtime import it explicitly when opting into platform attestation.
export 'src/attriax_platform_attestation.dart'
    show
        AttriaxPlatformAttestationProvider,
        attriaxAttestationMethodChannelName,
        attriaxAcquireAttestationTokenMethod;

// The Apple Search Ads (AdServices) token provider lives in its own library so
// the pure-model type surface above stays free of a `flutter/services`
// dependency, mirroring the attestation channel provider above. The runtime
// imports it explicitly to acquire the ASA token at startup (Epic 8.5).
export 'src/attriax_platform_asa.dart'
    show
        AttriaxAdServicesTokenProvider,
        attriaxAsaMethodChannelName,
        attriaxAcquireAdServicesTokenMethod;
