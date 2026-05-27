// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_gdpr_data_erase_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1GdprDataEraseDto _$SdkV1GdprDataEraseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1GdprDataEraseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['appToken', 'deviceId']);
  final val = SdkV1GdprDataEraseDto(
    appToken: $checkedConvert('appToken', (v) => v as String),
    deviceId: $checkedConvert('deviceId', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SdkV1GdprDataEraseDtoToJson(
  SdkV1GdprDataEraseDto instance,
) => <String, dynamic>{
  'appToken': instance.appToken,
  'deviceId': instance.deviceId,
};
