//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_revenue_usd_conversion_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkRevenueUsdConversionResponseDto {
  /// Returns a new [SdkRevenueUsdConversionResponseDto] instance.
  SdkRevenueUsdConversionResponseDto({
    required this.acceptedAt,

    required this.amountOriginalMicros,

    required this.amountUsd,

    required this.amountUsdMicros,

    required this.conversionStatus,

    required this.currency,

    required this.rate,

    required this.rateDate,

    required this.requestVersion,
  });

  @JsonKey(name: r'acceptedAt', required: true, includeIfNull: false)
  final DateTime acceptedAt;

  @JsonKey(name: r'amountOriginalMicros', required: true, includeIfNull: false)
  final String amountOriginalMicros;

  @JsonKey(name: r'amountUsd', required: true, includeIfNull: false)
  final num amountUsd;

  @JsonKey(name: r'amountUsdMicros', required: true, includeIfNull: false)
  final String amountUsdMicros;

  @JsonKey(name: r'conversionStatus', required: true, includeIfNull: false)
  final String conversionStatus;

  @JsonKey(name: r'currency', required: true, includeIfNull: false)
  final String currency;

  @JsonKey(name: r'rate', required: true, includeIfNull: false)
  final String rate;

  @JsonKey(name: r'rateDate', required: true, includeIfNull: false)
  final String rateDate;

  @JsonKey(name: r'requestVersion', required: true, includeIfNull: false)
  final String requestVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkRevenueUsdConversionResponseDto &&
          other.acceptedAt == acceptedAt &&
          other.amountOriginalMicros == amountOriginalMicros &&
          other.amountUsd == amountUsd &&
          other.amountUsdMicros == amountUsdMicros &&
          other.conversionStatus == conversionStatus &&
          other.currency == currency &&
          other.rate == rate &&
          other.rateDate == rateDate &&
          other.requestVersion == requestVersion;

  @override
  int get hashCode =>
      acceptedAt.hashCode +
      amountOriginalMicros.hashCode +
      amountUsd.hashCode +
      amountUsdMicros.hashCode +
      conversionStatus.hashCode +
      currency.hashCode +
      rate.hashCode +
      rateDate.hashCode +
      requestVersion.hashCode;

  factory SdkRevenueUsdConversionResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SdkRevenueUsdConversionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkRevenueUsdConversionResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
