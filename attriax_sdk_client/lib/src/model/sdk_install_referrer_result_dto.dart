//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:attriax_sdk_client/src/model/attribution_type.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_install_referrer_result_dto.g.dart';

/// SdkInstallReferrerResultDto
///
/// Properties:
/// * [adClickId] 
/// * [adNetwork] 
/// * [attributionType] 
/// * [campaign] 
/// * [content] 
/// * [deepLinkData] 
/// * [medium] 
/// * [precision] 
/// * [rawPlatformInstallReferrer] 
/// * [source_] 
/// * [term] 
@BuiltValue()
abstract class SdkInstallReferrerResultDto implements Built<SdkInstallReferrerResultDto, SdkInstallReferrerResultDtoBuilder> {
  @BuiltValueField(wireName: r'adClickId')
  String? get adClickId;

  @BuiltValueField(wireName: r'adNetwork')
  String? get adNetwork;

  @BuiltValueField(wireName: r'attributionType')
  AttributionType get attributionType;
  // enum attributionTypeEnum {  referrer,  fingerprint,  external,  organic,  };

  @BuiltValueField(wireName: r'campaign')
  String? get campaign;

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'deepLinkData')
  BuiltMap<String, JsonObject?>? get deepLinkData;

  @BuiltValueField(wireName: r'medium')
  String? get medium;

  @BuiltValueField(wireName: r'precision')
  num get precision;

  @BuiltValueField(wireName: r'rawPlatformInstallReferrer')
  String? get rawPlatformInstallReferrer;

  @BuiltValueField(wireName: r'source')
  String? get source_;

  @BuiltValueField(wireName: r'term')
  String? get term;

  SdkInstallReferrerResultDto._();

  factory SdkInstallReferrerResultDto([void updates(SdkInstallReferrerResultDtoBuilder b)]) = _$SdkInstallReferrerResultDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkInstallReferrerResultDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkInstallReferrerResultDto> get serializer => _$SdkInstallReferrerResultDtoSerializer();
}

class _$SdkInstallReferrerResultDtoSerializer implements PrimitiveSerializer<SdkInstallReferrerResultDto> {
  @override
  final Iterable<Type> types = const [SdkInstallReferrerResultDto, _$SdkInstallReferrerResultDto];

  @override
  final String wireName = r'SdkInstallReferrerResultDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkInstallReferrerResultDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.adClickId != null) {
      yield r'adClickId';
      yield serializers.serialize(
        object.adClickId,
        specifiedType: const FullType(String),
      );
    }
    if (object.adNetwork != null) {
      yield r'adNetwork';
      yield serializers.serialize(
        object.adNetwork,
        specifiedType: const FullType(String),
      );
    }
    yield r'attributionType';
    yield serializers.serialize(
      object.attributionType,
      specifiedType: const FullType(AttributionType),
    );
    if (object.campaign != null) {
      yield r'campaign';
      yield serializers.serialize(
        object.campaign,
        specifiedType: const FullType(String),
      );
    }
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.deepLinkData != null) {
      yield r'deepLinkData';
      yield serializers.serialize(
        object.deepLinkData,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.medium != null) {
      yield r'medium';
      yield serializers.serialize(
        object.medium,
        specifiedType: const FullType(String),
      );
    }
    yield r'precision';
    yield serializers.serialize(
      object.precision,
      specifiedType: const FullType(num),
    );
    if (object.rawPlatformInstallReferrer != null) {
      yield r'rawPlatformInstallReferrer';
      yield serializers.serialize(
        object.rawPlatformInstallReferrer,
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
    if (object.term != null) {
      yield r'term';
      yield serializers.serialize(
        object.term,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkInstallReferrerResultDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkInstallReferrerResultDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'adClickId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.adClickId = valueDes;
          break;
        case r'adNetwork':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.adNetwork = valueDes;
          break;
        case r'attributionType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AttributionType),
          ) as AttributionType;
          result.attributionType = valueDes;
          break;
        case r'campaign':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.campaign = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'deepLinkData':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.deepLinkData.replace(valueDes);
          break;
        case r'medium':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.medium = valueDes;
          break;
        case r'precision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.precision = valueDes;
          break;
        case r'rawPlatformInstallReferrer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rawPlatformInstallReferrer = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.source_ = valueDes;
          break;
        case r'term':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.term = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkInstallReferrerResultDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkInstallReferrerResultDtoBuilder();
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

