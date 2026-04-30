//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_json_deep_link_dto.g.dart';

/// SdkJsonDeepLinkDto
///
/// Properties:
/// * [data] 
/// * [path] 
@BuiltValue()
abstract class SdkJsonDeepLinkDto implements Built<SdkJsonDeepLinkDto, SdkJsonDeepLinkDtoBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?>? get data;

  @BuiltValueField(wireName: r'path')
  String get path;

  SdkJsonDeepLinkDto._();

  factory SdkJsonDeepLinkDto([void updates(SdkJsonDeepLinkDtoBuilder b)]) = _$SdkJsonDeepLinkDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkJsonDeepLinkDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkJsonDeepLinkDto> get serializer => _$SdkJsonDeepLinkDtoSerializer();
}

class _$SdkJsonDeepLinkDtoSerializer implements PrimitiveSerializer<SdkJsonDeepLinkDto> {
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
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    yield r'path';
    yield serializers.serialize(
      object.path,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkJsonDeepLinkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
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
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.data.replace(valueDes);
          break;
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.path = valueDes;
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

