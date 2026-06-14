import '../attriax_consent.dart';

const Set<String> _attriaxExplicitGdprTimezones = <String>{
  'Arctic/Longyearbyen',
  'Asia/Famagusta',
  'Asia/Nicosia',
  'Atlantic/Azores',
  'Atlantic/Canary',
  'Atlantic/Faroe',
  'Atlantic/Madeira',
  'Atlantic/Reykjavik',
  // EU outermost regions / overseas territories where GDPR applies but the
  // timezone is not under `Europe/`. Without these they would fall through to
  // the `notRequired` default below — the under-protective direction.
  'America/Cayenne', // French Guiana
  'America/Guadeloupe', // Guadeloupe
  'America/Marigot', // Saint-Martin
  'America/Martinique', // Martinique
  'America/St_Barthelemy', // Saint-Barthélemy
  'Indian/Mayotte', // Mayotte
  'Indian/Reunion', // Réunion
};

const Set<String> _attriaxExcludedEuropeTimezones = <String>{
  'Europe/Andorra',
  'Europe/Belgrade',
  'Europe/Chisinau',
  'Europe/Istanbul',
  'Europe/Kaliningrad',
  'Europe/Kiev',
  'Europe/Kirov',
  'Europe/Kyiv',
  'Europe/Minsk',
  'Europe/Moscow',
  'Europe/Podgorica',
  'Europe/Pristina',
  'Europe/Samara',
  'Europe/Sarajevo',
  'Europe/Simferopol',
  'Europe/Skopje',
  'Europe/Tirane',
  'Europe/Uzhgorod',
  'Europe/Volgograd',
  'Europe/Zaporozhye',
};

const Map<String, String> _attriaxTimezoneAliases = <String, String>{
  'Belarus Standard Time': 'Europe/Minsk',
  'Central Europe Standard Time': 'Europe/Budapest',
  'Central European Standard Time': 'Europe/Warsaw',
  'E. Europe Standard Time': 'Europe/Chisinau',
  'FLE Standard Time': 'Europe/Helsinki',
  'GMT Standard Time': 'Europe/London',
  'GTB Standard Time': 'Europe/Bucharest',
  'Greenwich Standard Time': 'Atlantic/Reykjavik',
  'Kaliningrad Standard Time': 'Europe/Kaliningrad',
  'Romance Standard Time': 'Europe/Paris',
  'Russia Time Zone 3': 'Europe/Samara',
  'Russian Standard Time': 'Europe/Moscow',
  'Turkey Standard Time': 'Europe/Istanbul',
  'Volgograd Standard Time': 'Europe/Volgograd',
  'W. Europe Standard Time': 'Europe/Berlin',
};

AttriaxGdprConsentState? attriaxResolveGdprStateForTimezone(String? timezone) {
  final normalized = _attriaxCanonicalizeTimezone(timezone);
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  if (!normalized.contains('/')) {
    return null;
  }

  if (_attriaxExplicitGdprTimezones.contains(normalized)) {
    return AttriaxGdprConsentState.pending;
  }

  if (normalized.startsWith('Europe/')) {
    return _attriaxExcludedEuropeTimezones.contains(normalized)
        ? AttriaxGdprConsentState.notRequired
        : AttriaxGdprConsentState.pending;
  }

  return AttriaxGdprConsentState.notRequired;
}

String? _attriaxCanonicalizeTimezone(String? timezone) {
  final normalized = timezone?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return _attriaxTimezoneAliases[normalized] ?? normalized;
}
