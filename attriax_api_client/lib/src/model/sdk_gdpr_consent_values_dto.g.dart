// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_gdpr_consent_values_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkGdprConsentValuesDto _$SdkGdprConsentValuesDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkGdprConsentValuesDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['adEvents', 'analytics', 'attribution'],
  );
  final val = SdkGdprConsentValuesDto(
    adEvents: $checkedConvert('adEvents', (v) => v as bool),
    analytics: $checkedConvert('analytics', (v) => v as bool),
    attribution: $checkedConvert('attribution', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$SdkGdprConsentValuesDtoToJson(
  SdkGdprConsentValuesDto instance,
) => <String, dynamic>{
  'adEvents': instance.adEvents,
  'analytics': instance.analytics,
  'attribution': instance.attribution,
};
