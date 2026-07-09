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
    this.attestationEnabled = false,
    this.attestationProvider,
    this.pinnedCertificateSha256Fingerprints = const <String>[],
    this.doNotSell,
    this.usPrivacy,
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

  /// Opts this SDK instance into device attestation (Epic 7.3b).
  ///
  /// Default `false`. When `false`, the SDK never requests an attestation nonce
  /// and never attaches an attestation envelope to the init request — behavior
  /// is identical to earlier SDK versions.
  ///
  /// When `true`, before the app-open/init request the SDK fetches a single-use
  /// nonce from the challenge endpoint, asks [attestationProvider] to produce a
  /// token, and attaches the resulting envelope. Server-side verification is
  /// itself inert unless the project opts into `requireAttestation`, so enabling
  /// this is safe and never blocks or fails init: a failed challenge fetch or a
  /// `null` provider result simply sends init with no envelope.
  final bool attestationEnabled;

  /// The provider that acquires the platform attestation token.
  ///
  /// Ignored unless [attestationEnabled] is `true`. When attestation is enabled
  /// and this is `null`, the SDK uses [AttriaxNoopAttestationProvider] (always
  /// `null`), so no envelope is attached. Supply an
  /// `AttriaxPlatformAttestationProvider` (or a custom implementation) to attach
  /// a real Play Integrity / App Attest envelope.
  final AttriaxAttestationProvider? attestationProvider;

  /// SHA-256 certificate fingerprints to pin the SDK transport against.
  ///
  /// Empty by default → certificate pinning is DISABLED and the default system
  /// trust store is used (no behavior change). Provide the hex-encoded SHA-256
  /// fingerprints of the leaf/intermediate certificates you trust to enable
  /// pinning.
  ///
  /// NOTE (Epic 7.3b): the enforcement seam is present but the real per-request
  /// SHA-256 validation is a `TODO(live)` in the transport layer — pinning is
  /// device/OS/CA-rotation-sensitive and cannot be verified here, so no fake
  /// certificates are shipped. See the SDK transport setup for the seam.
  final List<String> pinnedCertificateSha256Fingerprints;

  /// CCPA "do not sell / share" election (Epic 10.1).
  ///
  /// Sent TOP-LEVEL on the app-open and identify requests (mirrors `attStatus`),
  /// NOT nested under device context. `null` (the default) omits the field
  /// entirely; an explicit `true` durably suppresses this user's outbound and an
  /// explicit `false` may clear a prior server-side latch. Can also be changed at
  /// runtime via `setCcpaConsent`.
  final bool? doNotSell;

  /// Raw IAB US-Privacy (USP) string, e.g. `1YYN` (Epic 10.1).
  ///
  /// Sent TOP-LEVEL alongside [doNotSell]; its sale opt-out flag also drives the
  /// backend do-not-sell latch. `null`/empty omits the field. Capped at 16 chars
  /// on the wire.
  final String? usPrivacy;

  /// Serializes the JSON-representable config surface for the native engine
  /// `initialize` command.
  ///
  /// Durations are emitted as integer milliseconds to match the KMP
  /// `AttriaxConfig` `*Ms` fields. The runtime-only [clock] and
  /// [attestationProvider] are NOT serialized — they are Dart-side objects a
  /// native engine cannot consume; a native binding sources its own clock and
  /// attaches its platform attestation provider from [attestationEnabled].
  Map<String, Object?> toJson() => <String, Object?>{
    'projectToken': projectToken,
    'apiBaseUrl': apiBaseUrl,
    if (appVersion != null) 'appVersion': appVersion,
    if (appBuildNumber != null) 'appBuildNumber': appBuildNumber,
    if (appPackageName != null) 'appPackageName': appPackageName,
    if (sdkMetadata.isNotEmpty) 'sdkMetadata': _normalizeJsonMap(sdkMetadata),
    if (enableDebugLogs != null) 'enableDebugLogs': enableDebugLogs,
    'requestTimeoutMs': requestTimeout.inMilliseconds,
    'maxQueueSize': maxQueueSize,
    'eventFlushIntervalMs': eventFlushInterval.inMilliseconds,
    'flushEventsImmediatelyOnFirstLaunch': flushEventsImmediatelyOnFirstLaunch,
    'collectAdvertisingId': collectAdvertisingId,
    'automaticCrashReportingEnabled': automaticCrashReportingEnabled,
    'requestTrackingAuthorizationOnInit': requestTrackingAuthorizationOnInit,
    'trackingAuthorizationStatusTimeoutMs':
        trackingAuthorizationStatusTimeout.inMilliseconds,
    'automaticBrowserHandling': automaticBrowserHandling,
    'gdprEnabled': gdprEnabled,
    'anonymousTracking': anonymousTracking,
    'sessionTrackingEnabled': sessionTrackingEnabled,
    'sessionHeartbeatIntervalMs': sessionHeartbeatInterval.inMilliseconds,
    'firstLaunchSessionHeartbeatIntervalMs':
        firstLaunchSessionHeartbeatInterval.inMilliseconds,
    if (skan != null) 'skan': skan!.toJson(),
    'attestationEnabled': attestationEnabled,
    if (pinnedCertificateSha256Fingerprints.isNotEmpty)
      'pinnedCertificateSha256Fingerprints':
          List<String>.from(pinnedCertificateSha256Fingerprints),
    if (doNotSell != null) 'doNotSell': doNotSell,
    if (usPrivacy != null && usPrivacy!.isNotEmpty) 'usPrivacy': usPrivacy,
  };
}
