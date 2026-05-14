//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_open_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_open_response_envelope_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1OpenResponseEnvelopeDto {
  /// Returns a new [SdkV1OpenResponseEnvelopeDto] instance.
  SdkV1OpenResponseEnvelopeDto({
    required this.data,

    required this.success,

    required this.timestamp,
  });

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SdkV1OpenResponseDto data;

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'timestamp', required: true, includeIfNull: false)
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1OpenResponseEnvelopeDto &&
          other.data == data &&
          other.success == success &&
          other.timestamp == timestamp;

  @override
  int get hashCode => data.hashCode + success.hashCode + timestamp.hashCode;

  factory SdkV1OpenResponseEnvelopeDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1OpenResponseEnvelopeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1OpenResponseEnvelopeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
