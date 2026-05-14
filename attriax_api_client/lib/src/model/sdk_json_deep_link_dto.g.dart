// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_json_deep_link_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkJsonDeepLinkDto _$SdkJsonDeepLinkDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkJsonDeepLinkDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['path']);
      final val = SdkJsonDeepLinkDto(
        data: $checkedConvert(
          'data',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ),
        ),
        path: $checkedConvert('path', (v) => v as String),
        uri: $checkedConvert('uri', (v) => v as String?),
        utm: $checkedConvert(
          'utm',
          (v) => v == null
              ? null
              : SdkUtmPayloadDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SdkJsonDeepLinkDtoToJson(SdkJsonDeepLinkDto instance) =>
    <String, dynamic>{
      'data': ?instance.data,
      'path': instance.path,
      'uri': ?instance.uri,
      'utm': ?instance.utm?.toJson(),
    };
