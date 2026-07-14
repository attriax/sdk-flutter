// ignore_for_file: cascade_invocations

import 'package:attriax_flutter/attriax_flutter.dart';
// ignore: implementation_imports
import 'package:attriax_flutter/src/internal/attriax_runtime_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records CCPA getter reads and setter calls so the facade forwarding can be
/// asserted. Every other runtime member routes to [noSuchMethod] (unused here).
class _FakeCcpaRuntime implements AttriaxRuntimeInterface {
  _FakeCcpaRuntime({bool? doNotSell, String? usPrivacy})
    : _doNotSell = doNotSell,
      _usPrivacy = usPrivacy;

  bool? _doNotSell;
  String? _usPrivacy;
  final List<bool?> doNotSellCalls = <bool?>[];
  final List<String?> usPrivacyCalls = <String?>[];

  @override
  bool? get ccpaDoNotSell => _doNotSell;

  @override
  String? get ccpaUsPrivacy => _usPrivacy;

  @override
  void setCcpaDoNotSell(bool? doNotSell) {
    doNotSellCalls.add(doNotSell);
    _doNotSell = doNotSell;
  }

  @override
  void setCcpaUsPrivacy(String? usPrivacy) {
    usPrivacyCalls.add(usPrivacy);
    _usPrivacy = usPrivacy;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AttriaxCcpaConsent facade', () {
    test('getters read the seeded runtime election', () {
      final runtime = _FakeCcpaRuntime(doNotSell: true, usPrivacy: '1YYN');
      final ccpa = AttriaxCcpaConsent(runtime);

      expect(ccpa.doNotSell, isTrue);
      expect(ccpa.usPrivacy, '1YYN');
    });

    test('getters default to null when the election is unset', () {
      final ccpa = AttriaxCcpaConsent(_FakeCcpaRuntime());

      expect(ccpa.doNotSell, isNull);
      expect(ccpa.usPrivacy, isNull);
    });

    test('setDoNotSell forwards the election, including an explicit false', () {
      final runtime = _FakeCcpaRuntime();
      final ccpa = AttriaxCcpaConsent(runtime);

      ccpa.setDoNotSell(false);

      expect(runtime.doNotSellCalls, <bool?>[false]);
      expect(runtime.usPrivacyCalls, isEmpty);
      expect(ccpa.doNotSell, isFalse);
    });

    test('setUsPrivacy forwards the raw string', () {
      final runtime = _FakeCcpaRuntime();
      final ccpa = AttriaxCcpaConsent(runtime);

      ccpa.setUsPrivacy('1YNN');

      expect(runtime.usPrivacyCalls, <String?>['1YNN']);
      expect(runtime.doNotSellCalls, isEmpty);
      expect(ccpa.usPrivacy, '1YNN');
    });

    test('setDoNotSell(null) returns the election to the unset state', () {
      final runtime = _FakeCcpaRuntime(doNotSell: true);
      final ccpa = AttriaxCcpaConsent(runtime);

      ccpa.setDoNotSell(null);

      expect(runtime.doNotSellCalls, <bool?>[null]);
      expect(ccpa.doNotSell, isNull);
    });

    test('set forwards both fields in one call', () {
      final runtime = _FakeCcpaRuntime();
      final ccpa = AttriaxCcpaConsent(runtime);

      ccpa.set(true, '1YYN');

      expect(runtime.doNotSellCalls, <bool?>[true]);
      expect(runtime.usPrivacyCalls, <String?>['1YYN']);
    });

    test('exposed under attriax.consent.ccpa on a live instance', () {
      final attriax = Attriax(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          doNotSell: false,
          usPrivacy: '1YYN',
        ),
      );

      expect(attriax.consent.ccpa, isA<AttriaxCcpaConsent>());
      expect(attriax.consent.ccpa.doNotSell, isFalse);
      expect(attriax.consent.ccpa.usPrivacy, '1YYN');
    });
  });
}
