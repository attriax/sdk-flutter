//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_revenue_receipt_validate_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkRevenueReceiptValidateResponseDto {
  /// Returns a new [SdkRevenueReceiptValidateResponseDto] instance.
  SdkRevenueReceiptValidateResponseDto({
    required this.acceptedAt,

    this.environment,

    this.expiresAt,

    this.failureReason,

    this.originalTransactionId,

    this.productId,

    this.provider,

    this.providerResult,

    required this.publicReceipt,

    required this.requestVersion,

    required this.status,

    this.transactionId,

    required this.validationId,
  });

  @JsonKey(name: r'acceptedAt', required: true, includeIfNull: false)
  final DateTime acceptedAt;

  @JsonKey(name: r'environment', required: false, includeIfNull: false)
  final String? environment;

  @JsonKey(name: r'expiresAt', required: false, includeIfNull: false)
  final DateTime? expiresAt;

  @JsonKey(name: r'failureReason', required: false, includeIfNull: false)
  final String? failureReason;

  @JsonKey(
    name: r'originalTransactionId',
    required: false,
    includeIfNull: false,
  )
  final String? originalTransactionId;

  @JsonKey(name: r'productId', required: false, includeIfNull: false)
  final String? productId;

  @JsonKey(name: r'provider', required: false, includeIfNull: false)
  final String? provider;

  @JsonKey(name: r'providerResult', required: false, includeIfNull: false)
  final Map<String, Object>? providerResult;

  @JsonKey(name: r'publicReceipt', required: true, includeIfNull: false)
  final Map<String, Object> publicReceipt;

  @JsonKey(name: r'requestVersion', required: true, includeIfNull: false)
  final String requestVersion;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final SdkRevenueReceiptValidateResponseDtoStatusEnum status;

  @JsonKey(name: r'transactionId', required: false, includeIfNull: false)
  final String? transactionId;

  @JsonKey(name: r'validationId', required: true, includeIfNull: false)
  final String validationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkRevenueReceiptValidateResponseDto &&
          other.acceptedAt == acceptedAt &&
          other.environment == environment &&
          other.expiresAt == expiresAt &&
          other.failureReason == failureReason &&
          other.originalTransactionId == originalTransactionId &&
          other.productId == productId &&
          other.provider == provider &&
          other.providerResult == providerResult &&
          other.publicReceipt == publicReceipt &&
          other.requestVersion == requestVersion &&
          other.status == status &&
          other.transactionId == transactionId &&
          other.validationId == validationId;

  @override
  int get hashCode =>
      acceptedAt.hashCode +
      (environment == null ? 0 : environment.hashCode) +
      (expiresAt == null ? 0 : expiresAt.hashCode) +
      (failureReason == null ? 0 : failureReason.hashCode) +
      (originalTransactionId == null ? 0 : originalTransactionId.hashCode) +
      (productId == null ? 0 : productId.hashCode) +
      (provider == null ? 0 : provider.hashCode) +
      (providerResult == null ? 0 : providerResult.hashCode) +
      publicReceipt.hashCode +
      requestVersion.hashCode +
      status.hashCode +
      (transactionId == null ? 0 : transactionId.hashCode) +
      validationId.hashCode;

  factory SdkRevenueReceiptValidateResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SdkRevenueReceiptValidateResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SdkRevenueReceiptValidateResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum SdkRevenueReceiptValidateResponseDtoStatusEnum {
  @JsonValue(r'verified')
  verified(r'verified'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'unconfigured')
  unconfigured(r'unconfigured'),
  @JsonValue(r'provider_error')
  providerError(r'provider_error'),
  @JsonValue(r'passthrough')
  passthrough(r'passthrough');

  const SdkRevenueReceiptValidateResponseDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
