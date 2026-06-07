//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_revenue_receipt_validate_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1RevenueReceiptValidateDto {
  /// Returns a new [SdkV1RevenueReceiptValidateDto] instance.
  SdkV1RevenueReceiptValidateDto({
    this.appToken,

    this.clientOccurredAt,

    this.deviceId,

    this.environment,

    this.productId,

    this.projectToken,

    this.provider,

    this.receipt,

    this.test,

    this.transactionId,
  });

  /// Deprecated alias for projectToken kept for released SDK compatibility.
  @Deprecated('appToken has been deprecated')
  @JsonKey(name: r'appToken', required: false, includeIfNull: false)
  final String? appToken;

  @JsonKey(name: r'clientOccurredAt', required: false, includeIfNull: false)
  final String? clientOccurredAt;

  @JsonKey(name: r'deviceId', required: false, includeIfNull: false)
  final String? deviceId;

  @JsonKey(name: r'environment', required: false, includeIfNull: false)
  final String? environment;

  @JsonKey(name: r'productId', required: false, includeIfNull: false)
  final String? productId;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  @JsonKey(name: r'provider', required: false, includeIfNull: false)
  final String? provider;

  @JsonKey(name: r'receipt', required: false, includeIfNull: false)
  final String? receipt;

  @JsonKey(name: r'test', required: false, includeIfNull: false)
  final bool? test;

  @JsonKey(name: r'transactionId', required: false, includeIfNull: false)
  final String? transactionId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1RevenueReceiptValidateDto &&
          other.appToken == appToken &&
          other.clientOccurredAt == clientOccurredAt &&
          other.deviceId == deviceId &&
          other.environment == environment &&
          other.productId == productId &&
          other.projectToken == projectToken &&
          other.provider == provider &&
          other.receipt == receipt &&
          other.test == test &&
          other.transactionId == transactionId;

  @override
  int get hashCode =>
      appToken.hashCode +
      clientOccurredAt.hashCode +
      deviceId.hashCode +
      environment.hashCode +
      productId.hashCode +
      projectToken.hashCode +
      provider.hashCode +
      receipt.hashCode +
      test.hashCode +
      transactionId.hashCode;

  factory SdkV1RevenueReceiptValidateDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1RevenueReceiptValidateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1RevenueReceiptValidateDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
