import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../attriax_platform_types.dart';

import 'method_channel_attriax.dart';

/// The interface that implementations of attriax must implement.
///
/// Phase 1 of the native-engine re-wrap (see `NATIVE_ENGINE_REWRAP.md`) expands
/// this from the historical signal-collection surface into the FULL engine
/// command + event surface, mirroring the KMP public core (`com.attriax.sdk`)
/// 1:1. Native bindings (Android AAR / iOS XCFramework / desktop FFI) implement
/// these by delegating to their native engine; the web plugin bridges to
/// `@attriax/js`.
///
/// This interface is an INTENTIONAL SUPERSET of what the public `Attriax` facade
/// currently invokes. It is deliberately broader for two reasons, and members
/// the facade never calls today should NOT be pruned on that basis alone:
///
///  1. Native signal-collection seams. The legacy signal methods
///     (`collectNativeContext`, `collectInstallReferrer`,
///     `readAttributionClipboard`, `collectWebViewUserAgent`,
///     `consumePendingCrashReport`, `setAutomaticCrashReportingEnabled`,
///     `openBrowserUrl`) are consumed by the native engine's own context /
///     attribution / crash collection rather than by a facade call. They keep
///     benign defaults so a binding can omit them safely.
///  2. Cache-seeding + forward reads. The deep-link snapshot getters
///     (`getInitialDeepLink`, `getRawInitialDeepLink`, `getLatestDeepLink`,
///     `getIsInitialDeepLinkResolved`) let a native runtime seed its
///     synchronous caches on init; most launch state also arrives via the
///     `attriax/events/*` streams, so a binding may serve these from the stream
///     instead and leave the getter unimplemented.
///
/// Because the facade does not exercise every member, this surface is verified
/// against the KMP core / iOS + Android bindings, not against facade call sites —
/// keep that in mind before assuming an "unused" method is dead.
///
/// Default implementations follow the established pattern: required engine
/// commands + getters throw [UnimplementedError]; event streams default to
/// `const Stream.empty()`; the retained optional signal methods keep their
/// benign defaults.
abstract class AttriaxPlatform extends PlatformInterface {
  AttriaxPlatform() : super(token: _token);

  static final Object _token = Object();

  static AttriaxPlatform _instance = MethodChannelAttriax();

  static AttriaxPlatform get instance => _instance;

