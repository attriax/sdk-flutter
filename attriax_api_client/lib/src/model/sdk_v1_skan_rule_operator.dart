//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SdkV1SkanRuleOperator {
  @JsonValue(r'exists')
  exists(r'exists'),
  @JsonValue(r'eq')
  eq(r'eq'),
  @JsonValue(r'not_eq')
  notEq(r'not_eq'),
  @JsonValue(r'gt')
  gt(r'gt'),
  @JsonValue(r'gte')
  gte(r'gte'),
  @JsonValue(r'lt')
  lt(r'lt'),
  @JsonValue(r'lte')
  lte(r'lte'),
  @JsonValue(r'contains')
  contains(r'contains');

  const SdkV1SkanRuleOperator(this.value);

  final String value;

  @override
  String toString() => value;
}
