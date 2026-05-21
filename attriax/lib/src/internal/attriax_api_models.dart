import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:attriax_api_client/attriax_api_client.dart' as sdk;

import 'attriax_json_utils.dart';

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

final class AttriaxCrashReportPayload {
  const AttriaxCrashReportPayload({
    required this.appToken,
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
        appToken: attriaxRequireString(json, 'appToken'),
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

  final String appToken;
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
    'appToken': appToken,
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
    required this.appToken,
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
        appToken: attriaxRequireString(json, 'appToken'),
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

  final String appToken;
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
    'appToken': appToken,
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

String attriaxApiRequestLabel(AttriaxApiRequest request) => request.label;

bool attriaxCanBatchRequest(AttriaxApiRequest request) => switch (request) {
  AttriaxTrackEventRequest(:final payload) => payload.deviceId != null,
  AttriaxTrackSessionRequest(:final payload) => payload.deviceId != null,
  AttriaxUserRequest() => true,
  _ => false,
};

final class AttriaxBatchRequestIdentity {
  const AttriaxBatchRequestIdentity({
    required this.appToken,
    required this.deviceId,
    this.deviceIdSource,
  });

  final String appToken;
  final String deviceId;
  final String? deviceIdSource;
}

AttriaxBatchRequestIdentity attriaxBatchRequestIdentity(
  AttriaxApiRequest request,
) {
  switch (request) {
    case AttriaxTrackEventRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        appToken: payload.appToken,
        deviceId: payload.deviceId!,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    case AttriaxTrackSessionRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        appToken: payload.appToken,
        deviceId: payload.deviceId!,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    case AttriaxUserRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        appToken: payload.appToken,
        deviceId: payload.deviceId,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    default:
      throw ArgumentError(
        'Unsupported Attriax batch request kind: ${request.kindName}',
      );
  }
}

bool attriaxCanShareBatchRequest(
  AttriaxApiRequest left,
  AttriaxApiRequest right,
) {
  if (!attriaxCanBatchRequest(left) || !attriaxCanBatchRequest(right)) {
    return false;
  }

  final leftIdentity = attriaxBatchRequestIdentity(left);
  final rightIdentity = attriaxBatchRequestIdentity(right);
  return leftIdentity.appToken == rightIdentity.appToken &&
      leftIdentity.deviceId == rightIdentity.deviceId &&
      leftIdentity.deviceIdSource == rightIdentity.deviceIdSource;
}

Map<String, Object?> attriaxBatchBody(AttriaxApiRequest request) {
  if (!attriaxCanBatchRequest(request)) {
    throw ArgumentError(
      'Unsupported Attriax batch request kind: ${request.kindName}',
    );
  }

  final body = Map<String, Object?>.from(request.toQueueBody())
    ..remove('appToken')
    ..remove('deviceId')
    ..remove('deviceIdSource');
  return body;
}

String attriaxBatchRequestId(String queuedRequestId) =>
    'batch_$queuedRequestId';

String attriaxBatchKindName(AttriaxApiRequest request) => switch (request) {
  AttriaxTrackEventRequest() => 'event',
  AttriaxTrackSessionRequest() => 'session',
  AttriaxUserRequest() => 'user',
  _ => throw ArgumentError(
    'Unsupported Attriax batch request kind: ${request.kindName}',
  ),
};

AttriaxApiRequest attriaxAnonymizeRequestForConsent(
  AttriaxApiRequest request,
) => switch (request) {
  AttriaxTrackEventRequest(:final payload) => AttriaxTrackEventRequest(
    sdk.SdkEventDto(
      appToken: payload.appToken,
      clientOccurredAt: payload.clientOccurredAt,
      eventData: payload.eventData,
      eventName: payload.eventName,
      sessionId: payload.sessionId,
      sessionRelativeTimeMs: payload.sessionRelativeTimeMs,
    ),
  ),
  AttriaxTrackCrashRequest(:final payload) => AttriaxTrackCrashRequest(
    AttriaxCrashReportPayload(
      appToken: payload.appToken,
      source: payload.source,
      clientOccurredAt: payload.clientOccurredAt,
      platform: payload.platform,
      isFatal: payload.isFatal,
      exceptionType: payload.exceptionType,
      message: payload.message,
      stackTrace: payload.stackTrace,
      isFirstLaunch: payload.isFirstLaunch,
      reason: payload.reason,
      sessionId: payload.sessionId,
      sessionRelativeTimeMs: payload.sessionRelativeTimeMs,
      locale: payload.locale,
      appVersion: payload.appVersion,
      appBuildNumber: payload.appBuildNumber,
      appPackageName: payload.appPackageName,
      sdkApiVersion: payload.sdkApiVersion,
      sdkPackageVersion: payload.sdkPackageVersion,
      metadata: payload.metadata,
    ),
  ),
  AttriaxTrackSessionRequest(:final payload) => AttriaxTrackSessionRequest(
    AttriaxSessionLifecyclePayload(
      appToken: payload.appToken,
      kind: payload.kind,
      sessionId: payload.sessionId,
      sessionRelativeTimeMs: payload.sessionRelativeTimeMs,
      clientOccurredAt: payload.clientOccurredAt,
      platform: payload.platform,
      locale: payload.locale,
      isFirstLaunch: payload.isFirstLaunch,
      appVersion: payload.appVersion,
      appBuildNumber: payload.appBuildNumber,
      appPackageName: payload.appPackageName,
      sdkApiVersion: payload.sdkApiVersion,
      sdkPackageVersion: payload.sdkPackageVersion,
      metadata: payload.metadata,
    ),
  ),
  AttriaxResolveDeepLinkRequest(:final payload) =>
    AttriaxResolveDeepLinkRequest(
      sdk.SdkV1DeepLinkResolveDto(
        appToken: payload.appToken,
        isFirstLaunch: payload.isFirstLaunch,
        linkPath: payload.linkPath,
        metadata: payload.metadata,
        platform: payload.platform,
        rawUrl: payload.rawUrl,
        source_: payload.source_,
      ),
    ),
  _ => request,
};

AttriaxApiRequest? attriaxIdentifyRequestForConsentNotRequired(
  AttriaxApiRequest request, {
  required String deviceId,
  required String deviceIdSource,
}) => switch (request) {
  AttriaxTrackEventRequest(:final payload) when payload.deviceId == null =>
    AttriaxTrackEventRequest(
      sdk.SdkEventDto(
        appToken: payload.appToken,
        clientOccurredAt: payload.clientOccurredAt,
        deviceId: deviceId,
        deviceIdSource: deviceIdSource,
        eventData: payload.eventData,
        eventName: payload.eventName,
        sessionId: payload.sessionId,
        sessionRelativeTimeMs: payload.sessionRelativeTimeMs,
      ),
    ),
  AttriaxTrackCrashRequest(:final payload) when payload.deviceId == null =>
    AttriaxTrackCrashRequest(
      AttriaxCrashReportPayload(
        appToken: payload.appToken,
        deviceId: deviceId,
        deviceIdSource: deviceIdSource,
        source: payload.source,
        clientOccurredAt: payload.clientOccurredAt,
        platform: payload.platform,
        isFatal: payload.isFatal,
        exceptionType: payload.exceptionType,
        message: payload.message,
        stackTrace: payload.stackTrace,
        isFirstLaunch: payload.isFirstLaunch,
        reason: payload.reason,
        sessionId: payload.sessionId,
        sessionRelativeTimeMs: payload.sessionRelativeTimeMs,
        locale: payload.locale,
        appVersion: payload.appVersion,
        appBuildNumber: payload.appBuildNumber,
        appPackageName: payload.appPackageName,
        sdkApiVersion: payload.sdkApiVersion,
        sdkPackageVersion: payload.sdkPackageVersion,
        metadata: payload.metadata,
      ),
    ),
  AttriaxTrackSessionRequest(:final payload) when payload.deviceId == null =>
    AttriaxTrackSessionRequest(
      AttriaxSessionLifecyclePayload(
        appToken: payload.appToken,
        deviceId: deviceId,
        deviceIdSource: deviceIdSource,
        kind: payload.kind,
        sessionId: payload.sessionId,
        sessionRelativeTimeMs: payload.sessionRelativeTimeMs,
        clientOccurredAt: payload.clientOccurredAt,
        platform: payload.platform,
        locale: payload.locale,
        isFirstLaunch: payload.isFirstLaunch,
        appVersion: payload.appVersion,
        appBuildNumber: payload.appBuildNumber,
        appPackageName: payload.appPackageName,
        sdkApiVersion: payload.sdkApiVersion,
        sdkPackageVersion: payload.sdkPackageVersion,
        metadata: payload.metadata,
      ),
    ),
  AttriaxResolveDeepLinkRequest(:final payload) when payload.deviceId == null =>
    AttriaxResolveDeepLinkRequest(
      sdk.SdkV1DeepLinkResolveDto(
        appToken: payload.appToken,
        deviceId: deviceId,
        deviceIdSource: deviceIdSource,
        isFirstLaunch: payload.isFirstLaunch,
        linkPath: payload.linkPath,
        metadata: payload.metadata,
        platform: payload.platform,
        rawUrl: payload.rawUrl,
        source_: payload.source_,
      ),
    ),
  _ => null,
};

AttriaxApiRequest attriaxApiRequestFromJson(
  String kindName,
  Map<String, Object?> body,
) {
  switch (kindName) {
    case 'open':
      return AttriaxOpenRequest(
        _parseGeneratedPayload(body, sdk.SdkV1OpenDto.fromJson),
      );
    case 'trackEvent':
      return AttriaxTrackEventRequest(
        _parseGeneratedPayload(body, sdk.SdkEventDto.fromJson),
      );
    case 'trackCrash':
      return AttriaxTrackCrashRequest(AttriaxCrashReportPayload.fromJson(body));
    case 'trackSession':
      return AttriaxTrackSessionRequest(
        AttriaxSessionLifecyclePayload.fromJson(body),
      );
    case 'user':
    case 'identify':
      return AttriaxUserRequest(
        _parseGeneratedPayload(body, sdk.SdkUserDto.fromJson),
      );
    case 'resolveDeepLink':
      return AttriaxResolveDeepLinkRequest(
        _parseGeneratedPayload(body, sdk.SdkV1DeepLinkResolveDto.fromJson),
      );
    case 'createDynamicLink':
      return AttriaxCreateDynamicLinkRequest(
        _parseGeneratedPayload(body, sdk.SdkCreateDynamicLinkDto.fromJson),
      );
    case 'registerUninstallToken':
      return AttriaxRegisterUninstallTokenRequest(body);
  }

  throw FormatException('Unsupported Attriax request kind: $kindName');
}

AttriaxOpenRequest attriaxBuildOpenRequest({
  required AttriaxConfig config,
  required AttriaxContextSnapshot context,
  required String deviceIdSource,
  AttriaxInstallReferrerContext? platformInstallReferrerContext,
  String? sessionId,
  DateTime? sessionStartedAt,
}) {
  final installReferrerMetadata =
      platformInstallReferrerContext?.metadata ?? const <String, Object?>{};
  final requestDto = sdk.SdkV1OpenDto(
    app: _generatedAppVersionContext(context.app),
    appToken: config.appToken,
    device: _generatedDeviceContext(context.device),
    deviceId: context.deviceId,
    deviceIdSource: deviceIdSource,
    googlePlayInstantParam: attriaxBoolValue(
      installReferrerMetadata['googlePlayInstantParam'],
    ),
    installBeginTimestampSeconds: _attriaxIntValue(
      installReferrerMetadata['installBeginTimestampSeconds'],
    ),
    installReferrer: attriaxStringValue(
      platformInstallReferrerContext?.installReferrer,
    ),
    isFirstLaunch: context.isFirstLaunch,
    platform: _generatedPlatform(context.platform),
    referrerClickTimestampSeconds: _attriaxIntValue(
      installReferrerMetadata['referrerClickTimestampSeconds'],
    ),
    sdk: _generatedSdkVersionContext(context.sdk),
    sessionId: attriaxStringValue(sessionId),
    sessionStartedAt: sessionStartedAt?.toUtc(),
  );

  return AttriaxOpenRequest(requestDto);
}

AttriaxInstallReferrerDetails? attriaxBuildLocalInstallReferrerDetails(
  AttriaxInstallReferrerContext context,
) {
  final rawReferrer = attriaxStringValue(context.installReferrer);
  if (rawReferrer == null || rawReferrer.isEmpty) {
    return null;
  }

  final query = Uri.splitQueryString(rawReferrer);
  String? firstValue(List<String> keys) {
    for (final key in keys) {
      final value = attriaxStringValue(query[key]);
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  final deepLinkUrl = firstValue(const <String>[
    'deep_link_uri',
    'deep_link_url',
    'deep_link',
    'af_dp',
  ]);

  return AttriaxInstallReferrerDetails(
    rawPlatformInstallReferrer: rawReferrer,
    source: firstValue(const <String>['utm_source', 'source']),
    medium: firstValue(const <String>['utm_medium', 'medium']),
    campaign: firstValue(const <String>['utm_campaign', 'campaign']),
    term: firstValue(const <String>['utm_term', 'term']),
    content: firstValue(const <String>['utm_content', 'content']),
    adClickId: firstValue(const <String>[
      'gclid',
      'gbraid',
      'wbraid',
      'fbclid',
    ]),
    attributionType: AttributionType.referrer,
    deepLinkUrl: deepLinkUrl,
    deepLinkUri: deepLinkUrl == null ? null : Uri.tryParse(deepLinkUrl),
    installBeginTimestampSeconds: _attriaxIntValue(
      context.metadata['installBeginTimestampSeconds'],
    ),
    referrerClickTimestampSeconds: _attriaxIntValue(
      context.metadata['referrerClickTimestampSeconds'],
    ),
    googlePlayInstantParam: attriaxBoolValue(
      context.metadata['googlePlayInstantParam'],
    ),
    precision: 0.5,
  );
}

AttriaxTrackEventRequest attriaxBuildTrackEventRequest({
  required String appToken,
  required String eventName,
  String? deviceId,
  String? deviceIdSource,
  Map<String, Object?>? eventData,
  String? sessionId,
  int? sessionRelativeTimeMs,
  DateTime? clientOccurredAt,
}) {
  final requestDto = sdk.SdkEventDto(
    appToken: appToken,
    clientOccurredAt: clientOccurredAt?.toUtc(),
    deviceId: deviceId,
    deviceIdSource: deviceIdSource,
    eventData: _generatedOptionalJsonObjectMap(eventData),
    eventName: eventName,
    sessionId: attriaxStringValue(sessionId),
    sessionRelativeTimeMs: sessionRelativeTimeMs,
  );

  return AttriaxTrackEventRequest(requestDto);
}

AttriaxTrackCrashRequest attriaxBuildTrackCrashRequest({
  required String appToken,
  required AttriaxContextSnapshot context,
  required String source,
  required bool isFatal,
  required String exceptionType,
  required String message,
  required String stackTrace,
  String? deviceId,
  String? deviceIdSource,
  AttriaxSessionSnapshot? session,
  DateTime? clientOccurredAt,
  String? reason,
  Map<String, Object?>? metadata,
}) {
  final occurredAt = clientOccurredAt?.toUtc() ?? DateTime.now().toUtc();
  final sessionRelativeTimeMs = session == null
      ? null
      : occurredAt
            .difference(session.startedAt)
            .inMilliseconds
            .clamp(0, 0x7fffffff);

  return AttriaxTrackCrashRequest(
    AttriaxCrashReportPayload(
      appToken: appToken,
      deviceId: deviceId,
      deviceIdSource: deviceIdSource,
      source: source,
      clientOccurredAt: occurredAt,
      platform: context.platform,
      isFatal: isFatal,
      exceptionType: exceptionType,
      message: message,
      stackTrace: stackTrace,
      isFirstLaunch: context.isFirstLaunch,
      reason: attriaxStringValue(reason),
      sessionId: session?.id,
      sessionRelativeTimeMs: sessionRelativeTimeMs,
      locale: session?.locale ?? context.device.language,
      appVersion: context.app.version,
      appBuildNumber: context.app.buildNumber,
      appPackageName: context.app.packageName,
      sdkApiVersion: context.sdk.apiVersion,
      sdkPackageVersion: context.sdk.packageVersion,
      metadata: metadata,
    ),
  );
}

AttriaxTrackSessionRequest attriaxBuildTrackSessionRequest({
  required String appToken,
  required AttriaxSessionSnapshot session,
  required AttriaxSessionLifecycleKind kind,
  String? deviceIdSource,
  bool attachDeviceIdentity = true,
  DateTime? occurredAt,
  Map<String, Object?>? metadata,
}) {
  final clientOccurredAt = (occurredAt ?? session.lastActivityAt).toUtc();
  final sessionRelativeTimeMs = clientOccurredAt
      .difference(session.startedAt)
      .inMilliseconds
      .clamp(0, 0x7fffffff);

  return AttriaxTrackSessionRequest(
    AttriaxSessionLifecyclePayload(
      appToken: appToken,
      deviceId: attachDeviceIdentity ? session.deviceId : null,
      deviceIdSource: attachDeviceIdentity ? deviceIdSource : null,
      kind: kind,
      sessionId: session.id,
      sessionRelativeTimeMs: sessionRelativeTimeMs,
      clientOccurredAt: clientOccurredAt,
      platform: session.platform,
      locale: session.locale,
      isFirstLaunch: session.isFirstLaunch,
      appVersion: session.appVersion,
      appBuildNumber: session.appBuildNumber,
      appPackageName: session.appPackageName,
      sdkApiVersion: attriaxSdkApiVersion,
      sdkPackageVersion: session.sdkPackageVersion,
      metadata: metadata,
    ),
  );
}

sdk.SdkSessionDto attriaxGeneratedTrackSessionDto(
  AttriaxSessionLifecyclePayload payload,
) => sdk.SdkSessionDto(
  appToken: payload.appToken,
  deviceId: payload.deviceId,
  deviceIdSource: attriaxStringValue(payload.deviceIdSource),
  kind: _generatedSessionLifecycleKind(payload.kind),
  sessionId: payload.sessionId,
  sessionRelativeTimeMs: payload.sessionRelativeTimeMs,
  clientOccurredAt: payload.clientOccurredAt.toUtc(),
  platform: _generatedPlatform(payload.platform),
  locale: attriaxStringValue(payload.locale),
  isFirstLaunch: payload.isFirstLaunch,
  appVersion: attriaxStringValue(payload.appVersion),
  appBuildNumber: attriaxStringValue(payload.appBuildNumber),
  appPackageName: attriaxStringValue(payload.appPackageName),
  sdkApiVersion: attriaxStringValue(payload.sdkApiVersion),
  sdkPackageVersion: attriaxStringValue(payload.sdkPackageVersion),
  metadata: _generatedOptionalJsonObjectMap(payload.metadata),
);

sdk.SdkBatchItemKind attriaxGeneratedBatchItemKind(AttriaxApiRequest request) =>
    switch (request) {
      AttriaxTrackEventRequest() => sdk.SdkBatchItemKind.event,
      AttriaxTrackSessionRequest() => sdk.SdkBatchItemKind.session,
      AttriaxUserRequest() => sdk.SdkBatchItemKind.user,
      _ => throw ArgumentError(
        'Unsupported Attriax batch request kind: ${request.kindName}',
      ),
    };

Map<String, Object> attriaxGeneratedJsonObjectMap(Map<String, Object?> value) =>
    Map<String, Object>.from(_generatedJsonMap(value));

AttriaxUserRequest attriaxBuildUserRequest({
  required String appToken,
  required String deviceId,
  required String deviceIdSource,
  String? externalUserId,
  String? externalUserName,
  bool clearExternalUser = false,
  Map<String, Object?>? properties,
  List<String>? clearPropertyKeys,
  bool clearAllProperties = false,
}) {
  final normalizedClearPropertyKeys = clearPropertyKeys
      ?.map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  final requestDto = sdk.SdkUserDto(
    appToken: appToken,
    clearAllProperties: clearAllProperties ? true : null,
    clearExternalUser: clearExternalUser ? true : null,
    clearPropertyKeys:
        normalizedClearPropertyKeys == null ||
            normalizedClearPropertyKeys.isEmpty
        ? null
        : normalizedClearPropertyKeys,
    deviceId: deviceId,
    deviceIdSource: deviceIdSource,
    externalUserId: attriaxStringValue(externalUserId),
    externalUserName: attriaxStringValue(externalUserName),
    properties: _generatedOptionalJsonObjectMap(properties),
  );

  return AttriaxUserRequest(requestDto);
}

AttriaxResolveDeepLinkRequest attriaxBuildResolveDeepLinkRequest({
  required String appToken,
  required AttriaxPlatformType platform,
  required String source,
  required bool isFirstLaunch,
  String? deviceId,
  String? deviceIdSource,
  String? rawUrl,
  String? linkPath,
  Map<String, Object?>? metadata,
}) {
  final requestDto = sdk.SdkV1DeepLinkResolveDto(
    appToken: appToken,
    deviceId: deviceId,
    deviceIdSource: deviceIdSource,
    isFirstLaunch: isFirstLaunch,
    linkPath: attriaxStringValue(linkPath),
    metadata: _generatedOptionalJsonObjectMap(metadata),
    platform: _generatedPlatform(platform),
    rawUrl: attriaxStringValue(rawUrl),
    source_: source,
  );

  return AttriaxResolveDeepLinkRequest(requestDto);
}

AttriaxCreateDynamicLinkRequest attriaxBuildCreateDynamicLinkRequest({
  required String appToken,
  String? name,
  String? destinationUrl,
  String? group,
  String? prefix,
  AttriaxDynamicLinkRedirects? redirects,
  AttriaxDynamicLinkSocialPreview? socialPreview,
  AttriaxDynamicLinkUtms? utms,
  Map<String, Object?>? data,
}) {
  final requestDto = sdk.SdkCreateDynamicLinkDto(
    androidRedirect: redirects?.android,
    appToken: appToken,
    data: _generatedOptionalJsonObjectMap(data),
    destinationUrl: attriaxStringValue(destinationUrl),
    group: attriaxStringValue(group),
    iosRedirect: redirects?.ios,
    name: attriaxStringValue(name),
    prefix: attriaxStringValue(prefix),
    previewDescription: attriaxStringValue(socialPreview?.description),
    previewImagePath: attriaxStringValue(socialPreview?.imagePath),
    previewTitle: attriaxStringValue(socialPreview?.title),
    utmCampaign: attriaxStringValue(utms?.campaign),
    utmContent: attriaxStringValue(utms?.content),
    utmMedium: attriaxStringValue(utms?.medium),
    utmSource: attriaxStringValue(utms?.source),
    utmTerm: attriaxStringValue(utms?.term),
  );

  return AttriaxCreateDynamicLinkRequest(requestDto);
}

Map<String, Object?> attriaxBuildValidateRevenueReceiptRequest({
  required String appToken,
  required String deviceId,
  required DateTime clientOccurredAt,
  String? provider,
  String? environment,
  String? transactionId,
  String? originalTransactionId,
  String? productId,
  String? store,
  String? packageName,
  String? purchaseToken,
  String? receiptData,
  String? signedPayload,
  String? receiptSignature,
  bool? test,
}) => <String, Object?>{
  'appToken': appToken,
  'deviceId': deviceId,
  'clientOccurredAt': clientOccurredAt.toUtc().toIso8601String(),
  'provider': ?attriaxStringValue(provider),
  'environment': ?attriaxStringValue(environment),
  'transactionId': ?attriaxStringValue(transactionId),
  'originalTransactionId': ?attriaxStringValue(originalTransactionId),
  'productId': ?attriaxStringValue(productId),
  'store': ?attriaxStringValue(store),
  'packageName': ?attriaxStringValue(packageName),
  'purchaseToken': ?attriaxStringValue(purchaseToken),
  'receiptData': ?attriaxStringValue(receiptData),
  'signedPayload': ?attriaxStringValue(signedPayload),
  'receiptSignature': ?attriaxStringValue(receiptSignature),
  'test': ?test,
};

Map<String, Object?> attriaxBuildRegisterUninstallTokenRequest({
  required String appToken,
  required String deviceId,
  required String deviceIdSource,
  required AttriaxPlatformType platform,
  required String provider,
  String? token,
  Map<String, Object?>? metadata,
}) => <String, Object?>{
  'appToken': appToken,
  'deviceId': deviceId,
  'deviceIdSource': deviceIdSource,
  'platform': _uninstallTrackingPlatformName(platform),
  'provider': provider,
  'token': ?attriaxStringValue(token),
  'metadata': ?metadata,
};

AttriaxRegisterUninstallTokenRequest
attriaxBuildRegisterUninstallTokenQueueRequest({
  required String appToken,
  required String deviceId,
  required String deviceIdSource,
  required AttriaxPlatformType platform,
  required String provider,
  String? token,
  Map<String, Object?>? metadata,
}) => AttriaxRegisterUninstallTokenRequest(
  attriaxBuildRegisterUninstallTokenRequest(
    appToken: appToken,
    deviceId: deviceId,
    deviceIdSource: deviceIdSource,
    platform: platform,
    provider: provider,
    token: token,
    metadata: metadata,
  ),
);

String _uninstallTrackingPlatformName(AttriaxPlatformType platform) =>
    switch (platform) {
      AttriaxPlatformType.android => 'android',
      AttriaxPlatformType.ios => 'ios',
      _ => throw UnsupportedError(
        'Uninstall token registration is only supported on Android and iOS.',
      ),
    };

abstract class AttriaxApiResponse {
  const AttriaxApiResponse();
}

class AttriaxAckResponse extends AttriaxApiResponse {
  const AttriaxAckResponse({required this.success});

  final bool success;
}

class AttriaxOpenApiResponse extends AttriaxApiResponse {
  const AttriaxOpenApiResponse({required this.result});

  final AttriaxAppOpenResult result;
}

class AttriaxResolveDeepLinkApiResponse extends AttriaxApiResponse {
  const AttriaxResolveDeepLinkApiResponse({required this.result});

  final AttriaxDeepLinkResolutionResult result;
}

class AttriaxCreateDynamicLinkApiResponse extends AttriaxApiResponse {
  const AttriaxCreateDynamicLinkApiResponse({required this.result});

  final AttriaxCreateDynamicLinkResult result;
}

class AttriaxRevenueReceiptValidationApiResponse extends AttriaxApiResponse {
  const AttriaxRevenueReceiptValidationApiResponse({required this.result});

  final AttriaxRevenueReceiptValidationResult result;
}

class AttriaxRevenueUsdConversionResult {
  const AttriaxRevenueUsdConversionResult({
    required this.requestVersion,
    required this.acceptedAt,
    required this.currency,
    required this.amountOriginalMicros,
    required this.amountUsdMicros,
    required this.amountUsd,
    required this.rate,
    required this.rateDate,
    required this.conversionStatus,
  });

  factory AttriaxRevenueUsdConversionResult.fromJson(
    Map<String, Object?> json,
  ) => AttriaxRevenueUsdConversionResult(
    requestVersion: attriaxStringValue(json['requestVersion']) ?? 'v1',
    acceptedAt:
        attriaxDateTimeValue(json['acceptedAt'])?.toUtc() ??
        DateTime.now().toUtc(),
    currency: attriaxStringValue(json['currency']) ?? 'USD',
    amountOriginalMicros:
        attriaxStringValue(json['amountOriginalMicros']) ?? '0',
    amountUsdMicros: attriaxStringValue(json['amountUsdMicros']) ?? '0',
    amountUsd: _attriaxDoubleValue(json['amountUsd']) ?? 0,
    rate: attriaxStringValue(json['rate']) ?? '1',
    rateDate: attriaxStringValue(json['rateDate']) ?? '',
    conversionStatus: attriaxStringValue(json['conversionStatus']) ?? 'usd',
  );

  final String requestVersion;
  final DateTime acceptedAt;
  final String currency;
  final String amountOriginalMicros;
  final String amountUsdMicros;
  final double amountUsd;
  final String rate;
  final String rateDate;
  final String conversionStatus;
}

class AttriaxRevenueUsdConversionApiResponse extends AttriaxApiResponse {
  const AttriaxRevenueUsdConversionApiResponse({required this.result});

  final AttriaxRevenueUsdConversionResult result;
}

AttriaxAckResponse attriaxAckResponseFromGenerated(
  sdk.SdkAcknowledgeResponseEnvelopeDto envelope,
) => AttriaxAckResponse(success: envelope.data.success);

AttriaxAckResponse attriaxAckResponseFromJsonEnvelope(
  Map<String, Object?> envelope,
) {
  final data = attriaxObjectMap(envelope['data']);
  return AttriaxAckResponse(
    success:
        attriaxBoolValue(data?['success']) ??
        attriaxBoolValue(envelope['success']) ??
        false,
  );
}

AttriaxOpenApiResponse attriaxOpenResponseFromGenerated(
  sdk.SdkV1OpenResponseEnvelopeDto envelope,
) => AttriaxOpenApiResponse(result: _mapOpenResult(envelope.data));

AttriaxOpenApiResponse attriaxOpenResponseFromJsonEnvelope(
  Map<String, Object?> envelope,
) {
  final data = attriaxObjectMap(envelope['data']);
  if (data == null) {
    throw const FormatException('Missing or invalid "data".');
  }

  return AttriaxOpenApiResponse(result: AttriaxAppOpenResult.fromJson(data));
}

AttriaxResolveDeepLinkApiResponse attriaxResolveDeepLinkResponseFromGenerated(
  sdk.SdkV1DeepLinkResolveResponseEnvelopeDto envelope,
) => AttriaxResolveDeepLinkApiResponse(
  result: _mapDeepLinkResolutionResult(envelope.data),
);

AttriaxCreateDynamicLinkApiResponse
attriaxCreateDynamicLinkResponseFromGenerated(
  sdk.SdkCreateDynamicLinkResponseEnvelopeDto envelope,
) => AttriaxCreateDynamicLinkApiResponse(
  result: _mapCreateDynamicLinkResult(envelope.data),
);

AttriaxRevenueReceiptValidationApiResponse
attriaxRevenueReceiptValidationResponseFromJsonEnvelope(
  Map<String, Object?> envelope,
) {
  final data = attriaxObjectMap(envelope['data']);
  if (data == null) {
    throw const FormatException('Missing or invalid "data".');
  }

  return AttriaxRevenueReceiptValidationApiResponse(
    result: AttriaxRevenueReceiptValidationResult.fromJson(data),
  );
}

AttriaxRevenueUsdConversionApiResponse
attriaxRevenueUsdConversionResponseFromJsonEnvelope(
  Map<String, Object?> envelope,
) {
  final data = attriaxObjectMap(envelope['data']);
  if (data == null) {
    throw const FormatException('Missing or invalid "data".');
  }

  return AttriaxRevenueUsdConversionApiResponse(
    result: AttriaxRevenueUsdConversionResult.fromJson(data),
  );
}

sdk.Platform _generatedPlatform(AttriaxPlatformType platform) =>
    switch (platform) {
      AttriaxPlatformType.ios => sdk.Platform.ios,
      AttriaxPlatformType.android => sdk.Platform.android,
      AttriaxPlatformType.unknown => sdk.Platform.unknown,
      AttriaxPlatformType.web => sdk.Platform.web,
      AttriaxPlatformType.windows => sdk.Platform.windows,
      AttriaxPlatformType.macos => sdk.Platform.macos,
      AttriaxPlatformType.linux => sdk.Platform.linux,
    };

sdk.SdkSessionLifecycleKind _generatedSessionLifecycleKind(
  AttriaxSessionLifecycleKind kind,
) => switch (kind) {
  AttriaxSessionLifecycleKind.start => sdk.SdkSessionLifecycleKind.start,
  AttriaxSessionLifecycleKind.heartbeat =>
    sdk.SdkSessionLifecycleKind.heartbeat,
  AttriaxSessionLifecycleKind.pause => sdk.SdkSessionLifecycleKind.pause,
  AttriaxSessionLifecycleKind.resume => sdk.SdkSessionLifecycleKind.resume,
  AttriaxSessionLifecycleKind.end => sdk.SdkSessionLifecycleKind.end,
};

AttriaxPlatformType _parseAttriaxPlatformType(String value) =>
    AttriaxPlatformType.values.firstWhere(
      (platform) => platform.name == value,
      orElse: () => AttriaxPlatformType.unknown,
    );

AttriaxSessionLifecycleKind _parseSessionLifecycleKind(String value) =>
    AttriaxSessionLifecycleKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => throw FormatException(
        'Unsupported Attriax session lifecycle kind: $value',
      ),
    );

int? _attriaxIntValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

double? _attriaxDoubleValue(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return null;
}

sdk.AppVersionContextDto _generatedAppVersionContext(AttriaxAppSnapshot app) =>
    sdk.AppVersionContextDto(
      buildNumber: attriaxStringValue(app.buildNumber),
      packageName: attriaxStringValue(app.packageName),
      version: attriaxStringValue(app.version),
    );

sdk.DeviceContextDto _generatedDeviceContext(AttriaxDeviceSnapshot device) =>
    sdk.DeviceContextDto(
      advertisingId: attriaxStringValue(device.advertisingId),
      androidId: attriaxStringValue(device.androidId),
      brand: attriaxStringValue(device.brand),
      colorDepth: device.colorDepth,
      devicePixelRatio: device.devicePixelRatio,
      hardware: attriaxStringValue(device.hardware),
      isPhysicalDevice: device.isPhysicalDevice,
      language: attriaxStringValue(device.language),
      manufacturer: attriaxStringValue(device.manufacturer),
      metadata: _generatedOptionalJsonObjectMap(device.metadata),
      model: attriaxStringValue(device.model),
      name: attriaxStringValue(device.name),
      osVersion: attriaxStringValue(device.osVersion),
      screenHeight: device.screenHeight,
      screenResolution: attriaxStringValue(device.screenResolution),
      screenWidth: device.screenWidth,
      supportedAbis: device.supportedAbis.isEmpty
          ? null
          : List<String>.from(device.supportedAbis),
      timezone: attriaxStringValue(device.timezone),
    );

sdk.SdkVersionContextDto _generatedSdkVersionContext(
  AttriaxSdkSnapshot sdkSnapshot,
) => sdk.SdkVersionContextDto(
  apiVersion: sdkSnapshot.apiVersion,
  metadata: _generatedOptionalJsonObjectMap(sdkSnapshot.metadata),
  packageVersion: sdkSnapshot.packageVersion,
);

AttriaxAppOpenResult _mapOpenResult(sdk.SdkV1OpenResponseDto response) =>
    AttriaxAppOpenResult(
      userId: response.userId,
      isNewUser: response.isNewUser,
      isFirstLaunch: response.isFirstLaunch,
      installState: _mapInstallState(response.installState),
      requestVersion: response.requestVersion,
      acceptedAt: response.acceptedAt,
      skan: response.skan == null
          ? null
          : AttriaxSkanRuntimeConfiguration.fromJson(
              attriaxObjectMap(response.skan) ?? const <String, Object?>{},
            ),
      deepLink: _mapDeepLink(response.deepLink),
      originalInstallReferrer: _mapInstallReferrerDetails(
        response.originalInstallReferrer,
      ),
      reinstallReferrer: _mapInstallReferrerDetails(response.reinstallReferrer),
      installReferrer: _mapInstallReferrerDetails(response.installReferrer),
    );

AttriaxDeepLinkResolutionResult _mapDeepLinkResolutionResult(
  sdk.SdkV1DeepLinkResolveResponseDto response,
) => AttriaxDeepLinkResolutionResult(
  matched: response.matched,
  status: _mapDeepLinkResolutionStatus(response.status),
  isFirstLaunch: response.isFirstLaunch,
  reason: response.reason,
  deepLink: _mapDeepLink(response.deepLink),
  browserAction: _mapBrowserAction(response.browserAction),
  requestVersion: response.requestVersion,
  acceptedAt: response.acceptedAt,
  consumedAt: response.consumedAt,
);

AttriaxCreateDynamicLinkResult _mapCreateDynamicLinkResult(
  sdk.SdkCreateDynamicLinkResponseDto response,
) => AttriaxCreateDynamicLinkResult(
  link: _mapDynamicLinkRecord(response.link),
  requestVersion: response.requestVersion,
  acceptedAt: response.acceptedAt,
);

AttriaxDeepLink? _mapDeepLink(sdk.SdkJsonDeepLinkDto? deepLink) =>
    deepLink == null
    ? null
    : AttriaxDeepLink(
        path: deepLink.path,
        uri: deepLink.uri == null ? null : Uri.tryParse(deepLink.uri!),
        data: _plainStringObjectMap(deepLink.data),
        utm: _mapUtmPayload(deepLink.utm),
      );

AttriaxResolvedUrlAction? _mapBrowserAction(
  sdk.SdkBrowserActionDto? browserAction,
) {
  if (browserAction == null) {
    return null;
  }

  final uri = Uri.tryParse(browserAction.url);
  if (uri == null) {
    return null;
  }

  return AttriaxResolvedUrlAction(
    uri: uri,
    openMode: _mapResolvedUrlOpenMode(browserAction.openMode),
  );
}

AttriaxResolvedUrlOpenMode _mapResolvedUrlOpenMode(
  sdk.RouteUrlOpenMode openMode,
) => switch (openMode) {
  sdk.RouteUrlOpenMode.inApp => AttriaxResolvedUrlOpenMode.inApp,
  sdk.RouteUrlOpenMode.external_ => AttriaxResolvedUrlOpenMode.external,
};

AttriaxInstallReferrerDetails? _mapInstallReferrerDetails(
  sdk.SdkInstallReferrerResultDto? details,
) => details == null
    ? null
    : AttriaxInstallReferrerDetails(
        rawPlatformInstallReferrer: details.rawPlatformInstallReferrer,
        source: details.source_,
        medium: details.medium,
        campaign: details.campaign,
        term: details.term,
        content: details.content,
        adNetwork: details.adNetwork,
        adClickId: details.adClickId,
        attributionType: _mapAttributionType(details.attributionType),
        deepLinkUri: Uri.tryParse(
          details.deepLinkUri ?? details.deepLinkUrl ?? '',
        ),
        deepLinkUrl: details.deepLinkUrl,
        deepLinkData: _plainStringMap(details.deepLinkData),
        registeredAt: details.registeredAt,
        installBeginTimestampSeconds: details.installBeginTimestampSeconds
            ?.toInt(),
        referrerClickTimestampSeconds: details.referrerClickTimestampSeconds
            ?.toInt(),
        googlePlayInstantParam: details.googlePlayInstantParam,
        precision: details.precision.toDouble(),
      );

AttriaxUtmParameters? _mapUtmPayload(sdk.SdkUtmPayloadDto? utm) {
  if (utm == null) {
    return null;
  }

  final mapped = AttriaxUtmParameters(
    source: utm.source_,
    medium: utm.medium,
    campaign: utm.campaign,
    term: utm.term,
    content: utm.content,
  );
  return mapped.isEmpty ? null : mapped;
}

AttriaxInstallState _mapInstallState(sdk.SdkInstallState installState) =>
    switch (installState) {
      sdk.SdkInstallState.newInstall => AttriaxInstallState.newInstall,
      sdk.SdkInstallState.reinstall => AttriaxInstallState.reinstall,
      sdk.SdkInstallState.appDataClear => AttriaxInstallState.appDataClear,
      sdk.SdkInstallState.existing => AttriaxInstallState.existing,
    };

AttriaxDynamicLinkRecord _mapDynamicLinkRecord(
  sdk.SdkDynamicLinkRecordDto link,
) => AttriaxDynamicLinkRecord(
  id: link.id,
  path: link.path,
  shortUrl: link.shortUrl,
  name: link.name,
  destinationUrl: link.destinationUrl,
  group: link.group,
  prefix: link.prefix,
  data: _plainJsonObjectMap(link.data),
  previewTitle: link.previewTitle,
  previewDescription: link.previewDescription,
  previewImagePath: link.previewImagePath,
  iosRedirect: link.iosRedirect,
  androidRedirect: link.androidRedirect,
  utmSource: link.utmSource,
  utmMedium: link.utmMedium,
  utmCampaign: link.utmCampaign,
  utmTerm: link.utmTerm,
  utmContent: link.utmContent,
  createdAt: link.createdAt,
);

AttriaxDeepLinkResolutionStatus _mapDeepLinkResolutionStatus(
  sdk.DeepLinkResolutionStatus status,
) => switch (status) {
  sdk.DeepLinkResolutionStatus.matched =>
    AttriaxDeepLinkResolutionStatus.matched,
  sdk.DeepLinkResolutionStatus.unmatched =>
    AttriaxDeepLinkResolutionStatus.unmatched,
  sdk.DeepLinkResolutionStatus.invalid =>
    AttriaxDeepLinkResolutionStatus.invalid,
};

AttributionType _mapAttributionType(sdk.AttributionType attributionType) =>
    switch (attributionType) {
      sdk.AttributionType.referrer => AttributionType.referrer,
      sdk.AttributionType.fingerprint => AttributionType.fingerprint,
      sdk.AttributionType.external_ => AttributionType.external,
      sdk.AttributionType.organic => AttributionType.organic,
    };

Map<String, Object>? _generatedOptionalJsonObjectMap(
  Map<String, Object?>? value,
) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final result = <String, Object>{};
  for (final entry in value.entries) {
    final generatedValue = _generatedJsonValue(entry.value);
    if (identical(generatedValue, _generatedJsonOmittedValue)) {
      continue;
    }
    result[entry.key] = generatedValue;
  }

  if (result.isEmpty) {
    return null;
  }

  return result;
}

const Object _generatedJsonOmittedValue = Object();

Map<String, dynamic> _generatedJsonMap(Map<String, Object?> value) =>
    Map<String, dynamic>.from(
      _generatedOptionalJsonObjectMap(value) ?? const <String, Object>{},
    );

Object _generatedJsonValue(Object? value) {
  if (value == null) {
    return _generatedJsonOmittedValue;
  }

  if (value is String || value is num || value is bool) {
    return value;
  }

  if (value is List) {
    return value
        .map(_generatedJsonValue)
        .where((item) => !identical(item, _generatedJsonOmittedValue))
        .toList(growable: false);
  }

  if (value is Map) {
    final result = <String, Object>{};
    for (final entry in value.entries) {
      final generatedValue = _generatedJsonValue(entry.value);
      if (identical(generatedValue, _generatedJsonOmittedValue)) {
        continue;
      }
      result[entry.key.toString()] = generatedValue;
    }
    return result;
  }

  return value.toString();
}

Map<String, Object?>? _plainJsonObjectMap(Map<String, Object>? value) =>
    attriaxObjectMap(value);

Map<String, String>? _plainStringMap(Map<String, String>? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return Map<String, String>.from(value);
}

Map<String, Object?>? _plainStringObjectMap(Map<String, String>? value) {
  final plain = _plainStringMap(value);
  if (plain == null || plain.isEmpty) {
    return null;
  }

  return Map<String, Object?>.from(plain);
}

Map<String, Object?> _generatedQueueBody(Object payload) {
  final dynamic serializable = payload;
  return attriaxObjectMapOrEmpty(serializable.toJson());
}

T _parseGeneratedPayload<T>(
  Map<String, Object?> body,
  T Function(Map<String, dynamic>) fromJson,
) => fromJson(_generatedJsonMap(body));
