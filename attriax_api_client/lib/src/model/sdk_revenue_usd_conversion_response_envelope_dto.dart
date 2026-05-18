//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_revenue_usd_conversion_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_revenue_usd_conversion_response_envelope_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkRevenueUsdConversionResponseEnvelopeDto {
  /// Returns a new [SdkRevenueUsdConversionResponseEnvelopeDto] instance.
  SdkRevenueUsdConversionResponseEnvelopeDto({
    required this.data,

    required this.success,

    required this.timestamp,
  });

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SdkRevenueUsdConversionResponseDto data;

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'timestamp', required: true, includeIfNull: false)
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkRevenueUsdConversionResponseEnvelopeDto &&
          other.data == data &&
          other.success == success &&
          other.timestamp == timestamp;

  @override
  int get hashCode => data.hashCode + success.hashCode + timestamp.hashCode;

  factory SdkRevenueUsdConversionResponseEnvelopeDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SdkRevenueUsdConversionResponseEnvelopeDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkRevenueUsdConversionResponseEnvelopeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
