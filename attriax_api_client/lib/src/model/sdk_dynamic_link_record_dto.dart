//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_dynamic_link_record_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkDynamicLinkRecordDto {
  /// Returns a new [SdkDynamicLinkRecordDto] instance.
  SdkDynamicLinkRecordDto({
    this.androidRedirect,

    required this.createdAt,

    this.data,

    this.destinationUrl,

    this.group,

    required this.id,

    this.iosRedirect,

    this.name,

    required this.path,

    this.prefix,

    this.previewDescription,

    this.previewImagePath,

    this.previewTitle,

    required this.shortUrl,

    this.utmCampaign,

    this.utmContent,

    this.utmMedium,

    this.utmSource,

    this.utmTerm,
  });

  @JsonKey(name: r'androidRedirect', required: false, includeIfNull: false)
  final bool? androidRedirect;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final Map<String, Object>? data;

  @JsonKey(name: r'destinationUrl', required: false, includeIfNull: false)
  final String? destinationUrl;

  @JsonKey(name: r'group', required: false, includeIfNull: false)
  final String? group;

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'iosRedirect', required: false, includeIfNull: false)
  final bool? iosRedirect;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'path', required: true, includeIfNull: false)
  final String path;

  @JsonKey(name: r'prefix', required: false, includeIfNull: false)
  final String? prefix;

  @JsonKey(name: r'previewDescription', required: false, includeIfNull: false)
  final String? previewDescription;

  @JsonKey(name: r'previewImagePath', required: false, includeIfNull: false)
  final String? previewImagePath;

  @JsonKey(name: r'previewTitle', required: false, includeIfNull: false)
  final String? previewTitle;

  @JsonKey(name: r'shortUrl', required: true, includeIfNull: false)
  final String shortUrl;

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
      other is SdkDynamicLinkRecordDto &&
          other.androidRedirect == androidRedirect &&
          other.createdAt == createdAt &&
          other.data == data &&
          other.destinationUrl == destinationUrl &&
          other.group == group &&
          other.id == id &&
          other.iosRedirect == iosRedirect &&
          other.name == name &&
          other.path == path &&
          other.prefix == prefix &&
          other.previewDescription == previewDescription &&
          other.previewImagePath == previewImagePath &&
          other.previewTitle == previewTitle &&
          other.shortUrl == shortUrl &&
          other.utmCampaign == utmCampaign &&
          other.utmContent == utmContent &&
          other.utmMedium == utmMedium &&
          other.utmSource == utmSource &&
          other.utmTerm == utmTerm;

  @override
  int get hashCode =>
      (androidRedirect == null ? 0 : androidRedirect.hashCode) +
      createdAt.hashCode +
      data.hashCode +
      (destinationUrl == null ? 0 : destinationUrl.hashCode) +
      (group == null ? 0 : group.hashCode) +
      id.hashCode +
      (iosRedirect == null ? 0 : iosRedirect.hashCode) +
      (name == null ? 0 : name.hashCode) +
      path.hashCode +
      (prefix == null ? 0 : prefix.hashCode) +
      (previewDescription == null ? 0 : previewDescription.hashCode) +
      (previewImagePath == null ? 0 : previewImagePath.hashCode) +
      (previewTitle == null ? 0 : previewTitle.hashCode) +
      shortUrl.hashCode +
      (utmCampaign == null ? 0 : utmCampaign.hashCode) +
      (utmContent == null ? 0 : utmContent.hashCode) +
      (utmMedium == null ? 0 : utmMedium.hashCode) +
      (utmSource == null ? 0 : utmSource.hashCode) +
      (utmTerm == null ? 0 : utmTerm.hashCode);

  factory SdkDynamicLinkRecordDto.fromJson(Map<String, dynamic> json) =>
      _$SdkDynamicLinkRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkDynamicLinkRecordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
