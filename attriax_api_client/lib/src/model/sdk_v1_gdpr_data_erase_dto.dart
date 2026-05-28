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
  SdkV1GdprDataEraseDto({
    this.appToken,

    required this.deviceId,

    this.projectToken,
  });

  /// Deprecated alias for projectToken kept for released SDK compatibility.
  @Deprecated('appToken has been deprecated')
  @JsonKey(name: r'appToken', required: false, includeIfNull: false)
  final String? appToken;

  /// Stable SDK device identifier for the installation whose identified data should be anonymized.
  @JsonKey(name: r'deviceId', required: true, includeIfNull: false)
  final String deviceId;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1GdprDataEraseDto &&
          other.appToken == appToken &&
          other.deviceId == deviceId &&
          other.projectToken == projectToken;

  @override
  int get hashCode =>
      appToken.hashCode + deviceId.hashCode + projectToken.hashCode;

  factory SdkV1GdprDataEraseDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1GdprDataEraseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1GdprDataEraseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
