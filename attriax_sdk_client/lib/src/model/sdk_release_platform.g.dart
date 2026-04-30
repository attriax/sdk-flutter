// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_release_platform.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SdkReleasePlatform _$unity = const SdkReleasePlatform._('unity');

SdkReleasePlatform _$valueOf(String name) {
  switch (name) {
    case 'unity':
      return _$unity;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SdkReleasePlatform> _$values = BuiltSet<SdkReleasePlatform>(
  const <SdkReleasePlatform>[_$unity],
);

Serializer<SdkReleasePlatform> _$sdkReleasePlatformSerializer =
    _$SdkReleasePlatformSerializer();

class _$SdkReleasePlatformSerializer
    implements PrimitiveSerializer<SdkReleasePlatform> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'unity': 'unity',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'unity': 'unity',
  };

  @override
  final Iterable<Type> types = const <Type>[SdkReleasePlatform];
  @override
  final String wireName = 'SdkReleasePlatform';

  @override
  Object serialize(
    Serializers serializers,
    SdkReleasePlatform object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SdkReleasePlatform deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SdkReleasePlatform.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
