// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkEventDto _$SdkEventDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkEventDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['appToken', 'deviceId', 'eventName']);
  final val = SdkEventDto(
    appToken: $checkedConvert('appToken', (v) => v as String),
    clientOccurredAt: $checkedConvert(
      'clientOccurredAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    deviceId: $checkedConvert('deviceId', (v) => v as String),
    deviceIdSource: $checkedConvert('deviceIdSource', (v) => v as String?),
    eventData: $checkedConvert(
      'eventData',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    eventName: $checkedConvert('eventName', (v) => v as String),
    sessionId: $checkedConvert('sessionId', (v) => v as String?),
    sessionRelativeTimeMs: $checkedConvert(
      'sessionRelativeTimeMs',
      (v) => v as num?,
    ),
  );
  return val;
});

Map<String, dynamic> _$SdkEventDtoToJson(SdkEventDto instance) =>
    <String, dynamic>{
      'appToken': instance.appToken,
      'clientOccurredAt': ?instance.clientOccurredAt?.toIso8601String(),
      'deviceId': instance.deviceId,
      'deviceIdSource': ?instance.deviceIdSource,
      'eventData': ?instance.eventData,
      'eventName': instance.eventName,
      'sessionId': ?instance.sessionId,
      'sessionRelativeTimeMs': ?instance.sessionRelativeTimeMs,
    };
