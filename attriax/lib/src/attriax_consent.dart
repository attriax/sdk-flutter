import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

import 'internal/attriax_runtime.dart';

/// Local GDPR consent state for the current SDK device.
enum AttriaxGdprConsentState {
  /// Consent has not been checked or set yet.
  unknown,

  /// GDPR consent is not required for this device.
  notRequired,

  /// GDPR consent is required and the SDK is waiting for a decision.
  pending,

  /// Consent values have been granted and stored.
  granted,
}

/// Category-level GDPR consent values.
class AttriaxGdprConsentValues {
  const AttriaxGdprConsentValues({
    required this.analytics,
    required this.attribution,
    required this.adEvents,
  });

  /// Allows analytics, session, crash, and diagnostic tracking.
  final bool analytics;

  /// Allows attribution, install referrer, deep-link attribution, and identity.
  final bool attribution;

  /// Allows ad-event measurement and related revenue analytics.
  final bool adEvents;

  Map<String, Object?> toJson() => <String, Object?>{
    'analytics': analytics,
    'attribution': attribution,
    'adEvents': adEvents,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttriaxGdprConsentValues &&
          other.analytics == analytics &&
          other.attribution == attribution &&
          other.adEvents == adEvents;

  @override
  int get hashCode => Object.hash(analytics, attribution, adEvents);
}

/// Regulation-scoped consent helpers exposed by Attriax.
class AttriaxConsent {
  AttriaxConsent(this._runtime);

  final AttriaxRuntime _runtime;

  /// GDPR-specific consent state and actions.
  late final AttriaxGdprConsent gdpr = AttriaxGdprConsent(_runtime);

  /// Apple App Tracking Transparency helpers.
  late final AttriaxAttConsent att = AttriaxAttConsent(_runtime);
}

/// Apple App Tracking Transparency actions.
class AttriaxAttConsent {
  AttriaxAttConsent(this._runtime);

  final AttriaxRuntime _runtime;

  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) => _runtime.requestTrackingAuthorization(timeout: timeout);

  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus() =>
      _runtime.getTrackingAuthorizationStatus();
}

/// GDPR consent state and actions for the current device.
///
/// Use this when [AttriaxConfig.gdprEnabled] is enabled. Until consent is
/// granted or marked not required, identified tracking is held back according
/// to the configured anonymous-tracking policy.
class AttriaxGdprConsent {
  AttriaxGdprConsent(this._runtime);

  final AttriaxRuntime _runtime;

  /// Last stored category values, or `null` before consent is granted.
  AttriaxGdprConsentValues? get values => _runtime.gdprConsentValues;

  /// Current local GDPR consent state.
  AttriaxGdprConsentState get state => _runtime.gdprConsentState;

  /// Whether the SDK is currently waiting for an explicit GDPR decision.
  bool get isWaitingForConsent => _runtime.isWaitingForGdprConsent;

  /// Resolves whether this device needs a GDPR consent decision.
  ///
  /// When [localOnly] is `true`, the SDK uses local region detection and stored
  /// state only. Otherwise it may ask Attriax for the current consent status.
  Future<bool> needsConsent({bool localOnly = false}) =>
      _runtime.needsGdprConsent(localOnly: localOnly);

  /// Stores granted GDPR consent category values.
  ///
  /// The SDK updates local behavior immediately and syncs the decision to
  /// Attriax in the background.
  void setConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) => _runtime.setGdprConsent(
    analytics: analytics,
    attribution: attribution,
    adEvents: adEvents,
  );

  /// Marks GDPR consent as not required for this device.
  ///
  /// Use this when your own regional logic determines GDPR does not apply.
  void setNotRequired() => _runtime.setGdprConsentNotRequired();

  /// Clears the local GDPR decision and returns the SDK to pending evaluation.
  void reset() => _runtime.resetGdprConsent();

  /// Requests deletion of device-linked GDPR data on the Attriax backend.
  ///
  /// On success, this also clears the local SDK state and returns this instance
  /// to the pre-init state.
  Future<void> requestDataErasure() => _runtime.requestGdprDataErasure();
}
