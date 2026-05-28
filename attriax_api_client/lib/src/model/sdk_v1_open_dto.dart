//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/device_context_dto.dart';
import 'package:attriax_api_client/src/model/app_version_context_dto.dart';
import 'package:attriax_api_client/src/model/sdk_version_context_dto.dart';
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_open_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1OpenDto {
  /// Returns a new [SdkV1OpenDto] instance.
  SdkV1OpenDto({
    required this.app,

    this.appToken,

    required this.device,

    required this.deviceId,

    this.deviceIdSource,

    this.googlePlayInstantParam,

    this.installBeginTimestampSeconds,

    this.installReferrer,

    this.isFirstLaunch,

    required this.platform,

    this.projectToken,

    this.referrerClickTimestampSeconds,

    required this.sdk,

    this.sessionId,

    this.sessionStartedAt,
  });

  @JsonKey(name: r'app', required: true, includeIfNull: false)
  final AppVersionContextDto app;

  /// Deprecated alias for projectToken kept for released SDK compatibility.
  @Deprecated('appToken has been deprecated')
  @JsonKey(name: r'appToken', required: false, includeIfNull: false)
  final String? appToken;

  @JsonKey(name: r'device', required: true, includeIfNull: false)
  final DeviceContextDto device;

  @JsonKey(name: r'deviceId', required: true, includeIfNull: false)
  final String deviceId;

  @JsonKey(name: r'deviceIdSource', required: false, includeIfNull: false)
  final String? deviceIdSource;

  @JsonKey(
    name: r'googlePlayInstantParam',
    required: false,
    includeIfNull: false,
  )
  final bool? googlePlayInstantParam;

  @JsonKey(
    name: r'installBeginTimestampSeconds',
    required: false,
    includeIfNull: false,
  )
  final num? installBeginTimestampSeconds;

  @JsonKey(name: r'installReferrer', required: false, includeIfNull: false)
  final String? installReferrer;

  @JsonKey(name: r'isFirstLaunch', required: false, includeIfNull: false)
  final bool? isFirstLaunch;

  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final Platform platform;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  @JsonKey(
    name: r'referrerClickTimestampSeconds',
    required: false,
    includeIfNull: false,
  )
  final num? referrerClickTimestampSeconds;

  @JsonKey(name: r'sdk', required: true, includeIfNull: false)
  final SdkVersionContextDto sdk;

  @JsonKey(name: r'sessionId', required: false, includeIfNull: false)
  final String? sessionId;

  @JsonKey(name: r'sessionStartedAt', required: false, includeIfNull: false)
  final DateTime? sessionStartedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1OpenDto &&
          other.app == app &&
          other.appToken == appToken &&
          other.device == device &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.googlePlayInstantParam == googlePlayInstantParam &&
          other.installBeginTimestampSeconds == installBeginTimestampSeconds &&
          other.installReferrer == installReferrer &&
          other.isFirstLaunch == isFirstLaunch &&
          other.platform == platform &&
          other.projectToken == projectToken &&
          other.referrerClickTimestampSeconds ==
              referrerClickTimestampSeconds &&
          other.sdk == sdk &&
          other.sessionId == sessionId &&
          other.sessionStartedAt == sessionStartedAt;

  @override
  int get hashCode =>
      app.hashCode +
      appToken.hashCode +
      device.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      googlePlayInstantParam.hashCode +
      installBeginTimestampSeconds.hashCode +
      installReferrer.hashCode +
      isFirstLaunch.hashCode +
      platform.hashCode +
      projectToken.hashCode +
      referrerClickTimestampSeconds.hashCode +
      sdk.hashCode +
      sessionId.hashCode +
      sessionStartedAt.hashCode;

  factory SdkV1OpenDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1OpenDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1OpenDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
