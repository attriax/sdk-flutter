import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_api_base_url.dart';

void validateAttriaxRuntimeConfig({
  required AttriaxConfig config,
  required AttriaxNormalizedApiBaseUrl Function() normalizeApiBaseUrl,
}) {
  if (config.projectToken.trim().isEmpty) {
    throw ArgumentError('Attriax projectToken must not be empty.');
  }
  normalizeApiBaseUrl();
  if (config.maxQueueSize <= 0) {
    throw ArgumentError('Attriax maxQueueSize must be greater than zero.');
  }
  if (config.eventFlushInterval.isNegative) {
    throw ArgumentError('Attriax eventFlushInterval must not be negative.');
  }
  if (config.trackingAuthorizationStatusTimeout.isNegative) {
    throw ArgumentError(
      'Attriax trackingAuthorizationStatusTimeout must not be negative.',
    );
  }
}
