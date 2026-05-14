//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_dynamic_link_record_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_create_dynamic_link_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkCreateDynamicLinkResponseDto {
  /// Returns a new [SdkCreateDynamicLinkResponseDto] instance.
  SdkCreateDynamicLinkResponseDto({
    required this.acceptedAt,

    required this.link,

    required this.requestVersion,
  });

  @JsonKey(name: r'acceptedAt', required: true, includeIfNull: false)
  final DateTime acceptedAt;

  @JsonKey(name: r'link', required: true, includeIfNull: false)
  final SdkDynamicLinkRecordDto link;

  @JsonKey(name: r'requestVersion', required: true, includeIfNull: false)
  final String requestVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkCreateDynamicLinkResponseDto &&
          other.acceptedAt == acceptedAt &&
          other.link == link &&
          other.requestVersion == requestVersion;

  @override
  int get hashCode =>
      acceptedAt.hashCode + link.hashCode + requestVersion.hashCode;

  factory SdkCreateDynamicLinkResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SdkCreateDynamicLinkResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkCreateDynamicLinkResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
