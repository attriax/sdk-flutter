// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_acknowledge_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkAcknowledgeResponseDto _$SdkAcknowledgeResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkAcknowledgeResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['success']);
  final val = SdkAcknowledgeResponseDto(
    success: $checkedConvert('success', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$SdkAcknowledgeResponseDtoToJson(
  SdkAcknowledgeResponseDto instance,
) => <String, dynamic>{'success': instance.success};
