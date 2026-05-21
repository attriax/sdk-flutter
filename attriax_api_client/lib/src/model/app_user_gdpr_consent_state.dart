//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum AppUserGdprConsentState {
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'not_required')
  notRequired(r'not_required'),
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'granted')
  granted(r'granted');

  const AppUserGdprConsentState(this.value);

  final String value;

  @override
  String toString() => value;
}
