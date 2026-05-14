//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_utm_payload_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkUtmPayloadDto {
  /// Returns a new [SdkUtmPayloadDto] instance.
  SdkUtmPayloadDto({
    this.campaign,

    this.content,

    this.medium,

    this.source_,

    this.term,
  });

  @JsonKey(name: r'campaign', required: false, includeIfNull: false)
  final String? campaign;

  @JsonKey(name: r'content', required: false, includeIfNull: false)
  final String? content;

  @JsonKey(name: r'medium', required: false, includeIfNull: false)
  final String? medium;

  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final String? source_;

  @JsonKey(name: r'term', required: false, includeIfNull: false)
  final String? term;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkUtmPayloadDto &&
          other.campaign == campaign &&
          other.content == content &&
          other.medium == medium &&
          other.source_ == source_ &&
          other.term == term;

  @override
  int get hashCode =>
      campaign.hashCode +
      content.hashCode +
      medium.hashCode +
      source_.hashCode +
      term.hashCode;

  factory SdkUtmPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$SdkUtmPayloadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkUtmPayloadDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
