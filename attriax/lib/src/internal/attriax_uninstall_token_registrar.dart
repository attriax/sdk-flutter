import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_api_models.dart';
import 'attriax_consent_manager.dart';
import 'attriax_context_manager.dart';
import 'attriax_logger.dart';
import 'attriax_request_manager.dart';

/// Builds and enqueues uninstall-tracking (push) token registrations.
///
/// Extracted from `AttriaxRuntime` so the consent gate + request construction
/// for FCM/APNs tokens can be read and tested without the full runtime. The
/// runtime keeps the public `registerFirebaseMessagingToken` /
/// `registerApplePushToken` entrypoints and delegates here.
class AttriaxUninstallTokenRegistrar {
  AttriaxUninstallTokenRegistrar({
    required AttriaxConfig config,
    required AttriaxContextManager contextManager,
    required AttriaxRequestManager requestManager,
    required AttriaxConsentReadView consent,
    required AttriaxLogger logger,
  }) : _config = config,
       _contextManager = contextManager,
       _requestManager = requestManager,
       _consent = consent,
       _logger = logger;

  final AttriaxConfig _config;
  final AttriaxContextManager _contextManager;
  final AttriaxRequestManager _requestManager;
  final AttriaxConsentReadView _consent;
  final AttriaxLogger _logger;

  Future<void> register({
    required String provider,
    required String? token,
    Map<String, Object?>? metadata,
  }) async {
    final canCapture = _consent
        .trackingDecisionFor(AttriaxTrackingSignal.uninstallTracking)
        .capture;
    if (!canCapture) {
      _logger.verbose(
        'Ignoring uninstall-token registration because GDPR attribution consent is not granted.',
      );
      return;
    }

    final deviceId = _contextManager.deviceId;
    if (deviceId == null) {
      throw StateError('Attriax SDK did not restore a device id.');
    }

    final normalizedToken = token?.trim();
    final request = attriaxBuildRegisterUninstallTokenQueueRequest(
      appToken: _config.projectToken,
      deviceId: deviceId,
      deviceIdSource: _contextManager.requireDeviceIdSource(),
      platform: _contextManager.requiredSnapshot.platform,
      provider: provider,
      token: normalizedToken == null || normalizedToken.isEmpty
          ? null
          : normalizedToken,
      metadata: metadata,
    );

    await _requestManager.enqueue(request);
  }
}
