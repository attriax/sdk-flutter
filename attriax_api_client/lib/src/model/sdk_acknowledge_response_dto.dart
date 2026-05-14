//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_acknowledge_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkAcknowledgeResponseDto {
  /// Returns a new [SdkAcknowledgeResponseDto] instance.
  SdkAcknowledgeResponseDto({required this.success});

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkAcknowledgeResponseDto && other.success == success;

  @override
  int get hashCode => success.hashCode;

  factory SdkAcknowledgeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SdkAcknowledgeResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkAcknowledgeResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
