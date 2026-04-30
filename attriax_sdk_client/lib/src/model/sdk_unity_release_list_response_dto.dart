//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:attriax_sdk_client/src/model/unity_release_summary_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_unity_release_list_response_dto.g.dart';

/// SdkUnityReleaseListResponseDto
///
/// Properties:
/// * [releases] 
@BuiltValue()
abstract class SdkUnityReleaseListResponseDto implements Built<SdkUnityReleaseListResponseDto, SdkUnityReleaseListResponseDtoBuilder> {
  @BuiltValueField(wireName: r'releases')
  BuiltList<UnityReleaseSummaryDto> get releases;

  SdkUnityReleaseListResponseDto._();

  factory SdkUnityReleaseListResponseDto([void updates(SdkUnityReleaseListResponseDtoBuilder b)]) = _$SdkUnityReleaseListResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkUnityReleaseListResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkUnityReleaseListResponseDto> get serializer => _$SdkUnityReleaseListResponseDtoSerializer();
}

class _$SdkUnityReleaseListResponseDtoSerializer implements PrimitiveSerializer<SdkUnityReleaseListResponseDto> {
  @override
  final Iterable<Type> types = const [SdkUnityReleaseListResponseDto, _$SdkUnityReleaseListResponseDto];

  @override
  final String wireName = r'SdkUnityReleaseListResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkUnityReleaseListResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'releases';
    yield serializers.serialize(
      object.releases,
      specifiedType: const FullType(BuiltList, [FullType(UnityReleaseSummaryDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkUnityReleaseListResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkUnityReleaseListResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'releases':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UnityReleaseSummaryDto)]),
          ) as BuiltList<UnityReleaseSummaryDto>;
          result.releases.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkUnityReleaseListResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkUnityReleaseListResponseDtoBuilder();
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

