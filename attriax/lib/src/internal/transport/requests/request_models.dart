part of '../../attriax_api_models.dart';

sealed class AttriaxApiRequest {
  const AttriaxApiRequest();

  String get kindName;
  String get label;

  Map<String, Object?> toQueueBody();
}

final class AttriaxOpenRequest extends AttriaxApiRequest {
  const AttriaxOpenRequest(this.payload);

  final sdk.SdkV1OpenDto payload;

  @override
  String get kindName => 'open';

  @override
  String get label => 'app-open';

  @override
  Map<String, Object?> toQueueBody() => _generatedQueueBody(payload);
}

final class AttriaxTrackEventRequest extends AttriaxApiRequest {
  const AttriaxTrackEventRequest(this.payload);

  final sdk.SdkEventDto payload;

  @override
  String get kindName => 'trackEvent';

  @override
  String get label => 'event';

  @override
  Map<String, Object?> toQueueBody() => _generatedQueueBody(payload);
}

final class AttriaxTrackNotificationRequest extends AttriaxApiRequest {
  const AttriaxTrackNotificationRequest(this.payload);

  final sdk.SdkNotificationDto payload;

  @override
  String get kindName => 'trackNotification';

  @override
  String get label => 'notification';

  @override
  Map<String, Object?> toQueueBody() => _generatedQueueBody(payload);
}

final class AttriaxCrashReportPayload {
  const AttriaxCrashReportPayload({
    required this.projectToken,
    required this.source,
    required this.clientOccurredAt,
    required this.platform,
    required this.isFatal,
    required this.exceptionType,
    required this.message,
    required this.stackTrace,
    required this.isFirstLaunch,
    this.deviceId,
    this.deviceIdSource,
    this.reason,
    this.sessionId,
    this.sessionRelativeTimeMs,
    this.locale,
    this.appVersion,
    this.appBuildNumber,
    this.appPackageName,
    this.sdkApiVersion,
    this.sdkPackageVersion,
    this.metadata,
  });

  factory AttriaxCrashReportPayload.fromJson(Map<String, Object?> json) =>
      AttriaxCrashReportPayload(
        projectToken: attriaxRequireString(json, 'projectToken'),
        deviceId: attriaxStringValue(json['deviceId']),
        deviceIdSource: attriaxStringValue(json['deviceIdSource']),
        source: attriaxRequireString(json, 'source'),
        clientOccurredAt:
            attriaxDateTimeValue(json['clientOccurredAt'])?.toUtc() ??
            DateTime.now().toUtc(),
        platform: _parseAttriaxPlatformType(
          attriaxStringValue(json['platform']) ?? 'unknown',
        ),
        isFatal: attriaxBoolValue(json['isFatal']) ?? false,
        exceptionType: attriaxRequireString(json, 'exceptionType'),
        message: attriaxRequireString(json, 'message'),
        stackTrace: attriaxRequireString(json, 'stackTrace'),
        isFirstLaunch: attriaxBoolValue(json['isFirstLaunch']) ?? false,
        reason: attriaxStringValue(json['reason']),
        sessionId: attriaxStringValue(json['sessionId']),
        sessionRelativeTimeMs: _attriaxIntValue(json['sessionRelativeTimeMs']),
        locale: attriaxStringValue(json['locale']),
        appVersion: attriaxStringValue(json['appVersion']),
        appBuildNumber: attriaxStringValue(json['appBuildNumber']),
        appPackageName: attriaxStringValue(json['appPackageName']),
        sdkApiVersion: attriaxStringValue(json['sdkApiVersion']),
        sdkPackageVersion: attriaxStringValue(json['sdkPackageVersion']),
        metadata: attriaxObjectMap(json['metadata']),
      );

