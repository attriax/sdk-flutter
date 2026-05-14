// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_batch_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1BatchResponseEnvelopeDto _$SdkV1BatchResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1BatchResponseEnvelopeDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkV1BatchResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) => SdkV1BatchResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkV1BatchResponseEnvelopeDtoToJson(
  SdkV1BatchResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
