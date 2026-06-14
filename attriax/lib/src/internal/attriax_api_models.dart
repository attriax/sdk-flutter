// ignore_for_file: deprecated_member_use

import 'package:attriax_api_client/attriax_api_client.dart' as sdk;
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_json_utils.dart';

part 'transport/requests/request_models.dart';
part 'transport/requests/batching_helpers.dart';
part 'transport/requests/consent_request_rewrites.dart';
part 'transport/requests/request_json_codec.dart';
part 'transport/requests/request_builders.dart';
part 'transport/requests/response_mappers.dart';

abstract class AttriaxApiResponse {
  const AttriaxApiResponse();
}

class AttriaxAckResponse extends AttriaxApiResponse {
  const AttriaxAckResponse({required this.success});

  final bool success;
}

class AttriaxOpenApiResponse extends AttriaxApiResponse {
  const AttriaxOpenApiResponse({required this.result});

  final AttriaxAppOpenResult result;
}

class AttriaxResolveDeepLinkApiResponse extends AttriaxApiResponse {
  const AttriaxResolveDeepLinkApiResponse({required this.result});

  final AttriaxDeepLinkResolutionResult result;
}

class AttriaxCreateDynamicLinkApiResponse extends AttriaxApiResponse {
  const AttriaxCreateDynamicLinkApiResponse({required this.result});

  final AttriaxCreateDynamicLinkResult result;
}

class AttriaxRevenueReceiptValidationApiResponse extends AttriaxApiResponse {
  const AttriaxRevenueReceiptValidationApiResponse({required this.result});

  final AttriaxRevenueReceiptValidationResult result;
}

class AttriaxRevenueUsdConversionResult {
  const AttriaxRevenueUsdConversionResult({
    required this.requestVersion,
    required this.acceptedAt,
    required this.currency,
    required this.amountOriginalMicros,
    required this.amountUsdMicros,
    required this.amountUsd,
    required this.rate,
    required this.rateDate,
    required this.conversionStatus,
  });

  factory AttriaxRevenueUsdConversionResult.fromJson(
    Map<String, Object?> json,
  ) => AttriaxRevenueUsdConversionResult(
    requestVersion: attriaxStringValue(json['requestVersion']) ?? 'v1',
    acceptedAt:
        attriaxDateTimeValue(json['acceptedAt'])?.toUtc() ??
        DateTime.now().toUtc(),
    currency: attriaxStringValue(json['currency']) ?? 'USD',
    amountOriginalMicros:
        attriaxStringValue(json['amountOriginalMicros']) ?? '0',
    amountUsdMicros: attriaxStringValue(json['amountUsdMicros']) ?? '0',
    amountUsd: _attriaxDoubleValue(json['amountUsd']) ?? 0,
    rate: attriaxStringValue(json['rate']) ?? '1',
    rateDate: attriaxStringValue(json['rateDate']) ?? '',
    conversionStatus: attriaxStringValue(json['conversionStatus']) ?? 'usd',
  );

  final String requestVersion;
  final DateTime acceptedAt;
  final String currency;
  final String amountOriginalMicros;
  final String amountUsdMicros;
  final double amountUsd;
  final String rate;
  final String rateDate;
  final String conversionStatus;
}

class AttriaxRevenueUsdConversionApiResponse extends AttriaxApiResponse {
  const AttriaxRevenueUsdConversionApiResponse({required this.result});

  final AttriaxRevenueUsdConversionResult result;
}
