// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_crash_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkCrashDto _$SdkCrashDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkCrashDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'appToken',
          'clientOccurredAt',
          'deviceId',
          'deviceIdSource',
          'exceptionType',
          'isFatal',
          'isFirstLaunch',
          'message',
          'platform',
          'source',
          'stackTrace',
        ],
      );
      final val = SdkCrashDto(
        appBuildNumber: $checkedConvert('appBuildNumber', (v) => v as String?),
        appPackageName: $checkedConvert('appPackageName', (v) => v as String?),
        appToken: $checkedConvert('appToken', (v) => v as String),
        appVersion: $checkedConvert('appVersion', (v) => v as String?),
        clientOccurredAt: $checkedConvert(
          'clientOccurredAt',
          (v) => DateTime.parse(v as String),
        ),
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String),
        exceptionType: $checkedConvert('exceptionType', (v) => v as String),
        isFatal: $checkedConvert('isFatal', (v) => v as bool),
        isFirstLaunch: $checkedConvert('isFirstLaunch', (v) => v as bool),
        locale: $checkedConvert('locale', (v) => v as String?),
        message: $checkedConvert('message', (v) => v as String),
        metadata: $checkedConvert(
          'metadata',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$PlatformEnumMap, v),
        ),
        reason: $checkedConvert('reason', (v) => v as String?),
        sdkApiVersion: $checkedConvert('sdkApiVersion', (v) => v as String?),
        sdkPackageVersion: $checkedConvert(
          'sdkPackageVersion',
          (v) => v as String?,
        ),
        sessionId: $checkedConvert('sessionId', (v) => v as String?),
        sessionRelativeTimeMs: $checkedConvert(
          'sessionRelativeTimeMs',
          (v) => v as num?,
        ),
        source_: $checkedConvert('source', (v) => v as String),
        stackTrace: $checkedConvert('stackTrace', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$SdkCrashDtoToJson(SdkCrashDto instance) =>
    <String, dynamic>{
      'appBuildNumber': ?instance.appBuildNumber,
      'appPackageName': ?instance.appPackageName,
      'appToken': instance.appToken,
      'appVersion': ?instance.appVersion,
      'clientOccurredAt': instance.clientOccurredAt.toIso8601String(),
      'deviceId': instance.deviceId,
      'deviceIdSource': instance.deviceIdSource,
      'exceptionType': instance.exceptionType,
      'isFatal': instance.isFatal,
      'isFirstLaunch': instance.isFirstLaunch,
      'locale': ?instance.locale,
      'message': instance.message,
      'metadata': ?instance.metadata,
      'platform': _$PlatformEnumMap[instance.platform]!,
      'reason': ?instance.reason,
      'sdkApiVersion': ?instance.sdkApiVersion,
      'sdkPackageVersion': ?instance.sdkPackageVersion,
      'sessionId': ?instance.sessionId,
      'sessionRelativeTimeMs': ?instance.sessionRelativeTimeMs,
      'source': instance.source_,
      'stackTrace': instance.stackTrace,
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
