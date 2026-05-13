//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_install_state.g.dart';

class SdkInstallState extends EnumClass {
  @BuiltValueEnumConst(wireName: r'existing')
  static const SdkInstallState existing = _$existing;
  @BuiltValueEnumConst(wireName: r'new_install')
  static const SdkInstallState newInstall = _$newInstall;
  @BuiltValueEnumConst(wireName: r'reinstall')
  static const SdkInstallState reinstall = _$reinstall;
  @BuiltValueEnumConst(wireName: r'app_data_clear')
  static const SdkInstallState appDataClear = _$appDataClear;

  static Serializer<SdkInstallState> get serializer =>
      _$sdkInstallStateSerializer;

  const SdkInstallState._(String name) : super(name);

  static BuiltSet<SdkInstallState> get values => _$values;
  static SdkInstallState valueOf(String name) => _$valueOf(name);
}
