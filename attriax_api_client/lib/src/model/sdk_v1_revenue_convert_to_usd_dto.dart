//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_revenue_convert_to_usd_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1RevenueConvertToUsdDto {
  /// Returns a new [SdkV1RevenueConvertToUsdDto] instance.
  SdkV1RevenueConvertToUsdDto({
    this.amount,

    this.amountMicros,

    this.appToken,

    this.clientOccurredAt,

    required this.currency,

    this.projectToken,

    this.revenueInMicros,
  });

  /// Revenue amount in normal currency units.
  @JsonKey(name: r'amount', required: false, includeIfNull: false)
  final num? amount;

  /// Revenue amount in micros of the original currency.
  @JsonKey(name: r'amountMicros', required: false, includeIfNull: false)
  final String? amountMicros;

  /// Deprecated alias for projectToken kept for released SDK compatibility.
  @Deprecated('appToken has been deprecated')
  @JsonKey(name: r'appToken', required: false, includeIfNull: false)
  final String? appToken;

  @JsonKey(name: r'clientOccurredAt', required: false, includeIfNull: false)
  final String? clientOccurredAt;

  @JsonKey(name: r'currency', required: true, includeIfNull: false)
  final String currency;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  /// Treat amount as micros when amountMicros is not supplied.
  @JsonKey(name: r'revenueInMicros', required: false, includeIfNull: false)
  final bool? revenueInMicros;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1RevenueConvertToUsdDto &&
          other.amount == amount &&
          other.amountMicros == amountMicros &&
          other.appToken == appToken &&
          other.clientOccurredAt == clientOccurredAt &&
          other.currency == currency &&
          other.projectToken == projectToken &&
          other.revenueInMicros == revenueInMicros;

  @override
  int get hashCode =>
      amount.hashCode +
      amountMicros.hashCode +
      appToken.hashCode +
      clientOccurredAt.hashCode +
      currency.hashCode +
      projectToken.hashCode +
      revenueInMicros.hashCode;

  factory SdkV1RevenueConvertToUsdDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1RevenueConvertToUsdDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1RevenueConvertToUsdDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
