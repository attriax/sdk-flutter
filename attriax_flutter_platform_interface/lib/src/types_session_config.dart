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

class AttriaxConfig {
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
    this.maxQueueSize = 500,
    this.eventFlushInterval = const Duration(seconds: 60),
    this.flushEventsImmediatelyOnFirstLaunch = true,
    this.collectAdvertisingId = true,
    this.automaticCrashReportingEnabled = true,
    this.requestTrackingAuthorizationOnInit = false,
    this.trackingAuthorizationStatusTimeout = const Duration(seconds: 60),
    this.automaticBrowserHandling = true,
    this.gdprEnabled = false,
    this.gdprAutoDetect = true,
    this.sessionTrackingEnabled = true,
    this.sessionHeartbeatInterval = const Duration(minutes: 5),
    this.firstLaunchSessionHeartbeatInterval = const Duration(seconds: 30),
    this.skan,
  });

  final String appToken;
  final String apiBaseUrl;
  final String? appVersion;
  final String? appBuildNumber;
  final String? appPackageName;
  final Map<String, Object?> sdkMetadata;
  final AttriaxClock? clock;
  final bool? enableDebugLogs;
  final Duration requestTimeout;
  final int maxQueueSize;
  final Duration eventFlushInterval;
  final bool flushEventsImmediatelyOnFirstLaunch;
  final bool collectAdvertisingId;
  final bool automaticCrashReportingEnabled;
  final bool requestTrackingAuthorizationOnInit;
  final Duration trackingAuthorizationStatusTimeout;
  final bool automaticBrowserHandling;
  final bool gdprEnabled;
  final bool gdprAutoDetect;
  final bool sessionTrackingEnabled;
  final Duration sessionHeartbeatInterval;
  final Duration firstLaunchSessionHeartbeatInterval;
  final AttriaxSkanConfig? skan;
}