//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_create_dynamic_link_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkCreateDynamicLinkDto {
  /// Returns a new [SdkCreateDynamicLinkDto] instance.
  SdkCreateDynamicLinkDto({
    this.androidRedirect,

    required this.appToken,

    this.data,

    this.destinationUrl,

    this.group,

    this.iosRedirect,

    this.name,

    this.prefix,

    this.previewDescription,

    this.previewImagePath,

    this.previewTitle,

    this.utmCampaign,

    this.utmContent,

    this.utmMedium,

    this.utmSource,

    this.utmTerm,
  });

  @JsonKey(name: r'androidRedirect', required: false, includeIfNull: false)
  final bool? androidRedirect;

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final Map<String, Object>? data;

  @JsonKey(name: r'destinationUrl', required: false, includeIfNull: false)
  final String? destinationUrl;

  @JsonKey(name: r'group', required: false, includeIfNull: false)
  final String? group;

  @JsonKey(name: r'iosRedirect', required: false, includeIfNull: false)
  final bool? iosRedirect;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'prefix', required: false, includeIfNull: false)
  final String? prefix;

  @JsonKey(name: r'previewDescription', required: false, includeIfNull: false)
  final String? previewDescription;

  @JsonKey(name: r'previewImagePath', required: false, includeIfNull: false)
  final String? previewImagePath;

  @JsonKey(name: r'previewTitle', required: false, includeIfNull: false)
  final String? previewTitle;

  @JsonKey(name: r'utmCampaign', required: false, includeIfNull: false)
  final String? utmCampaign;

  @JsonKey(name: r'utmContent', required: false, includeIfNull: false)
  final String? utmContent;

  @JsonKey(name: r'utmMedium', required: false, includeIfNull: false)
  final String? utmMedium;

  @JsonKey(name: r'utmSource', required: false, includeIfNull: false)
  final String? utmSource;

  @JsonKey(name: r'utmTerm', required: false, includeIfNull: false)
  final String? utmTerm;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkCreateDynamicLinkDto &&
          other.androidRedirect == androidRedirect &&
          other.appToken == appToken &&
          other.data == data &&
          other.destinationUrl == destinationUrl &&
          other.group == group &&
          other.iosRedirect == iosRedirect &&
          other.name == name &&
          other.prefix == prefix &&
          other.previewDescription == previewDescription &&
          other.previewImagePath == previewImagePath &&
          other.previewTitle == previewTitle &&
          other.utmCampaign == utmCampaign &&
          other.utmContent == utmContent &&
          other.utmMedium == utmMedium &&
          other.utmSource == utmSource &&
          other.utmTerm == utmTerm;

  @override
  int get hashCode =>
      androidRedirect.hashCode +
      appToken.hashCode +
      data.hashCode +
      destinationUrl.hashCode +
      group.hashCode +
      iosRedirect.hashCode +
      name.hashCode +
      prefix.hashCode +
      previewDescription.hashCode +
      previewImagePath.hashCode +
      previewTitle.hashCode +
      utmCampaign.hashCode +
      utmContent.hashCode +
      utmMedium.hashCode +
      utmSource.hashCode +
      utmTerm.hashCode;

  factory SdkCreateDynamicLinkDto.fromJson(Map<String, dynamic> json) =>
      _$SdkCreateDynamicLinkDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkCreateDynamicLinkDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
