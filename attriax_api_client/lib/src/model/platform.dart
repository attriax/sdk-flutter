//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum Platform {
  @JsonValue(r'ios')
  ios(r'ios'),
  @JsonValue(r'android')
  android(r'android'),
  @JsonValue(r'unity_editor')
  unityEditor(r'unity_editor'),
  @JsonValue(r'windows')
  windows(r'windows'),
  @JsonValue(r'macos')
  macos(r'macos'),
  @JsonValue(r'linux')
  linux(r'linux'),
  @JsonValue(r'web')
  web(r'web'),
  @JsonValue(r'unknown')
  unknown(r'unknown');

  const Platform(this.value);

  final String value;

  @override
  String toString() => value;
}
