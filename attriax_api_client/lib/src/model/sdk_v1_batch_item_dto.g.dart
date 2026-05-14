// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_batch_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1BatchItemDto _$SdkV1BatchItemDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkV1BatchItemDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['body', 'kind']);
      final val = SdkV1BatchItemDto(
        body: $checkedConvert(
          'body',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$SdkBatchItemKindEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SdkV1BatchItemDtoToJson(SdkV1BatchItemDto instance) =>
    <String, dynamic>{
      'body': instance.body,
      'kind': _$SdkBatchItemKindEnumMap[instance.kind]!,
    };

const _$SdkBatchItemKindEnumMap = {
  SdkBatchItemKind.event: 'event',
  SdkBatchItemKind.session: 'session',
  SdkBatchItemKind.user: 'user',
};
