//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_identify_dto.g.dart';

/// SdkIdentifyDto
///
/// Properties:
/// * [appToken] 
/// * [deviceId] 
/// * [externalUserId] 
/// * [externalUserName] 
@BuiltValue()
abstract class SdkIdentifyDto implements Built<SdkIdentifyDto, SdkIdentifyDtoBuilder> {
  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'externalUserId')
  String get externalUserId;

  @BuiltValueField(wireName: r'externalUserName')
  String? get externalUserName;

  SdkIdentifyDto._();

  factory SdkIdentifyDto([void updates(SdkIdentifyDtoBuilder b)]) = _$SdkIdentifyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkIdentifyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkIdentifyDto> get serializer => _$SdkIdentifyDtoSerializer();
}

class _$SdkIdentifyDtoSerializer implements PrimitiveSerializer<SdkIdentifyDto> {
  @override
  final Iterable<Type> types = const [SdkIdentifyDto, _$SdkIdentifyDto];

  @override
  final String wireName = r'SdkIdentifyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkIdentifyDto object, {
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
    yield r'externalUserId';
    yield serializers.serialize(
      object.externalUserId,
      specifiedType: const FullType(String),
    );
    if (object.externalUserName != null) {
      yield r'externalUserName';
      yield serializers.serialize(
        object.externalUserName,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkIdentifyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkIdentifyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appToken = valueDes;
          break;
        case r'deviceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'externalUserId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.externalUserId = valueDes;
          break;
        case r'externalUserName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.externalUserName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkIdentifyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkIdentifyDtoBuilder();
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

