const String attriaxSdkApiVersion = 'v1';
const String attriaxSdkPackageVersion = '0.1.0';

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

class AttriaxPendingCrashReport {
  const AttriaxPendingCrashReport({
    required this.source,
    required this.isFatal,
    required this.exceptionType,
    required this.message,
    required this.stackTrace,
    this.occurredAt,
    this.reason,
    this.metadata = const <String, Object?>{},
  });

  factory AttriaxPendingCrashReport.fromJson(Map<String, Object?> json) {
    final metadata =
        _jsonObject(json['metadata']) ??
        <String, Object?>{
          for (final entry in json.entries)
            if (entry.key != 'source' &&
                entry.key != 'isFatal' &&
                entry.key != 'exceptionType' &&
                entry.key != 'message' &&
                entry.key != 'stackTrace' &&
                entry.key != 'occurredAt' &&
                entry.key != 'reason')
              entry.key: _normalizeJsonValue(entry.value),
        };

    return AttriaxPendingCrashReport(
      source: _jsonString(json['source']) ?? 'native',
      isFatal: _jsonBool(json['isFatal']) ?? true,
      exceptionType: _jsonString(json['exceptionType']) ?? 'UnknownError',
      message: _jsonString(json['message']) ?? 'Unknown crash',
      stackTrace: _jsonString(json['stackTrace']) ?? '',
      occurredAt: _jsonDateTime(json['occurredAt']),
      reason: _jsonString(json['reason']),
      metadata: metadata,
    );
  }

  factory AttriaxPendingCrashReport.fromPayload(Object? payload) {
    final json = _jsonObject(payload);
    if (json == null || json.isEmpty) {
      throw const FormatException('Pending crash report payload is empty.');
    }

    return AttriaxPendingCrashReport.fromJson(json);
  }

  final String source;
  final bool isFatal;
  final String exceptionType;
  final String message;
  final String stackTrace;
  final DateTime? occurredAt;
  final String? reason;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    'source': source,
    'isFatal': isFatal,
    'exceptionType': exceptionType,
    'message': message,
    'stackTrace': stackTrace,
    if (occurredAt != null) 'occurredAt': occurredAt!.toUtc().toIso8601String(),
    if (reason != null) 'reason': reason,
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

class AttriaxUtmParameters {
  const AttriaxUtmParameters({
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
  });

  factory AttriaxUtmParameters.fromJson(Map<String, Object?> json) =>
      AttriaxUtmParameters(
        source: _jsonString(json['source']),
        medium: _jsonString(json['medium']),
        campaign: _jsonString(json['campaign']),
        term: _jsonString(json['term']),
        content: _jsonString(json['content']),
      );

  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;

  bool get isEmpty =>
      source == null &&
      medium == null &&
      campaign == null &&
      term == null &&
      content == null;

  Map<String, Object?> toJson() => <String, Object?>{
    if (source != null) 'source': source,
    if (medium != null) 'medium': medium,
    if (campaign != null) 'campaign': campaign,
    if (term != null) 'term': term,
    if (content != null) 'content': content,
  };
}

class AttriaxDeepLink {
  const AttriaxDeepLink({required this.path, this.data, this.uri, this.utm});

  factory AttriaxDeepLink.fromJson(Map<String, Object?> json) {
    final utmJson = _jsonObject(json['utm']);

    return AttriaxDeepLink(
      path: _requireJsonString(json, 'path'),
      data: _jsonObject(json['data']),
      uri: _jsonUri(json['uri']),
      utm: utmJson == null ? null : AttriaxUtmParameters.fromJson(utmJson),
    );
  }

  final String path;
  final Map<String, Object?>? data;
  final Uri? uri;
  final AttriaxUtmParameters? utm;

  Map<String, Object?> toJson() => <String, Object?>{
    'path': path,
    if (data != null && data!.isNotEmpty) 'data': _normalizeJsonMap(data!),
    if (uri != null) 'uri': uri.toString(),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
  };
}

class AttriaxResolvedUrlAction {
  const AttriaxResolvedUrlAction({required this.uri, required this.openMode});

