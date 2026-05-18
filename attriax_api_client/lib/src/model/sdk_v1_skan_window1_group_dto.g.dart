// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_skan_window1_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1SkanWindow1GroupDto _$SdkV1SkanWindow1GroupDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1SkanWindow1GroupDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['bitCount', 'events', 'id', 'startBit'],
  );
  final val = SdkV1SkanWindow1GroupDto(
    bitCount: $checkedConvert('bitCount', (v) => v as num),
    displayName: $checkedConvert('displayName', (v) => v),
    events: $checkedConvert(
      'events',
      (v) => (v as List<dynamic>)
          .map((e) => SdkV1SkanEventDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    id: $checkedConvert('id', (v) => v as String),
    startBit: $checkedConvert('startBit', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$SdkV1SkanWindow1GroupDtoToJson(
  SdkV1SkanWindow1GroupDto instance,
) => <String, dynamic>{
  'bitCount': instance.bitCount,
  'displayName': ?instance.displayName,
  'events': instance.events.map((e) => e.toJson()).toList(),
  'id': instance.id,
  'startBit': instance.startBit,
};
