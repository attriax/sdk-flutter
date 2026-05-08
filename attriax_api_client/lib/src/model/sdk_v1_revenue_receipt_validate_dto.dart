//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_revenue_receipt_validate_dto.g.dart';

/// SdkV1RevenueReceiptValidateDto
///
/// Properties:
/// * [appToken]
/// * [clientOccurredAt]
/// * [deviceId]
/// * [environment]
/// * [originalTransactionId]
/// * [packageName]
/// * [productId]
/// * [provider]
/// * [purchaseToken]
/// * [receiptData]
/// * [receiptSignature]
/// * [signedPayload]
/// * [store]
/// * [test]
/// * [transactionId]
@BuiltValue()
abstract class SdkV1RevenueReceiptValidateDto
    implements
        Built<
          SdkV1RevenueReceiptValidateDto,
          SdkV1RevenueReceiptValidateDtoBuilder
        > {
  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'clientOccurredAt')
  String? get clientOccurredAt;

  @BuiltValueField(wireName: r'deviceId')
  String? get deviceId;

  @BuiltValueField(wireName: r'environment')
  String? get environment;

  @BuiltValueField(wireName: r'originalTransactionId')
  String? get originalTransactionId;

  @BuiltValueField(wireName: r'packageName')
  String? get packageName;

  @BuiltValueField(wireName: r'productId')
  String? get productId;

  @BuiltValueField(wireName: r'provider')
  String? get provider;

  @BuiltValueField(wireName: r'purchaseToken')
  String? get purchaseToken;

  @BuiltValueField(wireName: r'receiptData')
  String? get receiptData;

  @BuiltValueField(wireName: r'receiptSignature')
  String? get receiptSignature;

  @BuiltValueField(wireName: r'signedPayload')
  String? get signedPayload;

  @BuiltValueField(wireName: r'store')
  String? get store;

  @BuiltValueField(wireName: r'test')
  bool? get test;

  @BuiltValueField(wireName: r'transactionId')
  String? get transactionId;

  SdkV1RevenueReceiptValidateDto._();

  factory SdkV1RevenueReceiptValidateDto([
    void updates(SdkV1RevenueReceiptValidateDtoBuilder b),
  ]) = _$SdkV1RevenueReceiptValidateDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1RevenueReceiptValidateDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1RevenueReceiptValidateDto> get serializer =>
      _$SdkV1RevenueReceiptValidateDtoSerializer();
}

class _$SdkV1RevenueReceiptValidateDtoSerializer
    implements PrimitiveSerializer<SdkV1RevenueReceiptValidateDto> {
  @override
  final Iterable<Type> types = const [
    SdkV1RevenueReceiptValidateDto,
    _$SdkV1RevenueReceiptValidateDto,
  ];

  @override
  final String wireName = r'SdkV1RevenueReceiptValidateDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1RevenueReceiptValidateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
    );
    if (object.clientOccurredAt != null) {
      yield r'clientOccurredAt';
      yield serializers.serialize(
        object.clientOccurredAt,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceId != null) {
      yield r'deviceId';
      yield serializers.serialize(
        object.deviceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.environment != null) {
      yield r'environment';
      yield serializers.serialize(
        object.environment,
        specifiedType: const FullType(String),
      );
    }
    if (object.originalTransactionId != null) {
      yield r'originalTransactionId';
      yield serializers.serialize(
        object.originalTransactionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.packageName != null) {
      yield r'packageName';
      yield serializers.serialize(
        object.packageName,
        specifiedType: const FullType(String),
      );
    }
    if (object.productId != null) {
      yield r'productId';
      yield serializers.serialize(
        object.productId,
        specifiedType: const FullType(String),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(String),
      );
    }
    if (object.purchaseToken != null) {
      yield r'purchaseToken';
      yield serializers.serialize(
        object.purchaseToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.receiptData != null) {
      yield r'receiptData';
      yield serializers.serialize(
        object.receiptData,
        specifiedType: const FullType(String),
      );
    }
    if (object.receiptSignature != null) {
      yield r'receiptSignature';
      yield serializers.serialize(
        object.receiptSignature,
        specifiedType: const FullType(String),
      );
    }
    if (object.signedPayload != null) {
      yield r'signedPayload';
      yield serializers.serialize(
        object.signedPayload,
        specifiedType: const FullType(String),
      );
    }
    if (object.store != null) {
      yield r'store';
      yield serializers.serialize(
        object.store,
        specifiedType: const FullType(String),
      );
    }
    if (object.test != null) {
      yield r'test';
      yield serializers.serialize(
        object.test,
        specifiedType: const FullType(bool),
      );
    }
    if (object.transactionId != null) {
      yield r'transactionId';
      yield serializers.serialize(
        object.transactionId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1RevenueReceiptValidateDto object, {
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
    required SdkV1RevenueReceiptValidateDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appToken':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.appToken = valueDes;
          break;
        case r'clientOccurredAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.clientOccurredAt = valueDes;
          break;
        case r'deviceId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deviceId = valueDes;
          break;
        case r'environment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.environment = valueDes;
          break;
        case r'originalTransactionId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.originalTransactionId = valueDes;
          break;
        case r'packageName':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.packageName = valueDes;
          break;
        case r'productId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productId = valueDes;
          break;
        case r'provider':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.provider = valueDes;
          break;
        case r'purchaseToken':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.purchaseToken = valueDes;
          break;
        case r'receiptData':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.receiptData = valueDes;
          break;
        case r'receiptSignature':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.receiptSignature = valueDes;
          break;
        case r'signedPayload':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.signedPayload = valueDes;
          break;
        case r'store':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.store = valueDes;
          break;
        case r'test':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.test = valueDes;
          break;
        case r'transactionId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.transactionId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkV1RevenueReceiptValidateDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1RevenueReceiptValidateDtoBuilder();
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
