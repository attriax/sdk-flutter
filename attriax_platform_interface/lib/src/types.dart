const String attriaxSdkApiVersion = 'v1';
const String attriaxSdkPackageVersion = '1.0.0';

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

/// SDK version and metadata snapshot captured during initialization.
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
    this.screenWidth,
    this.screenHeight,
    this.devicePixelRatio,
    this.colorDepth,
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
  final int? screenWidth;
  final int? screenHeight;
  final double? devicePixelRatio;
  final int? colorDepth;
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
    if (screenWidth != null) 'screenWidth': screenWidth,
    if (screenHeight != null) 'screenHeight': screenHeight,
    if (devicePixelRatio != null) 'devicePixelRatio': devicePixelRatio,
    if (colorDepth != null) 'colorDepth': colorDepth,
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
  });

  final AttriaxPlatformType platform;
  final String deviceId;
  final bool isFirstLaunch;

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

/// Structured install-referrer details resolved by Attriax.
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
    this.deepLinkUrl,
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
      deepLinkUrl: _jsonString(json['deepLinkUrl']),
      deepLinkData: deepLinkDataJson,
      precision: _jsonDouble(json['precision']) ?? 0,
    );
  }

  /// Raw platform install-referrer string cached by the SDK.
  final String? rawPlatformInstallReferrer;

  /// Resolved UTM source extracted from the install referrer.
  final String? source;

  /// Resolved UTM medium extracted from the install referrer.
  final String? medium;

  /// Resolved UTM campaign extracted from the install referrer.
  final String? campaign;

  /// Resolved UTM term extracted from the install referrer.
  final String? term;

  /// Resolved UTM content extracted from the install referrer.
  final String? content;

  /// Detected ad-network identifier inferred from the referrer.
  final String? adNetwork;

  /// Detected ad click identifier such as `gclid` or `fbclid`.
  final String? adClickId;

  /// Attribution classification for the install-referrer payload.
  ///
  /// Current platform install-referrer parsing reports
  /// [AttributionType.referrer]. [AttributionType.external] is reserved for
  /// future provider-based payloads.
  final AttributionType attributionType;

  /// Full tracked short-link URL associated with the resolved deep link.
  final String? deepLinkUrl;

  /// Resolved deep-link payload data associated with the install referrer.
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
    if (deepLinkUrl != null) 'deepLinkUrl': deepLinkUrl,
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
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
    this.utmTerm,
    this.utmContent,
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
        utmSource: _jsonString(json['utmSource']),
        utmMedium: _jsonString(json['utmMedium']),
        utmCampaign: _jsonString(json['utmCampaign']),
        utmTerm: _jsonString(json['utmTerm']),
        utmContent: _jsonString(json['utmContent']),
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
  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;
  final String? utmTerm;
  final String? utmContent;
  final DateTime? createdAt;
}

class AttriaxDynamicLinkSocialPreview {
  const AttriaxDynamicLinkSocialPreview({
    this.title,
    this.description,
    this.imagePath,
  });

  final String? title;
  final String? description;
  final String? imagePath;
}

class AttriaxDynamicLinkRedirects {
  const AttriaxDynamicLinkRedirects({this.ios, this.android});

  final bool? ios;
  final bool? android;
}

class AttriaxDynamicLinkUtms {
  const AttriaxDynamicLinkUtms({
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
  });

  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;
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

/// Raw deep-link activation captured by the SDK before backend resolution.
class AttriaxRawDeepLinkEvent {
  const AttriaxRawDeepLinkEvent({
    required this.uri,
    required this.isFirstLaunch,
    required this.isInitialLink,
    required this.occurredAt,
    this.linkPath,
  });

  /// Full incoming URI observed by the SDK.
  final Uri uri;

  /// Normalized Attriax link path extracted from [uri], when available.
  final String? linkPath;

  /// Whether this deep link belongs to the installation's first launch.
  final bool isFirstLaunch;

  /// Whether this deep link was captured during [Attriax.init].
  final bool isInitialLink;

  /// Local timestamp when the SDK captured the incoming deep link.
  final DateTime occurredAt;
}

/// Successful deep-link resolution emitted by the SDK.
class AttriaxDeepLinkResolution {
  const AttriaxDeepLinkResolution({
    required this.deepLink,
    required this.isFirstLaunch,
    required this.isDeferred,
    required this.occurredAt,
    this.rawEvent,
    this.consumedAt,
  });

  /// Deep-link payload matched by Attriax.
  final AttriaxDeepLink deepLink;

