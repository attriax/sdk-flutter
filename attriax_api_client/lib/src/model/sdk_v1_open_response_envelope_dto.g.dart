// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_open_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1OpenResponseEnvelopeDto _$SdkV1OpenResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1OpenResponseEnvelopeDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkV1OpenResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) => SdkV1OpenResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkV1OpenResponseEnvelopeDtoToJson(
  SdkV1OpenResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
