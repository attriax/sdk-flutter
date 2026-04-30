//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/sdk_json_deep_link_dto.dart';
import 'package:attriax_sdk_client/src/model/deep_link_resolution_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_deep_link_resolve_response_dto.g.dart';

/// SdkV1DeepLinkResolveResponseDto
///
/// Properties:
/// * [acceptedAt] 
/// * [consumedAt] 
/// * [deepLink] 
/// * [isFirstLaunch] 
/// * [matched] 
/// * [reason] 
/// * [requestVersion] 
/// * [status] 
@BuiltValue()
abstract class SdkV1DeepLinkResolveResponseDto implements Built<SdkV1DeepLinkResolveResponseDto, SdkV1DeepLinkResolveResponseDtoBuilder> {
  @BuiltValueField(wireName: r'acceptedAt')
  DateTime get acceptedAt;

  @BuiltValueField(wireName: r'consumedAt')
  DateTime? get consumedAt;

  @BuiltValueField(wireName: r'deepLink')
  SdkJsonDeepLinkDto? get deepLink;

  @BuiltValueField(wireName: r'isFirstLaunch')
  bool get isFirstLaunch;

  @BuiltValueField(wireName: r'matched')
  bool get matched;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'requestVersion')
  String get requestVersion;

  @BuiltValueField(wireName: r'status')
  DeepLinkResolutionStatus get status;
  // enum statusEnum {  matched,  unmatched,  invalid,  };

  SdkV1DeepLinkResolveResponseDto._();

  factory SdkV1DeepLinkResolveResponseDto([void updates(SdkV1DeepLinkResolveResponseDtoBuilder b)]) = _$SdkV1DeepLinkResolveResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1DeepLinkResolveResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1DeepLinkResolveResponseDto> get serializer => _$SdkV1DeepLinkResolveResponseDtoSerializer();
}

class _$SdkV1DeepLinkResolveResponseDtoSerializer implements PrimitiveSerializer<SdkV1DeepLinkResolveResponseDto> {
  @override
  final Iterable<Type> types = const [SdkV1DeepLinkResolveResponseDto, _$SdkV1DeepLinkResolveResponseDto];

  @override
  final String wireName = r'SdkV1DeepLinkResolveResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1DeepLinkResolveResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'acceptedAt';
    yield serializers.serialize(
      object.acceptedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.consumedAt != null) {
      yield r'consumedAt';
      yield serializers.serialize(
        object.consumedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.deepLink != null) {
      yield r'deepLink';
      yield serializers.serialize(
        object.deepLink,
        specifiedType: const FullType.nullable(SdkJsonDeepLinkDto),
      );
    }
    yield r'isFirstLaunch';
    yield serializers.serialize(
      object.isFirstLaunch,
      specifiedType: const FullType(bool),
    );
    yield r'matched';
    yield serializers.serialize(
      object.matched,
      specifiedType: const FullType(bool),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'requestVersion';
    yield serializers.serialize(
      object.requestVersion,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DeepLinkResolutionStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1DeepLinkResolveResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkV1DeepLinkResolveResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'acceptedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.acceptedAt = valueDes;
          break;
        case r'consumedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.consumedAt = valueDes;
          break;
        case r'deepLink':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(SdkJsonDeepLinkDto),
          ) as SdkJsonDeepLinkDto?;
          if (valueDes == null) continue;
          result.deepLink.replace(valueDes);
          break;
        case r'isFirstLaunch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isFirstLaunch = valueDes;
          break;
        case r'matched':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.matched = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'requestVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestVersion = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeepLinkResolutionStatus),
          ) as DeepLinkResolutionStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1DeepLinkResolveResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1DeepLinkResolveResponseDtoBuilder();
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