  /// Original raw event that led to this resolution, when available.
  final AttriaxRawDeepLinkEvent? rawEvent;

  /// Whether this resolution belongs to the installation's first launch.
  final bool isFirstLaunch;

  /// Whether the resolution came from deferred app-open processing.
  final bool isDeferred;

  /// Timestamp when the deep link was marked as consumed by the backend.
  final DateTime? consumedAt;

  /// Timestamp when this resolution became visible to the SDK caller.
  final DateTime occurredAt;
}

/// Failed deep-link resolution emitted by the SDK.
class AttriaxDeepLinkResolutionFailure {
  const AttriaxDeepLinkResolutionFailure({
    required this.reason,
    required this.isFirstLaunch,
    required this.occurredAt,
    this.rawEvent,
    this.status,
    this.requestVersion,
    this.acceptedAt,
  });

  /// Machine-readable failure reason returned by Attriax or generated locally.
  final String reason;

  /// Original raw event that led to this failure, when available.
  final AttriaxRawDeepLinkEvent? rawEvent;

  /// Whether this failure belongs to the installation's first launch.
  final bool isFirstLaunch;

  /// Optional backend resolution status for the failed request.
  final AttriaxDeepLinkResolutionStatus? status;

  /// Backend API version that handled the failed resolution, when returned.
  final String? requestVersion;

  /// Backend acceptance timestamp for the failed resolution, when returned.
  final DateTime? acceptedAt;

  /// Timestamp when this failure became visible to the SDK caller.
  final DateTime occurredAt;
}

/// Deferred or in-flight deep-link event emitted to subscribers.
class AttriaxDeepLinkEvent {
  const AttriaxDeepLinkEvent({required this.resultFuture, this.rawEvent});

  final AttriaxRawDeepLinkEvent? rawEvent;
  final Future<AttriaxDeepLinkResult> resultFuture;

  bool get hasRawEvent => rawEvent != null;

  /// Waits for the backend resolution corresponding to this deep link.
  Future<AttriaxDeepLinkResult> resolve() => resultFuture;
}

/// Final deep-link result produced for one incoming or recorded link.
class AttriaxDeepLinkResult {
  const AttriaxDeepLinkResult({this.rawEvent, this.resolution, this.failure})
    : assert(
        resolution != null || failure != null,
        'Either resolution or failure must be provided.',
      );

  final AttriaxRawDeepLinkEvent? rawEvent;
  final AttriaxDeepLinkResolution? resolution;
  final AttriaxDeepLinkResolutionFailure? failure;

  bool get isMatched => resolution != null;
  bool get isFailure => failure != null;
  bool get isDeferred => resolution?.isDeferred ?? false;
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

/// Internal runtime result for the initial app-open tracking request.
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

/// Public app-open summary exposed after app-open tracking completes.
class AttriaxAppOpen {
  const AttriaxAppOpen({
    required this.isNewUser,
    required this.isFirstLaunch,
    this.deepLink,
  });

  /// Whether Attriax created a new backend user for this app open.
  final bool isNewUser;

  /// Whether this app open belongs to the installation's first launch.
  final bool isFirstLaunch;

  /// Deferred deep link matched during the app-open flow, when available.
  final AttriaxDeepLink? deepLink;
}

typedef AttriaxInitResult = AttriaxAppOpen;

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
class AttriaxSessionSnapshot {
  const AttriaxSessionSnapshot({
    required this.id,
    required this.deviceId,
    required this.platform,
    required this.isFirstLaunch,
    required this.startedAt,
    required this.lastActivityAt,
    required this.heartbeatInterval,
    this.locale,
    this.appVersion,
    this.appBuildNumber,
    this.appPackageName,
    this.sdkPackageVersion,
  });

  factory AttriaxSessionSnapshot.fromJson(Map<String, Object?> json) {
    final heartbeatIntervalMs = _requireJsonInt(json, 'heartbeatIntervalMs');

    return AttriaxSessionSnapshot(
      id: _requireJsonString(json, 'id'),
      deviceId: _requireJsonString(json, 'deviceId'),
      platform: _parsePlatformType(_jsonString(json['platform'])),
      locale: _jsonString(json['locale']),
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      startedAt: _requireJsonDateTime(json, 'startedAt').toUtc(),
      lastActivityAt: _requireJsonDateTime(json, 'lastActivityAt').toUtc(),
      heartbeatInterval: Duration(milliseconds: heartbeatIntervalMs),
      appVersion: _jsonString(json['appVersion']),
      appBuildNumber: _jsonString(json['appBuildNumber']),
      appPackageName: _jsonString(json['appPackageName']),
      sdkPackageVersion: _jsonString(json['sdkPackageVersion']),
    );
  }

