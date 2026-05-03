//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/sdk_v1_batch_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_batch_response_envelope_dto.g.dart';

/// SdkV1BatchResponseEnvelopeDto
///
/// Properties:
/// * [data] 
/// * [success] 
/// * [timestamp] 
@BuiltValue()
abstract class SdkV1BatchResponseEnvelopeDto implements Built<SdkV1BatchResponseEnvelopeDto, SdkV1BatchResponseEnvelopeDtoBuilder> {
  @BuiltValueField(wireName: r'data')
  SdkV1BatchResponseDto get data;

  @BuiltValueField(wireName: r'success')
  bool get success;

  @BuiltValueField(wireName: r'timestamp')
  DateTime get timestamp;

  SdkV1BatchResponseEnvelopeDto._();

  factory SdkV1BatchResponseEnvelopeDto([void updates(SdkV1BatchResponseEnvelopeDtoBuilder b)]) = _$SdkV1BatchResponseEnvelopeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1BatchResponseEnvelopeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1BatchResponseEnvelopeDto> get serializer => _$SdkV1BatchResponseEnvelopeDtoSerializer();
}

class _$SdkV1BatchResponseEnvelopeDtoSerializer implements PrimitiveSerializer<SdkV1BatchResponseEnvelopeDto> {
  @override
  final Iterable<Type> types = const [SdkV1BatchResponseEnvelopeDto, _$SdkV1BatchResponseEnvelopeDto];

  @override
  final String wireName = r'SdkV1BatchResponseEnvelopeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1BatchResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SdkV1BatchResponseDto),
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
    SdkV1BatchResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkV1BatchResponseEnvelopeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkV1BatchResponseDto),
          ) as SdkV1BatchResponseDto;
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
  SdkV1BatchResponseEnvelopeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1BatchResponseEnvelopeDtoBuilder();
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

