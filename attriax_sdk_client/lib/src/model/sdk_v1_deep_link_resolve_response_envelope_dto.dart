//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/sdk_v1_deep_link_resolve_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_deep_link_resolve_response_envelope_dto.g.dart';

/// SdkV1DeepLinkResolveResponseEnvelopeDto
///
/// Properties:
/// * [data] 
/// * [success] 
/// * [timestamp] 
@BuiltValue()
abstract class SdkV1DeepLinkResolveResponseEnvelopeDto implements Built<SdkV1DeepLinkResolveResponseEnvelopeDto, SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder> {
  @BuiltValueField(wireName: r'data')
  SdkV1DeepLinkResolveResponseDto get data;

  @BuiltValueField(wireName: r'success')
  bool get success;

  @BuiltValueField(wireName: r'timestamp')
  DateTime get timestamp;

  SdkV1DeepLinkResolveResponseEnvelopeDto._();

  factory SdkV1DeepLinkResolveResponseEnvelopeDto([void updates(SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder b)]) = _$SdkV1DeepLinkResolveResponseEnvelopeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1DeepLinkResolveResponseEnvelopeDto> get serializer => _$SdkV1DeepLinkResolveResponseEnvelopeDtoSerializer();
}

class _$SdkV1DeepLinkResolveResponseEnvelopeDtoSerializer implements PrimitiveSerializer<SdkV1DeepLinkResolveResponseEnvelopeDto> {
  @override
  final Iterable<Type> types = const [SdkV1DeepLinkResolveResponseEnvelopeDto, _$SdkV1DeepLinkResolveResponseEnvelopeDto];

  @override
  final String wireName = r'SdkV1DeepLinkResolveResponseEnvelopeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1DeepLinkResolveResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SdkV1DeepLinkResolveResponseDto),
    );
    yield r'success';
    yield serializers.serialize(
      object.success,
      specifiedType: const FullType(bool),
    );
    yield r'timestamp';
    yield serializers.serialize(
      object.timestamp,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1DeepLinkResolveResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkV1DeepLinkResolveResponseDto),
          ) as SdkV1DeepLinkResolveResponseDto;
          result.data.replace(valueDes);
          break;
        case r'success':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.success = valueDes;
          break;
        case r'timestamp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.timestamp = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1DeepLinkResolveResponseEnvelopeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

