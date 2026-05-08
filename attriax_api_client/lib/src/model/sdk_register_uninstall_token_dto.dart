//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:attriax_api_client/src/model/app_user_uninstall_token_provider.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_register_uninstall_token_dto.g.dart';

/// SdkRegisterUninstallTokenDto
///
/// Properties:
/// * [appToken]
/// * [deviceId]
/// * [deviceIdSource]
/// * [metadata]
/// * [platform]
/// * [provider]
/// * [token]
@BuiltValue()
abstract class SdkRegisterUninstallTokenDto
    implements
        Built<
          SdkRegisterUninstallTokenDto,
          SdkRegisterUninstallTokenDtoBuilder
        > {
  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'deviceIdSource')
  String? get deviceIdSource;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  @BuiltValueField(wireName: r'platform')
  Platform get platform;
  // enum platformEnum {  ios,  android,  unity_editor,  windows,  macos,  linux,  web,  unknown,  };

  @BuiltValueField(wireName: r'provider')
  AppUserUninstallTokenProvider get provider;
  // enum providerEnum {  fcm,  };

  @BuiltValueField(wireName: r'token')
  String get token;

  SdkRegisterUninstallTokenDto._();

  factory SdkRegisterUninstallTokenDto([
    void updates(SdkRegisterUninstallTokenDtoBuilder b),
  ]) = _$SdkRegisterUninstallTokenDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkRegisterUninstallTokenDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkRegisterUninstallTokenDto> get serializer =>
      _$SdkRegisterUninstallTokenDtoSerializer();
}

class _$SdkRegisterUninstallTokenDtoSerializer
    implements PrimitiveSerializer<SdkRegisterUninstallTokenDto> {
  @override
  final Iterable<Type> types = const [
    SdkRegisterUninstallTokenDto,
    _$SdkRegisterUninstallTokenDto,
  ];

  @override
  final String wireName = r'SdkRegisterUninstallTokenDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkRegisterUninstallTokenDto object, {
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
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType.nullable(JsonObject),
        ]),
      );
    }
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(Platform),
    );
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(AppUserUninstallTokenProvider),
    );
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkRegisterUninstallTokenDto object, {
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
    required SdkRegisterUninstallTokenDtoBuilder result,
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
        case r'metadata':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>;
          result.metadata.replace(valueDes);
          break;
        case r'platform':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Platform),
                  )
                  as Platform;
          result.platform = valueDes;
          break;
        case r'provider':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(
                      AppUserUninstallTokenProvider,
                    ),
                  )
                  as AppUserUninstallTokenProvider;
          result.provider = valueDes;
          break;
        case r'token':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.token = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkRegisterUninstallTokenDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkRegisterUninstallTokenDtoBuilder();
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
