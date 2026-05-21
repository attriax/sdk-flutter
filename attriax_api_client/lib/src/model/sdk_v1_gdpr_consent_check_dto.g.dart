// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_gdpr_consent_check_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1GdprConsentCheckDto _$SdkV1GdprConsentCheckDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1GdprConsentCheckDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['appToken']);
  final val = SdkV1GdprConsentCheckDto(
    appToken: $checkedConvert('appToken', (v) => v as String),
    consentId: $checkedConvert('consentId', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$SdkV1GdprConsentCheckDtoToJson(
  SdkV1GdprConsentCheckDto instance,
) => <String, dynamic>{
  'appToken': instance.appToken,
  'consentId': ?instance.consentId,
};
