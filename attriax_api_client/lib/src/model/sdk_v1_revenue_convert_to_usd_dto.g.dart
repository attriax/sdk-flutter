// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_revenue_convert_to_usd_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1RevenueConvertToUsdDto _$SdkV1RevenueConvertToUsdDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1RevenueConvertToUsdDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['appToken', 'currency']);
  final val = SdkV1RevenueConvertToUsdDto(
    amount: $checkedConvert('amount', (v) => v as num?),
    amountMicros: $checkedConvert('amountMicros', (v) => v as String?),
    appToken: $checkedConvert('appToken', (v) => v as String),
    clientOccurredAt: $checkedConvert('clientOccurredAt', (v) => v as String?),
    currency: $checkedConvert('currency', (v) => v as String),
    revenueInMicros: $checkedConvert('revenueInMicros', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$SdkV1RevenueConvertToUsdDtoToJson(
  SdkV1RevenueConvertToUsdDto instance,
) => <String, dynamic>{
  'amount': ?instance.amount,
  'amountMicros': ?instance.amountMicros,
  'appToken': instance.appToken,
  'clientOccurredAt': ?instance.clientOccurredAt,
  'currency': instance.currency,
  'revenueInMicros': ?instance.revenueInMicros,
};
