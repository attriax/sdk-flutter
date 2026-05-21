import 'package:attriax_flutter/src/attriax_consent.dart';
import 'package:attriax_flutter/src/internal/attriax_gdpr_region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps Windows timezone ids into GDPR-aware states', () {
    expect(
      attriaxResolveGdprStateForTimezone('W. Europe Standard Time'),
      AttriaxGdprConsentState.pending,
    );
    expect(
      attriaxResolveGdprStateForTimezone('Turkey Standard Time'),
      AttriaxGdprConsentState.notRequired,
    );
  });
}
