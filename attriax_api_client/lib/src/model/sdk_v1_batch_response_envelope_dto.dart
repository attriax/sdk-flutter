//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_batch_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_batch_response_envelope_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1BatchResponseEnvelopeDto {
  /// Returns a new [SdkV1BatchResponseEnvelopeDto] instance.
  SdkV1BatchResponseEnvelopeDto({
    required this.data,

    required this.success,

    required this.timestamp,
  });

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SdkV1BatchResponseDto data;

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'timestamp', required: true, includeIfNull: false)
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1BatchResponseEnvelopeDto &&
          other.data == data &&
          other.success == success &&
          other.timestamp == timestamp;

  @override
  int get hashCode => data.hashCode + success.hashCode + timestamp.hashCode;

  factory SdkV1BatchResponseEnvelopeDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1BatchResponseEnvelopeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1BatchResponseEnvelopeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