  static set instance(AttriaxPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle (mirrors KMP `Attriax.init` / `reset` / `dispose` / `flush`).
  // ---------------------------------------------------------------------------

  /// Bootstrap the native engine with [config] (mirrors KMP `Attriax.init`
  /// plus construction from `AttriaxConfig`).
  Future<void> initialize(AttriaxConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Best-effort queue flush (mirrors KMP `Attriax.flush`).
  Future<void> flush() {
    throw UnimplementedError('flush() has not been implemented.');
  }

  /// Clear SDK state to pre-init (mirrors KMP `Attriax.reset`).
  Future<void> reset() {
    throw UnimplementedError('reset() has not been implemented.');
  }

  /// Release listeners and dispose runtime resources (mirrors KMP
  /// `Attriax.dispose`).
  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Tracking — events / page views (mirrors KMP `AttriaxTracking`).
  // ---------------------------------------------------------------------------

  /// Record a custom event (mirrors KMP `AttriaxTracking.recordEvent`).
  Future<void> recordEvent(
    String name, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) {
    throw UnimplementedError('recordEvent() has not been implemented.');
  }

  /// Record a page/screen view (mirrors KMP `AttriaxTracking.recordPageView`).
  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) {
    throw UnimplementedError('recordPageView() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Tracking — revenue / ad events (mirrors KMP `AttriaxTracking`). The native
  // engine performs the reserved-key lowering + currency normalization.
  // ---------------------------------------------------------------------------

  /// Record a completed purchase (mirrors KMP `AttriaxTracking.recordPurchase`).
  Future<void> recordPurchase({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    String? validationProvider,
    String? validationEnvironment,
    String? purchaseToken,
    String? receiptData,
    String? signedPayload,
    String? receiptSignature,
    bool? isRenewal,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? validationId,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) {
    throw UnimplementedError('recordPurchase() has not been implemented.');
  }

  /// Record a refund (mirrors KMP `AttriaxTracking.recordRefund`).
  Future<void> recordRefund({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? reason,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) {
    throw UnimplementedError('recordRefund() has not been implemented.');
  }

  /// Record realized ad revenue (mirrors KMP `AttriaxTracking.recordAdRevenue`).
  Future<void> recordAdRevenue({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? adNetwork,
    String? adFormat,
    String? adType,
    String? adPlacement,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) {
    throw UnimplementedError('recordAdRevenue() has not been implemented.');
  }

  /// Record an ad-lifecycle event under its reserved [eventName] (mirrors KMP
  /// `AttriaxTracking.recordAdEvent`, whose `AttriaxAdEventType` lowers to the
  /// reserved event name).
  Future<void> recordAdEvent({
    required String eventName,
    String? adNetwork,
    String? mediationNetwork,
    String? adUnitId,
    String? adPlacement,
    String? adFormat,
    String? adType,
    String? failureReason,
    num? loadLatencyMs,
    String? rewardType,
    num? rewardAmount,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) {
    throw UnimplementedError('recordAdEvent() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Tracking — notifications / errors (mirrors KMP `AttriaxTracking`).
  // ---------------------------------------------------------------------------

  /// Record a push-notification lifecycle event (mirrors KMP
  /// `AttriaxTracking.recordNotification`). [type] and [source] are the wire
  /// slugs the facade resolves from its `AttriaxNotificationEventType` /
  /// `AttriaxNotificationEventSource` enums.
  Future<void> recordNotification({
    required String type,
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    String? source,
    Map<String, Object?>? payload,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) {
    throw UnimplementedError('recordNotification() has not been implemented.');
  }

  /// Record an error/crash (mirrors KMP `AttriaxTracking.recordError`). The
  /// Dart `error`/`StackTrace` pair is lowered by the facade to the primitive
  /// [message]/[exceptionType]/[stackTrace] wire fields.
  Future<void> recordError({
    required String message,
    required String exceptionType,
    String? stackTrace,
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  }) {
    throw UnimplementedError('recordError() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Tracking — identify / user properties (mirrors KMP `AttriaxTracking`).
  // ---------------------------------------------------------------------------

  /// Associate the current device with a user; a `null` [userId] clears it
  /// (mirrors KMP `AttriaxTracking.setUser`).
  Future<void> setUser({String? userId, String? userName}) {
    throw UnimplementedError('setUser() has not been implemented.');
  }

  /// Set a single user property; a `null` [value] clears it (mirrors KMP
  /// `AttriaxTracking.setUserProperty`).
  Future<void> setUserProperty(String name, Object? value) {
    throw UnimplementedError('setUserProperty() has not been implemented.');
  }

  /// Merge user properties (mirrors KMP `AttriaxTracking.setUserProperties`).
  Future<void> setUserProperties(Map<String, Object?> properties) {
    throw UnimplementedError('setUserProperties() has not been implemented.');
  }

  /// Clear user properties; `null`/empty [propertyNames] clears all (mirrors KMP
  /// `AttriaxTracking.clearUserProperties`).
  Future<void> clearUserProperties({List<String>? propertyNames}) {
    throw UnimplementedError('clearUserProperties() has not been implemented.');
  }

  /// Register (or, with a `null` [token], de-register) a push/uninstall token
  /// for [provider] (mirrors KMP `registerFirebaseMessagingToken` /
  /// `registerApplePushToken`).
  Future<void> registerPushToken({
    required AttriaxPushTokenProvider provider,
    String? token,
    Map<String, Object?>? metadata,
  }) {
    throw UnimplementedError('registerPushToken() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Deep links (mirrors KMP `AttriaxDeepLinks`).
  // ---------------------------------------------------------------------------

  /// Feed a raw deep-link URI to the engine (mirrors KMP
  /// `AttriaxDeepLinks.handleUri`).
  Future<void> handleIncomingLink(String uri, {bool isInitialLink = false}) {
    throw UnimplementedError('handleIncomingLink() has not been implemented.');
  }

  /// Mark the initial-link probe complete when the launch carried no deep link
  /// (mirrors KMP `AttriaxDeepLinks.completeInitialLinkIfAbsent`).
  Future<void> completeInitialDeepLink() {
    throw UnimplementedError(
      'completeInitialDeepLink() has not been implemented.',
    );
  }

  /// Record a deep link manually and return its resolved event (mirrors KMP
  /// `AttriaxDeepLinks.recordDeepLink`).
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) {
    throw UnimplementedError('recordDeepLink() has not been implemented.');
  }

  /// Block until the initial-link probe settles (mirrors KMP
  /// `AttriaxDeepLinks.waitForInitialDeepLink`).
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() {
    throw UnimplementedError(
      'waitForInitialDeepLink() has not been implemented.',
    );
  }

  /// Block until the resolution for [rawEvent] completes (mirrors KMP
  /// `AttriaxDeepLinks.waitResolution`).
  Future<AttriaxDeepLinkEvent?> waitForDeepLinkResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) {
    throw UnimplementedError(
      'waitForDeepLinkResolution() has not been implemented.',
    );
  }

  /// Create a short dynamic link (mirrors KMP
  /// `AttriaxDeepLinks.createDynamicLink`).
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    Map<String, Object?>? data,
  }) {
    throw UnimplementedError('createDynamicLink() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Revenue receipt validation (mirrors KMP `Attriax.validateReceipt`).
  // ---------------------------------------------------------------------------

  /// Validate a purchase receipt directly (mirrors KMP
  /// `Attriax.validateReceipt`).
  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    required String receipt,
    bool test = false,
    String? provider,
    String? environment,
    String? productId,
    String? transactionId,
  }) {
    throw UnimplementedError('validateReceipt() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Consent — GDPR (mirrors KMP `AttriaxGdprConsent`).
  // ---------------------------------------------------------------------------

  /// Store granted GDPR consent category values (mirrors KMP
  /// `AttriaxGdprConsent.setConsent`).
  Future<void> setGdprConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) {
    throw UnimplementedError('setGdprConsent() has not been implemented.');
  }

  /// Mark GDPR consent as not required (mirrors KMP
  /// `AttriaxGdprConsent.setNotRequired`).
  Future<void> setGdprConsentNotRequired() {
    throw UnimplementedError(
      'setGdprConsentNotRequired() has not been implemented.',
    );
  }

  /// Clear the local GDPR decision (mirrors KMP `AttriaxGdprConsent.reset`).
  Future<void> resetGdprConsent() {
    throw UnimplementedError('resetGdprConsent() has not been implemented.');
  }

  /// Request GDPR data erasure (mirrors KMP
  /// `AttriaxGdprConsent.requestDataErasure`).
  Future<void> requestGdprDataErasure() {
    throw UnimplementedError(
      'requestGdprDataErasure() has not been implemented.',
    );
  }

  /// Resolve whether this device needs a GDPR consent decision (mirrors KMP
  /// `AttriaxGdprConsent.needsConsent`).
  Future<bool> needsGdprConsent({bool localOnly = false}) {
    throw UnimplementedError('needsGdprConsent() has not been implemented.');
  }

  // NOTE (Phase 1): the GDPR consent *reader* getters (state / values) are
  // deferred to the facade-rewire phase — the facade already owns those return
  // types, and duplicating them in the shared type surface would ambiguate its
  // imports. `getIsWaitingForGdprConsent` (a bool) and `needsGdprConsent`
  // remain, as they carry no facade-owned type.

  /// Whether the SDK is waiting for a GDPR decision (mirrors KMP
  /// `AttriaxGdprConsent.isWaitingForConsent`).
  Future<bool> getIsWaitingForGdprConsent() {
    throw UnimplementedError(
      'getIsWaitingForGdprConsent() has not been implemented.',
    );
  }

  // ---------------------------------------------------------------------------
  // Toggles (mirrors KMP `Attriax.enabled` / `anonymousTrackingEnabled` and the
  // facade's separate SDK-enabled vs events-enabled flags). A native binding may
  // conflate the two enabled flags onto the single KMP `enabled`.
  // ---------------------------------------------------------------------------

  /// Toggle GDPR-safe anonymous tracking (mirrors KMP
  /// `Attriax.anonymousTrackingEnabled`).
  Future<void> setAnonymousTracking({required bool enabled}) {
    throw UnimplementedError(
      'setAnonymousTracking() has not been implemented.',
    );
  }

  /// Set the CCPA "do not sell / share" election (mirrors KMP
  /// `consent.ccpa`).
  ///
  /// A non-null value is forwarded so the next app-open/identify carries it
  /// TOP-LEVEL as `doNotSell` / `usPrivacy`; an omitted (null) field is left
  /// unchanged. An explicit `doNotSell: false` may clear a prior server latch.
  Future<void> setCcpaConsent({bool? doNotSell, String? usPrivacy}) {
    throw UnimplementedError('setCcpaConsent() has not been implemented.');
  }

  /// Toggle the whole SDK runtime (mirrors KMP `Attriax.enabled`).
  Future<void> setSdkEnabled({required bool enabled}) {
    throw UnimplementedError('setSdkEnabled() has not been implemented.');
  }

  /// Toggle event-style tracking (facade `tracking.enabled`).
  Future<void> setEventTrackingEnabled({required bool enabled}) {
    throw UnimplementedError(
      'setEventTrackingEnabled() has not been implemented.',
    );
  }

  // ---------------------------------------------------------------------------
  // Apple seams (mirrors KMP `Attriax.submitAsaToken`, `AttriaxSkan`, ATT).
  // ---------------------------------------------------------------------------

  /// Submit an Apple Search Ads (AdServices) attribution token (mirrors KMP
  /// `Attriax.submitAsaToken`).
  Future<void> submitAsaToken(String token) {
    throw UnimplementedError('submitAsaToken() has not been implemented.');
  }

  /// Wrapper-supply the natively-obtained ATT status (mirrors KMP
  /// `AttriaxAttConsent.setStatus`).
  Future<void> setTrackingAuthorizationStatus(
    AttriaxTrackingAuthorizationStatus status,
  ) {
    throw UnimplementedError(
      'setTrackingAuthorizationStatus() has not been implemented.',
    );
  }

  // ---------------------------------------------------------------------------
  // Engine reads (mirrors KMP `Attriax` getters + the sub-surface getters).
  // ---------------------------------------------------------------------------

  /// Stable Attriax device identifier (mirrors KMP `Attriax.deviceId`).
  Future<String?> getDeviceId() {
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }

  /// Whether the current run is the first launch (mirrors KMP
  /// `Attriax.isFirstLaunch`).
  Future<bool> getIsFirstLaunch() {
    throw UnimplementedError('getIsFirstLaunch() has not been implemented.');
  }

  /// Whether the engine finished initialization (mirrors KMP
  /// `Attriax.isInitialized`).
  Future<bool> getIsInitialized() {
    throw UnimplementedError('getIsInitialized() has not been implemented.');
  }

  /// SDK version + metadata snapshot (mirrors KMP `Attriax.sdkSnapshot`).
  Future<AttriaxSdkSnapshot?> getSdkSnapshot() {
    throw UnimplementedError('getSdkSnapshot() has not been implemented.');
  }

  /// Whether the whole SDK runtime is enabled (mirrors KMP `Attriax.enabled`).
  Future<bool> getSdkEnabled() {
    throw UnimplementedError('getSdkEnabled() has not been implemented.');
  }

  /// Whether event-style tracking is enabled (facade `tracking.enabled`).
  Future<bool> getEventTrackingEnabled() {
    throw UnimplementedError(
      'getEventTrackingEnabled() has not been implemented.',
    );
  }

  /// Whether GDPR-safe anonymous tracking is allowed (mirrors KMP
  /// `Attriax.anonymousTrackingEnabled`).
  Future<bool> getAnonymousTracking() {
    throw UnimplementedError(
      'getAnonymousTracking() has not been implemented.',
    );
  }

  /// Current synchronization state (mirrors KMP `AttriaxSynchronization.state`).
  Future<AttriaxSynchronizationState> getSynchronizationState() {
    throw UnimplementedError(
      'getSynchronizationState() has not been implemented.',
    );
  }

  /// Whether every queued request has been delivered (mirrors KMP
  /// `AttriaxSynchronization.isSynchronized`).
  Future<bool> getIsSynchronized() {
    throw UnimplementedError('getIsSynchronized() has not been implemented.');
  }

  /// Original install referrer (mirrors KMP
  /// `AttriaxReferrer.getOriginalInstallReferrer`).
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
  }) {
    throw UnimplementedError(
      'getOriginalInstallReferrer() has not been implemented.',
    );
  }

  /// Reinstall referrer (mirrors KMP `AttriaxReferrer.getReinstallReferrer`).
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
  }) {
    throw UnimplementedError(
      'getReinstallReferrer() has not been implemented.',
    );
  }

  /// Raw platform install-referrer string (mirrors KMP
  /// `AttriaxReferrer.getRawInstallReferrer`).
  Future<String?> getRawInstallReferrer({Duration? timeout}) {
    throw UnimplementedError(
      'getRawInstallReferrer() has not been implemented.',
    );
  }

  /// Deep-link referrer that opened the current session (mirrors KMP
  /// `AttriaxReferrer.getSessionReferrer`).
  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
  }) {
    throw UnimplementedError('getSessionReferrer() has not been implemented.');
  }

  /// Most recent deep-link referrer (mirrors KMP
  /// `AttriaxReferrer.getLatestDeepLinkReferrer`).
  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
  }) {
    throw UnimplementedError(
      'getLatestDeepLinkReferrer() has not been implemented.',
    );
  }

  /// Latest locally persisted SKAdNetwork state (mirrors KMP `AttriaxSkan.state`).
  Future<AttriaxSkanState?> getSkanState() {
    throw UnimplementedError('getSkanState() has not been implemented.');
  }

  /// Most recent handled deep-link event (mirrors KMP
  /// `AttriaxDeepLinks.latestDeepLink`).
  Future<AttriaxDeepLinkEvent?> getLatestDeepLink() {
    throw UnimplementedError('getLatestDeepLink() has not been implemented.');
  }

  /// Launch deep-link event, once resolved (mirrors KMP
  /// `AttriaxDeepLinks.initialDeepLink`).
  Future<AttriaxDeepLinkEvent?> getInitialDeepLink() {
    throw UnimplementedError('getInitialDeepLink() has not been implemented.');
  }

  /// Launch raw deep-link event (mirrors KMP
  /// `AttriaxDeepLinks.rawInitialDeepLink`).
  Future<AttriaxRawDeepLinkEvent?> getRawInitialDeepLink() {
    throw UnimplementedError(
      'getRawInitialDeepLink() has not been implemented.',
    );
  }

  /// Whether the initial-link probe has completed (mirrors KMP
  /// `AttriaxDeepLinks.initialDeepLinkResolved`).
  Future<bool> getIsInitialDeepLinkResolved() {
    throw UnimplementedError(
      'getIsInitialDeepLinkResolved() has not been implemented.',
    );
  }

  // ---------------------------------------------------------------------------
  // Event streams (native → Dart). Mirror the KMP listener surfaces; default to
  // an empty stream so unimplemented platforms never emit.
  // ---------------------------------------------------------------------------

  /// Synchronization-state transitions (mirrors KMP
  /// `AttriaxSynchronization.addStateListener`).
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      const Stream<AttriaxSynchronizationState>.empty();

  /// Resolved deep-link events (mirrors KMP `AttriaxDeepLinks.addListener`).
  Stream<AttriaxDeepLinkEvent> get deepLinkEvents =>
      const Stream<AttriaxDeepLinkEvent>.empty();

  /// Raw (pre-resolution) deep-link inputs (mirrors KMP
  /// `AttriaxDeepLinks.addRawListener`).
  Stream<AttriaxRawDeepLinkEvent> get rawDeepLinkEvents =>
      const Stream<AttriaxRawDeepLinkEvent>.empty();

  /// Initial-link probe resolutions (mirrors KMP
  /// `AttriaxDeepLinks.waitForInitialDeepLink` completion).
  Stream<AttriaxInitialDeepLinkResolution> get initialDeepLinkResolutions =>
      const Stream<AttriaxInitialDeepLinkResolution>.empty();

  // ---------------------------------------------------------------------------
  // Retained legacy signal surface. Intentional superset (see the class doc):
  // these back native context / attribution / crash collection, NOT facade
  // calls, so they keep benign defaults and are not dead code.
  // ---------------------------------------------------------------------------

  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) {
    throw UnimplementedError(
      'collectNativeContext() has not been implemented.',
    );
  }

  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async =>
      const AttriaxInstallReferrerContext();

  Future<String?> readAttributionClipboard() async => null;

  Future<String?> collectWebViewUserAgent() async => null;

  Future<void> setAutomaticCrashReportingEnabled({
    required bool enabled,
  }) async {}

  Future<AttriaxTrackingAuthorizationStatus>
  getTrackingAuthorizationStatus() async =>
      AttriaxTrackingAuthorizationStatus.notSupported;

  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) async => AttriaxTrackingAuthorizationStatus.notSupported;

  Future<AttriaxPendingCrashReport?> consumePendingCrashReport() async => null;

  Future<bool> openBrowserUrl({
    required Uri uri,
    required AttriaxResolvedUrlOpenMode openMode,
  }) async => false;

  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async => const AttriaxSkanUpdateResult(
    status: AttriaxSkanUpdateStatus.notSupported,
    message:
        'SKAdNetwork conversion updates are not supported on this platform.',
  );
}
