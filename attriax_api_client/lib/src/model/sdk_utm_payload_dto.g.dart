// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_utm_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkUtmPayloadDto _$SdkUtmPayloadDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkUtmPayloadDto', json, ($checkedConvert) {
      final val = SdkUtmPayloadDto(
        campaign: $checkedConvert('campaign', (v) => v as String?),
        content: $checkedConvert('content', (v) => v as String?),
        medium: $checkedConvert('medium', (v) => v as String?),
        source_: $checkedConvert('source', (v) => v as String?),
        term: $checkedConvert('term', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$SdkUtmPayloadDtoToJson(SdkUtmPayloadDto instance) =>
    <String, dynamic>{
      'campaign': ?instance.campaign,
      'content': ?instance.content,
      'medium': ?instance.medium,
      'source': ?instance.source_,
      'term': ?instance.term,
    };
