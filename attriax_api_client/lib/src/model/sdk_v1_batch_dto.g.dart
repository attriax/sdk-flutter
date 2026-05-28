// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_batch_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1BatchDto _$SdkV1BatchDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkV1BatchDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['deviceId', 'items', 'requestId']);
      final val = SdkV1BatchDto(
        appToken: $checkedConvert('appToken', (v) => v as String?),
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String?),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => SdkV1BatchItemDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        projectToken: $checkedConvert('projectToken', (v) => v as String?),
        requestId: $checkedConvert('requestId', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SdkV1BatchDtoToJson(SdkV1BatchDto instance) =>
    <String, dynamic>{
      'appToken': ?instance.appToken,
      'deviceId': instance.deviceId,
      'deviceIdSource': ?instance.deviceIdSource,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'projectToken': ?instance.projectToken,
      'requestId': instance.requestId,
    };
