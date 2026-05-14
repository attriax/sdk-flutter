//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_install_referrer_result_dto.dart';
import 'package:attriax_api_client/src/model/sdk_json_deep_link_dto.dart';
import 'package:attriax_api_client/src/model/sdk_install_state.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_open_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1OpenResponseDto {
  /// Returns a new [SdkV1OpenResponseDto] instance.
  SdkV1OpenResponseDto({
    required this.acceptedAt,

    this.deepLink,

    this.deepLinkClickedAt,

    this.deepLinkConsumedAt,

    this.installReferrer,

    required this.installState,

    required this.isFirstLaunch,

    required this.isNewUser,

    this.originalInstallReferrer,

    this.reinstallReferrer,

    required this.requestVersion,

    required this.userId,
  });

  @JsonKey(name: r'acceptedAt', required: true, includeIfNull: false)
  final DateTime acceptedAt;

  @JsonKey(name: r'deepLink', required: false, includeIfNull: false)
  final SdkJsonDeepLinkDto? deepLink;

  @JsonKey(name: r'deepLinkClickedAt', required: false, includeIfNull: false)
  final DateTime? deepLinkClickedAt;

  @JsonKey(name: r'deepLinkConsumedAt', required: false, includeIfNull: false)
  final DateTime? deepLinkConsumedAt;

  @JsonKey(name: r'installReferrer', required: false, includeIfNull: false)
  final SdkInstallReferrerResultDto? installReferrer;

  @JsonKey(name: r'installState', required: true, includeIfNull: false)
  final SdkInstallState installState;

  @JsonKey(name: r'isFirstLaunch', required: true, includeIfNull: false)
  final bool isFirstLaunch;

  @JsonKey(name: r'isNewUser', required: true, includeIfNull: false)
  final bool isNewUser;

  @JsonKey(
    name: r'originalInstallReferrer',
    required: false,
    includeIfNull: false,
  )
  final SdkInstallReferrerResultDto? originalInstallReferrer;

  @JsonKey(name: r'reinstallReferrer', required: false, includeIfNull: false)
  final SdkInstallReferrerResultDto? reinstallReferrer;

  @JsonKey(name: r'requestVersion', required: true, includeIfNull: false)
  final String requestVersion;

  @JsonKey(name: r'userId', required: true, includeIfNull: false)
  final String userId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1OpenResponseDto &&
          other.acceptedAt == acceptedAt &&
          other.deepLink == deepLink &&
          other.deepLinkClickedAt == deepLinkClickedAt &&
          other.deepLinkConsumedAt == deepLinkConsumedAt &&
          other.installReferrer == installReferrer &&
          other.installState == installState &&
          other.isFirstLaunch == isFirstLaunch &&
          other.isNewUser == isNewUser &&
          other.originalInstallReferrer == originalInstallReferrer &&
          other.reinstallReferrer == reinstallReferrer &&
          other.requestVersion == requestVersion &&
          other.userId == userId;

  @override
  int get hashCode =>
      acceptedAt.hashCode +
      (deepLink == null ? 0 : deepLink.hashCode) +
      (deepLinkClickedAt == null ? 0 : deepLinkClickedAt.hashCode) +
      (deepLinkConsumedAt == null ? 0 : deepLinkConsumedAt.hashCode) +
      (installReferrer == null ? 0 : installReferrer.hashCode) +
      installState.hashCode +
      isFirstLaunch.hashCode +
      isNewUser.hashCode +
      (originalInstallReferrer == null ? 0 : originalInstallReferrer.hashCode) +
      (reinstallReferrer == null ? 0 : reinstallReferrer.hashCode) +
      requestVersion.hashCode +
      userId.hashCode;

  factory SdkV1OpenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1OpenResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1OpenResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
