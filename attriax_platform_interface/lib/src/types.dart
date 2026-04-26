const String attriaxSdkApiVersion = 'v1';
const String attriaxSdkPackageVersion = '1.0.0';

enum AttributionType {
  referrer,
  fingerprint,
  external,
  organic,
  deferredDeepLink,
}

enum AttriaxPlatformType { ios, android, web, windows, macos, linux, unknown }

enum AttriaxDeepLinkResolutionStatus { matched, unmatched, invalid }

enum AttriaxSynchronizationState {
  initializing,
  synchronizing,
  synchronized,
  offline,
  failed,
  disabled,
}

class AttriaxNativeContext {
  const AttriaxNativeContext({
    this.installReferrer,
    this.androidId,
    this.advertisingId,
    this.metadata = const <String, Object?>{},
  });

  factory AttriaxNativeContext.fromJson(Map<String, Object?> json) {
    final metadata =
        _jsonObject(json['metadata']) ??
        <String, Object?>{
          for (final entry in json.entries)
            if (entry.key != 'installReferrer' &&
                entry.key != 'androidId' &&
                entry.key != 'advertisingId')
              entry.key: _normalizeJsonValue(entry.value),
        };

    return AttriaxNativeContext(
      installReferrer: _jsonString(json['installReferrer']),
      androidId: _jsonString(json['androidId']),
      advertisingId: _jsonString(json['advertisingId']),
      metadata: metadata,
    );
  }

  factory AttriaxNativeContext.fromPayload(Object? payload) =>
      AttriaxNativeContext.fromJson(_jsonObjectOrEmpty(payload));

  final String? installReferrer;
  final String? androidId;
  final String? advertisingId;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    if (installReferrer != null) 'installReferrer': installReferrer,
    if (androidId != null) 'androidId': androidId,
    if (advertisingId != null) 'advertisingId': advertisingId,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

class AttriaxInstallReferrerContext {
  const AttriaxInstallReferrerContext({
    this.installReferrer,
    this.metadata = const <String, Object?>{},
  });

  factory AttriaxInstallReferrerContext.fromJson(Map<String, Object?> json) {
    final metadata =
        _jsonObject(json['metadata']) ??
        <String, Object?>{
          for (final entry in json.entries)
            if (entry.key != 'installReferrer')
              entry.key: _normalizeJsonValue(entry.value),
        };

    return AttriaxInstallReferrerContext(
      installReferrer: _jsonString(json['installReferrer']),
      metadata: metadata,
    );
  }

  factory AttriaxInstallReferrerContext.fromPayload(Object? payload) =>
      AttriaxInstallReferrerContext.fromJson(_jsonObjectOrEmpty(payload));

  final String? installReferrer;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    if (installReferrer != null) 'installReferrer': installReferrer,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

class AttriaxSdkSnapshot {
  const AttriaxSdkSnapshot({
    required this.apiVersion,
    required this.packageVersion,
    this.metadata = const <String, Object?>{},
  });

  final String apiVersion;
  final String packageVersion;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    'apiVersion': apiVersion,
    'packageVersion': packageVersion,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

class AttriaxAppSnapshot {
  const AttriaxAppSnapshot({this.version, this.buildNumber, this.packageName});

  final String? version;
  final String? buildNumber;
  final String? packageName;

  Map<String, Object?> toJson() => <String, Object?>{
    if (version != null) 'version': version,
    if (buildNumber != null) 'buildNumber': buildNumber,
    if (packageName != null) 'packageName': packageName,
  };
}

class AttriaxDeviceSnapshot {
  const AttriaxDeviceSnapshot({
    this.model,
    this.name,
    this.brand,
    this.manufacturer,
    this.hardware,
    this.osVersion,
    this.language,
    this.timezone,
    this.screenResolution,
    this.advertisingId,
    this.androidId,
    this.isPhysicalDevice,
    this.supportedAbis = const <String>[],
    this.metadata = const <String, Object?>{},
  });

