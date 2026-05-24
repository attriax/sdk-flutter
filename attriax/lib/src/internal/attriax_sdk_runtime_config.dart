import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

class AttriaxSdkRuntimeConfig {
  const AttriaxSdkRuntimeConfig({
    this.requestVersion = 'v1',
    this.acceptedAt,
    this.clipboardAttributionEnabled = false,
  });

  factory AttriaxSdkRuntimeConfig.fromJsonEnvelope(
    Map<String, Object?> envelope,
  ) {
    final data = _objectMap(envelope['data']) ?? envelope;
    return AttriaxSdkRuntimeConfig(
      requestVersion: _stringValue(data['requestVersion']) ?? 'v1',
      acceptedAt: _dateTimeValue(data['acceptedAt']),
      clipboardAttributionEnabled:
          _boolValue(data['clipboardAttributionEnabled']) ?? false,
    );
  }

  final String requestVersion;
  final DateTime? acceptedAt;
  final bool clipboardAttributionEnabled;
}

Map<String, Object?> attriaxBuildSdkRuntimeConfigRequest({
  required AttriaxConfig config,
  required AttriaxContextSnapshot context,
}) {
  final packageName =
      _trimOrNull(context.app.packageName) ??
      _trimOrNull(config.appPackageName);
  final signatureHashes = context.platform == AttriaxPlatformType.android
      ? _readStringList(context.device.metadata['signingSha256Fingerprints'])
      : const <String>[];

  return <String, Object?>{
    'appToken': config.appToken,
    'platform': context.platform.name,
    if (packageName != null) 'packageName': packageName,
    if (signatureHashes.isNotEmpty) 'signatureHashes': signatureHashes,
  };
}

Map<String, Object?>? _objectMap(Object? value) {
  if (value is Map<Object?, Object?>) {
    return value.map((key, entryValue) => MapEntry(key.toString(), entryValue));
  }

  return null;
}

bool? _boolValue(Object? value) => value is bool ? value : null;

DateTime? _dateTimeValue(Object? value) {
  final raw = _stringValue(value);
  if (raw == null) {
    return null;
  }

  return DateTime.tryParse(raw)?.toUtc();
}

List<String> _readStringList(Object? value) {
  if (value is! Iterable<Object?>) {
    return const <String>[];
  }

  final normalized = <String>[];
  for (final entry in value) {
    final raw = _stringValue(entry);
    if (raw != null) {
      normalized.add(raw);
    }
  }

  return normalized;
}

String? _stringValue(Object? value) =>
    value is String ? _trimOrNull(value) : null;

String? _trimOrNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}
