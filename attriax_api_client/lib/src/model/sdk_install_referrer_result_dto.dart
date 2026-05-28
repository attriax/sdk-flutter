//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/attribution_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_install_referrer_result_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkInstallReferrerResultDto {
  /// Returns a new [SdkInstallReferrerResultDto] instance.
  SdkInstallReferrerResultDto({
    this.adClickId,

    this.adNetwork,

    required this.attributionType,

    this.campaign,

    this.content,

    this.deepLinkData,

    this.deepLinkUri,

    this.deepLinkUrl,

    this.googlePlayInstantParam,

    this.installBeginTimestampSeconds,

    this.medium,

    required this.precision,

    this.rawPlatformInstallReferrer,

    this.referrerClickTimestampSeconds,

    this.registeredAt,

    this.source_,

    this.term,
  });

  /// Detected ad click identifier such as gclid or fbclid.
  @JsonKey(name: r'adClickId', required: false, includeIfNull: false)
  final String? adClickId;

  /// Detected ad-network identifier inferred from the referrer.
  @JsonKey(name: r'adNetwork', required: false, includeIfNull: false)
  final String? adNetwork;

  /// Attribution source classification for the startup referrer payload.
  @JsonKey(name: r'attributionType', required: true, includeIfNull: false)
  final AttributionType attributionType;

  /// Resolved UTM campaign extracted from the install referrer.
  @JsonKey(name: r'campaign', required: false, includeIfNull: false)
  final String? campaign;

  /// Resolved UTM content extracted from the install referrer.
  @JsonKey(name: r'content', required: false, includeIfNull: false)
  final String? content;

  /// Resolved deep-link payload data associated with the startup referrer.
  @JsonKey(name: r'deepLinkData', required: false, includeIfNull: false)
  final Map<String, String>? deepLinkData;

  /// Full tracked short-link URI associated with the resolved deep link.
  @JsonKey(name: r'deepLinkUri', required: false, includeIfNull: false)
  final String? deepLinkUri;

  /// Deprecated alias for deepLinkUri kept for HTTP compatibility.
  @Deprecated('deepLinkUrl has been deprecated')
  @JsonKey(name: r'deepLinkUrl', required: false, includeIfNull: false)
  final String? deepLinkUrl;

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

  /// Resolved UTM medium extracted from the install referrer.
  @JsonKey(name: r'medium', required: false, includeIfNull: false)
  final String? medium;

  /// Confidence score from 0.0 to 1.0 for the returned interpretation.
  @JsonKey(name: r'precision', required: true, includeIfNull: false)
  final num precision;

  /// Raw platform startup referrer string cached by the SDK, when available.
  @JsonKey(
    name: r'rawPlatformInstallReferrer',
    required: false,
    includeIfNull: false,
  )
  final String? rawPlatformInstallReferrer;

  @JsonKey(
    name: r'referrerClickTimestampSeconds',
    required: false,
    includeIfNull: false,
  )
  final num? referrerClickTimestampSeconds;

  @JsonKey(name: r'registeredAt', required: false, includeIfNull: false)
  final DateTime? registeredAt;

  /// Resolved UTM source extracted from the install referrer.
  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final String? source_;

  /// Resolved UTM term extracted from the install referrer.
  @JsonKey(name: r'term', required: false, includeIfNull: false)
  final String? term;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkInstallReferrerResultDto &&
          other.adClickId == adClickId &&
          other.adNetwork == adNetwork &&
          other.attributionType == attributionType &&
          other.campaign == campaign &&
          other.content == content &&
          other.deepLinkData == deepLinkData &&
          other.deepLinkUri == deepLinkUri &&
          other.deepLinkUrl == deepLinkUrl &&
          other.googlePlayInstantParam == googlePlayInstantParam &&
          other.installBeginTimestampSeconds == installBeginTimestampSeconds &&
          other.medium == medium &&
          other.precision == precision &&
          other.rawPlatformInstallReferrer == rawPlatformInstallReferrer &&
          other.referrerClickTimestampSeconds ==
              referrerClickTimestampSeconds &&
          other.registeredAt == registeredAt &&
          other.source_ == source_ &&
          other.term == term;

  @override
  int get hashCode =>
      adClickId.hashCode +
      adNetwork.hashCode +
      attributionType.hashCode +
      campaign.hashCode +
      content.hashCode +
      deepLinkData.hashCode +
      deepLinkUri.hashCode +
      deepLinkUrl.hashCode +
      googlePlayInstantParam.hashCode +
      installBeginTimestampSeconds.hashCode +
      medium.hashCode +
      precision.hashCode +
      rawPlatformInstallReferrer.hashCode +
      referrerClickTimestampSeconds.hashCode +
      registeredAt.hashCode +
      source_.hashCode +
      term.hashCode;

  factory SdkInstallReferrerResultDto.fromJson(Map<String, dynamic> json) =>
      _$SdkInstallReferrerResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkInstallReferrerResultDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
