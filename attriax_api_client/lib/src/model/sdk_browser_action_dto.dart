//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/route_url_open_mode.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_browser_action_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkBrowserActionDto {
  /// Returns a new [SdkBrowserActionDto] instance.
  SdkBrowserActionDto({required this.openMode, required this.url});

  @JsonKey(name: r'openMode', required: true, includeIfNull: false)
  final RouteUrlOpenMode openMode;

  @JsonKey(name: r'url', required: true, includeIfNull: false)
  final String url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkBrowserActionDto &&
          other.openMode == openMode &&
          other.url == url;

  @override
  int get hashCode => openMode.hashCode + url.hashCode;

  factory SdkBrowserActionDto.fromJson(Map<String, dynamic> json) =>
      _$SdkBrowserActionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkBrowserActionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
