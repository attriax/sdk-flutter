import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_attestation_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_generated_transport.dart';
import 'package:attriax_flutter/src/internal/attriax_queue.dart';
import 'package:attriax_flutter/src/internal/attriax_sdk_runtime_config.dart';
import 'package:attriax_api_client/attriax_api_client.dart' as sdk;
import 'attriax_platform_test_support.dart';

class FakeGeneratedTransport implements AttriaxGeneratedTransport {
  final List<AttriaxApiRequest> sentRequests = <AttriaxApiRequest>[];
  final List<List<AttriaxQueuedRequest>> sentBatches =
      <List<AttriaxQueuedRequest>>[];
  final List<Map<String, Object?>> runtimeConfigRequests =
      <Map<String, Object?>>[];

  AttriaxTransportSuccess? sendResult;
  AttriaxTransportSuccess? sendBatchResult;
  Exception? sendError;
  final List<Exception> batchErrors = <Exception>[];
  Exception? runtimeConfigError;
  AttriaxSdkRuntimeConfig runtimeConfigResult = const AttriaxSdkRuntimeConfig();

  @override
  Future<AttriaxTransportSuccess> send(AttriaxApiRequest request) async {
    sentRequests.add(request);
    if (sendError != null) {
      throw sendError!;
    }

    return sendResult ??
        const AttriaxTransportSuccess(
          statusCode: 200,
          response: AttriaxAckResponse(success: true),
        );
  }

  @override
  Future<AttriaxTransportSuccess> sendBatch(
    List<AttriaxQueuedRequest> requests,
  ) async {
    sentBatches.add(List<AttriaxQueuedRequest>.from(requests));
    if (batchErrors.isNotEmpty) {
      throw batchErrors.removeAt(0);
    }

    return sendBatchResult ??
        const AttriaxTransportSuccess(
          statusCode: 200,
          response: AttriaxAckResponse(success: true),
        );
  }

  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink(
    AttriaxCreateDynamicLinkRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> registerUninstallToken(Map<String, Object?> payload) {
    throw UnimplementedError();
  }

  @override
  Future<AttriaxRevenueReceiptValidationResult> validateRevenueReceipt(
    Map<String, Object?> payload,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<AttriaxRevenueUsdConversionResult> convertRevenueToUsd(
    Map<String, Object?> payload,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> eraseGdprData({
    required String projectToken,
    required String deviceId,
  }) async {}

  @override
  Future<sdk.SdkGdprConsentStatusDto> checkGdprConsent({
    required String projectToken,
    required String consentId,
  }) async => sdk.SdkGdprConsentStatusDto(
    checkedAt: DateTime.utc(2026, 5, 20),
    needsConsent: false,
    state: sdk.AppUserGdprConsentState.notRequired,
  );

  @override
  Future<sdk.SdkGdprConsentStatusDto> upsertGdprConsent({
    required String projectToken,
    required String consentId,
    required sdk.AppUserGdprConsentState state,
    sdk.SdkV1GdprConsentValuesDto? values,
    String? countryCode,
    String? regionSource,
    DateTime? clientOccurredAt,
  }) async => sdk.SdkGdprConsentStatusDto(
    checkedAt: clientOccurredAt ?? DateTime.utc(2026, 5, 20),
    countryCode: countryCode,
    needsConsent: state == sdk.AppUserGdprConsentState.pending,
    regionSource: regionSource,
    state: state,
    values: values == null
        ? null
        : sdk.SdkGdprConsentValuesDto(
            analytics: values.analytics,
            attribution: values.attribution,
            adEvents: values.adEvents,
          ),
  );

  AttriaxAttestationChallenge? attestationChallengeResult;

  @override
  Future<AttriaxAttestationChallenge?> fetchAttestationChallenge() async =>
      attestationChallengeResult;

  final List<Map<String, String>> asaTokenRequests = <Map<String, String>>[];

  @override
  Future<void> sendAsaToken({
    required String projectToken,
    required String token,
  }) async {
    asaTokenRequests.add(<String, String>{
      'projectToken': projectToken,
      'token': token,
    });
  }

  @override
  Future<AttriaxSdkRuntimeConfig> fetchSdkRuntimeConfig(
    Map<String, Object?> payload,
  ) async {
    runtimeConfigRequests.add(Map<String, Object?>.from(payload));
    if (runtimeConfigError != null) {
      throw runtimeConfigError!;
    }

    return runtimeConfigResult;
  }
}
