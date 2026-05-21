//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/app_user_gdpr_consent_state.dart';
import 'package:attriax_api_client/src/model/sdk_gdpr_consent_values_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_gdpr_consent_status_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkGdprConsentStatusDto {
  /// Returns a new [SdkGdprConsentStatusDto] instance.
  SdkGdprConsentStatusDto({
    required this.checkedAt,

    this.countryCode,

    required this.needsConsent,

    this.regionSource,

    required this.state,

    this.values,
  });

  @JsonKey(name: r'checkedAt', required: true, includeIfNull: false)
  final DateTime checkedAt;

  @JsonKey(name: r'countryCode', required: false, includeIfNull: false)
  final String? countryCode;

  /// Whether the SDK should wait for an explicit GDPR decision before tracking.
  @JsonKey(name: r'needsConsent', required: true, includeIfNull: false)
  final bool needsConsent;

  @JsonKey(name: r'regionSource', required: false, includeIfNull: false)
  final String? regionSource;

  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final AppUserGdprConsentState state;

  @JsonKey(name: r'values', required: false, includeIfNull: false)
  final SdkGdprConsentValuesDto? values;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkGdprConsentStatusDto &&
          other.checkedAt == checkedAt &&
          other.countryCode == countryCode &&
          other.needsConsent == needsConsent &&
          other.regionSource == regionSource &&
          other.state == state &&
          other.values == values;

  @override
  int get hashCode =>
      checkedAt.hashCode +
      countryCode.hashCode +
      needsConsent.hashCode +
      regionSource.hashCode +
      state.hashCode +
      values.hashCode;

  factory SdkGdprConsentStatusDto.fromJson(Map<String, dynamic> json) =>
      _$SdkGdprConsentStatusDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkGdprConsentStatusDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
