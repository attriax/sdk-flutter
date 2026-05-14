// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_version_context_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkVersionContextDto _$SdkVersionContextDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkVersionContextDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['apiVersion', 'packageVersion']);
  final val = SdkVersionContextDto(
    apiVersion: $checkedConvert('apiVersion', (v) => v as String),
    metadata: $checkedConvert(
      'metadata',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    packageVersion: $checkedConvert('packageVersion', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SdkVersionContextDtoToJson(
  SdkVersionContextDto instance,
) => <String, dynamic>{
  'apiVersion': instance.apiVersion,
  'metadata': ?instance.metadata,
  'packageVersion': instance.packageVersion,
};
