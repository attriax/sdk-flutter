// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_revenue_usd_conversion_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkRevenueUsdConversionResponseDto _$SdkRevenueUsdConversionResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkRevenueUsdConversionResponseDto', json, (
  $checkedConvert,
) {
  $checkKeys(
    json,
    requiredKeys: const [
      'acceptedAt',
      'amountOriginalMicros',
      'amountUsd',
      'amountUsdMicros',
      'conversionStatus',
      'currency',
      'rate',
      'rateDate',
      'requestVersion',
    ],
  );
  final val = SdkRevenueUsdConversionResponseDto(
    acceptedAt: $checkedConvert(
      'acceptedAt',
      (v) => DateTime.parse(v as String),
    ),
    amountOriginalMicros: $checkedConvert(
      'amountOriginalMicros',
      (v) => v as String,
    ),
    amountUsd: $checkedConvert('amountUsd', (v) => v as num),
    amountUsdMicros: $checkedConvert('amountUsdMicros', (v) => v as String),
    conversionStatus: $checkedConvert('conversionStatus', (v) => v as String),
    currency: $checkedConvert('currency', (v) => v as String),
    rate: $checkedConvert('rate', (v) => v as String),
    rateDate: $checkedConvert('rateDate', (v) => v as String),
    requestVersion: $checkedConvert('requestVersion', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SdkRevenueUsdConversionResponseDtoToJson(
  SdkRevenueUsdConversionResponseDto instance,
) => <String, dynamic>{
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'amountOriginalMicros': instance.amountOriginalMicros,
  'amountUsd': instance.amountUsd,
  'amountUsdMicros': instance.amountUsdMicros,
  'conversionStatus': instance.conversionStatus,
  'currency': instance.currency,
  'rate': instance.rate,
  'rateDate': instance.rateDate,
  'requestVersion': instance.requestVersion,
};
