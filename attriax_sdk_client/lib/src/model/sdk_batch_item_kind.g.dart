// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_batch_item_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SdkBatchItemKind _$event = const SdkBatchItemKind._('event');
const SdkBatchItemKind _$session = const SdkBatchItemKind._('session');
const SdkBatchItemKind _$identify = const SdkBatchItemKind._('identify');

SdkBatchItemKind _$valueOf(String name) {
  switch (name) {
    case 'event':
      return _$event;
    case 'session':
      return _$session;
    case 'identify':
      return _$identify;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SdkBatchItemKind> _$values = BuiltSet<SdkBatchItemKind>(
  const <SdkBatchItemKind>[_$event, _$session, _$identify],
);

Serializer<SdkBatchItemKind> _$sdkBatchItemKindSerializer =
    _$SdkBatchItemKindSerializer();

class _$SdkBatchItemKindSerializer
    implements PrimitiveSerializer<SdkBatchItemKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'event': 'event',
    'session': 'session',
    'identify': 'identify',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'event': 'event',
    'session': 'session',
    'identify': 'identify',
  };

  @override
  final Iterable<Type> types = const <Type>[SdkBatchItemKind];
  @override
  final String wireName = 'SdkBatchItemKind';

  @override
  Object serialize(
    Serializers serializers,
    SdkBatchItemKind object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SdkBatchItemKind deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SdkBatchItemKind.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
