//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_batch_response_dto.g.dart';

/// SdkV1BatchResponseDto
///
/// Properties:
/// * [acceptedAt]
/// * [duplicateCount]
/// * [itemCount]
/// * [processedCount]
/// * [requestVersion]
@BuiltValue()
abstract class SdkV1BatchResponseDto
    implements Built<SdkV1BatchResponseDto, SdkV1BatchResponseDtoBuilder> {
  @BuiltValueField(wireName: r'acceptedAt')
  DateTime get acceptedAt;

  @BuiltValueField(wireName: r'duplicateCount')
  num get duplicateCount;

  @BuiltValueField(wireName: r'itemCount')
  num get itemCount;

  @BuiltValueField(wireName: r'processedCount')
  num get processedCount;

  @BuiltValueField(wireName: r'requestVersion')
  String get requestVersion;

  SdkV1BatchResponseDto._();

  factory SdkV1BatchResponseDto([
    void updates(SdkV1BatchResponseDtoBuilder b),
  ]) = _$SdkV1BatchResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1BatchResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1BatchResponseDto> get serializer =>
      _$SdkV1BatchResponseDtoSerializer();
}

class _$SdkV1BatchResponseDtoSerializer
    implements PrimitiveSerializer<SdkV1BatchResponseDto> {
  @override
  final Iterable<Type> types = const [
    SdkV1BatchResponseDto,
    _$SdkV1BatchResponseDto,
  ];

  @override
  final String wireName = r'SdkV1BatchResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1BatchResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'acceptedAt';
    yield serializers.serialize(
      object.acceptedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'duplicateCount';
    yield serializers.serialize(
      object.duplicateCount,
      specifiedType: const FullType(num),
    );
    yield r'itemCount';
    yield serializers.serialize(
      object.itemCount,
      specifiedType: const FullType(num),
    );
    yield r'processedCount';
    yield serializers.serialize(
      object.processedCount,
      specifiedType: const FullType(num),
    );
    yield r'requestVersion';
    yield serializers.serialize(
      object.requestVersion,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1BatchResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(
      serializers,
      object,
      specifiedType: specifiedType,
    ).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkV1BatchResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'acceptedAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.acceptedAt = valueDes;
          break;
        case r'duplicateCount':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.duplicateCount = valueDes;
          break;
        case r'itemCount':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.itemCount = valueDes;
          break;
        case r'processedCount':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.processedCount = valueDes;
          break;
        case r'requestVersion':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.requestVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1BatchResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1BatchResponseDtoBuilder();
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
