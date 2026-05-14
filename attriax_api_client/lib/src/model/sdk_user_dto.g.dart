// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkUserDto _$SdkUserDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkUserDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['appToken', 'deviceId']);
  final val = SdkUserDto(
    appToken: $checkedConvert('appToken', (v) => v as String),
    clearAllProperties: $checkedConvert(
      'clearAllProperties',
      (v) => v as bool?,
    ),
    clearExternalUser: $checkedConvert('clearExternalUser', (v) => v as bool?),
    clearPropertyKeys: $checkedConvert(
      'clearPropertyKeys',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    deviceId: $checkedConvert('deviceId', (v) => v as String),
    deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String?),
    externalUserId: $checkedConvert('externalUserId', (v) => v as String?),
    externalUserName: $checkedConvert('externalUserName', (v) => v as String?),
    properties: $checkedConvert(
      'properties',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$SdkUserDtoToJson(SdkUserDto instance) =>
    <String, dynamic>{
      'appToken': instance.appToken,
      'clearAllProperties': ?instance.clearAllProperties,
      'clearExternalUser': ?instance.clearExternalUser,
      'clearPropertyKeys': ?instance.clearPropertyKeys,
      'deviceId': instance.deviceId,
      'deviceIdSource': ?instance.deviceIdSource,
      'externalUserId': ?instance.externalUserId,
      'externalUserName': ?instance.externalUserName,
      'properties': ?instance.properties,
    };
