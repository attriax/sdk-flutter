// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_revenue_receipt_validate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1RevenueReceiptValidateDto _$SdkV1RevenueReceiptValidateDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1RevenueReceiptValidateDto', json, ($checkedConvert) {
  final val = SdkV1RevenueReceiptValidateDto(
    appToken: $checkedConvert('appToken', (v) => v as String?),
    clientOccurredAt: $checkedConvert('clientOccurredAt', (v) => v as String?),
    deviceId: $checkedConvert('deviceId', (v) => v as String?),
    environment: $checkedConvert('environment', (v) => v as String?),
    originalTransactionId: $checkedConvert(
      'originalTransactionId',
      (v) => v as String?,
    ),
    packageName: $checkedConvert('packageName', (v) => v as String?),
    productId: $checkedConvert('productId', (v) => v as String?),
    projectToken: $checkedConvert('projectToken', (v) => v as String?),
    provider: $checkedConvert('provider', (v) => v as String?),
    purchaseToken: $checkedConvert('purchaseToken', (v) => v as String?),
    receiptData: $checkedConvert('receiptData', (v) => v as String?),
    receiptSignature: $checkedConvert('receiptSignature', (v) => v as String?),
    signedPayload: $checkedConvert('signedPayload', (v) => v as String?),
    store: $checkedConvert('store', (v) => v as String?),
    test: $checkedConvert('test', (v) => v as bool?),
    transactionId: $checkedConvert('transactionId', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$SdkV1RevenueReceiptValidateDtoToJson(
  SdkV1RevenueReceiptValidateDto instance,
) => <String, dynamic>{
  'appToken': ?instance.appToken,
  'clientOccurredAt': ?instance.clientOccurredAt,
  'deviceId': ?instance.deviceId,
  'environment': ?instance.environment,
  'originalTransactionId': ?instance.originalTransactionId,
  'packageName': ?instance.packageName,
  'productId': ?instance.productId,
  'projectToken': ?instance.projectToken,
  'provider': ?instance.provider,
  'purchaseToken': ?instance.purchaseToken,
  'receiptData': ?instance.receiptData,
  'receiptSignature': ?instance.receiptSignature,
  'signedPayload': ?instance.signedPayload,
  'store': ?instance.store,
  'test': ?instance.test,
  'transactionId': ?instance.transactionId,
};
