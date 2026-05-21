//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_gdpr_consent_values_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkGdprConsentValuesDto {
  /// Returns a new [SdkGdprConsentValuesDto] instance.
  SdkGdprConsentValuesDto({
    required this.adEvents,

    required this.analytics,

    required this.attribution,
  });

  @JsonKey(name: r'adEvents', required: true, includeIfNull: false)
  final bool adEvents;

  @JsonKey(name: r'analytics', required: true, includeIfNull: false)
  final bool analytics;

  @JsonKey(name: r'attribution', required: true, includeIfNull: false)
  final bool attribution;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkGdprConsentValuesDto &&
          other.adEvents == adEvents &&
          other.analytics == analytics &&
          other.attribution == attribution;

  @override
  int get hashCode =>
      adEvents.hashCode + analytics.hashCode + attribution.hashCode;

  factory SdkGdprConsentValuesDto.fromJson(Map<String, dynamic> json) =>
      _$SdkGdprConsentValuesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkGdprConsentValuesDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
