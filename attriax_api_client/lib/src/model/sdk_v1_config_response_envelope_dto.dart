//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_config_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_config_response_envelope_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1ConfigResponseEnvelopeDto {
  /// Returns a new [SdkV1ConfigResponseEnvelopeDto] instance.
  SdkV1ConfigResponseEnvelopeDto({
    required this.data,

    required this.success,

    required this.timestamp,
  });

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SdkV1ConfigResponseDto data;

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'timestamp', required: true, includeIfNull: false)
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1ConfigResponseEnvelopeDto &&
          other.data == data &&
          other.success == success &&
          other.timestamp == timestamp;

  @override
  int get hashCode => data.hashCode + success.hashCode + timestamp.hashCode;

  factory SdkV1ConfigResponseEnvelopeDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1ConfigResponseEnvelopeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1ConfigResponseEnvelopeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
