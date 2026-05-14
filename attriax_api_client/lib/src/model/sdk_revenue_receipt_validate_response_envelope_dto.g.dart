// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_revenue_receipt_validate_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkRevenueReceiptValidateResponseEnvelopeDto
_$SdkRevenueReceiptValidateResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkRevenueReceiptValidateResponseEnvelopeDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkRevenueReceiptValidateResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) => SdkRevenueReceiptValidateResponseDto.fromJson(
        v as Map<String, dynamic>,
      ),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkRevenueReceiptValidateResponseEnvelopeDtoToJson(
  SdkRevenueReceiptValidateResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
