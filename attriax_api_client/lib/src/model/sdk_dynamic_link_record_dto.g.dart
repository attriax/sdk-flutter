// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_dynamic_link_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkDynamicLinkRecordDto _$SdkDynamicLinkRecordDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkDynamicLinkRecordDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['createdAt', 'id', 'path', 'shortUrl']);
  final val = SdkDynamicLinkRecordDto(
    androidRedirect: $checkedConvert('androidRedirect', (v) => v as bool?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    data: $checkedConvert(
      'data',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    destinationUrl: $checkedConvert('destinationUrl', (v) => v as String?),
    group: $checkedConvert('group', (v) => v as String?),
    id: $checkedConvert('id', (v) => v as String),
    iosRedirect: $checkedConvert('iosRedirect', (v) => v as bool?),
    name: $checkedConvert('name', (v) => v as String?),
    path: $checkedConvert('path', (v) => v as String),
    prefix: $checkedConvert('prefix', (v) => v as String?),
    previewDescription: $checkedConvert(
      'previewDescription',
      (v) => v as String?,
    ),
    previewTitle: $checkedConvert('previewTitle', (v) => v as String?),
    shortUrl: $checkedConvert('shortUrl', (v) => v as String),
    utmCampaign: $checkedConvert('utmCampaign', (v) => v as String?),
    utmContent: $checkedConvert('utmContent', (v) => v as String?),
    utmMedium: $checkedConvert('utmMedium', (v) => v as String?),
    utmSource: $checkedConvert('utmSource', (v) => v as String?),
    utmTerm: $checkedConvert('utmTerm', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$SdkDynamicLinkRecordDtoToJson(
  SdkDynamicLinkRecordDto instance,
) => <String, dynamic>{
  'androidRedirect': ?instance.androidRedirect,
  'createdAt': instance.createdAt.toIso8601String(),
  'data': ?instance.data,
  'destinationUrl': ?instance.destinationUrl,
  'group': ?instance.group,
  'id': instance.id,
  'iosRedirect': ?instance.iosRedirect,
  'name': ?instance.name,
  'path': instance.path,
  'prefix': ?instance.prefix,
  'previewDescription': ?instance.previewDescription,
  'previewTitle': ?instance.previewTitle,
  'shortUrl': instance.shortUrl,
  'utmCampaign': ?instance.utmCampaign,
  'utmContent': ?instance.utmContent,
  'utmMedium': ?instance.utmMedium,
  'utmSource': ?instance.utmSource,
  'utmTerm': ?instance.utmTerm,
};
