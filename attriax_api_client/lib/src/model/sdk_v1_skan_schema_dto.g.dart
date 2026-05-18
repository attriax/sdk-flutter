// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_skan_schema_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1SkanSchemaDto _$SdkV1SkanSchemaDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkV1SkanSchemaDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['version', 'window1', 'window2', 'window3'],
      );
      final val = SdkV1SkanSchemaDto(
        updatedAt: $checkedConvert('updatedAt', (v) => v),
        version: $checkedConvert('version', (v) => v as num),
        window1: $checkedConvert(
          'window1',
          (v) => SdkV1SkanWindow1Dto.fromJson(v as Map<String, dynamic>),
        ),
        window2: $checkedConvert(
          'window2',
          (v) => SdkV1SkanCoarseWindowDto.fromJson(v as Map<String, dynamic>),
        ),
        window3: $checkedConvert(
          'window3',
          (v) => SdkV1SkanCoarseWindowDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SdkV1SkanSchemaDtoToJson(SdkV1SkanSchemaDto instance) =>
    <String, dynamic>{
      'updatedAt': ?instance.updatedAt,
      'version': instance.version,
      'window1': instance.window1.toJson(),
      'window2': instance.window2.toJson(),
      'window3': instance.window3.toJson(),
    };
