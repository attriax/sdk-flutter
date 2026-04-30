//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/sdk_release_platform.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'unity_release_summary_dto.g.dart';

/// UnityReleaseSummaryDto
///
/// Properties:
/// * [createdAt] 
/// * [downloadUrl] 
/// * [id] 
/// * [isLatest] 
/// * [mimeType] 
/// * [originalFilename] 
/// * [platform] 
/// * [releaseNotes] 
/// * [sizeBytes] 
/// * [updatedAt] 
/// * [version] 
@BuiltValue()
abstract class UnityReleaseSummaryDto implements Built<UnityReleaseSummaryDto, UnityReleaseSummaryDtoBuilder> {
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'downloadUrl')
  String get downloadUrl;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'isLatest')
  bool get isLatest;

  @BuiltValueField(wireName: r'mimeType')
  String get mimeType;

  @BuiltValueField(wireName: r'originalFilename')
  String get originalFilename;

  @BuiltValueField(wireName: r'platform')
  SdkReleasePlatform get platform;
  // enum platformEnum {  unity,  };

  @BuiltValueField(wireName: r'releaseNotes')
  String? get releaseNotes;

  @BuiltValueField(wireName: r'sizeBytes')
  num get sizeBytes;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  String get version;

  UnityReleaseSummaryDto._();

  factory UnityReleaseSummaryDto([void updates(UnityReleaseSummaryDtoBuilder b)]) = _$UnityReleaseSummaryDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UnityReleaseSummaryDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UnityReleaseSummaryDto> get serializer => _$UnityReleaseSummaryDtoSerializer();
}

class _$UnityReleaseSummaryDtoSerializer implements PrimitiveSerializer<UnityReleaseSummaryDto> {
  @override
  final Iterable<Type> types = const [UnityReleaseSummaryDto, _$UnityReleaseSummaryDto];

  @override
  final String wireName = r'UnityReleaseSummaryDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UnityReleaseSummaryDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'downloadUrl';
    yield serializers.serialize(
      object.downloadUrl,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'isLatest';
    yield serializers.serialize(
      object.isLatest,
      specifiedType: const FullType(bool),
    );
    yield r'mimeType';
    yield serializers.serialize(
      object.mimeType,
      specifiedType: const FullType(String),
    );
    yield r'originalFilename';
    yield serializers.serialize(
      object.originalFilename,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(SdkReleasePlatform),
    );
    if (object.releaseNotes != null) {
      yield r'releaseNotes';
      yield serializers.serialize(
        object.releaseNotes,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'sizeBytes';
    yield serializers.serialize(
      object.sizeBytes,
      specifiedType: const FullType(num),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UnityReleaseSummaryDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UnityReleaseSummaryDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'downloadUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.downloadUrl = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'isLatest':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isLatest = valueDes;
          break;
        case r'mimeType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mimeType = valueDes;
          break;
        case r'originalFilename':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.originalFilename = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkReleasePlatform),
          ) as SdkReleasePlatform;
          result.platform = valueDes;
          break;
        case r'releaseNotes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.releaseNotes = valueDes;
          break;
        case r'sizeBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sizeBytes = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UnityReleaseSummaryDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UnityReleaseSummaryDtoBuilder();
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

