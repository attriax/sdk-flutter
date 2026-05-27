//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_config_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1ConfigDto {
  /// Returns a new [SdkV1ConfigDto] instance.
  SdkV1ConfigDto({
    required this.appToken,

    this.packageName,

    required this.platform,

    this.signatureHashes,
  });

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'packageName', required: false, includeIfNull: false)
  final String? packageName;

  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final Platform platform;

  @JsonKey(name: r'signatureHashes', required: false, includeIfNull: false)
  final List<String>? signatureHashes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1ConfigDto &&
          other.appToken == appToken &&
          other.packageName == packageName &&
          other.platform == platform &&
          other.signatureHashes == signatureHashes;

  @override
  int get hashCode =>
      appToken.hashCode +
      packageName.hashCode +
      platform.hashCode +
      signatureHashes.hashCode;

  factory SdkV1ConfigDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1ConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1ConfigDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
