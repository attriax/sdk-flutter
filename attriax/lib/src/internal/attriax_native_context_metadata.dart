import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';

class AttriaxNativeContextMetadata {
  const AttriaxNativeContextMetadata();

  Map<String, Object?> loadRawDeviceData(AttriaxNativeContext nativeContext) =>
      _sanitizeDeviceData(Map<Object?, Object?>.from(nativeContext.metadata));

  String? nativeTimezone(AttriaxNativeContext nativeContext) {
    final value = nativeContext.metadata['timezone'];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  String? readString(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  String? readFirstString(Map<String, Object?> data, List<String> keys) {
    for (final key in keys) {
      final value = readString(data, key);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  int? readInt(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  String? readNestedString(Map<String, Object?> data, List<String> path) {
    Object? current = data;
    for (final segment in path) {
      if (current is! Map) {
        return null;
      }
      current = current[segment];
    }
    if (current is String && current.trim().isNotEmpty) {
      return current;
    }
    return null;
  }

  bool? readBool(Map<String, Object?> data, String key) {
    final value = data[key];
    return value is bool ? value : null;
  }

  List<String> readStringList(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is! List) {
      return const <String>[];
    }

    return value
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String? emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  Map<String, Object?> _sanitizeDeviceData(Map<Object?, Object?> input) => input
      .map((key, value) => MapEntry(key.toString(), _sanitizeValue(value)));

  Object? _sanitizeValue(Object? value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is List) {
      return value.map(_sanitizeValue).toList(growable: false);
    }
    if (value is Map) {
      return value.map(
        (key, nestedValue) =>
            MapEntry(key.toString(), _sanitizeValue(nestedValue)),
      );
    }
    return value.toString();
  }
}
