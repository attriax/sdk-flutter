//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_version_context_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkVersionContextDto {
  /// Returns a new [SdkVersionContextDto] instance.
  SdkVersionContextDto({
    required this.apiVersion,

    this.metadata,

    required this.packageVersion,
  });

  @JsonKey(name: r'apiVersion', required: true, includeIfNull: false)
  final String apiVersion;

  @JsonKey(name: r'metadata', required: false, includeIfNull: false)
  final Map<String, Object>? metadata;

  @JsonKey(name: r'packageVersion', required: true, includeIfNull: false)
  final String packageVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkVersionContextDto &&
          other.apiVersion == apiVersion &&
          other.metadata == metadata &&
          other.packageVersion == packageVersion;

  @override
  int get hashCode =>
      apiVersion.hashCode + metadata.hashCode + packageVersion.hashCode;

  factory SdkVersionContextDto.fromJson(Map<String, dynamic> json) =>
      _$SdkVersionContextDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkVersionContextDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
