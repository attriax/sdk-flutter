//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/platform.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_deep_link_resolve_dto.g.dart';

/// SdkV1DeepLinkResolveDto
///
/// Properties:
/// * [appToken] 
/// * [deviceId] 
/// * [deviceIdSource] 
/// * [isFirstLaunch] 
/// * [linkPath] 
/// * [metadata] 
/// * [platform] 
/// * [rawUrl] 
/// * [source_] 
@BuiltValue()
abstract class SdkV1DeepLinkResolveDto implements Built<SdkV1DeepLinkResolveDto, SdkV1DeepLinkResolveDtoBuilder> {
  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'deviceIdSource')
  String? get deviceIdSource;

  @BuiltValueField(wireName: r'isFirstLaunch')
  bool? get isFirstLaunch;

  @BuiltValueField(wireName: r'linkPath')
  String? get linkPath;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  @BuiltValueField(wireName: r'platform')
  Platform get platform;
  // enum platformEnum {  ios,  android,  unity_editor,  windows,  macos,  linux,  web,  unknown,  };

  @BuiltValueField(wireName: r'rawUrl')
  String? get rawUrl;

  @BuiltValueField(wireName: r'source')
  String? get source_;

  SdkV1DeepLinkResolveDto._();

  factory SdkV1DeepLinkResolveDto([void updates(SdkV1DeepLinkResolveDtoBuilder b)]) = _$SdkV1DeepLinkResolveDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1DeepLinkResolveDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1DeepLinkResolveDto> get serializer => _$SdkV1DeepLinkResolveDtoSerializer();
}

class _$SdkV1DeepLinkResolveDtoSerializer implements PrimitiveSerializer<SdkV1DeepLinkResolveDto> {
  @override
  final Iterable<Type> types = const [SdkV1DeepLinkResolveDto, _$SdkV1DeepLinkResolveDto];

  @override
  final String wireName = r'SdkV1DeepLinkResolveDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1DeepLinkResolveDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
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
    if (object.isFirstLaunch != null) {
      yield r'isFirstLaunch';
      yield serializers.serialize(
        object.isFirstLaunch,
        specifiedType: const FullType(bool),
      );
    }
    if (object.linkPath != null) {
      yield r'linkPath';
      yield serializers.serialize(
        object.linkPath,
        specifiedType: const FullType(String),
      );
    }
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(Platform),
    );
    if (object.rawUrl != null) {
      yield r'rawUrl';
      yield serializers.serialize(
        object.rawUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1DeepLinkResolveDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkV1DeepLinkResolveDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appToken = valueDes;
          break;
        case r'deviceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'deviceIdSource':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceIdSource = valueDes;
          break;
        case r'isFirstLaunch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isFirstLaunch = valueDes;
          break;
        case r'linkPath':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.linkPath = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.metadata.replace(valueDes);
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Platform),
          ) as Platform;
          result.platform = valueDes;
          break;
        case r'rawUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rawUrl = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.source_ = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1DeepLinkResolveDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1DeepLinkResolveDtoBuilder();
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