  final String projectToken;
  final String? deviceId;
  final String? deviceIdSource;
  final String source;
  final DateTime clientOccurredAt;
  final AttriaxPlatformType platform;
  final bool isFatal;
  final String exceptionType;
  final String message;
  final String stackTrace;
  final bool isFirstLaunch;
  final String? reason;
  final String? sessionId;
  final int? sessionRelativeTimeMs;
  final String? locale;
  final String? appVersion;
  final String? appBuildNumber;
  final String? appPackageName;
  final String? sdkApiVersion;
  final String? sdkPackageVersion;
  final Map<String, Object?>? metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    'projectToken': projectToken,
    if (deviceId != null) 'deviceId': deviceId,
    if (deviceIdSource != null) 'deviceIdSource': deviceIdSource,
    'source': source,
    'clientOccurredAt': clientOccurredAt.toUtc().toIso8601String(),
    'platform': platform.name,
    'isFatal': isFatal,
    'exceptionType': exceptionType,
    'message': message,
    'stackTrace': stackTrace,
    'isFirstLaunch': isFirstLaunch,
    if (reason != null) 'reason': reason,
    if (sessionId != null) 'sessionId': sessionId,
    if (sessionRelativeTimeMs != null)
      'sessionRelativeTimeMs': sessionRelativeTimeMs,
    if (locale != null) 'locale': locale,
    if (appVersion != null) 'appVersion': appVersion,
    if (appBuildNumber != null) 'appBuildNumber': appBuildNumber,
    if (appPackageName != null) 'appPackageName': appPackageName,
    if (sdkApiVersion != null) 'sdkApiVersion': sdkApiVersion,
    if (sdkPackageVersion != null) 'sdkPackageVersion': sdkPackageVersion,
    if (metadata != null && metadata!.isNotEmpty)
      'metadata': attriaxNormalizeJsonMap(metadata!),
  };
}

final class AttriaxTrackCrashRequest extends AttriaxApiRequest {
  const AttriaxTrackCrashRequest(this.payload);

  final AttriaxCrashReportPayload payload;

  @override
  String get kindName => 'trackCrash';

  @override
  String get label => 'crash report';

  @override
  Map<String, Object?> toQueueBody() => payload.toJson();
}

enum AttriaxSessionLifecycleKind { start, heartbeat, pause, resume, end }

final class AttriaxSessionLifecyclePayload {
  const AttriaxSessionLifecyclePayload({
    required this.projectToken,
    required this.kind,
    required this.sessionId,
    required this.clientOccurredAt,
    required this.platform,
    required this.isFirstLaunch,
    this.deviceId,
    this.deviceIdSource,
    this.sessionRelativeTimeMs,
    this.locale,
    this.appVersion,
    this.appBuildNumber,
    this.appPackageName,
    this.sdkApiVersion,
    this.sdkPackageVersion,
    this.metadata,
  });

  factory AttriaxSessionLifecyclePayload.fromJson(Map<String, Object?> json) =>
      AttriaxSessionLifecyclePayload(
        projectToken: attriaxRequireString(json, 'projectToken'),
        deviceId: attriaxStringValue(json['deviceId']),
        deviceIdSource: attriaxStringValue(json['deviceIdSource']),
        kind: _parseSessionLifecycleKind(attriaxRequireString(json, 'kind')),
        sessionId: attriaxRequireString(json, 'sessionId'),
        sessionRelativeTimeMs: _attriaxIntValue(json['sessionRelativeTimeMs']),
        clientOccurredAt:
            attriaxDateTimeValue(json['clientOccurredAt'])?.toUtc() ??
            DateTime.now().toUtc(),
        platform: _parseAttriaxPlatformType(
          attriaxStringValue(json['platform']) ?? 'unknown',
        ),
        locale: attriaxStringValue(json['locale']),
        isFirstLaunch: attriaxBoolValue(json['isFirstLaunch']) ?? false,
        appVersion: attriaxStringValue(json['appVersion']),
        appBuildNumber: attriaxStringValue(json['appBuildNumber']),
        appPackageName: attriaxStringValue(json['appPackageName']),
        sdkApiVersion: attriaxStringValue(json['sdkApiVersion']),
        sdkPackageVersion: attriaxStringValue(json['sdkPackageVersion']),
        metadata: attriaxObjectMap(json['metadata']),
      );

