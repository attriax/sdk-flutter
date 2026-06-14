import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_api_models.dart';
import 'attriax_generated_transport.dart';

class AttriaxDirectApiClient {
  const AttriaxDirectApiClient({
    required AttriaxConfig config,
    required AttriaxClock clock,
    required String? Function() deviceId,
    required AttriaxGeneratedTransport Function() transport,
  }) : _config = config,
       _clock = clock,
       _deviceId = deviceId,
       _transport = transport;

  final AttriaxConfig _config;
  final AttriaxClock _clock;
  final String? Function() _deviceId;
  final AttriaxGeneratedTransport Function() _transport;

  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    Map<String, Object?>? data,
  }) {
    final request = attriaxBuildCreateDynamicLinkRequest(
      appToken: _config.projectToken,
      name: _trimOrNull(name),
      destinationUrl: _trimOrNull(destinationUrl),
      group: _trimOrNull(group),
      prefix: _trimOrNull(prefix),
      redirects: redirects == null
          ? null
          : AttriaxDynamicLinkRedirects(
              ios: redirects.ios,
              android: redirects.android,
            ),
      socialPreview: socialPreview == null
          ? null
          : AttriaxDynamicLinkSocialPreview(
              title: _trimOrNull(socialPreview.title),
              description: _trimOrNull(socialPreview.description),
            ),
      utms: utms == null
          ? null
          : AttriaxDynamicLinkUtms(
              source: _trimOrNull(utms.source),
              medium: _trimOrNull(utms.medium),
              campaign: _trimOrNull(utms.campaign),
              term: _trimOrNull(utms.term),
              content: _trimOrNull(utms.content),
            ),
      data: data,
    );

    return _transport().createDynamicLink(request);
  }

  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    required String receipt,
    bool test = false,
    String? provider,
    String? environment,
    String? productId,
    String? transactionId,
  }) {
    final normalizedReceipt = _trimOrNull(receipt);
    if (normalizedReceipt == null) {
      throw ArgumentError.value(
        receipt,
        'receipt',
        'receipt must not be empty.',
      );
    }

    final request = attriaxBuildValidateRevenueReceiptRequest(
      projectToken: _config.projectToken,
      deviceId: _deviceId(),
      clientOccurredAt: _clock.now(),
      receipt: normalizedReceipt,
      provider: _trimOrNull(provider),
      environment: _trimOrNull(environment),
      transactionId: _trimOrNull(transactionId),
      productId: _trimOrNull(productId),
      test: test,
    );

    return _transport().validateRevenueReceipt(request);
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
