// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_gdpr_consent_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkGdprConsentResponseEnvelopeDto _$SdkGdprConsentResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkGdprConsentResponseEnvelopeDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkGdprConsentResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) => SdkGdprConsentStatusDto.fromJson(v as Map<String, dynamic>),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkGdprConsentResponseEnvelopeDtoToJson(
  SdkGdprConsentResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