  final String? model;
  final String? name;
  final String? brand;
  final String? manufacturer;
  final String? hardware;
  final String? osVersion;
  final String? language;
  final String? timezone;
  final String? screenResolution;
  final String? advertisingId;
  final String? androidId;
  final bool? isPhysicalDevice;
  final List<String> supportedAbis;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    if (model != null) 'model': model,
    if (name != null) 'name': name,
    if (brand != null) 'brand': brand,
    if (manufacturer != null) 'manufacturer': manufacturer,
    if (hardware != null) 'hardware': hardware,
    if (osVersion != null) 'osVersion': osVersion,
    if (language != null) 'language': language,
    if (timezone != null) 'timezone': timezone,
    if (screenResolution != null) 'screenResolution': screenResolution,
    if (advertisingId != null) 'advertisingId': advertisingId,
    if (androidId != null) 'androidId': androidId,
    if (isPhysicalDevice != null) 'isPhysicalDevice': isPhysicalDevice,
    if (supportedAbis.isNotEmpty) 'supportedAbis': supportedAbis,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

class AttriaxContextSnapshot {
  const AttriaxContextSnapshot({
    required this.platform,
    required this.deviceId,
    required this.isFirstLaunch,
    required this.sdk,
    required this.app,
    required this.device,
    this.installReferrer,
  });

  final AttriaxPlatformType platform;
  final String deviceId;
  final bool isFirstLaunch;
  final String? installReferrer;
  final AttriaxSdkSnapshot sdk;
  final AttriaxAppSnapshot app;
  final AttriaxDeviceSnapshot device;
}

class AttriaxDeepLink {
  const AttriaxDeepLink({
    required this.path,
    this.linkId,
    this.name,
    this.destinationUrl,
    this.data,
  });

  factory AttriaxDeepLink.fromJson(Map<String, Object?> json) =>
      AttriaxDeepLink(
        path: _requireJsonString(json, 'path'),
        linkId: _jsonString(json['linkId']),
        name: _jsonString(json['name']),
        destinationUrl: _jsonString(json['destinationUrl']),
        data: _jsonObject(json['data']),
      );

  final String path;
  final String? linkId;
  final String? name;
  final String? destinationUrl;
  final Map<String, Object?>? data;
}

class AttriaxDynamicLinkRecord {
  const AttriaxDynamicLinkRecord({
    required this.id,
    required this.path,
    required this.shortUrl,
    this.name,
    this.destinationUrl,
    this.group,
    this.prefix,
    this.data,
    this.previewTitle,
    this.previewDescription,
    this.previewImagePath,
    this.iosRedirect,
    this.androidRedirect,
    this.createdAt,
  });

  factory AttriaxDynamicLinkRecord.fromJson(Map<String, Object?> json) =>
      AttriaxDynamicLinkRecord(
        id: _requireJsonString(json, 'id'),
        path: _requireJsonString(json, 'path'),
        shortUrl: _requireJsonString(json, 'shortUrl'),
        name: _jsonString(json['name']),
        destinationUrl: _jsonString(json['destinationUrl']),
        group: _jsonString(json['group']),
        prefix: _jsonString(json['prefix']),
        data: _jsonObject(json['data']),
        previewTitle: _jsonString(json['previewTitle']),
        previewDescription: _jsonString(json['previewDescription']),
        previewImagePath: _jsonString(json['previewImagePath']),
        iosRedirect: _jsonBool(json['iosRedirect']),
        androidRedirect: _jsonBool(json['androidRedirect']),
        createdAt: _jsonDateTime(json['createdAt']),
      );

  final String id;
  final String path;
  final String shortUrl;
  final String? name;
  final String? destinationUrl;
  final String? group;
  final String? prefix;
  final Map<String, Object?>? data;
  final String? previewTitle;
  final String? previewDescription;
  final String? previewImagePath;
  final bool? iosRedirect;
  final bool? androidRedirect;
  final DateTime? createdAt;
}

class AttriaxCreateDynamicLinkResult {
  const AttriaxCreateDynamicLinkResult({
    required this.link,
    this.requestVersion,
    this.acceptedAt,
  });

  factory AttriaxCreateDynamicLinkResult.fromJson(Map<String, Object?> json) {
    final linkJson = _jsonObject(json['link']);
    if (linkJson == null) {
      throw const FormatException('Missing or invalid "link".');
    }

    return AttriaxCreateDynamicLinkResult(
      link: AttriaxDynamicLinkRecord.fromJson(linkJson),
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
    );
  }

  final AttriaxDynamicLinkRecord link;
  final String? requestVersion;
  final DateTime? acceptedAt;
}

class AttriaxRawDeepLinkEvent {
  const AttriaxRawDeepLinkEvent({
    required this.uri,
    required this.isFirstLaunch,
    required this.isInitialLink,
    required this.occurredAt,
    this.linkPath,
  });

  final Uri uri;
  final String? linkPath;
  final bool isFirstLaunch;
  final bool isInitialLink;
  final DateTime occurredAt;
}

class AttriaxDeepLinkConversionEvent {
  const AttriaxDeepLinkConversionEvent({
    required this.deepLink,
    required this.isFirstLaunch,
    required this.isDeferred,
    required this.occurredAt,
    this.rawEvent,
    this.requestVersion,
  });

