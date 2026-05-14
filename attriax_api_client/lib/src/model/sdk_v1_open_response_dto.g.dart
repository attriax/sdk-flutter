// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_open_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1OpenResponseDto _$SdkV1OpenResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1OpenResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'acceptedAt',
      'installState',
      'isFirstLaunch',
      'isNewUser',
      'requestVersion',
      'userId',
    ],
  );
  final val = SdkV1OpenResponseDto(
    acceptedAt: $checkedConvert(
      'acceptedAt',
      (v) => DateTime.parse(v as String),
    ),
    deepLink: $checkedConvert(
      'deepLink',
      (v) => v == null
          ? null
          : SdkJsonDeepLinkDto.fromJson(v as Map<String, dynamic>),
    ),
    deepLinkClickedAt: $checkedConvert(
      'deepLinkClickedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    deepLinkConsumedAt: $checkedConvert(
      'deepLinkConsumedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    installReferrer: $checkedConvert(
      'installReferrer',
      (v) => v == null
          ? null
          : SdkInstallReferrerResultDto.fromJson(v as Map<String, dynamic>),
    ),
    installState: $checkedConvert(
      'installState',
      (v) => $enumDecode(_$SdkInstallStateEnumMap, v),
    ),
    isFirstLaunch: $checkedConvert('isFirstLaunch', (v) => v as bool),
    isNewUser: $checkedConvert('isNewUser', (v) => v as bool),
    originalInstallReferrer: $checkedConvert(
      'originalInstallReferrer',
      (v) => v == null
          ? null
          : SdkInstallReferrerResultDto.fromJson(v as Map<String, dynamic>),
    ),
    reinstallReferrer: $checkedConvert(
      'reinstallReferrer',
      (v) => v == null
          ? null
          : SdkInstallReferrerResultDto.fromJson(v as Map<String, dynamic>),
    ),
    requestVersion: $checkedConvert('requestVersion', (v) => v as String),
    userId: $checkedConvert('userId', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SdkV1OpenResponseDtoToJson(
  SdkV1OpenResponseDto instance,
) => <String, dynamic>{
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'deepLink': ?instance.deepLink?.toJson(),
  'deepLinkClickedAt': ?instance.deepLinkClickedAt?.toIso8601String(),
  'deepLinkConsumedAt': ?instance.deepLinkConsumedAt?.toIso8601String(),
  'installReferrer': ?instance.installReferrer?.toJson(),
  'installState': _$SdkInstallStateEnumMap[instance.installState]!,
  'isFirstLaunch': instance.isFirstLaunch,
  'isNewUser': instance.isNewUser,
  'originalInstallReferrer': ?instance.originalInstallReferrer?.toJson(),
  'reinstallReferrer': ?instance.reinstallReferrer?.toJson(),
  'requestVersion': instance.requestVersion,
  'userId': instance.userId,
};

const _$SdkInstallStateEnumMap = {
  SdkInstallState.existing: 'existing',
  SdkInstallState.newInstall: 'new_install',
  SdkInstallState.reinstall: 'reinstall',
  SdkInstallState.appDataClear: 'app_data_clear',
};