  factory AttriaxResolvedUrlAction.fromJson(Map<String, Object?> json) {
    final uri = _jsonUri(json['url'] ?? json['uri']);
    if (uri == null) {
      throw const FormatException('Missing or invalid "url".');
    }

    return AttriaxResolvedUrlAction(
      uri: uri,
      openMode: _parseResolvedUrlOpenMode(_jsonString(json['openMode'])),
    );
  }

  final Uri uri;
  final AttriaxResolvedUrlOpenMode openMode;

  Map<String, Object?> toJson() => <String, Object?>{
    'url': uri.toString(),
    'openMode': openMode.name,
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
    this.deepLinkUri,
    this.deepLinkData,
    this.registeredAt,
    this.installBeginTimestampSeconds,
    this.referrerClickTimestampSeconds,
    this.googlePlayInstantParam,
  });

  factory AttriaxInstallReferrerDetails.fromJson(Map<String, Object?> json) {
    final deepLinkDataJson = _jsonStringMap(json['deepLinkData']);

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
      deepLinkUri: _jsonUri(json['deepLinkUri']),
      deepLinkData: deepLinkDataJson,
      registeredAt: _jsonDateTime(json['registeredAt']),
      installBeginTimestampSeconds: _jsonInt(
        json['installBeginTimestampSeconds'],
      ),
      referrerClickTimestampSeconds: _jsonInt(
        json['referrerClickTimestampSeconds'],
      ),
      googlePlayInstantParam: _jsonBool(json['googlePlayInstantParam']),
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
  @Deprecated('Use deepLinkUri instead.')
  final String? deepLinkUrl;

  /// Full tracked short-link URI associated with the resolved deep link.
  final Uri? deepLinkUri;

  /// Resolved deep-link payload data associated with the startup referrer.
  final Map<String, String>? deepLinkData;

  /// When the backend registered this startup referrer snapshot.
  final DateTime? registeredAt;

  /// Play install begin timestamp, when the current platform reports one.
  final int? installBeginTimestampSeconds;

  /// Play referrer click timestamp, when the current platform reports one.
  final int? referrerClickTimestampSeconds;

  /// Google Play instant-app flag, when the current platform reports one.
  final bool? googlePlayInstantParam;

  AttriaxUtmParameters? get utm {
    final value = AttriaxUtmParameters(
      source: source,
      medium: medium,
      campaign: campaign,
      term: term,
      content: content,
    );
    return value.isEmpty ? null : value;
  }

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
    if (deepLinkUri != null) 'deepLinkUri': deepLinkUri.toString(),
    if (deepLinkUrl != null) 'deepLinkUrl': deepLinkUrl,
    if (deepLinkData != null && deepLinkData!.isNotEmpty)
      'deepLinkData': Map<String, String>.from(deepLinkData!),
    if (registeredAt != null) 'registeredAt': registeredAt!.toIso8601String(),
    if (installBeginTimestampSeconds != null)
      'installBeginTimestampSeconds': installBeginTimestampSeconds,
    if (referrerClickTimestampSeconds != null)
      'referrerClickTimestampSeconds': referrerClickTimestampSeconds,
    if (googlePlayInstantParam != null)
      'googlePlayInstantParam': googlePlayInstantParam,
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

class AttriaxRevenueReceiptValidationResult {
  const AttriaxRevenueReceiptValidationResult({
    required this.validationId,
    required this.status,
    required this.publicReceipt,
    this.requestVersion,
    this.acceptedAt,
    this.provider,
    this.environment,
    this.transactionId,
    this.originalTransactionId,
    this.productId,
    this.failureReason,
    this.expiresAt,
    this.providerResult,
  });

  factory AttriaxRevenueReceiptValidationResult.fromJson(
    Map<String, Object?> json,
  ) => AttriaxRevenueReceiptValidationResult(
    requestVersion: _jsonString(json['requestVersion']),
    acceptedAt: _jsonDateTime(json['acceptedAt']),
    validationId: _requireJsonString(json, 'validationId'),
    status: _parseRevenueReceiptValidationStatus(_jsonString(json['status'])),
    provider: _jsonString(json['provider']),
    environment: _jsonString(json['environment']),
    transactionId: _jsonString(json['transactionId']),
    originalTransactionId: _jsonString(json['originalTransactionId']),
    productId: _jsonString(json['productId']),
    failureReason: _jsonString(json['failureReason']),
    expiresAt: _jsonDateTime(json['expiresAt']),
    providerResult: _jsonObject(json['providerResult']),
    publicReceipt:
        _jsonObject(json['publicReceipt']) ?? const <String, Object?>{},
  );

  final String validationId;
  final AttriaxRevenueReceiptValidationStatus status;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final String? provider;
  final String? environment;
  final String? transactionId;
  final String? originalTransactionId;
  final String? productId;
  final String? failureReason;
  final DateTime? expiresAt;
  final Map<String, Object?>? providerResult;
  final Map<String, Object?> publicReceipt;
}

class AttriaxRawDeepLinkEvent {
  const AttriaxRawDeepLinkEvent({
    required this.uri,
    required this.receivedAt,
    required this.isInitial,
  });

  factory AttriaxRawDeepLinkEvent.fromJson(Map<String, Object?> json) {
    return AttriaxRawDeepLinkEvent(
      uri: _jsonUri(json['uri']) ?? Uri(path: _jsonString(json['path']) ?? '/'),
      receivedAt: _requireJsonDateTime(json, 'receivedAt'),
      isInitial: _jsonBool(json['isInitial']) ?? false,
    );
  }

  /// The full URI captured directly from the native deep-link source.
  final Uri uri;

  /// Local timestamp when the SDK observed the raw deep-link input.
  final DateTime receivedAt;

  /// Whether this raw event came from the launch link captured during startup.
  final bool isInitial;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'receivedAt': receivedAt.toIso8601String(),
    'isInitial': isInitial,
  };
}

class AttriaxDeepLinkReferrerDetails {
  const AttriaxDeepLinkReferrerDetails({
    required this.uri,
    required this.receivedAt,
    required this.clickedAt,
    required this.consumedAt,
    required this.trigger,
    required this.isAttriaxDomain,
    required this.found,
    this.data,
    this.utm,
    this.browserAction,
    this.handledBySdk = false,
  });

