// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_skan_window1_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1SkanWindow1Dto _$SdkV1SkanWindow1DtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkV1SkanWindow1Dto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['groups']);
      final val = SdkV1SkanWindow1Dto(
        groups: $checkedConvert(
          'groups',
          (v) => (v as List<dynamic>)
              .map(
                (e) => SdkV1SkanWindow1GroupDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SdkV1SkanWindow1DtoToJson(
  SdkV1SkanWindow1Dto instance,
) => <String, dynamic>{
  'groups': instance.groups.map((e) => e.toJson()).toList(),
};
