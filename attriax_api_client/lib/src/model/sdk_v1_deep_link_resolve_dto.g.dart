// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_deep_link_resolve_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1DeepLinkResolveDto _$SdkV1DeepLinkResolveDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1DeepLinkResolveDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['appToken', 'deviceId', 'platform']);
  final val = SdkV1DeepLinkResolveDto(
    appToken: $checkedConvert('appToken', (v) => v as String),
    deviceId: $checkedConvert('deviceId', (v) => v as String),
    deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String?),
    isFirstLaunch: $checkedConvert('isFirstLaunch', (v) => v as bool?),
    linkPath: $checkedConvert('linkPath', (v) => v as String?),
    metadata: $checkedConvert(
      'metadata',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    platform: $checkedConvert(
      'platform',
      (v) => $enumDecode(_$PlatformEnumMap, v),
    ),
    rawUrl: $checkedConvert('rawUrl', (v) => v as String?),
    source_: $checkedConvert('source', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$SdkV1DeepLinkResolveDtoToJson(
  SdkV1DeepLinkResolveDto instance,
) => <String, dynamic>{
  'appToken': instance.appToken,
  'deviceId': instance.deviceId,
  'deviceIdSource': ?instance.deviceIdSource,
  'isFirstLaunch': ?instance.isFirstLaunch,
  'linkPath': ?instance.linkPath,
  'metadata': ?instance.metadata,
  'platform': _$PlatformEnumMap[instance.platform]!,
  'rawUrl': ?instance.rawUrl,
  'source': ?instance.source_,
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
