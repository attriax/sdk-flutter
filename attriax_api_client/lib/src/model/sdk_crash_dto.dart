//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_crash_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkCrashDto {
  /// Returns a new [SdkCrashDto] instance.
  SdkCrashDto({
    this.appBuildNumber,

    this.appPackageName,

    required this.appToken,

    this.appVersion,

    required this.clientOccurredAt,

    required this.deviceId,

    required this.deviceIdSource,

    required this.exceptionType,

    required this.isFatal,

    required this.isFirstLaunch,

    this.locale,

    required this.message,

    this.metadata,

    required this.platform,

    this.reason,

    this.sdkApiVersion,

    this.sdkPackageVersion,

    this.sessionId,

    this.sessionRelativeTimeMs,

    required this.source_,

    required this.stackTrace,
  });

  @JsonKey(name: r'appBuildNumber', required: false, includeIfNull: false)
  final String? appBuildNumber;

  @JsonKey(name: r'appPackageName', required: false, includeIfNull: false)
  final String? appPackageName;

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'appVersion', required: false, includeIfNull: false)
  final String? appVersion;

  @JsonKey(name: r'clientOccurredAt', required: true, includeIfNull: false)
  final DateTime clientOccurredAt;

  @JsonKey(name: r'deviceId', required: true, includeIfNull: false)
  final String deviceId;

  @JsonKey(name: r'deviceIdSource', required: true, includeIfNull: false)
  final String deviceIdSource;

  @JsonKey(name: r'exceptionType', required: true, includeIfNull: false)
  final String exceptionType;

  @JsonKey(name: r'isFatal', required: true, includeIfNull: false)
  final bool isFatal;

  @JsonKey(name: r'isFirstLaunch', required: true, includeIfNull: false)
  final bool isFirstLaunch;

  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final String? locale;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'metadata', required: false, includeIfNull: false)
  final Map<String, Object>? metadata;

  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final Platform platform;

  @JsonKey(name: r'reason', required: false, includeIfNull: false)
  final String? reason;

  @JsonKey(name: r'sdkApiVersion', required: false, includeIfNull: false)
  final String? sdkApiVersion;

  @JsonKey(name: r'sdkPackageVersion', required: false, includeIfNull: false)
  final String? sdkPackageVersion;

  @JsonKey(name: r'sessionId', required: false, includeIfNull: false)
  final String? sessionId;

  /// Milliseconds since the session started.
  @JsonKey(
    name: r'sessionRelativeTimeMs',
    required: false,
    includeIfNull: false,
  )
  final num? sessionRelativeTimeMs;

  /// Crash origin inside the SDK or native bridge.
  @JsonKey(name: r'source', required: true, includeIfNull: false)
  final String source_;

  @JsonKey(name: r'stackTrace', required: true, includeIfNull: false)
  final String stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkCrashDto &&
          other.appBuildNumber == appBuildNumber &&
          other.appPackageName == appPackageName &&
          other.appToken == appToken &&
          other.appVersion == appVersion &&
          other.clientOccurredAt == clientOccurredAt &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.exceptionType == exceptionType &&
          other.isFatal == isFatal &&
          other.isFirstLaunch == isFirstLaunch &&
          other.locale == locale &&
          other.message == message &&
          other.metadata == metadata &&
          other.platform == platform &&
          other.reason == reason &&
          other.sdkApiVersion == sdkApiVersion &&
          other.sdkPackageVersion == sdkPackageVersion &&
          other.sessionId == sessionId &&
          other.sessionRelativeTimeMs == sessionRelativeTimeMs &&
          other.source_ == source_ &&
          other.stackTrace == stackTrace;

  @override
  int get hashCode =>
      appBuildNumber.hashCode +
      appPackageName.hashCode +
      appToken.hashCode +
      appVersion.hashCode +
      clientOccurredAt.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      exceptionType.hashCode +
      isFatal.hashCode +
      isFirstLaunch.hashCode +
      locale.hashCode +
      message.hashCode +
      metadata.hashCode +
      platform.hashCode +
      reason.hashCode +
      sdkApiVersion.hashCode +
      sdkPackageVersion.hashCode +
      sessionId.hashCode +
      sessionRelativeTimeMs.hashCode +
      source_.hashCode +
      stackTrace.hashCode;

  factory SdkCrashDto.fromJson(Map<String, dynamic> json) =>
      _$SdkCrashDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkCrashDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
