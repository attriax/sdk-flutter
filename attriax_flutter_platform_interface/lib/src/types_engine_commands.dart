part of 'types.dart';

/// Push-notification token provider slugs registered through the engine
/// `registerPushToken` command.
///
/// Mirrors the KMP `AttriaxTracking.registerFirebaseMessagingToken` /
/// `registerApplePushToken` split, which lower to a single uninstall-token wire
/// keyed by the provider slug (`fcm` / `apns`).
enum AttriaxPushTokenProvider {
  /// Firebase Cloud Messaging (Android / cross-platform).
  fcm,

  /// Apple Push Notification service (iOS / macOS).
  apns,
}

/// The wire slug for an [AttriaxPushTokenProvider], matching the KMP
/// `UNINSTALL_TOKEN_PROVIDER_*` constants.
extension AttriaxPushTokenProviderWire on AttriaxPushTokenProvider {
  String get wireValue => switch (this) {
    AttriaxPushTokenProvider.fcm => 'fcm',
    AttriaxPushTokenProvider.apns => 'apns',
  };
}

// NOTE (Phase 1): the GDPR consent *reader* types (`AttriaxGdprConsentState` /
// `AttriaxGdprConsentValues`) are intentionally NOT redefined here. The app
// facade already declares those names, and re-exporting duplicates through the
// shared type surface would ambiguate the facade's imports. The engine consent
// *mutators* (`setGdprConsent` etc.) take primitives, so they need no types;
// the reader getters are deferred to the facade-rewire phase, which will decide
// where those types canonically live.

/// Resolution outcome for the startup initial-link probe emitted on the
/// initial-deep-link event stream.
///
/// Mirrors the KMP `deepLinks.waitForInitialDeepLink()` completion: once the
/// probe settles, [resolved] becomes `true` and [deepLink] carries the launch
/// deep-link event, or `null` when the launch carried no deep link.
class AttriaxInitialDeepLinkResolution {
  const AttriaxInitialDeepLinkResolution({
    required this.resolved,
    this.deepLink,
  });

  factory AttriaxInitialDeepLinkResolution.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);

    return AttriaxInitialDeepLinkResolution(
      resolved: _jsonBool(json['resolved']) ?? true,
      deepLink: deepLinkJson == null
          ? null
          : AttriaxDeepLinkEvent.fromJson(deepLinkJson),
    );
  }

  factory AttriaxInitialDeepLinkResolution.fromPayload(Object? payload) =>
      AttriaxInitialDeepLinkResolution.fromJson(_jsonObjectOrEmpty(payload));

  /// Whether the initial-link probe has completed for this app session.
  final bool resolved;

  /// The launch deep-link event, when one was present.
  final AttriaxDeepLinkEvent? deepLink;

  Map<String, Object?> toJson() => <String, Object?>{
    'resolved': resolved,
    if (deepLink != null) 'deepLink': deepLink!.toJson(),
  };
}

// Wire ↔ enum parsing for these engine-command enums lives in the
// MethodChannel implementation (which owns the transport boundary), mirroring
// the existing `_trackingAuthorizationStatusFromPayload` placement.
