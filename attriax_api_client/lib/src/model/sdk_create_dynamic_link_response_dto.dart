//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_dynamic_link_record_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_create_dynamic_link_response_dto.g.dart';

/// SdkCreateDynamicLinkResponseDto
///
/// Properties:
/// * [acceptedAt]
/// * [link]
/// * [requestVersion]
@BuiltValue()
abstract class SdkCreateDynamicLinkResponseDto
    implements
        Built<
          SdkCreateDynamicLinkResponseDto,
          SdkCreateDynamicLinkResponseDtoBuilder
        > {
  @BuiltValueField(wireName: r'acceptedAt')
  DateTime get acceptedAt;

  @BuiltValueField(wireName: r'link')
  SdkDynamicLinkRecordDto get link;

  @BuiltValueField(wireName: r'requestVersion')
  String get requestVersion;

  SdkCreateDynamicLinkResponseDto._();

  factory SdkCreateDynamicLinkResponseDto([
    void updates(SdkCreateDynamicLinkResponseDtoBuilder b),
  ]) = _$SdkCreateDynamicLinkResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkCreateDynamicLinkResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkCreateDynamicLinkResponseDto> get serializer =>
      _$SdkCreateDynamicLinkResponseDtoSerializer();
}

class _$SdkCreateDynamicLinkResponseDtoSerializer
    implements PrimitiveSerializer<SdkCreateDynamicLinkResponseDto> {
  @override
  final Iterable<Type> types = const [
    SdkCreateDynamicLinkResponseDto,
    _$SdkCreateDynamicLinkResponseDto,
  ];

  @override
  final String wireName = r'SdkCreateDynamicLinkResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkCreateDynamicLinkResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'acceptedAt';
    yield serializers.serialize(
      object.acceptedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'link';
    yield serializers.serialize(
      object.link,
      specifiedType: const FullType(SdkDynamicLinkRecordDto),
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
    SdkCreateDynamicLinkResponseDto object, {
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
    required SdkCreateDynamicLinkResponseDtoBuilder result,
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
        case r'link':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(SdkDynamicLinkRecordDto),
                  )
                  as SdkDynamicLinkRecordDto;
          result.link.replace(valueDes);
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
  SdkCreateDynamicLinkResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkCreateDynamicLinkResponseDtoBuilder();
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
