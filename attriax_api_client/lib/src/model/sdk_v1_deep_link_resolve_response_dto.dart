//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_json_deep_link_dto.dart';
import 'package:attriax_api_client/src/model/deep_link_resolution_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_deep_link_resolve_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1DeepLinkResolveResponseDto {
  /// Returns a new [SdkV1DeepLinkResolveResponseDto] instance.
  SdkV1DeepLinkResolveResponseDto({
    required this.acceptedAt,

    required this.consumedAt,

    this.deepLink,

    required this.isFirstLaunch,

    required this.matched,

    this.reason,

    required this.requestVersion,

    required this.status,
  });

  @JsonKey(name: r'acceptedAt', required: true, includeIfNull: false)
  final DateTime acceptedAt;

  @JsonKey(name: r'consumedAt', required: true, includeIfNull: false)
  final DateTime consumedAt;

  @JsonKey(name: r'deepLink', required: false, includeIfNull: false)
  final SdkJsonDeepLinkDto? deepLink;

  @JsonKey(name: r'isFirstLaunch', required: true, includeIfNull: false)
  final bool isFirstLaunch;

  @JsonKey(name: r'matched', required: true, includeIfNull: false)
  final bool matched;

  @JsonKey(name: r'reason', required: false, includeIfNull: false)
  final String? reason;

  @JsonKey(name: r'requestVersion', required: true, includeIfNull: false)
  final String requestVersion;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final DeepLinkResolutionStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1DeepLinkResolveResponseDto &&
          other.acceptedAt == acceptedAt &&
          other.consumedAt == consumedAt &&
          other.deepLink == deepLink &&
          other.isFirstLaunch == isFirstLaunch &&
          other.matched == matched &&
          other.reason == reason &&
          other.requestVersion == requestVersion &&
          other.status == status;

  @override
  int get hashCode =>
      acceptedAt.hashCode +
      consumedAt.hashCode +
      (deepLink == null ? 0 : deepLink.hashCode) +
      isFirstLaunch.hashCode +
      matched.hashCode +
      (reason == null ? 0 : reason.hashCode) +
      requestVersion.hashCode +
      status.hashCode;

  factory SdkV1DeepLinkResolveResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1DeepLinkResolveResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkV1DeepLinkResolveResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
