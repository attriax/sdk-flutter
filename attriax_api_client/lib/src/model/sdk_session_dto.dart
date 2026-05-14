//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_session_lifecycle_kind.dart';
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_session_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkSessionDto {
  /// Returns a new [SdkSessionDto] instance.
  SdkSessionDto({
    this.appBuildNumber,

    this.appPackageName,

    required this.appToken,

    this.appVersion,

    this.clientOccurredAt,

    required this.deviceId,

    this.deviceIdSource,

    this.isFirstLaunch,

    required this.kind,

    this.locale,

    this.metadata,

    this.platform,

    this.sdkApiVersion,

    this.sdkPackageVersion,

    required this.sessionId,

    this.sessionRelativeTimeMs,
  });

  @JsonKey(name: r'appBuildNumber', required: false, includeIfNull: false)
  final String? appBuildNumber;

  @JsonKey(name: r'appPackageName', required: false, includeIfNull: false)
  final String? appPackageName;

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'appVersion', required: false, includeIfNull: false)
  final String? appVersion;

  @JsonKey(name: r'clientOccurredAt', required: false, includeIfNull: false)
  final DateTime? clientOccurredAt;

  @JsonKey(name: r'deviceId', required: true, includeIfNull: false)
  final String deviceId;

  @JsonKey(name: r'deviceIdSource', required: false, includeIfNull: false)
  final String? deviceIdSource;

  @JsonKey(name: r'isFirstLaunch', required: false, includeIfNull: false)
  final bool? isFirstLaunch;

  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final SdkSessionLifecycleKind kind;

  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final String? locale;

  @JsonKey(name: r'metadata', required: false, includeIfNull: false)
  final Map<String, Object>? metadata;

  @JsonKey(name: r'platform', required: false, includeIfNull: false)
  final Platform? platform;

  @JsonKey(name: r'sdkApiVersion', required: false, includeIfNull: false)
  final String? sdkApiVersion;

  @JsonKey(name: r'sdkPackageVersion', required: false, includeIfNull: false)
  final String? sdkPackageVersion;

  @JsonKey(name: r'sessionId', required: true, includeIfNull: false)
  final String sessionId;

  /// Milliseconds since the session started.
  @JsonKey(
    name: r'sessionRelativeTimeMs',
    required: false,
    includeIfNull: false,
  )
  final num? sessionRelativeTimeMs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkSessionDto &&
          other.appBuildNumber == appBuildNumber &&
          other.appPackageName == appPackageName &&
          other.appToken == appToken &&
          other.appVersion == appVersion &&
          other.clientOccurredAt == clientOccurredAt &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.isFirstLaunch == isFirstLaunch &&
          other.kind == kind &&
          other.locale == locale &&
          other.metadata == metadata &&
          other.platform == platform &&
          other.sdkApiVersion == sdkApiVersion &&
          other.sdkPackageVersion == sdkPackageVersion &&
          other.sessionId == sessionId &&
          other.sessionRelativeTimeMs == sessionRelativeTimeMs;

  @override
  int get hashCode =>
      appBuildNumber.hashCode +
      appPackageName.hashCode +
      appToken.hashCode +
      appVersion.hashCode +
      clientOccurredAt.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      isFirstLaunch.hashCode +
      kind.hashCode +
      locale.hashCode +
      metadata.hashCode +
      platform.hashCode +
      sdkApiVersion.hashCode +
      sdkPackageVersion.hashCode +
      sessionId.hashCode +
      sessionRelativeTimeMs.hashCode;

  factory SdkSessionDto.fromJson(Map<String, dynamic> json) =>
      _$SdkSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkSessionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
