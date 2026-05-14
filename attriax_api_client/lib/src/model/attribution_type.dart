//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Attribution source classification for the startup referrer payload.
enum AttributionType {
  /// Attribution source classification for the startup referrer payload.
  @JsonValue(r'referrer')
  referrer(r'referrer'),

  /// Attribution source classification for the startup referrer payload.
  @JsonValue(r'fingerprint')
  fingerprint(r'fingerprint'),

  /// Attribution source classification for the startup referrer payload.
  @JsonValue(r'external')
  external_(r'external'),

  /// Attribution source classification for the startup referrer payload.
  @JsonValue(r'organic')
  organic(r'organic');

  const AttributionType(this.value);

  final String value;

  @override
  String toString() => value;
}
