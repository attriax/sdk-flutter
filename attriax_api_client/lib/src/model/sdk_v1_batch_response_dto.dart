//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_batch_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1BatchResponseDto {
  /// Returns a new [SdkV1BatchResponseDto] instance.
  SdkV1BatchResponseDto({
    required this.acceptedAt,

    required this.duplicateCount,

    required this.itemCount,

    required this.processedCount,

    required this.requestVersion,
  });

  @JsonKey(name: r'acceptedAt', required: true, includeIfNull: false)
  final DateTime acceptedAt;

  @JsonKey(name: r'duplicateCount', required: true, includeIfNull: false)
  final num duplicateCount;

  @JsonKey(name: r'itemCount', required: true, includeIfNull: false)
  final num itemCount;

  @JsonKey(name: r'processedCount', required: true, includeIfNull: false)
  final num processedCount;

  @JsonKey(name: r'requestVersion', required: true, includeIfNull: false)
  final String requestVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1BatchResponseDto &&
          other.acceptedAt == acceptedAt &&
          other.duplicateCount == duplicateCount &&
          other.itemCount == itemCount &&
          other.processedCount == processedCount &&
          other.requestVersion == requestVersion;

  @override
  int get hashCode =>
      acceptedAt.hashCode +
      duplicateCount.hashCode +
      itemCount.hashCode +
      processedCount.hashCode +
      requestVersion.hashCode;

  factory SdkV1BatchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1BatchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1BatchResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
