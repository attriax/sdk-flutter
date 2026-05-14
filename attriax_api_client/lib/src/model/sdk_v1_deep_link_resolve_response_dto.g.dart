// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_deep_link_resolve_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1DeepLinkResolveResponseDto _$SdkV1DeepLinkResolveResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1DeepLinkResolveResponseDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'acceptedAt',
      'consumedAt',
      'isFirstLaunch',
      'matched',
      'requestVersion',
      'status',
    ],
  );
  final val = SdkV1DeepLinkResolveResponseDto(
    acceptedAt: $checkedConvert(
      'acceptedAt',
      (v) => DateTime.parse(v as String),
    ),
    consumedAt: $checkedConvert(
      'consumedAt',
      (v) => DateTime.parse(v as String),
    ),
    deepLink: $checkedConvert(
      'deepLink',
      (v) => v == null
          ? null
          : SdkJsonDeepLinkDto.fromJson(v as Map<String, dynamic>),
    ),
    isFirstLaunch: $checkedConvert('isFirstLaunch', (v) => v as bool),
    matched: $checkedConvert('matched', (v) => v as bool),
    reason: $checkedConvert('reason', (v) => v as String?),
    requestVersion: $checkedConvert('requestVersion', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$DeepLinkResolutionStatusEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$SdkV1DeepLinkResolveResponseDtoToJson(
  SdkV1DeepLinkResolveResponseDto instance,
) => <String, dynamic>{
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'consumedAt': instance.consumedAt.toIso8601String(),
  'deepLink': ?instance.deepLink?.toJson(),
  'isFirstLaunch': instance.isFirstLaunch,
  'matched': instance.matched,
  'reason': ?instance.reason,
  'requestVersion': instance.requestVersion,
  'status': _$DeepLinkResolutionStatusEnumMap[instance.status]!,
};

const _$DeepLinkResolutionStatusEnumMap = {
  DeepLinkResolutionStatus.matched: 'matched',
  DeepLinkResolutionStatus.unmatched: 'unmatched',
  DeepLinkResolutionStatus.invalid: 'invalid',
};
