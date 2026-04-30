const String attriaxSdkApiVersion = 'v1';
const String attriaxSdkPackageVersion = '1.0.0';

enum AttributionType { referrer, fingerprint, external, organic }

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
    String? rawPlatformInstallReferrer,
    @Deprecated('Use rawPlatformInstallReferrer instead.')
    String? installReferrer,
  }) : rawPlatformInstallReferrer =
           rawPlatformInstallReferrer ?? installReferrer;

  final AttriaxPlatformType platform;
  final String deviceId;
  final bool isFirstLaunch;

  /// Cached raw platform install referrer value.
  ///
  /// This is supported only on Android and reflects the latest raw platform
  /// referrer value the SDK has cached locally. The SDK updates it when a new
  /// platform referrer value is retrieved.
  final String? rawPlatformInstallReferrer;

  @Deprecated('Use rawPlatformInstallReferrer instead.')
  String? get installReferrer => rawPlatformInstallReferrer;

  final AttriaxSdkSnapshot sdk;
  final AttriaxAppSnapshot app;
  final AttriaxDeviceSnapshot device;
}

class AttriaxDeepLink {
  const AttriaxDeepLink({required this.path, this.data});

  factory AttriaxDeepLink.fromJson(Map<String, Object?> json) =>
      AttriaxDeepLink(
        path: _requireJsonString(json, 'path'),
        data: _jsonObject(json['data']),
      );

  final String path;
  final Map<String, Object?>? data;

  Map<String, Object?> toJson() => <String, Object?>{
    'path': path,
    if (data != null && data!.isNotEmpty) 'data': _normalizeJsonMap(data!),
  };
}

class AttriaxInstallReferrerDetails {
  const AttriaxInstallReferrerDetails({
    required this.attributionType,
    required this.precision,
    this.rawPlatformInstallReferrer,
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
    this.adNetwork,
    this.adClickId,
    this.deepLinkData,
  });

  factory AttriaxInstallReferrerDetails.fromJson(Map<String, Object?> json) {
    final deepLinkDataJson = _jsonObject(json['deepLinkData']);

    return AttriaxInstallReferrerDetails(
      rawPlatformInstallReferrer: _jsonString(
        json['rawPlatformInstallReferrer'],
      ),
      source: _jsonString(json['source']),
      medium: _jsonString(json['medium']),
      campaign: _jsonString(json['campaign']),
      term: _jsonString(json['term']),
      content: _jsonString(json['content']),
      adNetwork: _jsonString(json['adNetwork']),
      adClickId: _jsonString(json['adClickId']),
      attributionType: _parseAttributionType(
        _jsonString(json['attributionType']),
      ),
      deepLinkData: deepLinkDataJson,
      precision: _jsonDouble(json['precision']) ?? 0,
    );
  }

  final String? rawPlatformInstallReferrer;
  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;
  final String? adNetwork;
  final String? adClickId;
  final AttributionType attributionType;
  final Map<String, Object?>? deepLinkData;

  /// Confidence score from `0.0` to `1.0` for the resolved install referrer.
  ///
  /// Higher values mean Attriax has stronger evidence for the returned
  /// install-referrer interpretation.
  final double precision;

  Map<String, Object?> toJson() => <String, Object?>{
    if (rawPlatformInstallReferrer != null)
      'rawPlatformInstallReferrer': rawPlatformInstallReferrer,
    if (source != null) 'source': source,
    if (medium != null) 'medium': medium,
    if (campaign != null) 'campaign': campaign,
    if (term != null) 'term': term,
    if (content != null) 'content': content,
    if (adNetwork != null) 'adNetwork': adNetwork,
    if (adClickId != null) 'adClickId': adClickId,
    'attributionType': attributionType.name,
    if (deepLinkData != null && deepLinkData!.isNotEmpty)
      'deepLinkData': _normalizeJsonMap(deepLinkData!),
    'precision': precision,
  };
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
    this.acceptedAt,
    this.consumedAt,
  });

  final AttriaxDeepLink deepLink;
  final AttriaxRawDeepLinkEvent? rawEvent;
  final bool isFirstLaunch;
  final bool isDeferred;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final DateTime? consumedAt;
  final DateTime occurredAt;
}

class AttriaxDeepLinkConversionFailure {
  const AttriaxDeepLinkConversionFailure({
    required this.reason,
    required this.isFirstLaunch,
    required this.occurredAt,
    this.rawEvent,
    this.status,
    this.requestVersion,
    this.acceptedAt,
  });

  final String reason;
  final AttriaxRawDeepLinkEvent? rawEvent;
  final bool isFirstLaunch;
  final AttriaxDeepLinkResolutionStatus? status;
  final String? requestVersion;
  final DateTime? acceptedAt;
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
    this.consumedAt,
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
      consumedAt: _jsonDateTime(json['consumedAt']),
    );
  }

  final bool matched;
  final AttriaxDeepLinkResolutionStatus status;
  final bool isFirstLaunch;
  final String? reason;
  final AttriaxDeepLink? deepLink;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final DateTime? consumedAt;
}

class AttriaxAppOpenResult {
  const AttriaxAppOpenResult({
    required this.userId,
    required this.isNewUser,
    required this.isFirstLaunch,
    this.requestVersion,
    this.acceptedAt,
    this.deepLink,
    this.installReferrer,
  });

  factory AttriaxAppOpenResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);
    final installReferrerJson = _jsonObject(json['installReferrer']);

    return AttriaxAppOpenResult(
      userId: _requireJsonString(json, 'userId'),
      isNewUser: _jsonBool(json['isNewUser']) ?? false,
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
      installReferrer: installReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(installReferrerJson)
          : null,
    );
  }

  final String userId;
  final bool isNewUser;
  final bool isFirstLaunch;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final AttriaxDeepLink? deepLink;
  final AttriaxInstallReferrerDetails? installReferrer;
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

double? _jsonDouble(Object? value) => value is num ? value.toDouble() : null;

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
