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

  test('treats EU outermost regions outside Europe/ as GDPR-required', () {
    for (final zone in const <String>[
      'America/Cayenne',
      'America/Guadeloupe',
      'America/Martinique',
      'America/Marigot',
      'America/St_Barthelemy',
      'Indian/Mayotte',
      'Indian/Reunion',
    ]) {
      expect(
        attriaxResolveGdprStateForTimezone(zone),
        AttriaxGdprConsentState.pending,
        reason: '$zone is an EU outermost region and requires consent',
      );
    }
  });

  test('still defaults non-EU zones to notRequired', () {
    expect(
      attriaxResolveGdprStateForTimezone('America/New_York'),
      AttriaxGdprConsentState.notRequired,
    );
    expect(
      attriaxResolveGdprStateForTimezone('Asia/Tokyo'),
      AttriaxGdprConsentState.notRequired,
    );
  });
}
