import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

import 'internal/attriax_runtime.dart';

enum AttriaxGdprConsentState { unknown, notRequired, pending, granted }

class AttriaxGdprConsentValues {
  const AttriaxGdprConsentValues({
    required this.analytics,
    required this.attribution,
    required this.adEvents,
  });

  final bool analytics;
  final bool attribution;
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
class AttriaxGdprConsent {
  AttriaxGdprConsent(this._runtime);

  final AttriaxRuntime _runtime;

  AttriaxGdprConsentValues? get values => _runtime.gdprConsentValues;

  AttriaxGdprConsentState get state => _runtime.gdprConsentState;

  bool get isWaitingForConsent => _runtime.isWaitingForGdprConsent;

  Future<bool> needsConsent({bool localOnly = false}) =>
      _runtime.needsGdprConsent(localOnly: localOnly);

  void setConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) => _runtime.setGdprConsent(
    analytics: analytics,
    attribution: attribution,
    adEvents: adEvents,
  );

  void setNotRequired() => _runtime.setGdprConsentNotRequired();

  void reset() => _runtime.resetGdprConsent();

  /// Requests deletion of device-linked GDPR data on the Attriax backend.
  ///
  /// On success, this also clears the local SDK state and returns this instance
  /// to the pre-init state.
  Future<void> requestDataErasure() => _runtime.requestGdprDataErasure();
}
