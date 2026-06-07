part of 'types.dart';

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
      deviceId: _jsonString(json['deviceId']),
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
  final String? deviceId;
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
    if (deviceId != null) 'deviceId': deviceId,
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

/// Configuration for an Attriax SDK instance.
///
/// Create one config for the project token and runtime behavior you want this
/// app process to use. Values are read during SDK construction and
/// initialization; runtime toggles such as `tracking.enabled` can be changed
/// through the SDK instance.
class AttriaxConfig {
  const AttriaxConfig({
    required this.projectToken,
    this.apiBaseUrl = 'https://api.attriax.com',
    this.appVersion,
    this.appBuildNumber,
    this.appPackageName,
    this.sdkMetadata = const <String, Object?>{},
    this.clock,
    this.enableDebugLogs,
    this.requestTimeout = const Duration(seconds: 12),
    this.maxQueueSize = 500,
    this.eventFlushInterval = const Duration(seconds: 60),
    this.flushEventsImmediatelyOnFirstLaunch = true,
    this.collectAdvertisingId = true,
    this.automaticCrashReportingEnabled = true,
    this.requestTrackingAuthorizationOnInit = false,
    this.trackingAuthorizationStatusTimeout = const Duration(seconds: 60),
    this.automaticBrowserHandling = true,
    this.gdprEnabled = false,
    this.anonymousTracking = true,
    this.sessionTrackingEnabled = true,
    this.sessionHeartbeatInterval = const Duration(minutes: 5),
    this.firstLaunchSessionHeartbeatInterval = const Duration(seconds: 30),
    this.skan,
  });

  /// Project token from the Attriax dashboard.
  final String projectToken;

  /// Base URL for the Attriax API.
  ///
  /// Leave this as the default in production. Tests and self-hosted
  /// environments can point it at another compatible API origin.
  final String apiBaseUrl;

  /// Application version to attach to SDK context and session payloads.
  final String? appVersion;

  /// Application build number to attach to SDK context and session payloads.
  final String? appBuildNumber;

  /// Platform package or bundle identifier for this app.
  final String? appPackageName;

  /// Extra SDK metadata attached to runtime context payloads.
  final Map<String, Object?> sdkMetadata;

  /// Optional clock override for deterministic tests.
  final AttriaxClock? clock;

  /// Overrides SDK log verbosity.
  ///
  /// When `null`, debug Flutter builds log verbosely and release builds use a
  /// quieter warning/error level.
  final bool? enableDebugLogs;

  /// Timeout used by direct SDK network calls.
  final Duration requestTimeout;

  /// Maximum number of queued SDK requests kept locally.
  final int maxQueueSize;

  /// Interval used for automatic event queue flushing while online.
  final Duration eventFlushInterval;

  /// Whether first-launch events should flush immediately.
  final bool flushEventsImmediatelyOnFirstLaunch;

  /// Whether the SDK should collect the advertising identifier when available.
  final bool collectAdvertisingId;

  /// Whether the SDK should install automatic Flutter crash handlers.
  final bool automaticCrashReportingEnabled;

  /// Whether the SDK should request App Tracking Transparency authorization
  /// during initialization on supported Apple platforms.
  final bool requestTrackingAuthorizationOnInit;

  /// Maximum time to wait for App Tracking Transparency status during startup.
  final Duration trackingAuthorizationStatusTimeout;

  /// Whether resolved deep links may open browser fallback URLs automatically.
  final bool automaticBrowserHandling;

  /// Enables GDPR-aware consent gating for analytics and attribution traffic.
  final bool gdprEnabled;

  /// Enables GDPR-safe anonymous tracking while consent is unresolved.
  ///
  /// When this is `true`, anonymous-capable analytics, crash, session, and
  /// deep-link requests can still be sent without Attriax device identity.
  /// When this is `false`, the SDK buffers that traffic locally until consent
  /// allows identified delivery, or drops it if the resolved consent denies
  /// the relevant categories.
  final bool anonymousTracking;

  /// Whether the SDK should create and update tracked app sessions.
  final bool sessionTrackingEnabled;

  /// Heartbeat interval for regular app sessions.
  final Duration sessionHeartbeatInterval;

  /// Heartbeat interval used during the first launch session.
  final Duration firstLaunchSessionHeartbeatInterval;

  /// Optional local SKAN defaults used until dashboard runtime config loads.
  final AttriaxSkanConfig? skan;
}
