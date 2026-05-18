//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_skan_rule_operator.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_skan_condition_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1SkanConditionDto {
  /// Returns a new [SdkV1SkanConditionDto] instance.
  SdkV1SkanConditionDto({
    required this.id,

    required this.operator_,

    required this.paramKey,

    this.value,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'operator', required: true, includeIfNull: false)
  final SdkV1SkanRuleOperator operator_;

  @JsonKey(name: r'paramKey', required: true, includeIfNull: false)
  final String paramKey;

  /// JSON scalar used by the SDK when evaluating this condition.
  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final Object? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1SkanConditionDto &&
          other.id == id &&
          other.operator_ == operator_ &&
          other.paramKey == paramKey &&
          other.value == value;

  @override
  int get hashCode =>
      id.hashCode + operator_.hashCode + paramKey.hashCode + value.hashCode;

  factory SdkV1SkanConditionDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1SkanConditionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1SkanConditionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
