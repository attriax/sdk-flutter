// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_link_resolution_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeepLinkResolutionStatus _$matched = const DeepLinkResolutionStatus._(
  'matched',
);
const DeepLinkResolutionStatus _$unmatched = const DeepLinkResolutionStatus._(
  'unmatched',
);
const DeepLinkResolutionStatus _$invalid = const DeepLinkResolutionStatus._(
  'invalid',
);

DeepLinkResolutionStatus _$valueOf(String name) {
  switch (name) {
    case 'matched':
      return _$matched;
    case 'unmatched':
      return _$unmatched;
    case 'invalid':
      return _$invalid;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeepLinkResolutionStatus> _$values =
    BuiltSet<DeepLinkResolutionStatus>(const <DeepLinkResolutionStatus>[
      _$matched,
      _$unmatched,
      _$invalid,
    ]);

Serializer<DeepLinkResolutionStatus> _$deepLinkResolutionStatusSerializer =
    _$DeepLinkResolutionStatusSerializer();

class _$DeepLinkResolutionStatusSerializer
    implements PrimitiveSerializer<DeepLinkResolutionStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'matched': 'matched',
    'unmatched': 'unmatched',
    'invalid': 'invalid',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'matched': 'matched',
    'unmatched': 'unmatched',
    'invalid': 'invalid',
  };

  @override
  final Iterable<Type> types = const <Type>[DeepLinkResolutionStatus];
  @override
  final String wireName = 'DeepLinkResolutionStatus';

  @override
  Object serialize(
    Serializers serializers,
    DeepLinkResolutionStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DeepLinkResolutionStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DeepLinkResolutionStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
