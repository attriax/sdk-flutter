//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/attribution_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_install_referrer_result_dto.g.dart';

/// SdkInstallReferrerResultDto
///
/// Properties:
/// * [adClickId] - Detected ad click identifier such as gclid or fbclid.
/// * [adNetwork] - Detected ad-network identifier inferred from the referrer.
/// * [attributionType] - Attribution source classification for the startup referrer payload.
/// * [campaign] - Resolved UTM campaign extracted from the install referrer.
/// * [content] - Resolved UTM content extracted from the install referrer.
/// * [deepLinkData] - Resolved deep-link payload data associated with the startup referrer.
/// * [deepLinkUri] - Full tracked short-link URI associated with the resolved deep link.
/// * [deepLinkUrl] - Deprecated alias for deepLinkUri kept for HTTP compatibility.
/// * [googlePlayInstantParam]
/// * [installBeginTimestampSeconds]
/// * [medium] - Resolved UTM medium extracted from the install referrer.
/// * [precision] - Confidence score from 0.0 to 1.0 for the returned interpretation.
/// * [rawPlatformInstallReferrer] - Raw platform startup referrer string cached by the SDK, when available.
/// * [referrerClickTimestampSeconds]
/// * [registeredAt]
/// * [source_] - Resolved UTM source extracted from the install referrer.
/// * [term] - Resolved UTM term extracted from the install referrer.
@BuiltValue()
abstract class SdkInstallReferrerResultDto
    implements
        Built<SdkInstallReferrerResultDto, SdkInstallReferrerResultDtoBuilder> {
  /// Detected ad click identifier such as gclid or fbclid.
  @BuiltValueField(wireName: r'adClickId')
  String? get adClickId;

  /// Detected ad-network identifier inferred from the referrer.
  @BuiltValueField(wireName: r'adNetwork')
  String? get adNetwork;

  /// Attribution source classification for the startup referrer payload.
  @BuiltValueField(wireName: r'attributionType')
  AttributionType get attributionType;
  // enum attributionTypeEnum {  referrer,  fingerprint,  external,  organic,  };

  /// Resolved UTM campaign extracted from the install referrer.
  @BuiltValueField(wireName: r'campaign')
  String? get campaign;

  /// Resolved UTM content extracted from the install referrer.
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// Resolved deep-link payload data associated with the startup referrer.
  @BuiltValueField(wireName: r'deepLinkData')
  BuiltMap<String, String>? get deepLinkData;

  /// Full tracked short-link URI associated with the resolved deep link.
  @BuiltValueField(wireName: r'deepLinkUri')
  String? get deepLinkUri;

  /// Deprecated alias for deepLinkUri kept for HTTP compatibility.
  @BuiltValueField(wireName: r'deepLinkUrl')
  String? get deepLinkUrl;

  @BuiltValueField(wireName: r'googlePlayInstantParam')
  bool? get googlePlayInstantParam;

  @BuiltValueField(wireName: r'installBeginTimestampSeconds')
  num? get installBeginTimestampSeconds;

  /// Resolved UTM medium extracted from the install referrer.
  @BuiltValueField(wireName: r'medium')
  String? get medium;

  /// Confidence score from 0.0 to 1.0 for the returned interpretation.
  @BuiltValueField(wireName: r'precision')
  num get precision;

  /// Raw platform startup referrer string cached by the SDK, when available.
  @BuiltValueField(wireName: r'rawPlatformInstallReferrer')
  String? get rawPlatformInstallReferrer;

  @BuiltValueField(wireName: r'referrerClickTimestampSeconds')
  num? get referrerClickTimestampSeconds;

  @BuiltValueField(wireName: r'registeredAt')
  DateTime? get registeredAt;

  /// Resolved UTM source extracted from the install referrer.
  @BuiltValueField(wireName: r'source')
  String? get source_;

  /// Resolved UTM term extracted from the install referrer.
  @BuiltValueField(wireName: r'term')
  String? get term;

  SdkInstallReferrerResultDto._();

  factory SdkInstallReferrerResultDto([
    void updates(SdkInstallReferrerResultDtoBuilder b),
  ]) = _$SdkInstallReferrerResultDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkInstallReferrerResultDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkInstallReferrerResultDto> get serializer =>
      _$SdkInstallReferrerResultDtoSerializer();
}

class _$SdkInstallReferrerResultDtoSerializer
    implements PrimitiveSerializer<SdkInstallReferrerResultDto> {
  @override
  final Iterable<Type> types = const [
    SdkInstallReferrerResultDto,
    _$SdkInstallReferrerResultDto,
  ];

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
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType(String),
        ]),
      );
    }
    if (object.deepLinkUri != null) {
      yield r'deepLinkUri';
      yield serializers.serialize(
        object.deepLinkUri,
        specifiedType: const FullType(String),
      );
    }
    if (object.deepLinkUrl != null) {
      yield r'deepLinkUrl';
      yield serializers.serialize(
        object.deepLinkUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.googlePlayInstantParam != null) {
      yield r'googlePlayInstantParam';
      yield serializers.serialize(
        object.googlePlayInstantParam,
        specifiedType: const FullType(bool),
      );
    }
    if (object.installBeginTimestampSeconds != null) {
      yield r'installBeginTimestampSeconds';
      yield serializers.serialize(
        object.installBeginTimestampSeconds,
        specifiedType: const FullType(num),
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
    if (object.referrerClickTimestampSeconds != null) {
      yield r'referrerClickTimestampSeconds';
      yield serializers.serialize(
        object.referrerClickTimestampSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.registeredAt != null) {
      yield r'registeredAt';
      yield serializers.serialize(
        object.registeredAt,
        specifiedType: const FullType(DateTime),
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
    required SdkInstallReferrerResultDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'adClickId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.adClickId = valueDes;
          break;
        case r'adNetwork':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.adNetwork = valueDes;
          break;
        case r'attributionType':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AttributionType),
                  )
                  as AttributionType;
          result.attributionType = valueDes;
          break;
        case r'campaign':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.campaign = valueDes;
          break;
        case r'content':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.content = valueDes;
          break;
        case r'deepLinkData':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType(String),
                    ]),
                  )
                  as BuiltMap<String, String>;
          result.deepLinkData.replace(valueDes);
          break;
        case r'deepLinkUri':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deepLinkUri = valueDes;
          break;
        case r'deepLinkUrl':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deepLinkUrl = valueDes;
          break;
        case r'googlePlayInstantParam':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.googlePlayInstantParam = valueDes;
          break;
        case r'installBeginTimestampSeconds':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.installBeginTimestampSeconds = valueDes;
          break;
        case r'medium':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.medium = valueDes;
          break;
        case r'precision':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.precision = valueDes;
          break;
        case r'rawPlatformInstallReferrer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.rawPlatformInstallReferrer = valueDes;
          break;
        case r'referrerClickTimestampSeconds':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.referrerClickTimestampSeconds = valueDes;
          break;
        case r'registeredAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.registeredAt = valueDes;
          break;
        case r'source':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.source_ = valueDes;
          break;
        case r'term':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
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
