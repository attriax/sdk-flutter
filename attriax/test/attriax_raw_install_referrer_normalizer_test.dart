import 'package:attriax_flutter/src/internal/referrers/attriax_raw_install_referrer_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('attriaxNormalizeRawInstallReferrer', () {
    test('normalizes null and blank raw referrers to null', () {
      expect(attriaxNormalizeRawInstallReferrer(null), isNull);
      expect(attriaxNormalizeRawInstallReferrer(''), isNull);
      expect(attriaxNormalizeRawInstallReferrer('   '), isNull);
    });

    test('trims non-empty raw referrers', () {
      expect(
        attriaxNormalizeRawInstallReferrer('  utm_source=test  '),
        'utm_source=test',
      );
    });
  });
}
