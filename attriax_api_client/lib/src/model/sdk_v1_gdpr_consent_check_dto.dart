//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_gdpr_consent_check_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1GdprConsentCheckDto {
  /// Returns a new [SdkV1GdprConsentCheckDto] instance.
  SdkV1GdprConsentCheckDto({this.appToken, this.consentId, this.projectToken});

  /// Deprecated alias for projectToken kept for released SDK compatibility.
  @Deprecated('appToken has been deprecated')
  @JsonKey(name: r'appToken', required: false, includeIfNull: false)
  final String? appToken;

  @JsonKey(name: r'consentId', required: false, includeIfNull: false)
  final String? consentId;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1GdprConsentCheckDto &&
          other.appToken == appToken &&
          other.consentId == consentId &&
          other.projectToken == projectToken;

  @override
  int get hashCode =>
      appToken.hashCode + consentId.hashCode + projectToken.hashCode;

  factory SdkV1GdprConsentCheckDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1GdprConsentCheckDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1GdprConsentCheckDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
