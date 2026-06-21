/// Push-notification lifecycle stages attributed by the Attriax SDKs.
///
/// Attriax never sends pushes itself — the host application's own FCM/APNs
/// handler reports these events and passes through any Attriax link/campaign
/// reference embedded in the notification payload.
enum AttriaxNotificationEventType {
  /// The notification was delivered to / displayed on the device.
  received('received'),

  /// The user opened (tapped) the notification.
  opened('opened'),

  /// The user dismissed the notification without opening it.
  dismissed('dismissed');

  const AttriaxNotificationEventType(this.value);

  /// Wire value sent to the Attriax ingestion endpoint.
  final String value;
}

/// Delivery channel a push notification arrived through.
enum AttriaxNotificationEventSource {
  /// Firebase Cloud Messaging (Android and cross-platform).
  fcm('fcm'),

  /// Apple Push Notification service (iOS / macOS).
  apns('apns'),

  /// Any other / unknown delivery channel.
  other('other');

  const AttriaxNotificationEventSource(this.value);

  /// Wire value sent to the Attriax ingestion endpoint.
  final String value;
}
