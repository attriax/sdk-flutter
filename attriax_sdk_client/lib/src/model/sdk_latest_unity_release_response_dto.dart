//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/unity_release_summary_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_latest_unity_release_response_dto.g.dart';

/// SdkLatestUnityReleaseResponseDto
///
/// Properties:
/// * [release] 
@BuiltValue()
abstract class SdkLatestUnityReleaseResponseDto implements Built<SdkLatestUnityReleaseResponseDto, SdkLatestUnityReleaseResponseDtoBuilder> {
  @BuiltValueField(wireName: r'release')
  UnityReleaseSummaryDto? get release;

  SdkLatestUnityReleaseResponseDto._();

  factory SdkLatestUnityReleaseResponseDto([void updates(SdkLatestUnityReleaseResponseDtoBuilder b)]) = _$SdkLatestUnityReleaseResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkLatestUnityReleaseResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkLatestUnityReleaseResponseDto> get serializer => _$SdkLatestUnityReleaseResponseDtoSerializer();
}

class _$SdkLatestUnityReleaseResponseDtoSerializer implements PrimitiveSerializer<SdkLatestUnityReleaseResponseDto> {
  @override
  final Iterable<Type> types = const [SdkLatestUnityReleaseResponseDto, _$SdkLatestUnityReleaseResponseDto];

  @override
  final String wireName = r'SdkLatestUnityReleaseResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkLatestUnityReleaseResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.release != null) {
      yield r'release';
      yield serializers.serialize(
        object.release,
        specifiedType: const FullType.nullable(UnityReleaseSummaryDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkLatestUnityReleaseResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkLatestUnityReleaseResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'release':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(UnityReleaseSummaryDto),
          ) as UnityReleaseSummaryDto?;
          if (valueDes == null) continue;
          result.release.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkLatestUnityReleaseResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkLatestUnityReleaseResponseDtoBuilder();
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

