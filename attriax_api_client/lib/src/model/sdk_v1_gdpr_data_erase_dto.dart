//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_gdpr_data_erase_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1GdprDataEraseDto {
  /// Returns a new [SdkV1GdprDataEraseDto] instance.
  SdkV1GdprDataEraseDto({required this.appToken, required this.deviceId});

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  /// Stable SDK device identifier for the installation whose identified data should be anonymized.
  @JsonKey(name: r'deviceId', required: true, includeIfNull: false)
  final String deviceId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1GdprDataEraseDto &&
          other.appToken == appToken &&
          other.deviceId == deviceId;

  @override
  int get hashCode => appToken.hashCode + deviceId.hashCode;

  factory SdkV1GdprDataEraseDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1GdprDataEraseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1GdprDataEraseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
