// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_skan_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1SkanEventDto _$SdkV1SkanEventDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkV1SkanEventDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['conditions', 'eventName', 'id']);
      final val = SdkV1SkanEventDto(
        coarseValue: $checkedConvert(
          'coarseValue',
          (v) => $enumDecodeNullable(_$SdkV1SkanCoarseValueEnumMap, v),
        ),
        conditions: $checkedConvert(
          'conditions',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    SdkV1SkanConditionDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        displayName: $checkedConvert('displayName', (v) => v),
        eventName: $checkedConvert('eventName', (v) => v as String),
        id: $checkedConvert('id', (v) => v as String),
        lockWindow: $checkedConvert('lockWindow', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$SdkV1SkanEventDtoToJson(SdkV1SkanEventDto instance) =>
    <String, dynamic>{
      'coarseValue': ?_$SdkV1SkanCoarseValueEnumMap[instance.coarseValue],
      'conditions': instance.conditions.map((e) => e.toJson()).toList(),
      'displayName': ?instance.displayName,
      'eventName': instance.eventName,
      'id': instance.id,
      'lockWindow': ?instance.lockWindow,
    };

const _$SdkV1SkanCoarseValueEnumMap = {
  SdkV1SkanCoarseValue.low: 'low',
  SdkV1SkanCoarseValue.medium: 'medium',
  SdkV1SkanCoarseValue.high: 'high',
};
