// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_skan_condition_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1SkanConditionDto _$SdkV1SkanConditionDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1SkanConditionDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'operator', 'paramKey']);
  final val = SdkV1SkanConditionDto(
    id: $checkedConvert('id', (v) => v as String),
    operator_: $checkedConvert(
      'operator',
      (v) => $enumDecode(_$SdkV1SkanRuleOperatorEnumMap, v),
    ),
    paramKey: $checkedConvert('paramKey', (v) => v as String),
    value: $checkedConvert('value', (v) => v),
  );
  return val;
}, fieldKeyMap: const {'operator_': 'operator'});

Map<String, dynamic> _$SdkV1SkanConditionDtoToJson(
  SdkV1SkanConditionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'operator': _$SdkV1SkanRuleOperatorEnumMap[instance.operator_]!,
  'paramKey': instance.paramKey,
  'value': ?instance.value,
};

const _$SdkV1SkanRuleOperatorEnumMap = {
  SdkV1SkanRuleOperator.exists: 'exists',
  SdkV1SkanRuleOperator.eq: 'eq',
  SdkV1SkanRuleOperator.notEq: 'not_eq',
  SdkV1SkanRuleOperator.gt: 'gt',
  SdkV1SkanRuleOperator.gte: 'gte',
  SdkV1SkanRuleOperator.lt: 'lt',
  SdkV1SkanRuleOperator.lte: 'lte',
  SdkV1SkanRuleOperator.contains: 'contains',
};
