//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Delivery channel the notification arrived through.
enum NotificationEventSource {
  /// Delivery channel the notification arrived through.
  @JsonValue(r'fcm')
  fcm(r'fcm'),

  /// Delivery channel the notification arrived through.
  @JsonValue(r'apns')
  apns(r'apns'),

  /// Delivery channel the notification arrived through.
  @JsonValue(r'other')
  other(r'other');

  const NotificationEventSource(this.value);

  final String value;

  @override
  String toString() => value;
}
