//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_json_deep_link_dto.dart';
import 'package:attriax_api_client/src/model/sdk_install_referrer_result_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_open_response_dto.g.dart';

/// SdkV1OpenResponseDto
///
/// Properties:
/// * [acceptedAt]
/// * [deepLink]
/// * [installReferrer]
/// * [isFirstLaunch]
/// * [isNewUser]
/// * [requestVersion]
/// * [userId]
@BuiltValue()
abstract class SdkV1OpenResponseDto
    implements Built<SdkV1OpenResponseDto, SdkV1OpenResponseDtoBuilder> {
  @BuiltValueField(wireName: r'acceptedAt')
  DateTime get acceptedAt;

  @BuiltValueField(wireName: r'deepLink')
  SdkJsonDeepLinkDto? get deepLink;

  @BuiltValueField(wireName: r'installReferrer')
  SdkInstallReferrerResultDto? get installReferrer;

  @BuiltValueField(wireName: r'isFirstLaunch')
  bool get isFirstLaunch;

  @BuiltValueField(wireName: r'isNewUser')
  bool get isNewUser;

  @BuiltValueField(wireName: r'requestVersion')
  String get requestVersion;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  SdkV1OpenResponseDto._();

  factory SdkV1OpenResponseDto([void updates(SdkV1OpenResponseDtoBuilder b)]) =
      _$SdkV1OpenResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1OpenResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1OpenResponseDto> get serializer =>
      _$SdkV1OpenResponseDtoSerializer();
}

class _$SdkV1OpenResponseDtoSerializer
    implements PrimitiveSerializer<SdkV1OpenResponseDto> {
  @override
  final Iterable<Type> types = const [
    SdkV1OpenResponseDto,
    _$SdkV1OpenResponseDto,
  ];

  @override
  final String wireName = r'SdkV1OpenResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1OpenResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'acceptedAt';
    yield serializers.serialize(
      object.acceptedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.deepLink != null) {
      yield r'deepLink';
      yield serializers.serialize(
        object.deepLink,
        specifiedType: const FullType.nullable(SdkJsonDeepLinkDto),
      );
    }
    if (object.installReferrer != null) {
      yield r'installReferrer';
      yield serializers.serialize(
        object.installReferrer,
        specifiedType: const FullType.nullable(SdkInstallReferrerResultDto),
      );
    }
    yield r'isFirstLaunch';
    yield serializers.serialize(
      object.isFirstLaunch,
      specifiedType: const FullType(bool),
    );
    yield r'isNewUser';
    yield serializers.serialize(
      object.isNewUser,
      specifiedType: const FullType(bool),
    );
    yield r'requestVersion';
    yield serializers.serialize(
      object.requestVersion,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1OpenResponseDto object, {
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
    required SdkV1OpenResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'acceptedAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.acceptedAt = valueDes;
          break;
        case r'deepLink':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(SdkJsonDeepLinkDto),
                  )
                  as SdkJsonDeepLinkDto?;
          if (valueDes == null) continue;
          result.deepLink.replace(valueDes);
          break;
        case r'installReferrer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      SdkInstallReferrerResultDto,
                    ),
                  )
                  as SdkInstallReferrerResultDto?;
          if (valueDes == null) continue;
          result.installReferrer.replace(valueDes);
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
        case r'isNewUser':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.isNewUser = valueDes;
          break;
        case r'requestVersion':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.requestVersion = valueDes;
          break;
        case r'userId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1OpenResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1OpenResponseDtoBuilder();
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
