// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkSessionDto _$SdkSessionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkSessionDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind', 'sessionId']);
      final val = SdkSessionDto(
        appBuildNumber: $checkedConvert('appBuildNumber', (v) => v as String?),
        appPackageName: $checkedConvert('appPackageName', (v) => v as String?),
        appToken: $checkedConvert('appToken', (v) => v as String?),
        appVersion: $checkedConvert('appVersion', (v) => v as String?),
        clientOccurredAt: $checkedConvert(
          'clientOccurredAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        deviceId: $checkedConvert('deviceId', (v) => v as String?),
        deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String?),
        isFirstLaunch: $checkedConvert('isFirstLaunch', (v) => v as bool?),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$SdkSessionLifecycleKindEnumMap, v),
        ),
        locale: $checkedConvert('locale', (v) => v as String?),
        metadata: $checkedConvert(
          'metadata',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecodeNullable(_$PlatformEnumMap, v),
        ),
        projectToken: $checkedConvert('projectToken', (v) => v as String?),
        sdkApiVersion: $checkedConvert('sdkApiVersion', (v) => v as String?),
        sdkPackageVersion: $checkedConvert(
          'sdkPackageVersion',
          (v) => v as String?,
        ),
        sessionId: $checkedConvert('sessionId', (v) => v as String),
        sessionRelativeTimeMs: $checkedConvert(
          'sessionRelativeTimeMs',
          (v) => v as num?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$SdkSessionDtoToJson(SdkSessionDto instance) =>
    <String, dynamic>{
      'appBuildNumber': ?instance.appBuildNumber,
      'appPackageName': ?instance.appPackageName,
      'appToken': ?instance.appToken,
      'appVersion': ?instance.appVersion,
      'clientOccurredAt': ?instance.clientOccurredAt?.toIso8601String(),
      'deviceId': ?instance.deviceId,
      'deviceIdSource': ?instance.deviceIdSource,
      'isFirstLaunch': ?instance.isFirstLaunch,
      'kind': _$SdkSessionLifecycleKindEnumMap[instance.kind]!,
      'locale': ?instance.locale,
      'metadata': ?instance.metadata,
      'platform': ?_$PlatformEnumMap[instance.platform],
      'projectToken': ?instance.projectToken,
      'sdkApiVersion': ?instance.sdkApiVersion,
      'sdkPackageVersion': ?instance.sdkPackageVersion,
      'sessionId': instance.sessionId,
      'sessionRelativeTimeMs': ?instance.sessionRelativeTimeMs,
    };

const _$SdkSessionLifecycleKindEnumMap = {
  SdkSessionLifecycleKind.start: 'start',
  SdkSessionLifecycleKind.heartbeat: 'heartbeat',
  SdkSessionLifecycleKind.pause: 'pause',
  SdkSessionLifecycleKind.resume: 'resume',
  SdkSessionLifecycleKind.end: 'end',
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
