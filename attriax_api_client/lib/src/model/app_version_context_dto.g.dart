// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_context_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionContextDto _$AppVersionContextDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AppVersionContextDto', json, ($checkedConvert) {
  final val = AppVersionContextDto(
    buildNumber: $checkedConvert('buildNumber', (v) => v as String?),
    packageName: $checkedConvert('packageName', (v) => v as String?),
    version: $checkedConvert('version', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AppVersionContextDtoToJson(
  AppVersionContextDto instance,
) => <String, dynamic>{
  'buildNumber': ?instance.buildNumber,
  'packageName': ?instance.packageName,
  'version': ?instance.version,
};
