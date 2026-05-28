// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_register_uninstall_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkRegisterUninstallTokenDto _$SdkRegisterUninstallTokenDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkRegisterUninstallTokenDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['deviceId', 'platform', 'provider']);
  final val = SdkRegisterUninstallTokenDto(
    appToken: $checkedConvert('appToken', (v) => v as String?),
    deviceId: $checkedConvert('deviceId', (v) => v as String),
    deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String?),
    metadata: $checkedConvert(
      'metadata',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    platform: $checkedConvert(
      'platform',
      (v) => $enumDecode(_$PlatformEnumMap, v),
    ),
    projectToken: $checkedConvert('projectToken', (v) => v as String?),
    provider: $checkedConvert(
      'provider',
      (v) => $enumDecode(_$AppUserUninstallTokenProviderEnumMap, v),
    ),
    token: $checkedConvert('token', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$SdkRegisterUninstallTokenDtoToJson(
  SdkRegisterUninstallTokenDto instance,
) => <String, dynamic>{
  'appToken': ?instance.appToken,
  'deviceId': instance.deviceId,
  'deviceIdSource': ?instance.deviceIdSource,
  'metadata': ?instance.metadata,
  'platform': _$PlatformEnumMap[instance.platform]!,
  'projectToken': ?instance.projectToken,
  'provider': _$AppUserUninstallTokenProviderEnumMap[instance.provider]!,
  'token': ?instance.token,
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

const _$AppUserUninstallTokenProviderEnumMap = {
  AppUserUninstallTokenProvider.fcm: 'fcm',
  AppUserUninstallTokenProvider.apns: 'apns',
};
