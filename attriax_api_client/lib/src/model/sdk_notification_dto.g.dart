// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkNotificationDto _$SdkNotificationDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkNotificationDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['notificationId', 'platform', 'type']);
  final val = SdkNotificationDto(
    appToken: $checkedConvert('appToken', (v) => v as String?),
    campaignId: $checkedConvert('campaignId', (v) => v as String?),
    deviceId: $checkedConvert('deviceId', (v) => v as String?),
    deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String?),
    linkId: $checkedConvert('linkId', (v) => v as String?),
    metadata: $checkedConvert(
      'metadata',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    notificationId: $checkedConvert('notificationId', (v) => v as String),
    occurredAt: $checkedConvert(
      'occurredAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    platform: $checkedConvert(
      'platform',
      (v) => $enumDecode(_$PlatformEnumMap, v),
    ),
    projectToken: $checkedConvert('projectToken', (v) => v as String?),
    sessionId: $checkedConvert('sessionId', (v) => v as String?),
    source_: $checkedConvert(
      'source',
      (v) => $enumDecodeNullable(_$NotificationEventSourceEnumMap, v),
    ),
    title: $checkedConvert('title', (v) => v as String?),
    type: $checkedConvert(
      'type',
      (v) => $enumDecode(_$NotificationEventTypeEnumMap, v),
    ),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$SdkNotificationDtoToJson(SdkNotificationDto instance) =>
    <String, dynamic>{
      'appToken': ?instance.appToken,
      'campaignId': ?instance.campaignId,
      'deviceId': ?instance.deviceId,
      'deviceIdSource': ?instance.deviceIdSource,
      'linkId': ?instance.linkId,
      'metadata': ?instance.metadata,
      'notificationId': instance.notificationId,
      'occurredAt': ?instance.occurredAt?.toIso8601String(),
      'platform': _$PlatformEnumMap[instance.platform]!,
      'projectToken': ?instance.projectToken,
      'sessionId': ?instance.sessionId,
      'source': ?_$NotificationEventSourceEnumMap[instance.source_],
      'title': ?instance.title,
      'type': _$NotificationEventTypeEnumMap[instance.type]!,
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

const _$NotificationEventSourceEnumMap = {
  NotificationEventSource.fcm: 'fcm',
  NotificationEventSource.apns: 'apns',
  NotificationEventSource.other: 'other',
};

const _$NotificationEventTypeEnumMap = {
  NotificationEventType.received: 'received',
  NotificationEventType.opened: 'opened',
  NotificationEventType.dismissed: 'dismissed',
};
