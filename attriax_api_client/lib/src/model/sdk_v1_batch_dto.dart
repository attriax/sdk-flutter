//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_batch_item_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_batch_dto.g.dart';

/// SdkV1BatchDto
///
/// Properties:
/// * [appToken] - Shared app token for every item in the batch.
/// * [deviceId] - Shared device identifier for every item in the batch.
/// * [deviceIdSource] - Optional shared device-id source for every item in the batch.
/// * [items]
/// * [requestId] - Stable client-generated batch identifier used for idempotent retries.
@BuiltValue()
abstract class SdkV1BatchDto
    implements Built<SdkV1BatchDto, SdkV1BatchDtoBuilder> {
  /// Shared app token for every item in the batch.
  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  /// Shared device identifier for every item in the batch.
  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  /// Optional shared device-id source for every item in the batch.
  @BuiltValueField(wireName: r'deviceIdSource')
  String? get deviceIdSource;

  @BuiltValueField(wireName: r'items')
  BuiltList<SdkV1BatchItemDto> get items;

  /// Stable client-generated batch identifier used for idempotent retries.
  @BuiltValueField(wireName: r'requestId')
  String get requestId;

  SdkV1BatchDto._();

  factory SdkV1BatchDto([void updates(SdkV1BatchDtoBuilder b)]) =
      _$SdkV1BatchDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1BatchDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1BatchDto> get serializer =>
      _$SdkV1BatchDtoSerializer();
}

class _$SdkV1BatchDtoSerializer implements PrimitiveSerializer<SdkV1BatchDto> {
  @override
  final Iterable<Type> types = const [SdkV1BatchDto, _$SdkV1BatchDto];

  @override
  final String wireName = r'SdkV1BatchDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1BatchDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
    );
    yield r'deviceId';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    if (object.deviceIdSource != null) {
      yield r'deviceIdSource';
      yield serializers.serialize(
        object.deviceIdSource,
        specifiedType: const FullType(String),
      );
    }
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(SdkV1BatchItemDto)]),
    );
    yield r'requestId';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1BatchDto object, {
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
    required SdkV1BatchDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appToken':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.appToken = valueDes;
          break;
        case r'deviceId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deviceId = valueDes;
          break;
        case r'deviceIdSource':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deviceIdSource = valueDes;
          break;
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(SdkV1BatchItemDto),
                    ]),
                  )
                  as BuiltList<SdkV1BatchItemDto>;
          result.items.replace(valueDes);
          break;
        case r'requestId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.requestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1BatchDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1BatchDtoBuilder();
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
