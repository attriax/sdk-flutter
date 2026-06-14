import '../../attriax_consent.dart';
import '../attriax_consent_manager.dart';

class AttriaxConsentPolicy {
  const AttriaxConsentPolicy({
    required this.gdprEnabled,
    required this.state,
    required this.values,
    required this.anonymousTrackingEnabled,
  });

  final bool gdprEnabled;
  final AttriaxGdprConsentState state;
  final AttriaxGdprConsentValues? values;
  final bool anonymousTrackingEnabled;

  bool get isWaitingForGdprConsent =>
      state == AttriaxGdprConsentState.pending ||
      state == AttriaxGdprConsentState.unknown;

  bool get shouldDeferNetworkDispatch =>
      gdprEnabled && isWaitingForGdprConsent && !anonymousTrackingEnabled;

  /// Whether runtime-scoped data may be persisted to disk under the current
  /// consent. Runtime persistence is allowed when GDPR is off, the region does
  /// not require consent, or the user granted at least one tracking category.
  /// Anything else keeps the store in consent-only mode (memory-backed runtime
  /// data) until a category is granted.
  bool get allowsRuntimePersistence {
    if (!gdprEnabled) {
      return true;
    }
    if (state == AttriaxGdprConsentState.notRequired) {
      return true;
    }
    final currentValues = values;
    return state == AttriaxGdprConsentState.granted &&
        currentValues != null &&
        (currentValues.analytics ||
            currentValues.attribution ||
            currentValues.adEvents);
  }

  /// Strict identity gate: may this category be tracked with the device
  /// identity (and full runtime persistence)? Anonymous tracking does NOT
  /// relax a category the user explicitly declined under granted consent.
  /// Pair with [canCaptureSignal] which answers the looser capture question.
  bool allowsCategory(bool Function(AttriaxGdprConsentValues values) selector) {
    if (!gdprEnabled) {
      return true;
    }

    return switch (state) {
      AttriaxGdprConsentState.notRequired => true,
      AttriaxGdprConsentState.granted => values != null && selector(values!),
      AttriaxGdprConsentState.pending ||
      AttriaxGdprConsentState.unknown => false,
    };
  }

  bool canCaptureCategory(
    bool Function(AttriaxGdprConsentValues values) selector, {
    required bool allowWhileWaiting,
  }) {
    if (!gdprEnabled) {
      return true;
    }

    return switch (state) {
      AttriaxGdprConsentState.notRequired => true,
      AttriaxGdprConsentState.granted => values != null && selector(values!),
      AttriaxGdprConsentState.pending ||
      AttriaxGdprConsentState.unknown => allowWhileWaiting,
    };
  }

  /// Permissive capture gate: may this signal be captured at all, possibly
  /// anonymously? With [anonymousTrackingEnabled] on, a declined but
  /// anonymous-capable signal is still captured (anonymized) — this is
  /// intentional. Pair with [allowsCategory] for the stricter identity gate.
  bool canCaptureSignal(AttriaxTrackingSignal signal) {
    if (!gdprEnabled) {
      return true;
    }

    return switch (state) {
      AttriaxGdprConsentState.notRequired => true,
      AttriaxGdprConsentState.granted =>
        values != null &&
            (isSignalGranted(signal, values!) ||
                (anonymousTrackingEnabled && isAnonymousCapableSignal(signal))),
      AttriaxGdprConsentState.pending ||
      AttriaxGdprConsentState.unknown => canCaptureWhileWaiting(signal),
    };
  }

  AttriaxTrackingDecision trackingDecisionFor(AttriaxTrackingSignal signal) {
    if (!gdprEnabled) {
      return _identified;
    }

    if (state == AttriaxGdprConsentState.unknown ||
        state == AttriaxGdprConsentState.pending) {
      if (!canCaptureWhileWaiting(signal)) {
        return _withheld;
      }

      return AttriaxTrackingDecision(
        capture: true,
        identityMode: AttriaxTrackingIdentityMode.anonymous,
        deferNetwork: !anonymousTrackingEnabled,
      );
    }

    if (state == AttriaxGdprConsentState.notRequired) {
      return _identified;
    }

    final currentValues = values;
    if (state != AttriaxGdprConsentState.granted || currentValues == null) {
      return _withheld;
    }

    if (isSignalGranted(signal, currentValues)) {
      return _identified;
    }

    if (anonymousTrackingEnabled && isAnonymousCapableSignal(signal)) {
      return _anonymous;
    }

    return _withheld;
  }

  bool canCaptureWhileWaiting(AttriaxTrackingSignal signal) => switch (signal) {
    AttriaxTrackingSignal.analytics ||
    AttriaxTrackingSignal.adEvents ||
    AttriaxTrackingSignal.session ||
    AttriaxTrackingSignal.deepLink => true,
    AttriaxTrackingSignal.attribution ||
    AttriaxTrackingSignal.uninstallTracking => false,
  };

  bool isAnonymousCapableSignal(AttriaxTrackingSignal signal) =>
      canCaptureWhileWaiting(signal);

  bool isSignalGranted(
    AttriaxTrackingSignal signal,
    AttriaxGdprConsentValues values,
  ) => switch (signal) {
    AttriaxTrackingSignal.analytics => values.analytics,
    AttriaxTrackingSignal.adEvents => values.adEvents,
    AttriaxTrackingSignal.attribution => values.attribution,
    AttriaxTrackingSignal.session => values.analytics || values.adEvents,
    AttriaxTrackingSignal.deepLink => values.attribution,
    AttriaxTrackingSignal.uninstallTracking => values.attribution,
  };
}

const AttriaxTrackingDecision _identified = AttriaxTrackingDecision(
  capture: true,
  identityMode: AttriaxTrackingIdentityMode.identified,
  deferNetwork: false,
);

const AttriaxTrackingDecision _anonymous = AttriaxTrackingDecision(
  capture: true,
  identityMode: AttriaxTrackingIdentityMode.anonymous,
  deferNetwork: false,
);

const AttriaxTrackingDecision _withheld = AttriaxTrackingDecision(
  capture: false,
  identityMode: AttriaxTrackingIdentityMode.withheld,
  deferNetwork: false,
);
