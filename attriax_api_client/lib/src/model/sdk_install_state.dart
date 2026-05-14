//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SdkInstallState {
  @JsonValue(r'existing')
  existing(r'existing'),
  @JsonValue(r'new_install')
  newInstall(r'new_install'),
  @JsonValue(r'reinstall')
  reinstall(r'reinstall'),
  @JsonValue(r'app_data_clear')
  appDataClear(r'app_data_clear');

  const SdkInstallState(this.value);

  final String value;

  @override
  String toString() => value;
}