  final Uri uri;
  final DateTime receivedAt;
  final DateTime clickedAt;
  final DateTime consumedAt;
  final AttriaxDeepLinkTrigger trigger;
  final bool isAttriaxDomain;
  final bool found;
  final Map<String, String>? data;
  final AttriaxUtmParameters? utm;
  final AttriaxResolvedUrlAction? browserAction;
  final bool handledBySdk;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'receivedAt': receivedAt.toIso8601String(),
    'clickedAt': clickedAt.toIso8601String(),
    'consumedAt': consumedAt.toIso8601String(),
    'trigger': trigger.name,
    'isAttriaxDomain': isAttriaxDomain,
    'found': found,
    if (data != null && data!.isNotEmpty)
      'data': Map<String, String>.from(data!),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
    if (browserAction != null) 'browserAction': browserAction!.toJson(),
    'handledBySdk': handledBySdk,
  };
}

class AttriaxDeepLinkEvent {
  const AttriaxDeepLinkEvent({
    required this.uri,
    required this.clickedAt,
    required this.consumedAt,
    required this.found,
    required this.trigger,
    required this.isAttriaxSubDomain,
    this.rawEvent,
    this.data,
    this.utm,
    this.browserAction,
    this.handledBySdk = false,
  });

  factory AttriaxDeepLinkEvent.fromJson(Map<String, Object?> json) {
    final utmJson = _jsonObject(json['utm']);
    final browserActionJson = _jsonObject(json['browserAction']);
    final rawEventJson = _jsonObject(json['rawEvent']);

    return AttriaxDeepLinkEvent(
      uri: _jsonUri(json['uri']) ?? Uri(path: _jsonString(json['path']) ?? '/'),
      clickedAt: _requireJsonDateTime(json, 'clickedAt'),
      consumedAt: _requireJsonDateTime(json, 'consumedAt'),
      found: _jsonBool(json['found']) ?? false,
      trigger: _parseDeepLinkTrigger(_jsonString(json['trigger'])),
      isAttriaxSubDomain:
          _jsonBool(json['isAttriaxSubDomain']) ??
          _jsonBool(json['isAttriaxDomain']) ??
          false,
      rawEvent: rawEventJson == null
          ? null
          : AttriaxRawDeepLinkEvent.fromJson(rawEventJson),
      data: _jsonStringMap(json['data']),
      utm: utmJson == null ? null : AttriaxUtmParameters.fromJson(utmJson),
      browserAction: browserActionJson == null
          ? null
          : AttriaxResolvedUrlAction.fromJson(browserActionJson),
      handledBySdk: _jsonBool(json['handledBySdk']) ?? false,
    );
  }

