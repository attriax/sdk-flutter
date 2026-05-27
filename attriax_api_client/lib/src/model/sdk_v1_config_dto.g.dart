// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1ConfigDto _$SdkV1ConfigDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkV1ConfigDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['appToken', 'platform']);
      final val = SdkV1ConfigDto(
        appToken: $checkedConvert('appToken', (v) => v as String),
        packageName: $checkedConvert('packageName', (v) => v as String?),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$PlatformEnumMap, v),
        ),
        signatureHashes: $checkedConvert(
          'signatureHashes',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SdkV1ConfigDtoToJson(SdkV1ConfigDto instance) =>
    <String, dynamic>{
      'appToken': instance.appToken,
      'packageName': ?instance.packageName,
      'platform': _$PlatformEnumMap[instance.platform]!,
      'signatureHashes': ?instance.signatureHashes,
    };

const _$PlatformEnumMap = {
  Platform.ios: 'ios',
  Platform.android: 'android',
  Platform.unityEditor: 'unity_editor',
  Platform.windows: 'windows',
  Platform.macos: 'macos',
  Platform.linux: 'linux',
  Platform.web: 'web',
  Platform.unknown: 'unknown',
};
