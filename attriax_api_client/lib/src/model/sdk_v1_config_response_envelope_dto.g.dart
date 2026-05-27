// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_config_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1ConfigResponseEnvelopeDto _$SdkV1ConfigResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1ConfigResponseEnvelopeDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkV1ConfigResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) => SdkV1ConfigResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkV1ConfigResponseEnvelopeDtoToJson(
  SdkV1ConfigResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