  /// Canonical referrer URI when Attriax resolved one, or the incoming URI.
  final Uri uri;

  /// The original click timestamp.
  final DateTime clickedAt;

  /// The timestamp when Attriax processed and consumed the deep-link event.
  final DateTime consumedAt;

  /// Whether Attriax matched this event to a registered link.
  final bool found;

  /// Describes how this deep-link event was triggered.
  final AttriaxDeepLinkTrigger trigger;

  /// Whether the resolved URI belongs to an Attriax-managed subdomain.
  final bool isAttriaxSubDomain;

  /// Raw deep-link input that started this resolution, when available.
  final AttriaxRawDeepLinkEvent? rawEvent;

  /// Dashboard-configured key-value payload for matched links.
  final Map<String, String>? data;

  /// Resolved UTM parameters associated with the matched link.
  final AttriaxUtmParameters? utm;

  /// Browser destination returned by Attriax for SDK-managed handling.
  final AttriaxResolvedUrlAction? browserAction;

  /// Whether the SDK already handled the link by opening a browser.
  final bool handledBySdk;

  bool get isDeferred => trigger == AttriaxDeepLinkTrigger.deferred;

  bool get isColdStart => trigger == AttriaxDeepLinkTrigger.coldStart;

  bool get isForeground => trigger == AttriaxDeepLinkTrigger.foreground;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'clickedAt': clickedAt.toIso8601String(),
    'consumedAt': consumedAt.toIso8601String(),
    'found': found,
    'trigger': trigger.name,
    'isAttriaxSubDomain': isAttriaxSubDomain,
    if (rawEvent != null) 'rawEvent': rawEvent!.toJson(),
    if (data != null && data!.isNotEmpty)
      'data': Map<String, String>.from(data!),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
    if (browserAction != null) 'browserAction': browserAction!.toJson(),
    'handledBySdk': handledBySdk,
  };
}

class AttriaxDeepLinkResolutionResult {
  const AttriaxDeepLinkResolutionResult({
    required this.matched,
    required this.status,
    required this.isFirstLaunch,
    this.reason,
    this.deepLink,
    this.browserAction,
    this.requestVersion,
    this.acceptedAt,
    this.consumedAt,
  });

  factory AttriaxDeepLinkResolutionResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);
    final browserActionJson = _jsonObject(json['browserAction']);

    return AttriaxDeepLinkResolutionResult(
      matched: _jsonBool(json['matched']) ?? false,
      status: _parseResolutionStatus(_jsonString(json['status'])),
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      reason: _jsonString(json['reason']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
      browserAction: browserActionJson != null
          ? AttriaxResolvedUrlAction.fromJson(browserActionJson)
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
  final AttriaxResolvedUrlAction? browserAction;
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
    this.installState = AttriaxInstallState.existing,
    this.requestVersion,
    this.acceptedAt,
    this.deepLink,
    this.deepLinkClickedAt,
    this.deepLinkConsumedAt,
    this.originalInstallReferrer,
    this.reinstallReferrer,
    this.installReferrer,
  });

  factory AttriaxAppOpenResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);
    final installReferrerJson = _jsonObject(json['installReferrer']);
    final originalInstallReferrerJson = _jsonObject(
      json['originalInstallReferrer'],
    );
    final reinstallReferrerJson = _jsonObject(json['reinstallReferrer']);

    return AttriaxAppOpenResult(
      userId: _requireJsonString(json, 'userId'),
      isNewUser: _jsonBool(json['isNewUser']) ?? false,
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      installState: _parseInstallState(_jsonString(json['installState'])),
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
      deepLinkClickedAt: _jsonDateTime(json['deepLinkClickedAt']),
      deepLinkConsumedAt: _jsonDateTime(json['deepLinkConsumedAt']),
      originalInstallReferrer: originalInstallReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(originalInstallReferrerJson)
          : null,
      reinstallReferrer: reinstallReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(reinstallReferrerJson)
          : null,
      installReferrer: installReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(installReferrerJson)
          : null,
    );
  }

  final String userId;
  final bool isNewUser;
  final bool isFirstLaunch;
  final AttriaxInstallState installState;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final AttriaxDeepLink? deepLink;
  final DateTime? deepLinkClickedAt;
  final DateTime? deepLinkConsumedAt;
  final AttriaxInstallReferrerDetails? originalInstallReferrer;
  final AttriaxInstallReferrerDetails? reinstallReferrer;
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
    this.eventFlushInterval = const Duration(seconds: 60),
    this.flushEventsImmediatelyOnFirstLaunch = true,
    this.collectAdvertisingId = true,
    this.automaticCrashReportingEnabled = true,
    this.requestTrackingAuthorizationOnInit = false,
    this.trackingAuthorizationStatusTimeout = const Duration(seconds: 60),
    this.automaticBrowserHandling = true,
    this.sessionTrackingEnabled = true,
    this.sessionHeartbeatInterval = const Duration(seconds: 60),
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

  /// Minimum delay between automatic flushes of regular queued events.
  ///
  /// Non-important events are buffered locally after first launch and flushed
  /// when this interval elapses, unless a later important request drains the
  /// queue sooner. Set this to `Duration.zero` to keep immediate event flushes.
  final Duration eventFlushInterval;

  /// Whether regular events should still flush immediately during first launch.
  ///
  /// When `true`, event requests keep the current eager delivery behavior for
  /// the installation's first launch session. Later launches use
  /// [eventFlushInterval] unless a caller marks an event as important.
  final bool flushEventsImmediatelyOnFirstLaunch;

  /// Whether native platform collectors may include advertising identifiers.
  ///
  /// Android uses this to control GAID collection. Apple platforms use it with
  /// App Tracking Transparency authorization to control SDK-managed IDFA
  /// collection. Host apps may still call the public ATT status/request APIs
  /// even when this is false.
  final bool collectAdvertisingId;

  /// Whether Attriax installs automatic Flutter/native crash handlers.
  ///
  /// Manual [Attriax.recordError] calls remain available when this is false.
  final bool automaticCrashReportingEnabled;

  /// Whether the SDK should request ATT authorization during startup.
  ///
  /// When this is `true` and [collectAdvertisingId] is enabled, the SDK calls
  /// ATT during initialization and waits for the user-driven result before it
  /// collects native context.
  final bool requestTrackingAuthorizationOnInit;

  /// Maximum time to poll ATT status during startup when
  /// [requestTrackingAuthorizationOnInit] is `false`.
  ///
  /// This wait is only used while initialization is collecting native context.
  /// Explicit [Attriax.requestTrackingAuthorization] calls do not use this
  /// timeout unless the caller passes one directly.
  final Duration trackingAuthorizationStatusTimeout;

  /// Whether the SDK opens backend-provided browser actions automatically.
  final bool automaticBrowserHandling;

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