  final String projectToken;
  final String? deviceId;
  final String? deviceIdSource;
  final AttriaxSessionLifecycleKind kind;
  final String sessionId;
  final int? sessionRelativeTimeMs;
  final DateTime clientOccurredAt;
  final AttriaxPlatformType platform;
  final String? locale;
  final bool isFirstLaunch;
  final String? appVersion;
  final String? appBuildNumber;
  final String? appPackageName;
  final String? sdkApiVersion;
  final String? sdkPackageVersion;
  final Map<String, Object?>? metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    'projectToken': projectToken,
    if (deviceId != null) 'deviceId': deviceId,
    if (deviceIdSource != null) 'deviceIdSource': deviceIdSource,
    'kind': kind.name,
    'sessionId': sessionId,
    if (sessionRelativeTimeMs != null)
      'sessionRelativeTimeMs': sessionRelativeTimeMs,
    'clientOccurredAt': clientOccurredAt.toUtc().toIso8601String(),
    'platform': platform.name,
    if (locale != null) 'locale': locale,
    'isFirstLaunch': isFirstLaunch,
    if (appVersion != null) 'appVersion': appVersion,
    if (appBuildNumber != null) 'appBuildNumber': appBuildNumber,
    if (appPackageName != null) 'appPackageName': appPackageName,
    if (sdkApiVersion != null) 'sdkApiVersion': sdkApiVersion,
    if (sdkPackageVersion != null) 'sdkPackageVersion': sdkPackageVersion,
    if (metadata != null && metadata!.isNotEmpty)
      'metadata': attriaxNormalizeJsonMap(metadata!),
  };
}

final class AttriaxTrackSessionRequest extends AttriaxApiRequest {
  const AttriaxTrackSessionRequest(this.payload);

  final AttriaxSessionLifecyclePayload payload;

  @override
  String get kindName => 'trackSession';

  @override
  String get label => 'session ${payload.kind.name}';

  @override
  Map<String, Object?> toQueueBody() => payload.toJson();
}

final class AttriaxUserRequest extends AttriaxApiRequest {
  const AttriaxUserRequest(this.payload);

  final sdk.SdkUserDto payload;

  @override
  String get kindName => 'user';

  @override
  String get label => 'user update';

  @override
  Map<String, Object?> toQueueBody() => _generatedQueueBody(payload);
}

final class AttriaxResolveDeepLinkRequest extends AttriaxApiRequest {
  const AttriaxResolveDeepLinkRequest(this.payload);

  final sdk.SdkV1DeepLinkResolveDto payload;

  @override
  String get kindName => 'resolveDeepLink';

  @override
  String get label => 'deep-link resolution';

  @override
  Map<String, Object?> toQueueBody() => _generatedQueueBody(payload);
}

final class AttriaxCreateDynamicLinkRequest extends AttriaxApiRequest {
  const AttriaxCreateDynamicLinkRequest(this.payload);

  final sdk.SdkCreateDynamicLinkDto payload;

  @override
  String get kindName => 'createDynamicLink';

  @override
  String get label => 'dynamic-link creation';

  @override
  Map<String, Object?> toQueueBody() => _generatedQueueBody(payload);
}

final class AttriaxRegisterUninstallTokenRequest extends AttriaxApiRequest {
  const AttriaxRegisterUninstallTokenRequest(this.payload);

  final Map<String, Object?> payload;

  @override
  String get kindName => 'registerUninstallToken';

  @override
  String get label => 'uninstall token registration';

  @override
  Map<String, Object?> toQueueBody() => attriaxNormalizeJsonMap(payload);
}
