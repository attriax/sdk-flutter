// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_config_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1ConfigResponseDto _$SdkV1ConfigResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1ConfigResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'acceptedAt',
      'clipboardAttributionEnabled',
      'requestVersion',
    ],
  );
  final val = SdkV1ConfigResponseDto(
    acceptedAt: $checkedConvert(
      'acceptedAt',
      (v) => DateTime.parse(v as String),
    ),
    clipboardAttributionEnabled: $checkedConvert(
      'clipboardAttributionEnabled',
      (v) => v as bool,
    ),
    requestVersion: $checkedConvert('requestVersion', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SdkV1ConfigResponseDtoToJson(
  SdkV1ConfigResponseDto instance,
) => <String, dynamic>{
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'clipboardAttributionEnabled': instance.clipboardAttributionEnabled,
  'requestVersion': instance.requestVersion,
};
