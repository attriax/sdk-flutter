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
    productId: $checkedConvert('productId', (v) => v as String?),
    projectToken: $checkedConvert('projectToken', (v) => v as String?),
    provider: $checkedConvert('provider', (v) => v as String?),
    receipt: $checkedConvert('receipt', (v) => v as String?),
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
  'productId': ?instance.productId,
  'projectToken': ?instance.projectToken,
  'provider': ?instance.provider,
  'receipt': ?instance.receipt,
  'test': ?instance.test,
  'transactionId': ?instance.transactionId,
};
