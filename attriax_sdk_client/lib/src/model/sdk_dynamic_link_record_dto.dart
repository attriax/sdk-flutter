//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_dynamic_link_record_dto.g.dart';

/// SdkDynamicLinkRecordDto
///
/// Properties:
/// * [androidRedirect] 
/// * [createdAt] 
/// * [data] 
/// * [destinationUrl] 
/// * [group] 
/// * [id] 
/// * [iosRedirect] 
/// * [name] 
/// * [path] 
/// * [prefix] 
/// * [previewDescription] 
/// * [previewImagePath] 
/// * [previewTitle] 
/// * [shortUrl] 
/// * [utmCampaign] 
/// * [utmContent] 
/// * [utmMedium] 
/// * [utmSource] 
/// * [utmTerm] 
@BuiltValue()
abstract class SdkDynamicLinkRecordDto implements Built<SdkDynamicLinkRecordDto, SdkDynamicLinkRecordDtoBuilder> {
  @BuiltValueField(wireName: r'androidRedirect')
  bool? get androidRedirect;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?>? get data;

  @BuiltValueField(wireName: r'destinationUrl')
  String? get destinationUrl;

  @BuiltValueField(wireName: r'group')
  String? get group;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'iosRedirect')
  bool? get iosRedirect;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'path')
  String get path;

  @BuiltValueField(wireName: r'prefix')
  String? get prefix;

  @BuiltValueField(wireName: r'previewDescription')
  String? get previewDescription;

  @BuiltValueField(wireName: r'previewImagePath')
  String? get previewImagePath;

  @BuiltValueField(wireName: r'previewTitle')
  String? get previewTitle;

  @BuiltValueField(wireName: r'shortUrl')
  String get shortUrl;

  @BuiltValueField(wireName: r'utmCampaign')
  String? get utmCampaign;

  @BuiltValueField(wireName: r'utmContent')
  String? get utmContent;

  @BuiltValueField(wireName: r'utmMedium')
  String? get utmMedium;

  @BuiltValueField(wireName: r'utmSource')
  String? get utmSource;

  @BuiltValueField(wireName: r'utmTerm')
  String? get utmTerm;

  SdkDynamicLinkRecordDto._();

  factory SdkDynamicLinkRecordDto([void updates(SdkDynamicLinkRecordDtoBuilder b)]) = _$SdkDynamicLinkRecordDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkDynamicLinkRecordDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkDynamicLinkRecordDto> get serializer => _$SdkDynamicLinkRecordDtoSerializer();
}

class _$SdkDynamicLinkRecordDtoSerializer implements PrimitiveSerializer<SdkDynamicLinkRecordDto> {
  @override
  final Iterable<Type> types = const [SdkDynamicLinkRecordDto, _$SdkDynamicLinkRecordDto];

  @override
  final String wireName = r'SdkDynamicLinkRecordDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkDynamicLinkRecordDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.androidRedirect != null) {
      yield r'androidRedirect';
      yield serializers.serialize(
        object.androidRedirect,
        specifiedType: const FullType.nullable(bool),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.destinationUrl != null) {
      yield r'destinationUrl';
      yield serializers.serialize(
        object.destinationUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.group != null) {
      yield r'group';
      yield serializers.serialize(
        object.group,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.iosRedirect != null) {
      yield r'iosRedirect';
      yield serializers.serialize(
        object.iosRedirect,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'path';
    yield serializers.serialize(
      object.path,
      specifiedType: const FullType(String),
    );
    if (object.prefix != null) {
      yield r'prefix';
      yield serializers.serialize(
        object.prefix,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.previewDescription != null) {
      yield r'previewDescription';
      yield serializers.serialize(
        object.previewDescription,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.previewImagePath != null) {
      yield r'previewImagePath';
      yield serializers.serialize(
        object.previewImagePath,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.previewTitle != null) {
      yield r'previewTitle';
      yield serializers.serialize(
        object.previewTitle,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'shortUrl';
    yield serializers.serialize(
      object.shortUrl,
      specifiedType: const FullType(String),
    );
    if (object.utmCampaign != null) {
      yield r'utmCampaign';
      yield serializers.serialize(
        object.utmCampaign,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.utmContent != null) {
      yield r'utmContent';
      yield serializers.serialize(
        object.utmContent,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.utmMedium != null) {
      yield r'utmMedium';
      yield serializers.serialize(
        object.utmMedium,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.utmSource != null) {
      yield r'utmSource';
      yield serializers.serialize(
        object.utmSource,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.utmTerm != null) {
      yield r'utmTerm';
      yield serializers.serialize(
        object.utmTerm,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkDynamicLinkRecordDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkDynamicLinkRecordDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'androidRedirect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.androidRedirect = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.data.replace(valueDes);
          break;
        case r'destinationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.destinationUrl = valueDes;
          break;
        case r'group':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.group = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'iosRedirect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.iosRedirect = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.path = valueDes;
          break;
        case r'prefix':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.prefix = valueDes;
          break;
        case r'previewDescription':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.previewDescription = valueDes;
          break;
        case r'previewImagePath':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.previewImagePath = valueDes;
          break;
        case r'previewTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.previewTitle = valueDes;
          break;
        case r'shortUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.shortUrl = valueDes;
          break;
        case r'utmCampaign':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.utmCampaign = valueDes;
          break;
        case r'utmContent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.utmContent = valueDes;
          break;
        case r'utmMedium':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.utmMedium = valueDes;
          break;
        case r'utmSource':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.utmSource = valueDes;
          break;
        case r'utmTerm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.utmTerm = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkDynamicLinkRecordDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkDynamicLinkRecordDtoBuilder();
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

