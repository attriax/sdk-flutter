//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/app_user_gdpr_consent_state.dart';
import 'package:attriax_api_client/src/model/sdk_v1_gdpr_consent_values_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_gdpr_consent_write_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1GdprConsentWriteDto {
  /// Returns a new [SdkV1GdprConsentWriteDto] instance.
  SdkV1GdprConsentWriteDto({
    required this.appToken,

    this.clientOccurredAt,

    this.consentId,

    this.countryCode,

    this.regionSource,

    required this.state,

    this.values,
  });

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'clientOccurredAt', required: false, includeIfNull: false)
  final DateTime? clientOccurredAt;

  @JsonKey(name: r'consentId', required: false, includeIfNull: false)
  final String? consentId;

  @JsonKey(name: r'countryCode', required: false, includeIfNull: false)
  final String? countryCode;

  @JsonKey(name: r'regionSource', required: false, includeIfNull: false)
  final String? regionSource;

  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final AppUserGdprConsentState state;

  @JsonKey(name: r'values', required: false, includeIfNull: false)
  final SdkV1GdprConsentValuesDto? values;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1GdprConsentWriteDto &&
          other.appToken == appToken &&
          other.clientOccurredAt == clientOccurredAt &&
          other.consentId == consentId &&
          other.countryCode == countryCode &&
          other.regionSource == regionSource &&
          other.state == state &&
          other.values == values;

  @override
  int get hashCode =>
      appToken.hashCode +
      clientOccurredAt.hashCode +
      consentId.hashCode +
      countryCode.hashCode +
      regionSource.hashCode +
      state.hashCode +
      values.hashCode;

  factory SdkV1GdprConsentWriteDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1GdprConsentWriteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1GdprConsentWriteDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
