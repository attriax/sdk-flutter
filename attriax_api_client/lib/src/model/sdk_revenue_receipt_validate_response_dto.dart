//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_revenue_receipt_validate_response_dto.g.dart';

/// SdkRevenueReceiptValidateResponseDto
///
/// Properties:
/// * [acceptedAt]
/// * [environment]
/// * [expiresAt]
/// * [failureReason]
/// * [originalTransactionId]
/// * [productId]
/// * [provider]
/// * [providerResult]
/// * [publicReceipt]
/// * [requestVersion]
/// * [status]
/// * [transactionId]
/// * [validationId]
@BuiltValue()
abstract class SdkRevenueReceiptValidateResponseDto
    implements
        Built<
          SdkRevenueReceiptValidateResponseDto,
          SdkRevenueReceiptValidateResponseDtoBuilder
        > {
  @BuiltValueField(wireName: r'acceptedAt')
  DateTime get acceptedAt;

  @BuiltValueField(wireName: r'environment')
  String? get environment;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime? get expiresAt;

  @BuiltValueField(wireName: r'failureReason')
  String? get failureReason;

  @BuiltValueField(wireName: r'originalTransactionId')
  String? get originalTransactionId;

  @BuiltValueField(wireName: r'productId')
  String? get productId;

  @BuiltValueField(wireName: r'provider')
  String? get provider;

  @BuiltValueField(wireName: r'providerResult')
  BuiltMap<String, JsonObject?>? get providerResult;

  @BuiltValueField(wireName: r'publicReceipt')
  BuiltMap<String, JsonObject?> get publicReceipt;

  @BuiltValueField(wireName: r'requestVersion')
  String get requestVersion;

  @BuiltValueField(wireName: r'status')
  SdkRevenueReceiptValidateResponseDtoStatusEnum get status;
  // enum statusEnum {  verified,  rejected,  pending,  unconfigured,  provider_error,  passthrough,  };

  @BuiltValueField(wireName: r'transactionId')
  String? get transactionId;

  @BuiltValueField(wireName: r'validationId')
  String get validationId;

  SdkRevenueReceiptValidateResponseDto._();

  factory SdkRevenueReceiptValidateResponseDto([
    void updates(SdkRevenueReceiptValidateResponseDtoBuilder b),
  ]) = _$SdkRevenueReceiptValidateResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkRevenueReceiptValidateResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkRevenueReceiptValidateResponseDto> get serializer =>
      _$SdkRevenueReceiptValidateResponseDtoSerializer();
}

class _$SdkRevenueReceiptValidateResponseDtoSerializer
    implements PrimitiveSerializer<SdkRevenueReceiptValidateResponseDto> {
  @override
  final Iterable<Type> types = const [
    SdkRevenueReceiptValidateResponseDto,
    _$SdkRevenueReceiptValidateResponseDto,
  ];

  @override
  final String wireName = r'SdkRevenueReceiptValidateResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkRevenueReceiptValidateResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'acceptedAt';
    yield serializers.serialize(
      object.acceptedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.environment != null) {
      yield r'environment';
      yield serializers.serialize(
        object.environment,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.expiresAt != null) {
      yield r'expiresAt';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.failureReason != null) {
      yield r'failureReason';
      yield serializers.serialize(
        object.failureReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.originalTransactionId != null) {
      yield r'originalTransactionId';
      yield serializers.serialize(
        object.originalTransactionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.productId != null) {
      yield r'productId';
      yield serializers.serialize(
        object.productId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.providerResult != null) {
      yield r'providerResult';
      yield serializers.serialize(
        object.providerResult,
        specifiedType: const FullType.nullable(BuiltMap, [
          FullType(String),
          FullType.nullable(JsonObject),
        ]),
      );
    }
    yield r'publicReceipt';
    yield serializers.serialize(
      object.publicReceipt,
      specifiedType: const FullType(BuiltMap, [
        FullType(String),
        FullType.nullable(JsonObject),
      ]),
    );
    yield r'requestVersion';
    yield serializers.serialize(
      object.requestVersion,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(
        SdkRevenueReceiptValidateResponseDtoStatusEnum,
      ),
    );
    if (object.transactionId != null) {
      yield r'transactionId';
      yield serializers.serialize(
        object.transactionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'validationId';
    yield serializers.serialize(
      object.validationId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkRevenueReceiptValidateResponseDto object, {
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
    required SdkRevenueReceiptValidateResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'acceptedAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.acceptedAt = valueDes;
          break;
        case r'environment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.environment = valueDes;
          break;
        case r'expiresAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        case r'failureReason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.failureReason = valueDes;
          break;
        case r'originalTransactionId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.originalTransactionId = valueDes;
          break;
        case r'productId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productId = valueDes;
          break;
        case r'provider':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.provider = valueDes;
          break;
        case r'providerResult':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.providerResult.replace(valueDes);
          break;
        case r'publicReceipt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>;
          result.publicReceipt.replace(valueDes);
          break;
        case r'requestVersion':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.requestVersion = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(
                      SdkRevenueReceiptValidateResponseDtoStatusEnum,
                    ),
                  )
                  as SdkRevenueReceiptValidateResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'transactionId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.transactionId = valueDes;
          break;
        case r'validationId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.validationId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkRevenueReceiptValidateResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkRevenueReceiptValidateResponseDtoBuilder();
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

class SdkRevenueReceiptValidateResponseDtoStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'verified')
  static const SdkRevenueReceiptValidateResponseDtoStatusEnum verified =
      _$sdkRevenueReceiptValidateResponseDtoStatusEnum_verified;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const SdkRevenueReceiptValidateResponseDtoStatusEnum rejected =
      _$sdkRevenueReceiptValidateResponseDtoStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'pending')
  static const SdkRevenueReceiptValidateResponseDtoStatusEnum pending =
      _$sdkRevenueReceiptValidateResponseDtoStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'unconfigured')
  static const SdkRevenueReceiptValidateResponseDtoStatusEnum unconfigured =
      _$sdkRevenueReceiptValidateResponseDtoStatusEnum_unconfigured;
  @BuiltValueEnumConst(wireName: r'provider_error')
  static const SdkRevenueReceiptValidateResponseDtoStatusEnum providerError =
      _$sdkRevenueReceiptValidateResponseDtoStatusEnum_providerError;
  @BuiltValueEnumConst(wireName: r'passthrough')
  static const SdkRevenueReceiptValidateResponseDtoStatusEnum passthrough =
      _$sdkRevenueReceiptValidateResponseDtoStatusEnum_passthrough;

  static Serializer<SdkRevenueReceiptValidateResponseDtoStatusEnum>
  get serializer => _$sdkRevenueReceiptValidateResponseDtoStatusEnumSerializer;

  const SdkRevenueReceiptValidateResponseDtoStatusEnum._(String name)
    : super(name);

  static BuiltSet<SdkRevenueReceiptValidateResponseDtoStatusEnum> get values =>
      _$sdkRevenueReceiptValidateResponseDtoStatusEnumValues;
  static SdkRevenueReceiptValidateResponseDtoStatusEnum valueOf(String name) =>
      _$sdkRevenueReceiptValidateResponseDtoStatusEnumValueOf(name);
}
