//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_config_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1ConfigResponseDto {
  /// Returns a new [SdkV1ConfigResponseDto] instance.
  SdkV1ConfigResponseDto({
    required this.acceptedAt,

    required this.clipboardAttributionEnabled,

    required this.requestVersion,
  });

  @JsonKey(name: r'acceptedAt', required: true, includeIfNull: false)
  final DateTime acceptedAt;

  @JsonKey(
    name: r'clipboardAttributionEnabled',
    required: true,
    includeIfNull: false,
  )
  final bool clipboardAttributionEnabled;

  @JsonKey(name: r'requestVersion', required: true, includeIfNull: false)
  final String requestVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1ConfigResponseDto &&
          other.acceptedAt == acceptedAt &&
          other.clipboardAttributionEnabled == clipboardAttributionEnabled &&
          other.requestVersion == requestVersion;

  @override
  int get hashCode =>
      acceptedAt.hashCode +
      clipboardAttributionEnabled.hashCode +
      requestVersion.hashCode;

  factory SdkV1ConfigResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1ConfigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1ConfigResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
