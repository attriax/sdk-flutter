const _attriaxInvalidUserPropertyValue = Object();
const _attriaxMaxUserPropertyKeys = 30;
const _attriaxMaxUserPropertyValueLength = 256;

final class AttriaxSanitizedUserPropertyUpdate {
  const AttriaxSanitizedUserPropertyUpdate({
    required this.properties,
    required this.clearPropertyKeys,
  });

  final Map<String, Object?> properties;
  final List<String> clearPropertyKeys;

  bool get isEmpty => properties.isEmpty && clearPropertyKeys.isEmpty;
}

AttriaxSanitizedUserPropertyUpdate attriaxSanitizeUserPropertyUpdate(
  Map<String, Object?> input,
) {
  final properties = <String, Object?>{};
  final clearPropertyKeys = <String>[];

  for (final entry in input.entries) {
    final normalizedKey = entry.key.trim();
    if (normalizedKey.isEmpty) {
      continue;
    }

    final rawValue = entry.value;
    if (rawValue == null) {
      properties.remove(normalizedKey);
      if (!clearPropertyKeys.contains(normalizedKey)) {
        clearPropertyKeys.add(normalizedKey);
      }
      continue;
    }

    final normalizedValue = _attriaxSanitizeUserPropertyValue(rawValue);
    if (identical(normalizedValue, _attriaxInvalidUserPropertyValue)) {
      continue;
    }

    clearPropertyKeys.remove(normalizedKey);
    if (!properties.containsKey(normalizedKey) &&
        properties.length >= _attriaxMaxUserPropertyKeys) {
      continue;
    }

    properties[normalizedKey] = normalizedValue;
  }

  return AttriaxSanitizedUserPropertyUpdate(
    properties: properties,
    clearPropertyKeys: clearPropertyKeys,
  );
}

Object _attriaxSanitizeUserPropertyValue(Object value) {
  if (value is String) {
    return value.length <= _attriaxMaxUserPropertyValueLength
        ? value
        : value.substring(0, _attriaxMaxUserPropertyValueLength);
  }

  if (value is num || value is bool) {
    return value;
  }

  return _attriaxInvalidUserPropertyValue;
}
