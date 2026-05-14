//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_deep_link_resolve_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_deep_link_resolve_response_envelope_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1DeepLinkResolveResponseEnvelopeDto {
  /// Returns a new [SdkV1DeepLinkResolveResponseEnvelopeDto] instance.
  SdkV1DeepLinkResolveResponseEnvelopeDto({
    required this.data,

    required this.success,

    required this.timestamp,
  });

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SdkV1DeepLinkResolveResponseDto data;

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'timestamp', required: true, includeIfNull: false)
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1DeepLinkResolveResponseEnvelopeDto &&
          other.data == data &&
          other.success == success &&
          other.timestamp == timestamp;

  @override
  int get hashCode => data.hashCode + success.hashCode + timestamp.hashCode;

  factory SdkV1DeepLinkResolveResponseEnvelopeDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SdkV1DeepLinkResolveResponseEnvelopeDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkV1DeepLinkResolveResponseEnvelopeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
