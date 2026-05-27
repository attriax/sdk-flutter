part 'types_skan.dart';
part 'types_platform_runtime.dart';
part 'types_links.dart';
part 'types_deep_link_lifecycle.dart';
part 'types_session_config.dart';

const String attriaxSdkApiVersion = 'v1';
const String attriaxSdkPackageVersion = '0.4.0';

/// Attribution classification returned by Attriax.
enum AttributionType {
  /// Attribution derived from platform install-referrer data.
  referrer,

  /// Attribution derived from probabilistic fingerprint matching.
  fingerprint,

  /// Attribution derived from external provider resolutions.
  external,

  /// Attribution assigned when no attributable source was found.
  organic,
}

enum AttriaxPlatformType { ios, android, web, windows, macos, linux, unknown }

enum AttriaxDeepLinkResolutionStatus { matched, unmatched, invalid }

enum AttriaxResolvedUrlOpenMode { inApp, external, unknown }

/// Describes what caused a deep-link event to be emitted.
enum AttriaxDeepLinkTrigger {
  /// The app launched from a fully stopped state because of this link.
  coldStart,

  /// The link arrived while the app was already running.
  foreground,

  /// The link click happened before install and resolved on first launch.
  deferred,
}

enum AttriaxInstallState { existing, newInstall, reinstall, appDataClear }

enum AttriaxSynchronizationState {
  initializing,
  synchronizing,
  deferred,
  synchronized,
  offline,
  failed,
  disabled,
}

enum AttriaxTrackingAuthorizationStatus {
  notSupported,
  disabled,
  notDetermined,
  restricted,
  denied,
  authorized,
  timedOut,
  unknown,
}

enum AttriaxRevenueReceiptValidationStatus {
  verified,
  rejected,
  pending,
  unconfigured,
  providerError,
  passthrough,
}

enum AttriaxSkanCoarseValue { low, medium, high }

enum AttriaxSkanRuleOperator { exists, eq, notEq, gt, gte, lt, lte, contains }

enum AttriaxSkanUpdateStatus {
  updated,
  skipped,
  alreadyAtOrAboveValue,
  invalidValue,
  disabled,
  notSupported,
  error,
}

// ignore: one_member_abstracts
abstract interface class AttriaxClock {
  DateTime now();
}

final class AttriaxSystemClock implements AttriaxClock {
  const AttriaxSystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

final class AttriaxMutableClock implements AttriaxClock {
  AttriaxMutableClock(this.currentTime);

  DateTime currentTime;

  @override
  DateTime now() => currentTime;
}

/// Snapshot of the current SDK session tracked locally by Attriax.

String _skanUpdateStatusToJson(AttriaxSkanUpdateStatus value) =>
    switch (value) {
      AttriaxSkanUpdateStatus.updated => 'updated',
      AttriaxSkanUpdateStatus.skipped => 'skipped',
      AttriaxSkanUpdateStatus.alreadyAtOrAboveValue =>
        'already_at_or_above_value',
      AttriaxSkanUpdateStatus.invalidValue => 'invalid_value',
      AttriaxSkanUpdateStatus.disabled => 'disabled',
      AttriaxSkanUpdateStatus.notSupported => 'not_supported',
      AttriaxSkanUpdateStatus.error => 'error',
    };

String _skanRuleOperatorToJson(AttriaxSkanRuleOperator value) =>
    switch (value) {
      AttriaxSkanRuleOperator.exists => 'exists',
      AttriaxSkanRuleOperator.eq => 'eq',
      AttriaxSkanRuleOperator.notEq => 'not_eq',
      AttriaxSkanRuleOperator.gt => 'gt',
      AttriaxSkanRuleOperator.gte => 'gte',
      AttriaxSkanRuleOperator.lt => 'lt',
      AttriaxSkanRuleOperator.lte => 'lte',
      AttriaxSkanRuleOperator.contains => 'contains',
    };

AttriaxSkanRuleOperator? _attriaxSkanRuleOperatorFromJson(String? value) =>
    switch (value) {
      'exists' => AttriaxSkanRuleOperator.exists,
      'eq' => AttriaxSkanRuleOperator.eq,
      'not_eq' => AttriaxSkanRuleOperator.notEq,
      'gt' => AttriaxSkanRuleOperator.gt,
      'gte' => AttriaxSkanRuleOperator.gte,
      'lt' => AttriaxSkanRuleOperator.lt,
      'lte' => AttriaxSkanRuleOperator.lte,
      'contains' => AttriaxSkanRuleOperator.contains,
      _ => null,
    };

AttriaxSkanCoarseValue? _attriaxSkanCoarseValueFromJson(String? value) =>
    switch (value) {
      'low' => AttriaxSkanCoarseValue.low,
      'medium' => AttriaxSkanCoarseValue.medium,
      'high' => AttriaxSkanCoarseValue.high,
      _ => null,
    };

AttriaxSkanUpdateStatus? _attriaxSkanUpdateStatusFromJson(String? value) =>
    switch (value) {
      'updated' => AttriaxSkanUpdateStatus.updated,
      'skipped' => AttriaxSkanUpdateStatus.skipped,
      'already_at_or_above_value' =>
        AttriaxSkanUpdateStatus.alreadyAtOrAboveValue,
      'invalid_value' => AttriaxSkanUpdateStatus.invalidValue,
      'disabled' => AttriaxSkanUpdateStatus.disabled,
      'not_supported' => AttriaxSkanUpdateStatus.notSupported,
      'error' => AttriaxSkanUpdateStatus.error,
      _ => null,
    };

Map<String, Object?> _jsonObjectOrEmpty(Object? value) =>
    _jsonObject(value) ?? const <String, Object?>{};

Map<String, Object?>? _jsonObject(Object? value) {
  if (value is! Map) {
    return null;
  }

  return value.map(
    (key, nestedValue) =>
        MapEntry(key.toString(), _normalizeJsonValue(nestedValue)),
  );
}

Map<String, Object?> _normalizeJsonMap(Map<String, Object?> input) =>
    input.map((key, value) => MapEntry(key, _normalizeJsonValue(value)));

Object? _normalizeJsonValue(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is List) {
    return value.map(_normalizeJsonValue).toList(growable: false);
  }
  if (value is Map) {
    return value.map(
      (key, nestedValue) =>
          MapEntry(key.toString(), _normalizeJsonValue(nestedValue)),
    );
  }
  return value.toString();
}

