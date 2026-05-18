// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_revenue_usd_conversion_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkRevenueUsdConversionResponseEnvelopeDto
_$SdkRevenueUsdConversionResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkRevenueUsdConversionResponseEnvelopeDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkRevenueUsdConversionResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) => SdkRevenueUsdConversionResponseDto.fromJson(
        v as Map<String, dynamic>,
      ),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkRevenueUsdConversionResponseEnvelopeDtoToJson(
  SdkRevenueUsdConversionResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
