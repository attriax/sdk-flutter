// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_revenue_receipt_validate_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkRevenueReceiptValidateResponseDto
_$SdkRevenueReceiptValidateResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkRevenueReceiptValidateResponseDto', json, (
  $checkedConvert,
) {
  $checkKeys(
    json,
    requiredKeys: const [
      'acceptedAt',
      'publicReceipt',
      'requestVersion',
      'status',
      'validationId',
    ],
  );
  final val = SdkRevenueReceiptValidateResponseDto(
    acceptedAt: $checkedConvert(
      'acceptedAt',
      (v) => DateTime.parse(v as String),
    ),
    environment: $checkedConvert('environment', (v) => v as String?),
    expiresAt: $checkedConvert(
      'expiresAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    failureReason: $checkedConvert('failureReason', (v) => v as String?),
    originalTransactionId: $checkedConvert(
      'originalTransactionId',
      (v) => v as String?,
    ),
    productId: $checkedConvert('productId', (v) => v as String?),
    provider: $checkedConvert('provider', (v) => v as String?),
    providerResult: $checkedConvert(
      'providerResult',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    publicReceipt: $checkedConvert(
      'publicReceipt',
      (v) =>
          (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
    ),
    requestVersion: $checkedConvert('requestVersion', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(
        _$SdkRevenueReceiptValidateResponseDtoStatusEnumEnumMap,
        v,
      ),
    ),
    transactionId: $checkedConvert('transactionId', (v) => v as String?),
    validationId: $checkedConvert('validationId', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SdkRevenueReceiptValidateResponseDtoToJson(
  SdkRevenueReceiptValidateResponseDto instance,
) => <String, dynamic>{
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'environment': ?instance.environment,
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'failureReason': ?instance.failureReason,
  'originalTransactionId': ?instance.originalTransactionId,
  'productId': ?instance.productId,
  'provider': ?instance.provider,
  'providerResult': ?instance.providerResult,
  'publicReceipt': instance.publicReceipt,
  'requestVersion': instance.requestVersion,
  'status':
      _$SdkRevenueReceiptValidateResponseDtoStatusEnumEnumMap[instance.status]!,
  'transactionId': ?instance.transactionId,
  'validationId': instance.validationId,
};

const _$SdkRevenueReceiptValidateResponseDtoStatusEnumEnumMap = {
  SdkRevenueReceiptValidateResponseDtoStatusEnum.verified: 'verified',
  SdkRevenueReceiptValidateResponseDtoStatusEnum.rejected: 'rejected',
  SdkRevenueReceiptValidateResponseDtoStatusEnum.pending: 'pending',
  SdkRevenueReceiptValidateResponseDtoStatusEnum.unconfigured: 'unconfigured',
  SdkRevenueReceiptValidateResponseDtoStatusEnum.providerError:
      'provider_error',
  SdkRevenueReceiptValidateResponseDtoStatusEnum.passthrough: 'passthrough',
};
