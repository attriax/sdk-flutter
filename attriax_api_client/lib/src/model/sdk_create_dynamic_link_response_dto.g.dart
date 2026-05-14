// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_create_dynamic_link_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkCreateDynamicLinkResponseDto _$SdkCreateDynamicLinkResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkCreateDynamicLinkResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['acceptedAt', 'link', 'requestVersion'],
  );
  final val = SdkCreateDynamicLinkResponseDto(
    acceptedAt: $checkedConvert(
      'acceptedAt',
      (v) => DateTime.parse(v as String),
    ),
    link: $checkedConvert(
      'link',
      (v) => SdkDynamicLinkRecordDto.fromJson(v as Map<String, dynamic>),
    ),
    requestVersion: $checkedConvert('requestVersion', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SdkCreateDynamicLinkResponseDtoToJson(
  SdkCreateDynamicLinkResponseDto instance,
) => <String, dynamic>{
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'link': instance.link.toJson(),
  'requestVersion': instance.requestVersion,
};
