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

    this.originalTransactionId,

    this.packageName,

    this.productId,

    this.projectToken,

    this.provider,

    this.purchaseToken,

    this.receiptData,

    this.receiptSignature,

    this.signedPayload,

    this.store,

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

  @JsonKey(
    name: r'originalTransactionId',
    required: false,
    includeIfNull: false,
  )
  final String? originalTransactionId;

  @JsonKey(name: r'packageName', required: false, includeIfNull: false)
  final String? packageName;

  @JsonKey(name: r'productId', required: false, includeIfNull: false)
  final String? productId;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  @JsonKey(name: r'provider', required: false, includeIfNull: false)
  final String? provider;

  @JsonKey(name: r'purchaseToken', required: false, includeIfNull: false)
  final String? purchaseToken;

  @JsonKey(name: r'receiptData', required: false, includeIfNull: false)
  final String? receiptData;

  @JsonKey(name: r'receiptSignature', required: false, includeIfNull: false)
  final String? receiptSignature;

  @JsonKey(name: r'signedPayload', required: false, includeIfNull: false)
  final String? signedPayload;

  @JsonKey(name: r'store', required: false, includeIfNull: false)
  final String? store;

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
          other.originalTransactionId == originalTransactionId &&
          other.packageName == packageName &&
          other.productId == productId &&
          other.projectToken == projectToken &&
          other.provider == provider &&
          other.purchaseToken == purchaseToken &&
          other.receiptData == receiptData &&
          other.receiptSignature == receiptSignature &&
          other.signedPayload == signedPayload &&
          other.store == store &&
          other.test == test &&
          other.transactionId == transactionId;

  @override
  int get hashCode =>
      appToken.hashCode +
      clientOccurredAt.hashCode +
      deviceId.hashCode +
      environment.hashCode +
      originalTransactionId.hashCode +
      packageName.hashCode +
      productId.hashCode +
      projectToken.hashCode +
      provider.hashCode +
      purchaseToken.hashCode +
      receiptData.hashCode +
      receiptSignature.hashCode +
      signedPayload.hashCode +
      store.hashCode +
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
