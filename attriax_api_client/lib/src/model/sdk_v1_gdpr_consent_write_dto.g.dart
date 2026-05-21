// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_gdpr_consent_write_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1GdprConsentWriteDto _$SdkV1GdprConsentWriteDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1GdprConsentWriteDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['appToken', 'state']);
  final val = SdkV1GdprConsentWriteDto(
    appToken: $checkedConvert('appToken', (v) => v as String),
    clientOccurredAt: $checkedConvert(
      'clientOccurredAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    consentId: $checkedConvert('consentId', (v) => v as String?),
    countryCode: $checkedConvert('countryCode', (v) => v as String?),
    regionSource: $checkedConvert('regionSource', (v) => v as String?),
    state: $checkedConvert(
      'state',
      (v) => $enumDecode(_$AppUserGdprConsentStateEnumMap, v),
    ),
    values: $checkedConvert(
      'values',
      (v) => v == null
          ? null
          : SdkV1GdprConsentValuesDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SdkV1GdprConsentWriteDtoToJson(
  SdkV1GdprConsentWriteDto instance,
) => <String, dynamic>{
  'appToken': instance.appToken,
  'clientOccurredAt': ?instance.clientOccurredAt?.toIso8601String(),
  'consentId': ?instance.consentId,
  'countryCode': ?instance.countryCode,
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
