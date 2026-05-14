//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/app_user_uninstall_token_provider.dart';
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_register_uninstall_token_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkRegisterUninstallTokenDto {
  /// Returns a new [SdkRegisterUninstallTokenDto] instance.
  SdkRegisterUninstallTokenDto({
    required this.appToken,

    required this.deviceId,

    this.deviceIdSource,

    this.metadata,

    required this.platform,

    required this.provider,

    this.token,
  });

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'deviceId', required: true, includeIfNull: false)
  final String deviceId;

  @JsonKey(name: r'deviceIdSource', required: false, includeIfNull: false)
  final String? deviceIdSource;

  @JsonKey(name: r'metadata', required: false, includeIfNull: false)
  final Map<String, Object>? metadata;

  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final Platform platform;

  @JsonKey(name: r'provider', required: true, includeIfNull: false)
  final AppUserUninstallTokenProvider provider;

  @JsonKey(name: r'token', required: false, includeIfNull: false)
  final Object? token;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkRegisterUninstallTokenDto &&
          other.appToken == appToken &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.metadata == metadata &&
          other.platform == platform &&
          other.provider == provider &&
          other.token == token;

  @override
  int get hashCode =>
      appToken.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      metadata.hashCode +
      platform.hashCode +
      provider.hashCode +
      (token == null ? 0 : token.hashCode);

  factory SdkRegisterUninstallTokenDto.fromJson(Map<String, dynamic> json) =>
      _$SdkRegisterUninstallTokenDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkRegisterUninstallTokenDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
