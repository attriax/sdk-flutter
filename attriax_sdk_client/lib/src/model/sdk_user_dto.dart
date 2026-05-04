//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_user_dto.g.dart';

/// SdkUserDto
///
/// Properties:
/// * [appToken] 
/// * [clearAllProperties] - Clears every stored user property before applying this request.
/// * [clearExternalUser] - Clears the stored external user id and name for future events.
/// * [clearPropertyKeys] - Specific stored user-property keys to clear.
/// * [deviceId] 
/// * [deviceIdSource] 
/// * [externalUserId] 
/// * [externalUserName] 
/// * [properties] - User properties merged into future event payloads until they are cleared or replaced.
@BuiltValue()
abstract class SdkUserDto implements Built<SdkUserDto, SdkUserDtoBuilder> {
  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  /// Clears every stored user property before applying this request.
  @BuiltValueField(wireName: r'clearAllProperties')
  bool? get clearAllProperties;

  /// Clears the stored external user id and name for future events.
  @BuiltValueField(wireName: r'clearExternalUser')
  bool? get clearExternalUser;

  /// Specific stored user-property keys to clear.
  @BuiltValueField(wireName: r'clearPropertyKeys')
  BuiltList<String>? get clearPropertyKeys;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'deviceIdSource')
  String? get deviceIdSource;

  @BuiltValueField(wireName: r'externalUserId')
  String? get externalUserId;

  @BuiltValueField(wireName: r'externalUserName')
  String? get externalUserName;

  /// User properties merged into future event payloads until they are cleared or replaced.
  @BuiltValueField(wireName: r'properties')
  BuiltMap<String, JsonObject?>? get properties;

  SdkUserDto._();

  factory SdkUserDto([void updates(SdkUserDtoBuilder b)]) = _$SdkUserDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkUserDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkUserDto> get serializer => _$SdkUserDtoSerializer();
}

class _$SdkUserDtoSerializer implements PrimitiveSerializer<SdkUserDto> {
  @override
  final Iterable<Type> types = const [SdkUserDto, _$SdkUserDto];

  @override
  final String wireName = r'SdkUserDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
    );
    if (object.clearAllProperties != null) {
      yield r'clearAllProperties';
      yield serializers.serialize(
        object.clearAllProperties,
        specifiedType: const FullType(bool),
      );
    }
    if (object.clearExternalUser != null) {
      yield r'clearExternalUser';
      yield serializers.serialize(
        object.clearExternalUser,
        specifiedType: const FullType(bool),
      );
    }
    if (object.clearPropertyKeys != null) {
      yield r'clearPropertyKeys';
      yield serializers.serialize(
        object.clearPropertyKeys,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
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
    if (object.externalUserId != null) {
      yield r'externalUserId';
      yield serializers.serialize(
        object.externalUserId,
        specifiedType: const FullType(String),
      );
    }
    if (object.externalUserName != null) {
      yield r'externalUserName';
      yield serializers.serialize(
        object.externalUserName,
        specifiedType: const FullType(String),
      );
    }
    if (object.properties != null) {
      yield r'properties';
      yield serializers.serialize(
        object.properties,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkUserDtoBuilder result,
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
        case r'clearAllProperties':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.clearAllProperties = valueDes;
          break;
        case r'clearExternalUser':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.clearExternalUser = valueDes;
          break;
        case r'clearPropertyKeys':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.clearPropertyKeys.replace(valueDes);
          break;
        case r'deviceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'deviceIdSource':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceIdSource = valueDes;
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
        case r'properties':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.properties.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkUserDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkUserDtoBuilder();
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

