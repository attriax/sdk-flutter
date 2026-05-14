// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_open_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1OpenDto _$SdkV1OpenDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkV1OpenDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'app',
          'appToken',
          'device',
          'deviceId',
          'platform',
          'sdk',
        ],
      );
      final val = SdkV1OpenDto(
        app: $checkedConvert(
          'app',
          (v) => AppVersionContextDto.fromJson(v as Map<String, dynamic>),
        ),
        appToken: $checkedConvert('appToken', (v) => v as String),
        device: $checkedConvert(
          'device',
          (v) => DeviceContextDto.fromJson(v as Map<String, dynamic>),
        ),
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String?),
        googlePlayInstantParam: $checkedConvert(
          'googlePlayInstantParam',
          (v) => v as bool?,
        ),
        installBeginTimestampSeconds: $checkedConvert(
          'installBeginTimestampSeconds',
          (v) => v as num?,
        ),
        installReferrer: $checkedConvert(
          'installReferrer',
          (v) => v as String?,
        ),
        isFirstLaunch: $checkedConvert('isFirstLaunch', (v) => v as bool?),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$PlatformEnumMap, v),
        ),
        referrerClickTimestampSeconds: $checkedConvert(
          'referrerClickTimestampSeconds',
          (v) => v as num?,
        ),
        sdk: $checkedConvert(
          'sdk',
          (v) => SdkVersionContextDto.fromJson(v as Map<String, dynamic>),
        ),
        sessionId: $checkedConvert('sessionId', (v) => v as String?),
        sessionStartedAt: $checkedConvert(
          'sessionStartedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SdkV1OpenDtoToJson(SdkV1OpenDto instance) =>
    <String, dynamic>{
      'app': instance.app.toJson(),
      'appToken': instance.appToken,
      'device': instance.device.toJson(),
      'deviceId': instance.deviceId,
      'deviceIdSource': ?instance.deviceIdSource,
      'googlePlayInstantParam': ?instance.googlePlayInstantParam,
      'installBeginTimestampSeconds': ?instance.installBeginTimestampSeconds,
      'installReferrer': ?instance.installReferrer,
      'isFirstLaunch': ?instance.isFirstLaunch,
      'platform': _$PlatformEnumMap[instance.platform]!,
      'referrerClickTimestampSeconds': ?instance.referrerClickTimestampSeconds,
      'sdk': instance.sdk.toJson(),
      'sessionId': ?instance.sessionId,
      'sessionStartedAt': ?instance.sessionStartedAt?.toIso8601String(),
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
