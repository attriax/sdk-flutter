// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribution_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AttributionType _$referrer = const AttributionType._('referrer');
const AttributionType _$fingerprint = const AttributionType._('fingerprint');
const AttributionType _$external_ = const AttributionType._('external_');
const AttributionType _$organic = const AttributionType._('organic');

AttributionType _$valueOf(String name) {
  switch (name) {
    case 'referrer':
      return _$referrer;
    case 'fingerprint':
      return _$fingerprint;
    case 'external_':
      return _$external_;
    case 'organic':
      return _$organic;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AttributionType> _$values = BuiltSet<AttributionType>(
  const <AttributionType>[_$referrer, _$fingerprint, _$external_, _$organic],
);

Serializer<AttributionType> _$attributionTypeSerializer =
    _$AttributionTypeSerializer();

class _$AttributionTypeSerializer
    implements PrimitiveSerializer<AttributionType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'referrer': 'referrer',
    'fingerprint': 'fingerprint',
    'external_': 'external',
    'organic': 'organic',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'referrer': 'referrer',
    'fingerprint': 'fingerprint',
    'external': 'external_',
    'organic': 'organic',
  };

  @override
  final Iterable<Type> types = const <Type>[AttributionType];
  @override
  final String wireName = 'AttributionType';

  @override
  Object serialize(
    Serializers serializers,
    AttributionType object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AttributionType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AttributionType.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
