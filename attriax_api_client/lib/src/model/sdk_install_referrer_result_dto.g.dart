// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_install_referrer_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkInstallReferrerResultDto _$SdkInstallReferrerResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkInstallReferrerResultDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['attributionType', 'precision']);
  final val = SdkInstallReferrerResultDto(
    adClickId: $checkedConvert('adClickId', (v) => v as String?),
    adNetwork: $checkedConvert('adNetwork', (v) => v as String?),
    attributionType: $checkedConvert(
      'attributionType',
      (v) => $enumDecode(_$AttributionTypeEnumMap, v),
    ),
    campaign: $checkedConvert('campaign', (v) => v as String?),
    content: $checkedConvert('content', (v) => v as String?),
    deepLinkData: $checkedConvert(
      'deepLinkData',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)),
    ),
    deepLinkUri: $checkedConvert('deepLinkUri', (v) => v as String?),
    deepLinkUrl: $checkedConvert('deepLinkUrl', (v) => v as String?),
    googlePlayInstantParam: $checkedConvert(
      'googlePlayInstantParam',
      (v) => v as bool?,
    ),
    installBeginTimestampSeconds: $checkedConvert(
      'installBeginTimestampSeconds',
      (v) => v as num?,
    ),
    medium: $checkedConvert('medium', (v) => v as String?),
    precision: $checkedConvert('precision', (v) => v as num),
    rawPlatformInstallReferrer: $checkedConvert(
      'rawPlatformInstallReferrer',
      (v) => v as String?,
    ),
    referrerClickTimestampSeconds: $checkedConvert(
      'referrerClickTimestampSeconds',
      (v) => v as num?,
    ),
    registeredAt: $checkedConvert(
      'registeredAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    source_: $checkedConvert('source', (v) => v as String?),
    term: $checkedConvert('term', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$SdkInstallReferrerResultDtoToJson(
  SdkInstallReferrerResultDto instance,
) => <String, dynamic>{
  'adClickId': ?instance.adClickId,
  'adNetwork': ?instance.adNetwork,
  'attributionType': _$AttributionTypeEnumMap[instance.attributionType]!,
  'campaign': ?instance.campaign,
  'content': ?instance.content,
  'deepLinkData': ?instance.deepLinkData,
  'deepLinkUri': ?instance.deepLinkUri,
  'deepLinkUrl': ?instance.deepLinkUrl,
  'googlePlayInstantParam': ?instance.googlePlayInstantParam,
  'installBeginTimestampSeconds': ?instance.installBeginTimestampSeconds,
  'medium': ?instance.medium,
  'precision': instance.precision,
  'rawPlatformInstallReferrer': ?instance.rawPlatformInstallReferrer,
  'referrerClickTimestampSeconds': ?instance.referrerClickTimestampSeconds,
  'registeredAt': ?instance.registeredAt?.toIso8601String(),
  'source': ?instance.source_,
  'term': ?instance.term,
};

const _$AttributionTypeEnumMap = {
  AttributionType.referrer: 'referrer',
  AttributionType.fingerprint: 'fingerprint',
  AttributionType.external_: 'external',
  AttributionType.organic: 'organic',
};
