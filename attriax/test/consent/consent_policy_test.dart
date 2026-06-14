import 'package:attriax_flutter/src/attriax_consent.dart';
import 'package:attriax_flutter/src/internal/consent/attriax_consent_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AttriaxConsentPolicy policy({
    bool gdprEnabled = true,
    AttriaxGdprConsentState state = AttriaxGdprConsentState.unknown,
    AttriaxGdprConsentValues? values,
  }) => AttriaxConsentPolicy(
    gdprEnabled: gdprEnabled,
    state: state,
    values: values,
    anonymousTrackingEnabled: false,
  );

  group('allowsRuntimePersistence', () {
    test('allows when GDPR is disabled', () {
      expect(policy(gdprEnabled: false).allowsRuntimePersistence, isTrue);
    });

    test('allows when consent is not required', () {
      expect(
        policy(state: AttriaxGdprConsentState.notRequired)
            .allowsRuntimePersistence,
        isTrue,
      );
    });

    test('defers (consent-only) while waiting for consent', () {
      expect(policy(state: AttriaxGdprConsentState.unknown).allowsRuntimePersistence, isFalse);
      expect(policy(state: AttriaxGdprConsentState.pending).allowsRuntimePersistence, isFalse);
    });

    test('allows once any category is granted', () {
      expect(
        policy(
          state: AttriaxGdprConsentState.granted,
          values: const AttriaxGdprConsentValues(
            analytics: false,
            attribution: true,
            adEvents: false,
          ),
        ).allowsRuntimePersistence,
        isTrue,
      );
    });

    test('defers when granted but every category is denied', () {
      expect(
        policy(
          state: AttriaxGdprConsentState.granted,
          values: const AttriaxGdprConsentValues(
            analytics: false,
            attribution: false,
            adEvents: false,
          ),
        ).allowsRuntimePersistence,
        isFalse,
      );
    });

    test('defers when granted with null values', () {
      expect(
        policy(state: AttriaxGdprConsentState.granted).allowsRuntimePersistence,
        isFalse,
      );
    });
  });
}
