// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_gdpr_consent_status_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkGdprConsentStatusDto _$SdkGdprConsentStatusDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkGdprConsentStatusDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['checkedAt', 'needsConsent', 'state']);
  final val = SdkGdprConsentStatusDto(
    checkedAt: $checkedConvert('checkedAt', (v) => DateTime.parse(v as String)),
    countryCode: $checkedConvert('countryCode', (v) => v as String?),
    needsConsent: $checkedConvert('needsConsent', (v) => v as bool),
    regionSource: $checkedConvert('regionSource', (v) => v as String?),
    state: $checkedConvert(
      'state',
      (v) => $enumDecode(_$AppUserGdprConsentStateEnumMap, v),
    ),
    values: $checkedConvert(
      'values',
      (v) => v == null
          ? null
          : SdkGdprConsentValuesDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SdkGdprConsentStatusDtoToJson(
  SdkGdprConsentStatusDto instance,
) => <String, dynamic>{
  'checkedAt': instance.checkedAt.toIso8601String(),
  'countryCode': ?instance.countryCode,
  'needsConsent': instance.needsConsent,
  'regionSource': ?instance.regionSource,
  'state': _$AppUserGdprConsentStateEnumMap[instance.state]!,
  'values': ?instance.values?.toJson(),
};

const _$AppUserGdprConsentStateEnumMap = {
  AppUserGdprConsentState.unknown: 'unknown',
  AppUserGdprConsentState.notRequired: 'not_required',
  AppUserGdprConsentState.pending: 'pending',
  AppUserGdprConsentState.granted: 'granted',
};
