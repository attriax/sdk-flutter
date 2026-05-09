//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:attriax_api_client/src/model/sdk_session_lifecycle_kind.dart';
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_session_dto.g.dart';

/// SdkSessionDto
///
/// Properties:
/// * [appBuildNumber]
/// * [appPackageName]
/// * [appToken]
/// * [appVersion]
/// * [clientOccurredAt]
/// * [deviceId]
/// * [deviceIdSource]
/// * [isFirstLaunch]
/// * [kind]
/// * [locale]
/// * [metadata]
/// * [platform]
/// * [sdkApiVersion]
/// * [sdkPackageVersion]
/// * [sessionId]
/// * [sessionRelativeTimeMs] - Milliseconds since the session started.
@BuiltValue()
abstract class SdkSessionDto
    implements Built<SdkSessionDto, SdkSessionDtoBuilder> {
  @BuiltValueField(wireName: r'appBuildNumber')
  String? get appBuildNumber;

  @BuiltValueField(wireName: r'appPackageName')
  String? get appPackageName;

  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'appVersion')
  String? get appVersion;

  @BuiltValueField(wireName: r'clientOccurredAt')
  DateTime? get clientOccurredAt;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'deviceIdSource')
  String? get deviceIdSource;

  @BuiltValueField(wireName: r'isFirstLaunch')
  bool? get isFirstLaunch;

  @BuiltValueField(wireName: r'kind')
  SdkSessionLifecycleKind get kind;
  // enum kindEnum {  start,  heartbeat,  pause,  resume,  end,  };

  @BuiltValueField(wireName: r'locale')
  String? get locale;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  @BuiltValueField(wireName: r'platform')
  Platform? get platform;
  // enum platformEnum {  ios,  android,  unity_editor,  windows,  macos,  linux,  web,  unknown,  };

  @BuiltValueField(wireName: r'sdkApiVersion')
  String? get sdkApiVersion;

  @BuiltValueField(wireName: r'sdkPackageVersion')
  String? get sdkPackageVersion;

  @BuiltValueField(wireName: r'sessionId')
  String get sessionId;

  /// Milliseconds since the session started.
  @BuiltValueField(wireName: r'sessionRelativeTimeMs')
  num? get sessionRelativeTimeMs;

  SdkSessionDto._();

  factory SdkSessionDto([void updates(SdkSessionDtoBuilder b)]) =
      _$SdkSessionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkSessionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkSessionDto> get serializer =>
      _$SdkSessionDtoSerializer();
}

class _$SdkSessionDtoSerializer implements PrimitiveSerializer<SdkSessionDto> {
  @override
  final Iterable<Type> types = const [SdkSessionDto, _$SdkSessionDto];

  @override
  final String wireName = r'SdkSessionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appBuildNumber != null) {
      yield r'appBuildNumber';
      yield serializers.serialize(
        object.appBuildNumber,
        specifiedType: const FullType(String),
      );
    }
    if (object.appPackageName != null) {
      yield r'appPackageName';
      yield serializers.serialize(
        object.appPackageName,
        specifiedType: const FullType(String),
      );
    }
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
    );
    if (object.appVersion != null) {
      yield r'appVersion';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.clientOccurredAt != null) {
      yield r'clientOccurredAt';
      yield serializers.serialize(
        object.clientOccurredAt,
        specifiedType: const FullType(DateTime),
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
    if (object.isFirstLaunch != null) {
      yield r'isFirstLaunch';
      yield serializers.serialize(
        object.isFirstLaunch,
        specifiedType: const FullType(bool),
      );
    }
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(SdkSessionLifecycleKind),
    );
    if (object.locale != null) {
      yield r'locale';
      yield serializers.serialize(
        object.locale,
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
    if (object.platform != null) {
      yield r'platform';
      yield serializers.serialize(
        object.platform,
        specifiedType: const FullType(Platform),
      );
    }
    if (object.sdkApiVersion != null) {
      yield r'sdkApiVersion';
      yield serializers.serialize(
        object.sdkApiVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.sdkPackageVersion != null) {
      yield r'sdkPackageVersion';
      yield serializers.serialize(
        object.sdkPackageVersion,
        specifiedType: const FullType(String),
      );
    }
    yield r'sessionId';
    yield serializers.serialize(
      object.sessionId,
      specifiedType: const FullType(String),
    );
    if (object.sessionRelativeTimeMs != null) {
      yield r'sessionRelativeTimeMs';
      yield serializers.serialize(
        object.sessionRelativeTimeMs,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkSessionDto object, {
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
    required SdkSessionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appBuildNumber':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.appBuildNumber = valueDes;
          break;
        case r'appPackageName':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.appPackageName = valueDes;
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
        case r'appVersion':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.appVersion = valueDes;
          break;
        case r'clientOccurredAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.clientOccurredAt = valueDes;
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
        case r'isFirstLaunch':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.isFirstLaunch = valueDes;
          break;
        case r'kind':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(SdkSessionLifecycleKind),
                  )
                  as SdkSessionLifecycleKind;
          result.kind = valueDes;
          break;
        case r'locale':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.locale = valueDes;
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
        case r'sdkApiVersion':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.sdkApiVersion = valueDes;
          break;
        case r'sdkPackageVersion':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.sdkPackageVersion = valueDes;
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
        case r'sessionRelativeTimeMs':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.sessionRelativeTimeMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkSessionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkSessionDtoBuilder();
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
