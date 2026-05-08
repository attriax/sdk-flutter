//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform.g.dart';

class Platform extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ios')
  static const Platform ios = _$ios;
  @BuiltValueEnumConst(wireName: r'android')
  static const Platform android = _$android;
  @BuiltValueEnumConst(wireName: r'unity_editor')
  static const Platform unityEditor = _$unityEditor;
  @BuiltValueEnumConst(wireName: r'windows')
  static const Platform windows = _$windows;
  @BuiltValueEnumConst(wireName: r'macos')
  static const Platform macos = _$macos;
  @BuiltValueEnumConst(wireName: r'linux')
  static const Platform linux = _$linux;
  @BuiltValueEnumConst(wireName: r'web')
  static const Platform web = _$web;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const Platform unknown = _$unknown;

  static Serializer<Platform> get serializer => _$platformSerializer;

  const Platform._(String name) : super(name);

  static BuiltSet<Platform> get values => _$values;
  static Platform valueOf(String name) => _$valueOf(name);
}
