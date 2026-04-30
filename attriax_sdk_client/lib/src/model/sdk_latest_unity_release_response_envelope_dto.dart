//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/sdk_latest_unity_release_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_latest_unity_release_response_envelope_dto.g.dart';

/// SdkLatestUnityReleaseResponseEnvelopeDto
///
/// Properties:
/// * [data] 
/// * [success] 
/// * [timestamp] 
@BuiltValue()
abstract class SdkLatestUnityReleaseResponseEnvelopeDto implements Built<SdkLatestUnityReleaseResponseEnvelopeDto, SdkLatestUnityReleaseResponseEnvelopeDtoBuilder> {
  @BuiltValueField(wireName: r'data')
  SdkLatestUnityReleaseResponseDto get data;

  @BuiltValueField(wireName: r'success')
  bool get success;

  @BuiltValueField(wireName: r'timestamp')
  DateTime get timestamp;

  SdkLatestUnityReleaseResponseEnvelopeDto._();

  factory SdkLatestUnityReleaseResponseEnvelopeDto([void updates(SdkLatestUnityReleaseResponseEnvelopeDtoBuilder b)]) = _$SdkLatestUnityReleaseResponseEnvelopeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkLatestUnityReleaseResponseEnvelopeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkLatestUnityReleaseResponseEnvelopeDto> get serializer => _$SdkLatestUnityReleaseResponseEnvelopeDtoSerializer();
}

class _$SdkLatestUnityReleaseResponseEnvelopeDtoSerializer implements PrimitiveSerializer<SdkLatestUnityReleaseResponseEnvelopeDto> {
  @override
  final Iterable<Type> types = const [SdkLatestUnityReleaseResponseEnvelopeDto, _$SdkLatestUnityReleaseResponseEnvelopeDto];

  @override
  final String wireName = r'SdkLatestUnityReleaseResponseEnvelopeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkLatestUnityReleaseResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SdkLatestUnityReleaseResponseDto),
    );
    yield r'success';
    yield serializers.serialize(
      object.success,
      specifiedType: const FullType(bool),
    );
    yield r'timestamp';
    yield serializers.serialize(
      object.timestamp,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkLatestUnityReleaseResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkLatestUnityReleaseResponseEnvelopeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkLatestUnityReleaseResponseDto),
          ) as SdkLatestUnityReleaseResponseDto;
          result.data.replace(valueDes);
          break;
        case r'success':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.success = valueDes;
          break;
        case r'timestamp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.timestamp = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkLatestUnityReleaseResponseEnvelopeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkLatestUnityReleaseResponseEnvelopeDtoBuilder();
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

