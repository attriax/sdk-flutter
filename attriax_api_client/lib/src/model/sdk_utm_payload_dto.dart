//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_utm_payload_dto.g.dart';

/// SdkUtmPayloadDto
///
/// Properties:
/// * [campaign]
/// * [content]
/// * [medium]
/// * [source_]
/// * [term]
@BuiltValue()
abstract class SdkUtmPayloadDto
    implements Built<SdkUtmPayloadDto, SdkUtmPayloadDtoBuilder> {
  @BuiltValueField(wireName: r'campaign')
  String? get campaign;

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'medium')
  String? get medium;

  @BuiltValueField(wireName: r'source')
  String? get source_;

  @BuiltValueField(wireName: r'term')
  String? get term;

  SdkUtmPayloadDto._();

  factory SdkUtmPayloadDto([void updates(SdkUtmPayloadDtoBuilder b)]) =
      _$SdkUtmPayloadDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkUtmPayloadDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkUtmPayloadDto> get serializer =>
      _$SdkUtmPayloadDtoSerializer();
}

class _$SdkUtmPayloadDtoSerializer
    implements PrimitiveSerializer<SdkUtmPayloadDto> {
  @override
  final Iterable<Type> types = const [SdkUtmPayloadDto, _$SdkUtmPayloadDto];

  @override
  final String wireName = r'SdkUtmPayloadDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkUtmPayloadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.campaign != null) {
      yield r'campaign';
      yield serializers.serialize(
        object.campaign,
        specifiedType: const FullType(String),
      );
    }
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.medium != null) {
      yield r'medium';
      yield serializers.serialize(
        object.medium,
        specifiedType: const FullType(String),
      );
    }
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(String),
      );
    }
    if (object.term != null) {
      yield r'term';
      yield serializers.serialize(
        object.term,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkUtmPayloadDto object, {
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
    required SdkUtmPayloadDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'campaign':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.campaign = valueDes;
          break;
        case r'content':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.content = valueDes;
          break;
        case r'medium':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.medium = valueDes;
          break;
        case r'source':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.source_ = valueDes;
          break;
        case r'term':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.term = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkUtmPayloadDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkUtmPayloadDtoBuilder();
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
