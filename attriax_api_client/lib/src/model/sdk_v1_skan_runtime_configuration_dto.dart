//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_skan_schema_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_skan_runtime_configuration_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1SkanRuntimeConfigurationDto {
  /// Returns a new [SdkV1SkanRuntimeConfigurationDto] instance.
  SdkV1SkanRuntimeConfigurationDto({
    required this.enabled,

    this.lastUpdatedAt,

    this.schema,
  });

  @JsonKey(name: r'enabled', required: true, includeIfNull: false)
  final bool enabled;

  @JsonKey(name: r'lastUpdatedAt', required: false, includeIfNull: false)
  final Object? lastUpdatedAt;

  @JsonKey(name: r'schema', required: false, includeIfNull: false)
  final SdkV1SkanSchemaDto? schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1SkanRuntimeConfigurationDto &&
          other.enabled == enabled &&
          other.lastUpdatedAt == lastUpdatedAt &&
          other.schema == schema;

  @override
  int get hashCode =>
      enabled.hashCode +
      (lastUpdatedAt == null ? 0 : lastUpdatedAt.hashCode) +
      (schema == null ? 0 : schema.hashCode);

  factory SdkV1SkanRuntimeConfigurationDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SdkV1SkanRuntimeConfigurationDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkV1SkanRuntimeConfigurationDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
