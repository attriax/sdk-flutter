//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Lifecycle stage: received, opened, or dismissed.
enum NotificationEventType {
  /// Lifecycle stage: received, opened, or dismissed.
  @JsonValue(r'received')
  received(r'received'),

  /// Lifecycle stage: received, opened, or dismissed.
  @JsonValue(r'opened')
  opened(r'opened'),

  /// Lifecycle stage: received, opened, or dismissed.
  @JsonValue(r'dismissed')
  dismissed(r'dismissed');

  const NotificationEventType(this.value);

  final String value;

  @override
  String toString() => value;
}
