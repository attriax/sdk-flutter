Map<String, Object?> attriaxObjectMapOrEmpty(Object? value) =>
    attriaxObjectMap(value) ?? const <String, Object?>{};

Map<String, Object?>? attriaxObjectMap(Object? value) {
  if (value is! Map) {
    return null;
  }

  return value.map(
    (key, nestedValue) =>
        MapEntry(key.toString(), attriaxNormalizeJsonValue(nestedValue)),
  );
}

Map<String, Object?> attriaxNormalizeJsonMap(Map<String, Object?> input) =>
    input.map((key, value) => MapEntry(key, attriaxNormalizeJsonValue(value)));

Map<String, Object?> attriaxNormalizeJsonObject(Map<Object?, Object?> input) =>
    input.map(
      (key, value) =>
          MapEntry(key.toString(), attriaxNormalizeJsonValue(value)),
    );

Object? attriaxNormalizeJsonValue(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is List) {
    return value.map(attriaxNormalizeJsonValue).toList(growable: false);
  }
  if (value is Map) {
    return value.map(
      (key, nestedValue) =>
          MapEntry(key.toString(), attriaxNormalizeJsonValue(nestedValue)),
    );
  }
  return value.toString();
}

String? attriaxStringValue(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  return null;
}

String attriaxRequireString(Map<String, Object?> json, String key) {
  final value = attriaxStringValue(json[key]);
  if (value == null) {
    throw FormatException('Missing or invalid "$key".');
  }
  return value;
}

bool? attriaxBoolValue(Object? value) => value is bool ? value : null;

DateTime? attriaxDateTimeValue(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
