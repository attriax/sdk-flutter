// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_gdpr_consent_values_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1GdprConsentValuesDto _$SdkV1GdprConsentValuesDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1GdprConsentValuesDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['adEvents', 'analytics', 'attribution'],
  );
  final val = SdkV1GdprConsentValuesDto(
    adEvents: $checkedConvert('adEvents', (v) => v as bool),
    analytics: $checkedConvert('analytics', (v) => v as bool),
    attribution: $checkedConvert('attribution', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$SdkV1GdprConsentValuesDtoToJson(
  SdkV1GdprConsentValuesDto instance,
) => <String, dynamic>{
  'adEvents': instance.adEvents,
  'analytics': instance.analytics,
  'attribution': instance.attribution,
};