  final String id;
  final String deviceId;
  final AttriaxPlatformType platform;
  final String? locale;
  final bool isFirstLaunch;
  final DateTime startedAt;
  final DateTime lastActivityAt;
  final Duration heartbeatInterval;
  final String? appVersion;
  final String? appBuildNumber;
  final String? appPackageName;
  final String? sdkPackageVersion;

  AttriaxSessionSnapshot copyWith({
    String? id,
    String? deviceId,
    AttriaxPlatformType? platform,
    String? locale,
    bool? isFirstLaunch,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    Duration? heartbeatInterval,
    String? appVersion,
    String? appBuildNumber,
    String? appPackageName,
    String? sdkPackageVersion,
  }) => AttriaxSessionSnapshot(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    platform: platform ?? this.platform,
    locale: locale ?? this.locale,
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    startedAt: startedAt ?? this.startedAt,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    heartbeatInterval: heartbeatInterval ?? this.heartbeatInterval,
    appVersion: appVersion ?? this.appVersion,
    appBuildNumber: appBuildNumber ?? this.appBuildNumber,
    appPackageName: appPackageName ?? this.appPackageName,
    sdkPackageVersion: sdkPackageVersion ?? this.sdkPackageVersion,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'deviceId': deviceId,
    'platform': platform.name,
    if (locale != null) 'locale': locale,
    'isFirstLaunch': isFirstLaunch,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'lastActivityAt': lastActivityAt.toUtc().toIso8601String(),
    'heartbeatIntervalMs': heartbeatInterval.inMilliseconds,
    if (appVersion != null) 'appVersion': appVersion,
    if (appBuildNumber != null) 'appBuildNumber': appBuildNumber,
    if (appPackageName != null) 'appPackageName': appPackageName,
    if (sdkPackageVersion != null) 'sdkPackageVersion': sdkPackageVersion,
  };
}

/// Immutable configuration used to construct an Attriax SDK instance.
class AttriaxConfig {
  /// Creates an SDK configuration with optional app/build metadata.
  const AttriaxConfig({
    required this.appToken,
    this.apiBaseUrl = 'https://api.attriax.com',
    this.appVersion,
    this.appBuildNumber,
    this.appPackageName,
    this.sdkMetadata = const <String, Object?>{},
    this.clock,
    this.enableDebugLogs,
    this.requestTimeout = const Duration(seconds: 12),
    this.maxQueueSize = 200,
    this.sessionTrackingEnabled = true,
    this.sessionHeartbeatInterval = const Duration(seconds: 30),
    this.firstLaunchSessionHeartbeatInterval = const Duration(seconds: 5),
  });

  /// Application token issued by Attriax for the current app.
  final String appToken;

  /// Base URL for the Attriax API.
  ///
  /// Leave this at the production default unless you are targeting a local,
  /// staging, or self-hosted Attriax environment.
  final String apiBaseUrl;

  /// Optional app version string attached to SDK requests.
  final String? appVersion;

  /// Optional app build number attached to SDK requests.
  final String? appBuildNumber;

  /// Optional application package identifier attached to SDK requests.
  final String? appPackageName;

  /// Extra SDK metadata sent with requests as a normalized JSON object.
  final Map<String, Object?> sdkMetadata;

  /// Optional clock implementation used by the SDK for time-sensitive behavior.
  final AttriaxClock? clock;

  /// Overrides whether verbose SDK logs are emitted.
  ///
  /// When `null`, the SDK defaults to debug logging in debug builds and a more
  /// restrictive log level in release builds.
  final bool? enableDebugLogs;

  /// Per-request timeout applied to outbound Attriax API calls.
  final Duration requestTimeout;

  /// Maximum number of queued requests persisted locally for retry.
  final int maxQueueSize;

  /// Enables automatic session lifecycle tracking and session enrichment.
  final bool sessionTrackingEnabled;

  /// Heartbeat interval used for established sessions after first launch.
  final Duration sessionHeartbeatInterval;

  /// Heartbeat interval used during the installation's first launch session.
  final Duration firstLaunchSessionHeartbeatInterval;
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

int? _jsonInt(Object? value) => value is num ? value.toInt() : null;

double? _jsonDouble(Object? value) => value is num ? value.toDouble() : null;

DateTime? _jsonDateTime(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

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
