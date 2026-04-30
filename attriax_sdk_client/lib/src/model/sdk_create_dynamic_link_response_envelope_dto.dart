//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/sdk_create_dynamic_link_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_create_dynamic_link_response_envelope_dto.g.dart';

/// SdkCreateDynamicLinkResponseEnvelopeDto
///
/// Properties:
/// * [data] 
/// * [success] 
/// * [timestamp] 
@BuiltValue()
abstract class SdkCreateDynamicLinkResponseEnvelopeDto implements Built<SdkCreateDynamicLinkResponseEnvelopeDto, SdkCreateDynamicLinkResponseEnvelopeDtoBuilder> {
  @BuiltValueField(wireName: r'data')
  SdkCreateDynamicLinkResponseDto get data;

  @BuiltValueField(wireName: r'success')
  bool get success;

  @BuiltValueField(wireName: r'timestamp')
  DateTime get timestamp;

  SdkCreateDynamicLinkResponseEnvelopeDto._();

  factory SdkCreateDynamicLinkResponseEnvelopeDto([void updates(SdkCreateDynamicLinkResponseEnvelopeDtoBuilder b)]) = _$SdkCreateDynamicLinkResponseEnvelopeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkCreateDynamicLinkResponseEnvelopeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkCreateDynamicLinkResponseEnvelopeDto> get serializer => _$SdkCreateDynamicLinkResponseEnvelopeDtoSerializer();
}

class _$SdkCreateDynamicLinkResponseEnvelopeDtoSerializer implements PrimitiveSerializer<SdkCreateDynamicLinkResponseEnvelopeDto> {
  @override
  final Iterable<Type> types = const [SdkCreateDynamicLinkResponseEnvelopeDto, _$SdkCreateDynamicLinkResponseEnvelopeDto];

  @override
  final String wireName = r'SdkCreateDynamicLinkResponseEnvelopeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkCreateDynamicLinkResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SdkCreateDynamicLinkResponseDto),
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
    SdkCreateDynamicLinkResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkCreateDynamicLinkResponseEnvelopeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkCreateDynamicLinkResponseDto),
          ) as SdkCreateDynamicLinkResponseDto;
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
  SdkCreateDynamicLinkResponseEnvelopeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkCreateDynamicLinkResponseEnvelopeDtoBuilder();
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

