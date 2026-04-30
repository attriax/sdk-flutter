// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Platform _$ios = const Platform._('ios');
const Platform _$android = const Platform._('android');
const Platform _$unityEditor = const Platform._('unityEditor');
const Platform _$windows = const Platform._('windows');
const Platform _$macos = const Platform._('macos');
const Platform _$linux = const Platform._('linux');
const Platform _$web = const Platform._('web');
const Platform _$unknown = const Platform._('unknown');

Platform _$valueOf(String name) {
  switch (name) {
    case 'ios':
      return _$ios;
    case 'android':
      return _$android;
    case 'unityEditor':
      return _$unityEditor;
    case 'windows':
      return _$windows;
    case 'macos':
      return _$macos;
    case 'linux':
      return _$linux;
    case 'web':
      return _$web;
    case 'unknown':
      return _$unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<Platform> _$values = BuiltSet<Platform>(const <Platform>[
  _$ios,
  _$android,
  _$unityEditor,
  _$windows,
  _$macos,
  _$linux,
  _$web,
  _$unknown,
]);

Serializer<Platform> _$platformSerializer = _$PlatformSerializer();

class _$PlatformSerializer implements PrimitiveSerializer<Platform> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ios': 'ios',
    'android': 'android',
    'unityEditor': 'unity_editor',
    'windows': 'windows',
    'macos': 'macos',
    'linux': 'linux',
    'web': 'web',
    'unknown': 'unknown',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ios': 'ios',
    'android': 'android',
    'unity_editor': 'unityEditor',
    'windows': 'windows',
    'macos': 'macos',
    'linux': 'linux',
    'web': 'web',
    'unknown': 'unknown',
  };

  @override
  final Iterable<Type> types = const <Type>[Platform];
  @override
  final String wireName = 'Platform';

  @override
  Object serialize(
    Serializers serializers,
    Platform object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  Platform deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => Platform.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
