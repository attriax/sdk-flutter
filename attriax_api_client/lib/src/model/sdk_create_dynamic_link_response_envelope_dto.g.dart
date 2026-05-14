// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_create_dynamic_link_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkCreateDynamicLinkResponseEnvelopeDto
_$SdkCreateDynamicLinkResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkCreateDynamicLinkResponseEnvelopeDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkCreateDynamicLinkResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) =>
          SdkCreateDynamicLinkResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkCreateDynamicLinkResponseEnvelopeDtoToJson(
  SdkCreateDynamicLinkResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
