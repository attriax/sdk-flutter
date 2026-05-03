//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:attriax_sdk_client/src/model/sdk_batch_item_kind.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_batch_item_dto.g.dart';

/// SdkV1BatchItemDto
///
/// Properties:
/// * [body] - SDK request payload for the selected item kind.
/// * [kind] 
@BuiltValue()
abstract class SdkV1BatchItemDto implements Built<SdkV1BatchItemDto, SdkV1BatchItemDtoBuilder> {
  /// SDK request payload for the selected item kind.
  @BuiltValueField(wireName: r'body')
  BuiltMap<String, JsonObject?> get body;

  @BuiltValueField(wireName: r'kind')
  SdkBatchItemKind get kind;
  // enum kindEnum {  event,  session,  identify,  };

  SdkV1BatchItemDto._();

  factory SdkV1BatchItemDto([void updates(SdkV1BatchItemDtoBuilder b)]) = _$SdkV1BatchItemDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1BatchItemDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1BatchItemDto> get serializer => _$SdkV1BatchItemDtoSerializer();
}

class _$SdkV1BatchItemDtoSerializer implements PrimitiveSerializer<SdkV1BatchItemDto> {
  @override
  final Iterable<Type> types = const [SdkV1BatchItemDto, _$SdkV1BatchItemDto];

  @override
  final String wireName = r'SdkV1BatchItemDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1BatchItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(SdkBatchItemKind),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1BatchItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkV1BatchItemDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.body.replace(valueDes);
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkBatchItemKind),
          ) as SdkBatchItemKind;
          result.kind = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1BatchItemDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1BatchItemDtoBuilder();
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

