//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SdkBatchItemKind {
  @JsonValue(r'event')
  event(r'event'),
  @JsonValue(r'session')
  session(r'session'),
  @JsonValue(r'user')
  user(r'user');

  const SdkBatchItemKind(this.value);

  final String value;

  @override
  String toString() => value;
}
