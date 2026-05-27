// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_create_dynamic_link_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkCreateDynamicLinkDto _$SdkCreateDynamicLinkDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkCreateDynamicLinkDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['appToken']);
  final val = SdkCreateDynamicLinkDto(
    androidRedirect: $checkedConvert('androidRedirect', (v) => v as bool?),
    appToken: $checkedConvert('appToken', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    destinationUrl: $checkedConvert('destinationUrl', (v) => v as String?),
    group: $checkedConvert('group', (v) => v as String?),
    iosRedirect: $checkedConvert('iosRedirect', (v) => v as bool?),
    name: $checkedConvert('name', (v) => v as String?),
    prefix: $checkedConvert('prefix', (v) => v as String?),
    previewDescription: $checkedConvert(
      'previewDescription',
      (v) => v as String?,
    ),
    previewTitle: $checkedConvert('previewTitle', (v) => v as String?),
    utmCampaign: $checkedConvert('utmCampaign', (v) => v as String?),
    utmContent: $checkedConvert('utmContent', (v) => v as String?),
    utmMedium: $checkedConvert('utmMedium', (v) => v as String?),
    utmSource: $checkedConvert('utmSource', (v) => v as String?),
    utmTerm: $checkedConvert('utmTerm', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$SdkCreateDynamicLinkDtoToJson(
  SdkCreateDynamicLinkDto instance,
) => <String, dynamic>{
  'androidRedirect': ?instance.androidRedirect,
  'appToken': instance.appToken,
  'data': ?instance.data,
  'destinationUrl': ?instance.destinationUrl,
  'group': ?instance.group,
  'iosRedirect': ?instance.iosRedirect,
  'name': ?instance.name,
  'prefix': ?instance.prefix,
  'previewDescription': ?instance.previewDescription,
  'previewTitle': ?instance.previewTitle,
  'utmCampaign': ?instance.utmCampaign,
  'utmContent': ?instance.utmContent,
  'utmMedium': ?instance.utmMedium,
  'utmSource': ?instance.utmSource,
  'utmTerm': ?instance.utmTerm,
};
