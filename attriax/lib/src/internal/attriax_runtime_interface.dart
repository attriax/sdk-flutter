import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

import '../attriax_consent.dart';
import '../attriax_notification_event.dart';

/// The engine surface the public `Attriax` facade and its sub-facades depend on.
///
/// Historically the facade held a concrete `AttriaxRuntime` — a full Dart
/// *engine* (HTTP/queue/consent/deep-links/sync). The native-engine re-wrap
/// (`NATIVE_ENGINE_REWRAP.md`) inverts that: on platforms with a native engine
/// (iOS/macOS via the KMP XCFramework), the facade forwards to that engine
/// through `attriax_flutter_platform_interface` instead. Both the Dart engine
/// and the native-backed runtime implement this interface so the facade can be
/// handed whichever one fits the current platform, with the public Dart API
/// unchanged.
///
/// The synchronous getters (`deviceId`, `isInitialized`, `synchronizationState`,
/// the deep-link snapshots, …) are the delicate part: a native engine resolves
/// asynchronously, so a native implementation must cache these locally — seeded
/// during [init] and kept fresh from the engine's event streams.
abstract class AttriaxRuntimeInterface {
  // --- lifecycle ---
  Future<void> init();
  Future<void> reset();
  Future<void> dispose();

  // --- synchronous state getters (native impls cache these) ---
  bool get isInitialized;
  bool get isEnabled;
  bool get areEventsEnabled;
  bool get anonymousTrackingEnabled;
  bool get isFirstLaunch;
  String? get deviceId;
  AttriaxSdkSnapshot? get sdkSnapshot;
  AttriaxGdprConsentState get gdprConsentState;
  AttriaxGdprConsentValues? get gdprConsentValues;
  bool get isWaitingForGdprConsent;
  bool get isSynchronized;
  AttriaxSynchronizationState get synchronizationState;
  AttriaxSkanState? get skanState;
  AttriaxDeepLinkEvent? get initialDeepLink;
  AttriaxRawDeepLinkEvent? get rawInitialDeepLink;
  bool get isInitialDeepLinkResolved;
  AttriaxDeepLinkEvent? get latestDeepLink;

  // --- event streams ---
  Stream<AttriaxSynchronizationState> get synchronizationStates;
  Stream<AttriaxDeepLinkEvent> get deepLinks;
  Stream<AttriaxRawDeepLinkEvent> get rawDeepLinks;

  // --- tracking ---
  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  });

  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  });

  Future<void> recordNotification({
    required AttriaxNotificationEventType type,
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    AttriaxNotificationEventSource? source,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  });

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  });

  Future<void> setUser(String? userId, {String? userName});
  Future<void> setUserProperty(String name, Object? value);
  Future<void> setUserProperties(Map<String, Object?> properties);
  Future<void> clearUserProperties({List<String>? propertyNames});

  Future<void> registerFirebaseMessagingToken({
    required String? token,
    Map<String, Object?>? metadata,
  });

  Future<void> registerApplePushToken({
    required String? token,
    Map<String, Object?>? metadata,
  });

  // --- toggles (synchronous fire-and-forget) ---
  void setEnabled({required bool enabled});
  void setEventsEnabled({required bool enabled});
  void setAnonymousTrackingEnabled({required bool enabled});

  // --- consent ---
  void setGdprConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  });
  void setGdprConsentNotRequired();
  void resetGdprConsent();
  Future<void> requestGdprDataErasure();
  Future<bool> needsGdprConsent({bool localOnly = false});

  // --- CCPA consent ---
  bool? get ccpaDoNotSell;
  String? get ccpaUsPrivacy;
  // ignore: avoid_positional_boolean_parameters
  void setCcpaDoNotSell(bool? doNotSell);
  void setCcpaUsPrivacy(String? usPrivacy);

  // --- deep links ---
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  });
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink();
  Future<AttriaxDeepLinkEvent> waitForDeepLinkResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  );
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    Map<String, Object?>? data,
  });

  // --- revenue ---
  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    required String receipt,
    bool test = false,
    String? provider,
    String? environment,
    String? productId,
    String? transactionId,
  });

  // --- SKAdNetwork ---
  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  });

  // --- App Tracking Transparency ---
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  });
  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus();

  // --- referrers ---
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
    bool safe = false,
  });
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
    bool safe = false,
  });
  Future<String?> getRawInstallReferrer({Duration? timeout, bool safe = false});
  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
    bool safe = false,
  });
  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
    bool safe = false,
  });
}
