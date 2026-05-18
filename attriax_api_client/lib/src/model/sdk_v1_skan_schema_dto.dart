//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_skan_window1_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_coarse_window_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_skan_schema_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1SkanSchemaDto {
  /// Returns a new [SdkV1SkanSchemaDto] instance.
  SdkV1SkanSchemaDto({
    this.updatedAt,

    required this.version,

    required this.window1,

    required this.window2,

    required this.window3,
  });

  @JsonKey(name: r'updatedAt', required: false, includeIfNull: false)
  final Object? updatedAt;

  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final num version;

  @JsonKey(name: r'window1', required: true, includeIfNull: false)
  final SdkV1SkanWindow1Dto window1;

  @JsonKey(name: r'window2', required: true, includeIfNull: false)
  final SdkV1SkanCoarseWindowDto window2;

  @JsonKey(name: r'window3', required: true, includeIfNull: false)
  final SdkV1SkanCoarseWindowDto window3;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1SkanSchemaDto &&
          other.updatedAt == updatedAt &&
          other.version == version &&
          other.window1 == window1 &&
          other.window2 == window2 &&
          other.window3 == window3;

  @override
  int get hashCode =>
      (updatedAt == null ? 0 : updatedAt.hashCode) +
      version.hashCode +
      window1.hashCode +
      window2.hashCode +
      window3.hashCode;

  factory SdkV1SkanSchemaDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1SkanSchemaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1SkanSchemaDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
