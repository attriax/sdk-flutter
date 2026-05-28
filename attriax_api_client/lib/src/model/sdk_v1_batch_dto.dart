//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_batch_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_batch_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1BatchDto {
  /// Returns a new [SdkV1BatchDto] instance.
  SdkV1BatchDto({
    this.appToken,

    required this.deviceId,

    this.deviceIdSource,

    required this.items,

    this.projectToken,

    required this.requestId,
  });

  /// Deprecated alias for projectToken kept for released SDK compatibility.
  @Deprecated('appToken has been deprecated')
  @JsonKey(name: r'appToken', required: false, includeIfNull: false)
  final String? appToken;

  /// Shared device identifier for every item in the batch.
  @JsonKey(name: r'deviceId', required: true, includeIfNull: false)
  final String deviceId;

  /// Optional shared device-id source for every item in the batch.
  @JsonKey(name: r'deviceIdSource', required: false, includeIfNull: false)
  final String? deviceIdSource;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<SdkV1BatchItemDto> items;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  /// Stable client-generated batch identifier used for idempotent retries.
  @JsonKey(name: r'requestId', required: true, includeIfNull: false)
  final String requestId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1BatchDto &&
          other.appToken == appToken &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.items == items &&
          other.projectToken == projectToken &&
          other.requestId == requestId;

  @override
  int get hashCode =>
      appToken.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      items.hashCode +
      projectToken.hashCode +
      requestId.hashCode;

  factory SdkV1BatchDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1BatchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1BatchDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
