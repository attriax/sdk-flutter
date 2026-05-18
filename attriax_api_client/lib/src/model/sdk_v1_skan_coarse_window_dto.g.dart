// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_skan_coarse_window_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1SkanCoarseWindowDto _$SdkV1SkanCoarseWindowDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1SkanCoarseWindowDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['events']);
  final val = SdkV1SkanCoarseWindowDto(
    events: $checkedConvert(
      'events',
      (v) => (v as List<dynamic>)
          .map(
            (e) => SdkV1SkanCoarseWindowEventDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SdkV1SkanCoarseWindowDtoToJson(
  SdkV1SkanCoarseWindowDto instance,
) => <String, dynamic>{
  'events': instance.events.map((e) => e.toJson()).toList(),
};
