//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:attriax_api_client/src/model/sdk_utm_payload_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_json_deep_link_dto.g.dart';

/// SdkJsonDeepLinkDto
///
/// Properties:
/// * [data]
/// * [path]
/// * [uri]
/// * [utm]
@BuiltValue()
abstract class SdkJsonDeepLinkDto
    implements Built<SdkJsonDeepLinkDto, SdkJsonDeepLinkDtoBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltMap<String, String>? get data;

  @BuiltValueField(wireName: r'path')
  String get path;

  @BuiltValueField(wireName: r'uri')
  String? get uri;

  @BuiltValueField(wireName: r'utm')
  SdkUtmPayloadDto? get utm;

  SdkJsonDeepLinkDto._();

  factory SdkJsonDeepLinkDto([void updates(SdkJsonDeepLinkDtoBuilder b)]) =
      _$SdkJsonDeepLinkDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkJsonDeepLinkDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkJsonDeepLinkDto> get serializer =>
      _$SdkJsonDeepLinkDtoSerializer();
}

class _$SdkJsonDeepLinkDtoSerializer
    implements PrimitiveSerializer<SdkJsonDeepLinkDto> {
  @override
  final Iterable<Type> types = const [SdkJsonDeepLinkDto, _$SdkJsonDeepLinkDto];

  @override
  final String wireName = r'SdkJsonDeepLinkDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkJsonDeepLinkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType(String),
        ]),
      );
    }
    yield r'path';
    yield serializers.serialize(
      object.path,
      specifiedType: const FullType(String),
    );
    if (object.uri != null) {
      yield r'uri';
      yield serializers.serialize(
        object.uri,
        specifiedType: const FullType(String),
      );
    }
    if (object.utm != null) {
      yield r'utm';
      yield serializers.serialize(
        object.utm,
        specifiedType: const FullType(SdkUtmPayloadDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkJsonDeepLinkDto object, {
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
    required SdkJsonDeepLinkDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType(String),
                    ]),
                  )
                  as BuiltMap<String, String>;
          result.data.replace(valueDes);
          break;
        case r'path':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.path = valueDes;
          break;
        case r'uri':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.uri = valueDes;
          break;
        case r'utm':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(SdkUtmPayloadDto),
                  )
                  as SdkUtmPayloadDto;
          result.utm.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkJsonDeepLinkDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkJsonDeepLinkDtoBuilder();
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
