//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_utm_payload_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_json_deep_link_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkJsonDeepLinkDto {
  /// Returns a new [SdkJsonDeepLinkDto] instance.
  SdkJsonDeepLinkDto({this.data, required this.path, this.uri, this.utm});

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final Map<String, String>? data;

  @JsonKey(name: r'path', required: true, includeIfNull: false)
  final String path;

  @JsonKey(name: r'uri', required: false, includeIfNull: false)
  final String? uri;

  @JsonKey(name: r'utm', required: false, includeIfNull: false)
  final SdkUtmPayloadDto? utm;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkJsonDeepLinkDto &&
          other.data == data &&
          other.path == path &&
          other.uri == uri &&
          other.utm == utm;

  @override
  int get hashCode =>
      data.hashCode + path.hashCode + uri.hashCode + utm.hashCode;

  factory SdkJsonDeepLinkDto.fromJson(Map<String, dynamic> json) =>
      _$SdkJsonDeepLinkDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkJsonDeepLinkDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