  final AttriaxDeepLink deepLink;
  final AttriaxRawDeepLinkEvent? rawEvent;
  final bool isFirstLaunch;
  final bool isDeferred;
  final String? requestVersion;
  final DateTime occurredAt;
}

class AttriaxDeepLinkConversionFailure {
  const AttriaxDeepLinkConversionFailure({
    required this.reason,
    required this.isFirstLaunch,
    required this.occurredAt,
    this.rawEvent,
  });

  final String reason;
  final AttriaxRawDeepLinkEvent? rawEvent;
  final bool isFirstLaunch;
  final DateTime occurredAt;
}

class AttriaxDeepLinkEvent {
  const AttriaxDeepLinkEvent({required this.resultFuture, this.rawEvent});

  final AttriaxRawDeepLinkEvent? rawEvent;
  final Future<AttriaxDeepLinkResult> resultFuture;

  bool get hasRawEvent => rawEvent != null;

  Future<AttriaxDeepLinkResult> waitForConversionResult() => resultFuture;
}

class AttriaxDeepLinkResult {
  const AttriaxDeepLinkResult({this.rawEvent, this.conversion, this.failure})
    : assert(
        conversion != null || failure != null,
        'Either conversion or failure must be provided.',
      );

  final AttriaxRawDeepLinkEvent? rawEvent;
  final AttriaxDeepLinkConversionEvent? conversion;
  final AttriaxDeepLinkConversionFailure? failure;

  bool get isMatched => conversion != null;
  bool get isFailure => failure != null;
  bool get isDeferred => conversion?.isDeferred ?? false;
}

class AttriaxDeepLinkResolutionResult {
  const AttriaxDeepLinkResolutionResult({
    required this.matched,
    required this.status,
    required this.isFirstLaunch,
    this.reason,
    this.deepLink,
    this.requestVersion,
    this.acceptedAt,
  });

  factory AttriaxDeepLinkResolutionResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);

    return AttriaxDeepLinkResolutionResult(
      matched: _jsonBool(json['matched']) ?? false,
      status: _parseResolutionStatus(_jsonString(json['status'])),
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      reason: _jsonString(json['reason']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
    );
  }

  final bool matched;
  final AttriaxDeepLinkResolutionStatus status;
  final bool isFirstLaunch;
  final String? reason;
  final AttriaxDeepLink? deepLink;
  final String? requestVersion;
  final DateTime? acceptedAt;
}

class AttriaxAppOpenResult {
  const AttriaxAppOpenResult({
    required this.userId,
    required this.isNewUser,
    required this.isFirstLaunch,
    required this.attributionType,
    this.attributedLinkId,
    this.requestVersion,
    this.acceptedAt,
    this.deepLink,
  });

  factory AttriaxAppOpenResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);

    return AttriaxAppOpenResult(
      userId: _requireJsonString(json, 'userId'),
      isNewUser: _jsonBool(json['isNewUser']) ?? false,
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      attributionType: _parseAttributionType(
        _jsonString(json['attributionType']),
      ),
      attributedLinkId: _jsonString(json['attributedLinkId']),
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
    );
  }

  final String userId;
  final bool isNewUser;
  final bool isFirstLaunch;
  final AttributionType attributionType;
  final String? attributedLinkId;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final AttriaxDeepLink? deepLink;
}

typedef AttriaxInitResult = AttriaxAppOpenResult;

class AttriaxConfig {
  const AttriaxConfig({
    required this.appToken,
    this.apiBaseUrl = 'https://api.attriax.com',
    this.appVersion,
    this.appBuildNumber,
    this.appPackageName,
    this.sdkMetadata = const <String, Object?>{},
    this.enableDebugLogs,
    this.requestTimeout = const Duration(seconds: 12),
    this.maxQueueSize = 200,
  });

  final String appToken;
  final String apiBaseUrl;
  final String? appVersion;
  final String? appBuildNumber;
  final String? appPackageName;
  final Map<String, Object?> sdkMetadata;
  final bool? enableDebugLogs;
  final Duration requestTimeout;
  final int maxQueueSize;
}

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

DateTime? _jsonDateTime(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

AttributionType _parseAttributionType(String? value) {
  switch (value) {
    case 'referrer':
      return AttributionType.referrer;
    case 'fingerprint':
      return AttributionType.fingerprint;
    case 'external':
      return AttributionType.external;
    case 'deferred_deep_link':
      return AttributionType.deferredDeepLink;
    case 'organic':
    default:
      return AttributionType.organic;
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
