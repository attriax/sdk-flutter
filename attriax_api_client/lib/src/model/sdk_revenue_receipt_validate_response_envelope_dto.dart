//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_revenue_receipt_validate_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_revenue_receipt_validate_response_envelope_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkRevenueReceiptValidateResponseEnvelopeDto {
  /// Returns a new [SdkRevenueReceiptValidateResponseEnvelopeDto] instance.
  SdkRevenueReceiptValidateResponseEnvelopeDto({
    required this.data,

    required this.success,

    required this.timestamp,
  });

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SdkRevenueReceiptValidateResponseDto data;

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'timestamp', required: true, includeIfNull: false)
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkRevenueReceiptValidateResponseEnvelopeDto &&
          other.data == data &&
          other.success == success &&
          other.timestamp == timestamp;

  @override
  int get hashCode => data.hashCode + success.hashCode + timestamp.hashCode;

  factory SdkRevenueReceiptValidateResponseEnvelopeDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SdkRevenueReceiptValidateResponseEnvelopeDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkRevenueReceiptValidateResponseEnvelopeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
