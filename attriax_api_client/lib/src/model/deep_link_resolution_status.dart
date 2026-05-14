//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DeepLinkResolutionStatus {
  @JsonValue(r'matched')
  matched(r'matched'),
  @JsonValue(r'unmatched')
  unmatched(r'unmatched'),
  @JsonValue(r'invalid')
  invalid(r'invalid');

  const DeepLinkResolutionStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
