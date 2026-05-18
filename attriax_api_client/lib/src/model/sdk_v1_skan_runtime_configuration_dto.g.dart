// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_skan_runtime_configuration_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1SkanRuntimeConfigurationDto _$SdkV1SkanRuntimeConfigurationDtoFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('SdkV1SkanRuntimeConfigurationDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['enabled']);
      final val = SdkV1SkanRuntimeConfigurationDto(
        enabled: $checkedConvert('enabled', (v) => v as bool),
        lastUpdatedAt: $checkedConvert('lastUpdatedAt', (v) => v),
        schema: $checkedConvert(
          'schema',
          (v) => v == null
              ? null
              : SdkV1SkanSchemaDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SdkV1SkanRuntimeConfigurationDtoToJson(
  SdkV1SkanRuntimeConfigurationDto instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'lastUpdatedAt': ?instance.lastUpdatedAt,
  'schema': ?instance.schema?.toJson(),
};
