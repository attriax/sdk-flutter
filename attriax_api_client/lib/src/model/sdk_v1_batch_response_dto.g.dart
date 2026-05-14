// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_batch_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1BatchResponseDto _$SdkV1BatchResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1BatchResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'acceptedAt',
      'duplicateCount',
      'itemCount',
      'processedCount',
      'requestVersion',
    ],
  );
  final val = SdkV1BatchResponseDto(
    acceptedAt: $checkedConvert(
      'acceptedAt',
      (v) => DateTime.parse(v as String),
    ),
    duplicateCount: $checkedConvert('duplicateCount', (v) => v as num),
    itemCount: $checkedConvert('itemCount', (v) => v as num),
    processedCount: $checkedConvert('processedCount', (v) => v as num),
    requestVersion: $checkedConvert('requestVersion', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SdkV1BatchResponseDtoToJson(
  SdkV1BatchResponseDto instance,
) => <String, dynamic>{
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'duplicateCount': instance.duplicateCount,
  'itemCount': instance.itemCount,
  'processedCount': instance.processedCount,
  'requestVersion': instance.requestVersion,
};
