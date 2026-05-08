//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:attriax_api_client/src/model/app_version_context_dto.dart';
import 'package:attriax_api_client/src/model/sdk_version_context_dto.dart';
import 'package:attriax_api_client/src/model/device_context_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_open_dto.g.dart';

/// SdkV1OpenDto
///
/// Properties:
/// * [app]
/// * [appToken]
/// * [device]
/// * [deviceId]
/// * [deviceIdSource]
/// * [installReferrer]
/// * [isFirstLaunch]
/// * [platform]
/// * [sdk]
/// * [sessionId]
/// * [sessionStartedAt]
@BuiltValue()
abstract class SdkV1OpenDto
    implements Built<SdkV1OpenDto, SdkV1OpenDtoBuilder> {
  @BuiltValueField(wireName: r'app')
  AppVersionContextDto get app;

  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'device')
  DeviceContextDto get device;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'deviceIdSource')
  String? get deviceIdSource;

  @BuiltValueField(wireName: r'installReferrer')
  String? get installReferrer;

  @BuiltValueField(wireName: r'isFirstLaunch')
  bool? get isFirstLaunch;

  @BuiltValueField(wireName: r'platform')
  Platform get platform;
  // enum platformEnum {  ios,  android,  unity_editor,  windows,  macos,  linux,  web,  unknown,  };

  @BuiltValueField(wireName: r'sdk')
  SdkVersionContextDto get sdk;

  @BuiltValueField(wireName: r'sessionId')
  String? get sessionId;

  @BuiltValueField(wireName: r'sessionStartedAt')
  DateTime? get sessionStartedAt;

  SdkV1OpenDto._();

  factory SdkV1OpenDto([void updates(SdkV1OpenDtoBuilder b)]) = _$SdkV1OpenDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1OpenDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1OpenDto> get serializer => _$SdkV1OpenDtoSerializer();
}

class _$SdkV1OpenDtoSerializer implements PrimitiveSerializer<SdkV1OpenDto> {
  @override
  final Iterable<Type> types = const [SdkV1OpenDto, _$SdkV1OpenDto];

  @override
  final String wireName = r'SdkV1OpenDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1OpenDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'app';
    yield serializers.serialize(
      object.app,
      specifiedType: const FullType(AppVersionContextDto),
    );
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
    );
    yield r'device';
    yield serializers.serialize(
      object.device,
      specifiedType: const FullType(DeviceContextDto),
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
    if (object.installReferrer != null) {
      yield r'installReferrer';
      yield serializers.serialize(
        object.installReferrer,
        specifiedType: const FullType(String),
      );
    }
    if (object.isFirstLaunch != null) {
      yield r'isFirstLaunch';
      yield serializers.serialize(
        object.isFirstLaunch,
        specifiedType: const FullType(bool),
      );
    }
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(Platform),
    );
    yield r'sdk';
    yield serializers.serialize(
      object.sdk,
      specifiedType: const FullType(SdkVersionContextDto),
    );
    if (object.sessionId != null) {
      yield r'sessionId';
      yield serializers.serialize(
        object.sessionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.sessionStartedAt != null) {
      yield r'sessionStartedAt';
      yield serializers.serialize(
        object.sessionStartedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1OpenDto object, {
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
    required SdkV1OpenDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AppVersionContextDto),
                  )
                  as AppVersionContextDto;
          result.app.replace(valueDes);
          break;
        case r'appToken':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.appToken = valueDes;
          break;
        case r'device':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DeviceContextDto),
                  )
                  as DeviceContextDto;
          result.device.replace(valueDes);
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
        case r'installReferrer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.installReferrer = valueDes;
          break;
        case r'isFirstLaunch':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.isFirstLaunch = valueDes;
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
        case r'sdk':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(SdkVersionContextDto),
                  )
                  as SdkVersionContextDto;
          result.sdk.replace(valueDes);
          break;
        case r'sessionId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.sessionId = valueDes;
          break;
        case r'sessionStartedAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.sessionStartedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1OpenDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1OpenDtoBuilder();
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
