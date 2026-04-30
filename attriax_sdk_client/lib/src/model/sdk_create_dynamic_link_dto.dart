//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_create_dynamic_link_dto.g.dart';

/// SdkCreateDynamicLinkDto
///
/// Properties:
/// * [androidRedirect] 
/// * [appToken] 
/// * [data] 
/// * [destinationUrl] 
/// * [group] 
/// * [iosRedirect] 
/// * [name] 
/// * [prefix] 
/// * [previewDescription] 
/// * [previewImagePath] 
/// * [previewTitle] 
@BuiltValue()
abstract class SdkCreateDynamicLinkDto implements Built<SdkCreateDynamicLinkDto, SdkCreateDynamicLinkDtoBuilder> {
  @BuiltValueField(wireName: r'androidRedirect')
  bool? get androidRedirect;

  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?>? get data;

  @BuiltValueField(wireName: r'destinationUrl')
  String? get destinationUrl;

  @BuiltValueField(wireName: r'group')
  String? get group;

  @BuiltValueField(wireName: r'iosRedirect')
  bool? get iosRedirect;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'prefix')
  String? get prefix;

  @BuiltValueField(wireName: r'previewDescription')
  String? get previewDescription;

  @BuiltValueField(wireName: r'previewImagePath')
  String? get previewImagePath;

  @BuiltValueField(wireName: r'previewTitle')
  String? get previewTitle;

  SdkCreateDynamicLinkDto._();

  factory SdkCreateDynamicLinkDto([void updates(SdkCreateDynamicLinkDtoBuilder b)]) = _$SdkCreateDynamicLinkDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkCreateDynamicLinkDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkCreateDynamicLinkDto> get serializer => _$SdkCreateDynamicLinkDtoSerializer();
}

class _$SdkCreateDynamicLinkDtoSerializer implements PrimitiveSerializer<SdkCreateDynamicLinkDto> {
  @override
  final Iterable<Type> types = const [SdkCreateDynamicLinkDto, _$SdkCreateDynamicLinkDto];

  @override
  final String wireName = r'SdkCreateDynamicLinkDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkCreateDynamicLinkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.androidRedirect != null) {
      yield r'androidRedirect';
      yield serializers.serialize(
        object.androidRedirect,
        specifiedType: const FullType(bool),
      );
    }
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
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
        specifiedType: const FullType(String),
      );
    }
    if (object.group != null) {
      yield r'group';
      yield serializers.serialize(
        object.group,
        specifiedType: const FullType(String),
      );
    }
    if (object.iosRedirect != null) {
      yield r'iosRedirect';
      yield serializers.serialize(
        object.iosRedirect,
        specifiedType: const FullType(bool),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.prefix != null) {
      yield r'prefix';
      yield serializers.serialize(
        object.prefix,
        specifiedType: const FullType(String),
      );
    }
    if (object.previewDescription != null) {
      yield r'previewDescription';
      yield serializers.serialize(
        object.previewDescription,
        specifiedType: const FullType(String),
      );
    }
    if (object.previewImagePath != null) {
      yield r'previewImagePath';
      yield serializers.serialize(
        object.previewImagePath,
        specifiedType: const FullType(String),
      );
    }
    if (object.previewTitle != null) {
      yield r'previewTitle';
      yield serializers.serialize(
        object.previewTitle,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkCreateDynamicLinkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkCreateDynamicLinkDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'androidRedirect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.androidRedirect = valueDes;
          break;
        case r'appToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appToken = valueDes;
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
            specifiedType: const FullType(String),
          ) as String;
          result.destinationUrl = valueDes;
          break;
        case r'group':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.group = valueDes;
          break;
        case r'iosRedirect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.iosRedirect = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'prefix':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.prefix = valueDes;
          break;
        case r'previewDescription':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previewDescription = valueDes;
          break;
        case r'previewImagePath':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previewImagePath = valueDes;
          break;
        case r'previewTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previewTitle = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkCreateDynamicLinkDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkCreateDynamicLinkDtoBuilder();
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

