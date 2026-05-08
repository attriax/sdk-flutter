// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_session_lifecycle_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SdkSessionLifecycleKind _$start = const SdkSessionLifecycleKind._(
  'start',
);
const SdkSessionLifecycleKind _$heartbeat = const SdkSessionLifecycleKind._(
  'heartbeat',
);
const SdkSessionLifecycleKind _$pause = const SdkSessionLifecycleKind._(
  'pause',
);
const SdkSessionLifecycleKind _$resume = const SdkSessionLifecycleKind._(
  'resume',
);
const SdkSessionLifecycleKind _$end = const SdkSessionLifecycleKind._('end');

SdkSessionLifecycleKind _$valueOf(String name) {
  switch (name) {
    case 'start':
      return _$start;
    case 'heartbeat':
      return _$heartbeat;
    case 'pause':
      return _$pause;
    case 'resume':
      return _$resume;
    case 'end':
      return _$end;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SdkSessionLifecycleKind> _$values =
    BuiltSet<SdkSessionLifecycleKind>(const <SdkSessionLifecycleKind>[
      _$start,
      _$heartbeat,
      _$pause,
      _$resume,
      _$end,
    ]);

Serializer<SdkSessionLifecycleKind> _$sdkSessionLifecycleKindSerializer =
    _$SdkSessionLifecycleKindSerializer();

class _$SdkSessionLifecycleKindSerializer
    implements PrimitiveSerializer<SdkSessionLifecycleKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'start': 'start',
    'heartbeat': 'heartbeat',
    'pause': 'pause',
    'resume': 'resume',
    'end': 'end',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'start': 'start',
    'heartbeat': 'heartbeat',
    'pause': 'pause',
    'resume': 'resume',
    'end': 'end',
  };

  @override
  final Iterable<Type> types = const <Type>[SdkSessionLifecycleKind];
  @override
  final String wireName = 'SdkSessionLifecycleKind';

  @override
  Object serialize(
    Serializers serializers,
    SdkSessionLifecycleKind object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SdkSessionLifecycleKind deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SdkSessionLifecycleKind.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