String? _jsonString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  return null;
}

String _requireJsonString(Map<String, Object?> json, String key) {
  final value = _jsonString(json[key]);
  if (value == null) {
    throw FormatException('Missing or invalid "$key".');
  }
  return value;
}

bool? _jsonBool(Object? value) => value is bool ? value : null;

int? _jsonInt(Object? value) => value is num ? value.toInt() : null;

double? _jsonDouble(Object? value) => value is num ? value.toDouble() : null;

DateTime? _jsonDateTime(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

Uri? _jsonUri(Object? value) {
  final stringValue = _jsonString(value);
  if (stringValue == null) {
    return null;
  }

  return Uri.tryParse(stringValue);
}

Map<String, String>? _jsonStringMap(Object? value) {
  final json = _jsonObject(value);
  if (json == null || json.isEmpty) {
    return null;
  }

  return <String, String>{
    for (final entry in json.entries)
      entry.key: entry.value == null ? '' : entry.value.toString(),
  };
}

DateTime _requireJsonDateTime(Map<String, Object?> json, String key) {
  final value = _jsonDateTime(json[key]);
  if (value == null) {
    throw FormatException('Missing or invalid "$key".');
  }
  return value;
}

int _requireJsonInt(Map<String, Object?> json, String key) {
  final value = _jsonInt(json[key]);
  if (value == null) {
    throw FormatException('Missing or invalid "$key".');
  }
  return value;
}

AttributionType _parseAttributionType(String? value) {
  switch (value) {
    case 'referrer':
      return AttributionType.referrer;
    case 'fingerprint':
      return AttributionType.fingerprint;
    case 'external':
      return AttributionType.external;
    case 'organic':
    default:
      return AttributionType.organic;
  }
}

AttriaxInstallState _parseInstallState(String? value) {
  switch (value) {
    case 'new_install':
      return AttriaxInstallState.newInstall;
    case 'reinstall':
      return AttriaxInstallState.reinstall;
    case 'app_data_clear':
      return AttriaxInstallState.appDataClear;
    case 'existing':
    default:
      return AttriaxInstallState.existing;
  }
}

AttriaxDeepLinkResolutionStatus _parseResolutionStatus(String? value) {
  switch (value) {
    case 'matched':
      return AttriaxDeepLinkResolutionStatus.matched;
    case 'unmatched':
      return AttriaxDeepLinkResolutionStatus.unmatched;
    case 'invalid':
    default:
      return AttriaxDeepLinkResolutionStatus.invalid;
  }
}

AttriaxDeepLinkTrigger _parseDeepLinkTrigger(String? value) {
  switch (value) {
    case 'coldStart':
      return AttriaxDeepLinkTrigger.coldStart;
    case 'deferred':
      return AttriaxDeepLinkTrigger.deferred;
    case 'foreground':
    default:
      return AttriaxDeepLinkTrigger.foreground;
  }
}

AttriaxResolvedUrlOpenMode _parseResolvedUrlOpenMode(String? value) {
  switch (value) {
    case 'in_app':
    case 'inApp':
      return AttriaxResolvedUrlOpenMode.inApp;
    case 'external':
      return AttriaxResolvedUrlOpenMode.external;
    case 'unknown':
    default:
      return AttriaxResolvedUrlOpenMode.unknown;
  }
}

AttriaxRevenueReceiptValidationStatus _parseRevenueReceiptValidationStatus(
  String? value,
) {
  switch (value) {
    case 'verified':
      return AttriaxRevenueReceiptValidationStatus.verified;
    case 'pending':
      return AttriaxRevenueReceiptValidationStatus.pending;
    case 'unconfigured':
      return AttriaxRevenueReceiptValidationStatus.unconfigured;
    case 'provider_error':
      return AttriaxRevenueReceiptValidationStatus.providerError;
    case 'passthrough':
      return AttriaxRevenueReceiptValidationStatus.passthrough;
    case 'rejected':
    default:
      return AttriaxRevenueReceiptValidationStatus.rejected;
  }
}

AttriaxPlatformType _parsePlatformType(String? value) {
  switch (value) {
    case 'ios':
      return AttriaxPlatformType.ios;
    case 'android':
      return AttriaxPlatformType.android;
    case 'web':
      return AttriaxPlatformType.web;
    case 'windows':
      return AttriaxPlatformType.windows;
    case 'macos':
      return AttriaxPlatformType.macos;
    case 'linux':
      return AttriaxPlatformType.linux;
    case 'unknown':
    default:
      return AttriaxPlatformType.unknown;
  }
}
