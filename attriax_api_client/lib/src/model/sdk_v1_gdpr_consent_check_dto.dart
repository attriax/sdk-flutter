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
  SdkV1GdprConsentCheckDto({required this.appToken, this.consentId});

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'consentId', required: false, includeIfNull: false)
  final String? consentId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1GdprConsentCheckDto &&
          other.appToken == appToken &&
          other.consentId == consentId;

  @override
  int get hashCode => appToken.hashCode + consentId.hashCode;

  factory SdkV1GdprConsentCheckDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1GdprConsentCheckDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1GdprConsentCheckDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
