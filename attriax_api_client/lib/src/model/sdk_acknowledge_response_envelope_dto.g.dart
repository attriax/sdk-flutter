// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_acknowledge_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkAcknowledgeResponseEnvelopeDto _$SdkAcknowledgeResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkAcknowledgeResponseEnvelopeDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkAcknowledgeResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) => SdkAcknowledgeResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkAcknowledgeResponseEnvelopeDtoToJson(
  SdkAcknowledgeResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
