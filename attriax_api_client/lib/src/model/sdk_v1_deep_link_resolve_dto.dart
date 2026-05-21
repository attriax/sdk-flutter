//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_deep_link_resolve_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1DeepLinkResolveDto {
  /// Returns a new [SdkV1DeepLinkResolveDto] instance.
  SdkV1DeepLinkResolveDto({
    required this.appToken,

    this.deviceId,

    this.deviceIdSource,

    this.isFirstLaunch,

    this.linkPath,

    this.metadata,

    required this.platform,

    this.rawUrl,

    this.source_,
  });

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'deviceId', required: false, includeIfNull: false)
  final String? deviceId;

  @JsonKey(name: r'deviceIdSource', required: false, includeIfNull: false)
  final String? deviceIdSource;

  @JsonKey(name: r'isFirstLaunch', required: false, includeIfNull: false)
  final bool? isFirstLaunch;

  @JsonKey(name: r'linkPath', required: false, includeIfNull: false)
  final String? linkPath;

  @JsonKey(name: r'metadata', required: false, includeIfNull: false)
  final Map<String, Object>? metadata;

  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final Platform platform;

  @JsonKey(name: r'rawUrl', required: false, includeIfNull: false)
  final String? rawUrl;

  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final String? source_;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1DeepLinkResolveDto &&
          other.appToken == appToken &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.isFirstLaunch == isFirstLaunch &&
          other.linkPath == linkPath &&
          other.metadata == metadata &&
          other.platform == platform &&
          other.rawUrl == rawUrl &&
          other.source_ == source_;

  @override
  int get hashCode =>
      appToken.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      isFirstLaunch.hashCode +
      linkPath.hashCode +
      metadata.hashCode +
      platform.hashCode +
      rawUrl.hashCode +
      source_.hashCode;

  factory SdkV1DeepLinkResolveDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1DeepLinkResolveDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1DeepLinkResolveDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
