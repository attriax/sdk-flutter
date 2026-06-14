import '../../attriax_ad_event_type.dart';
import '../../attriax_analytics_keys.dart';
import '../attriax_api_models.dart';
import '../attriax_consent_manager.dart';

class AttriaxConsentQueuePolicy {
  const AttriaxConsentQueuePolicy({
    required bool Function() isWaitingForGdprConsent,
    required bool Function() anonymousTrackingEnabled,
    required bool Function() allowsAttributionTracking,
    required AttriaxTrackingDecision Function(AttriaxTrackingSignal signal)
    trackingDecisionFor,
  }) : _isWaitingForGdprConsent = isWaitingForGdprConsent,
       _anonymousTrackingEnabled = anonymousTrackingEnabled,
       _allowsAttributionTracking = allowsAttributionTracking,
       _trackingDecisionFor = trackingDecisionFor;

  final bool Function() _isWaitingForGdprConsent;
  final bool Function() _anonymousTrackingEnabled;
  final bool Function() _allowsAttributionTracking;
  final AttriaxTrackingDecision Function(AttriaxTrackingSignal signal)
  _trackingDecisionFor;

  AttriaxTrackingDecision? trackingDecisionForQueuedRequest(
    AttriaxApiRequest request,
  ) => switch (request) {
    AttriaxTrackEventRequest(:final payload) => _trackingDecisionFor(
      _isAdEventName(payload.eventName)
          ? AttriaxTrackingSignal.adEvents
          : AttriaxTrackingSignal.analytics,
    ),
    AttriaxTrackCrashRequest() => _trackingDecisionFor(
      AttriaxTrackingSignal.analytics,
    ),
    AttriaxTrackSessionRequest() => _trackingDecisionFor(
      AttriaxTrackingSignal.session,
    ),
    AttriaxResolveDeepLinkRequest() => _trackingDecisionFor(
      AttriaxTrackingSignal.deepLink,
    ),
    _ => null,
  };

  bool shouldIdentifyQueuedRequestForResolvedConsent(
    AttriaxApiRequest request,
  ) {
    if (_isWaitingForGdprConsent()) {
      return false;
    }

    final decision = trackingDecisionForQueuedRequest(request);
    return decision != null &&
        decision.capture &&
        decision.attachDeviceIdentity;
  }

  bool isRequestAllowedByResolvedConsent(AttriaxApiRequest request) =>
      switch (request) {
        AttriaxTrackEventRequest() ||
        AttriaxTrackCrashRequest() ||
        AttriaxTrackSessionRequest() ||
        AttriaxResolveDeepLinkRequest() =>
          trackingDecisionForQueuedRequest(request)?.capture ?? false,
        AttriaxUserRequest() => _allowsAttributionTracking(),
        AttriaxOpenRequest() => _allowsAttributionTracking(),
        AttriaxRegisterUninstallTokenRequest() => _allowsAttributionTracking(),
        AttriaxCreateDynamicLinkRequest() => true,
      };

  bool shouldAnonymizeQueuedRequest(AttriaxApiRequest request) {
    if (_isWaitingForGdprConsent() || !_anonymousTrackingEnabled()) {
      return false;
    }

    final decision = trackingDecisionForQueuedRequest(request);
    return decision != null &&
        decision.capture &&
        !decision.attachDeviceIdentity;
  }

  bool _isAdEventName(String eventName) =>
      eventName == AttriaxAnalyticsEventKeys.adRevenue ||
      AttriaxAdEventType.values.any((value) => value.eventName == eventName);
}
