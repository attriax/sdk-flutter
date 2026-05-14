//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_create_dynamic_link_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_create_dynamic_link_response_envelope_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkCreateDynamicLinkResponseEnvelopeDto {
  /// Returns a new [SdkCreateDynamicLinkResponseEnvelopeDto] instance.
  SdkCreateDynamicLinkResponseEnvelopeDto({
    required this.data,

    required this.success,

    required this.timestamp,
  });

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SdkCreateDynamicLinkResponseDto data;

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'timestamp', required: true, includeIfNull: false)
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkCreateDynamicLinkResponseEnvelopeDto &&
          other.data == data &&
          other.success == success &&
          other.timestamp == timestamp;

  @override
  int get hashCode => data.hashCode + success.hashCode + timestamp.hashCode;

  factory SdkCreateDynamicLinkResponseEnvelopeDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SdkCreateDynamicLinkResponseEnvelopeDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkCreateDynamicLinkResponseEnvelopeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
