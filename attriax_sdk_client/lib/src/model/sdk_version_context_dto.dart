//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_version_context_dto.g.dart';

/// SdkVersionContextDto
///
/// Properties:
/// * [apiVersion] 
/// * [metadata] 
/// * [packageVersion] 
@BuiltValue()
abstract class SdkVersionContextDto implements Built<SdkVersionContextDto, SdkVersionContextDtoBuilder> {
  @BuiltValueField(wireName: r'apiVersion')
  String get apiVersion;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  @BuiltValueField(wireName: r'packageVersion')
  String get packageVersion;

  SdkVersionContextDto._();

  factory SdkVersionContextDto([void updates(SdkVersionContextDtoBuilder b)]) = _$SdkVersionContextDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkVersionContextDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkVersionContextDto> get serializer => _$SdkVersionContextDtoSerializer();
}

class _$SdkVersionContextDtoSerializer implements PrimitiveSerializer<SdkVersionContextDto> {
  @override
  final Iterable<Type> types = const [SdkVersionContextDto, _$SdkVersionContextDto];

  @override
  final String wireName = r'SdkVersionContextDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkVersionContextDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'apiVersion';
    yield serializers.serialize(
      object.apiVersion,
      specifiedType: const FullType(String),
    );
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    yield r'packageVersion';
    yield serializers.serialize(
      object.packageVersion,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkVersionContextDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkVersionContextDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'apiVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.apiVersion = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.metadata.replace(valueDes);
          break;
        case r'packageVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.packageVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkVersionContextDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkVersionContextDtoBuilder();
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

