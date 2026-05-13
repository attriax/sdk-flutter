import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:attriax_api_client/attriax_api_client.dart' as sdk;
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';

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
  Map<String, Object?> toQueueBody() =>
      _serializeGenerated(sdk.SdkV1OpenDto.serializer, payload);
}

final class AttriaxTrackEventRequest extends AttriaxApiRequest {
  const AttriaxTrackEventRequest(this.payload);

  final sdk.SdkEventDto payload;

  @override
  String get kindName => 'trackEvent';

  @override
  String get label => 'event';

  @override
  Map<String, Object?> toQueueBody() =>
      _serializeGenerated(sdk.SdkEventDto.serializer, payload);
}

final class AttriaxCrashReportPayload {
  const AttriaxCrashReportPayload({
    required this.appToken,
    required this.deviceId,
    required this.deviceIdSource,
    required this.source,
    required this.clientOccurredAt,
    required this.platform,
    required this.isFatal,
    required this.exceptionType,
    required this.message,
    required this.stackTrace,
    required this.isFirstLaunch,
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
        deviceId: attriaxRequireString(json, 'deviceId'),
        deviceIdSource: attriaxRequireString(json, 'deviceIdSource'),
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
  final String deviceId;
  final String deviceIdSource;
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
    'deviceId': deviceId,
    'deviceIdSource': deviceIdSource,
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
    required this.deviceId,
    required this.kind,
    required this.sessionId,
    required this.clientOccurredAt,
    required this.platform,
    required this.isFirstLaunch,
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
        deviceId: attriaxRequireString(json, 'deviceId'),
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
  final String deviceId;
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
    'deviceId': deviceId,
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
  Map<String, Object?> toQueueBody() =>
      _serializeGenerated(sdk.SdkUserDto.serializer, payload);
}

final class AttriaxResolveDeepLinkRequest extends AttriaxApiRequest {
  const AttriaxResolveDeepLinkRequest(this.payload);

  final sdk.SdkV1DeepLinkResolveDto payload;

  @override
  String get kindName => 'resolveDeepLink';

  @override
  String get label => 'deep-link resolution';

  @override
  Map<String, Object?> toQueueBody() =>
      _serializeGenerated(sdk.SdkV1DeepLinkResolveDto.serializer, payload);
}

final class AttriaxCreateDynamicLinkRequest extends AttriaxApiRequest {
  const AttriaxCreateDynamicLinkRequest(this.payload);

  final sdk.SdkCreateDynamicLinkDto payload;

  @override
  String get kindName => 'createDynamicLink';

  @override
  String get label => 'dynamic-link creation';

  @override
  Map<String, Object?> toQueueBody() =>
      _serializeGenerated(sdk.SdkCreateDynamicLinkDto.serializer, payload);
}

String attriaxApiRequestLabel(AttriaxApiRequest request) => request.label;

bool attriaxCanBatchRequest(AttriaxApiRequest request) => switch (request) {
  AttriaxTrackEventRequest() => true,
  AttriaxTrackSessionRequest() => true,
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
        deviceId: payload.deviceId,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    case AttriaxTrackSessionRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        appToken: payload.appToken,
        deviceId: payload.deviceId,
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

  final body = Map<String, Object?>.from(request.toQueueBody());
  body.remove('appToken');
  body.remove('deviceId');
  body.remove('deviceIdSource');
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

AttriaxApiRequest attriaxApiRequestFromJson(
  String kindName,
  Map<String, Object?> body,
) {
  switch (kindName) {
    case 'open':
      return AttriaxOpenRequest(
        _deserializeGenerated(sdk.SdkV1OpenDto.serializer, body),
      );
    case 'trackEvent':
      return AttriaxTrackEventRequest(
        _deserializeGenerated(sdk.SdkEventDto.serializer, body),
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
        _deserializeGenerated(sdk.SdkUserDto.serializer, body),
      );
    case 'resolveDeepLink':
      return AttriaxResolveDeepLinkRequest(
        _deserializeGenerated(sdk.SdkV1DeepLinkResolveDto.serializer, body),
      );
    case 'createDynamicLink':
      return AttriaxCreateDynamicLinkRequest(
        _deserializeGenerated(sdk.SdkCreateDynamicLinkDto.serializer, body),
      );
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
    (builder) => builder
      ..app.replace(_generatedAppVersionContext(context.app))
      ..appToken = config.appToken
      ..device.replace(_generatedDeviceContext(context.device))
      ..deviceId = context.deviceId
      ..deviceIdSource = deviceIdSource
      ..googlePlayInstantParam = attriaxBoolValue(
        installReferrerMetadata['googlePlayInstantParam'],
      )
      ..installBeginTimestampSeconds = _attriaxIntValue(
        installReferrerMetadata['installBeginTimestampSeconds'],
      )
      ..installReferrer = attriaxStringValue(
        platformInstallReferrerContext?.installReferrer,
      )
      ..isFirstLaunch = context.isFirstLaunch
      ..platform = _generatedPlatform(context.platform)
      ..referrerClickTimestampSeconds = _attriaxIntValue(
        installReferrerMetadata['referrerClickTimestampSeconds'],
      )
      ..sessionId = attriaxStringValue(sessionId)
      ..sessionStartedAt = sessionStartedAt?.toUtc()
      ..sdk.replace(_generatedSdkVersionContext(context.sdk)),
  );

  return AttriaxOpenRequest(requestDto);
}

AttriaxTrackEventRequest attriaxBuildTrackEventRequest({
  required String appToken,
  required String deviceId,
  required String deviceIdSource,
  required String eventName,
  Map<String, Object?>? eventData,
  String? sessionId,
  int? sessionRelativeTimeMs,
  DateTime? clientOccurredAt,
}) {
  final requestDto = sdk.SdkEventDto(
    (builder) => builder
      ..appToken = appToken
      ..clientOccurredAt = clientOccurredAt?.toUtc()
      ..deviceId = deviceId
      ..deviceIdSource = deviceIdSource
      ..eventName = eventName
      ..eventData = _generatedJsonObjectMap(eventData)?.toBuilder()
      ..sessionId = attriaxStringValue(sessionId)
      ..sessionRelativeTimeMs = sessionRelativeTimeMs,
  );

  return AttriaxTrackEventRequest(requestDto);
}

AttriaxTrackCrashRequest attriaxBuildTrackCrashRequest({
  required String appToken,
  required AttriaxContextSnapshot context,
  required String deviceId,
  required String deviceIdSource,
  required String source,
  required bool isFatal,
  required String exceptionType,
  required String message,
  required String stackTrace,
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
  required String deviceIdSource,
  required AttriaxSessionSnapshot session,
  required AttriaxSessionLifecycleKind kind,
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
      deviceId: session.deviceId,
      deviceIdSource: deviceIdSource,
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
  (builder) => builder
    ..appToken = payload.appToken
    ..deviceId = payload.deviceId
    ..deviceIdSource = attriaxStringValue(payload.deviceIdSource)
    ..kind = _generatedSessionLifecycleKind(payload.kind)
    ..sessionId = payload.sessionId
    ..sessionRelativeTimeMs = payload.sessionRelativeTimeMs
    ..clientOccurredAt = payload.clientOccurredAt.toUtc()
    ..platform = _generatedPlatform(payload.platform)
    ..locale = attriaxStringValue(payload.locale)
    ..isFirstLaunch = payload.isFirstLaunch
    ..appVersion = attriaxStringValue(payload.appVersion)
    ..appBuildNumber = attriaxStringValue(payload.appBuildNumber)
    ..appPackageName = attriaxStringValue(payload.appPackageName)
    ..sdkApiVersion = attriaxStringValue(payload.sdkApiVersion)
    ..sdkPackageVersion = attriaxStringValue(payload.sdkPackageVersion)
    ..metadata = _generatedJsonObjectMap(payload.metadata)?.toBuilder(),
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

BuiltMap<String, JsonObject?> attriaxGeneratedJsonObjectMap(
  Map<String, Object?> value,
) =>
    _generatedJsonObjectMap(value) ??
    BuiltMap<String, JsonObject?>(const <String, JsonObject?>{});

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
    (builder) => builder
      ..appToken = appToken
      ..deviceId = deviceId
      ..deviceIdSource = deviceIdSource
      ..externalUserId = attriaxStringValue(externalUserId)
      ..externalUserName = attriaxStringValue(externalUserName)
      ..clearAllProperties = clearAllProperties ? true : null
      ..clearExternalUser = clearExternalUser ? true : null
      ..clearPropertyKeys =
          normalizedClearPropertyKeys == null ||
              normalizedClearPropertyKeys.isEmpty
          ? null
          : ListBuilder<String>(normalizedClearPropertyKeys)
      ..properties = _generatedJsonObjectMap(properties)?.toBuilder(),
  );

  return AttriaxUserRequest(requestDto);
}

AttriaxResolveDeepLinkRequest attriaxBuildResolveDeepLinkRequest({
  required String appToken,
  required String deviceId,
  required String deviceIdSource,
  required AttriaxPlatformType platform,
  required String source,
  required bool isFirstLaunch,
  String? rawUrl,
  String? linkPath,
  Map<String, Object?>? metadata,
}) {
  final requestDto = sdk.SdkV1DeepLinkResolveDto(
    (builder) => builder
      ..appToken = appToken
      ..deviceId = deviceId
      ..deviceIdSource = deviceIdSource
      ..isFirstLaunch = isFirstLaunch
      ..linkPath = attriaxStringValue(linkPath)
      ..metadata = _generatedJsonObjectMap(metadata)?.toBuilder()
      ..platform = _generatedPlatform(platform)
      ..rawUrl = attriaxStringValue(rawUrl)
      ..source_ = source,
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
    (builder) => builder
      ..androidRedirect = redirects?.android
      ..appToken = appToken
      ..data = _generatedJsonObjectMap(data)?.toBuilder()
      ..destinationUrl = attriaxStringValue(destinationUrl)
      ..group = attriaxStringValue(group)
      ..iosRedirect = redirects?.ios
      ..name = attriaxStringValue(name)
      ..prefix = attriaxStringValue(prefix)
      ..previewDescription = attriaxStringValue(socialPreview?.description)
      ..previewImagePath = attriaxStringValue(socialPreview?.imagePath)
      ..previewTitle = attriaxStringValue(socialPreview?.title)
      ..utmCampaign = attriaxStringValue(utms?.campaign)
      ..utmContent = attriaxStringValue(utms?.content)
      ..utmMedium = attriaxStringValue(utms?.medium)
      ..utmSource = attriaxStringValue(utms?.source)
      ..utmTerm = attriaxStringValue(utms?.term),
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

sdk.AppVersionContextDto _generatedAppVersionContext(AttriaxAppSnapshot app) =>
    sdk.AppVersionContextDto(
      (builder) => builder
        ..buildNumber = attriaxStringValue(app.buildNumber)
        ..packageName = attriaxStringValue(app.packageName)
        ..version = attriaxStringValue(app.version),
    );

sdk.DeviceContextDto _generatedDeviceContext(AttriaxDeviceSnapshot device) =>
    sdk.DeviceContextDto(
      (builder) => builder
        ..advertisingId = attriaxStringValue(device.advertisingId)
        ..androidId = attriaxStringValue(device.androidId)
        ..brand = attriaxStringValue(device.brand)
        ..colorDepth = device.colorDepth
        ..devicePixelRatio = device.devicePixelRatio
        ..hardware = attriaxStringValue(device.hardware)
        ..isPhysicalDevice = device.isPhysicalDevice
        ..language = attriaxStringValue(device.language)
        ..manufacturer = attriaxStringValue(device.manufacturer)
        ..metadata = _generatedJsonObjectMap(device.metadata)?.toBuilder()
        ..model = attriaxStringValue(device.model)
        ..name = attriaxStringValue(device.name)
        ..osVersion = attriaxStringValue(device.osVersion)
        ..screenHeight = device.screenHeight
        ..screenResolution = attriaxStringValue(device.screenResolution)
        ..screenWidth = device.screenWidth
        ..supportedAbis = device.supportedAbis.isEmpty
            ? null
            : ListBuilder<String>(device.supportedAbis)
        ..timezone = attriaxStringValue(device.timezone),
    );

sdk.SdkVersionContextDto _generatedSdkVersionContext(
  AttriaxSdkSnapshot sdkSnapshot,
) => sdk.SdkVersionContextDto(
  (builder) => builder
    ..apiVersion = sdkSnapshot.apiVersion
    ..metadata = _generatedJsonObjectMap(sdkSnapshot.metadata)?.toBuilder()
    ..packageVersion = sdkSnapshot.packageVersion,
);

AttriaxAppOpenResult _mapOpenResult(sdk.SdkV1OpenResponseDto response) =>
    AttriaxAppOpenResult(
      userId: response.userId,
      isNewUser: response.isNewUser,
      isFirstLaunch: response.isFirstLaunch,
      installState: _mapInstallState(response.installState),
      requestVersion: response.requestVersion,
      acceptedAt: response.acceptedAt,
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
      _ => AttriaxInstallState.existing,
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
  _ => AttriaxDeepLinkResolutionStatus.invalid,
};

AttributionType _mapAttributionType(sdk.AttributionType attributionType) =>
    switch (attributionType) {
      sdk.AttributionType.referrer => AttributionType.referrer,
      sdk.AttributionType.fingerprint => AttributionType.fingerprint,
      sdk.AttributionType.external_ => AttributionType.external,
      sdk.AttributionType.organic => AttributionType.organic,
      _ => AttributionType.organic,
    };

BuiltMap<String, JsonObject?>? _generatedJsonObjectMap(
  Map<String, Object?>? value,
) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final result = <String, JsonObject?>{};
  for (final entry in value.entries) {
    final generatedValue = _generatedJsonValue(entry.value);
    if (identical(generatedValue, _generatedJsonOmittedValue)) {
      continue;
    }
    result[entry.key] = JsonObject(generatedValue);
  }

  if (result.isEmpty) {
    return null;
  }

  return BuiltMap<String, JsonObject?>(result);
}

const Object _generatedJsonOmittedValue = Object();

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
    final result = <String, Object?>{};
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

Map<String, Object?>? _plainJsonObjectMap(
  BuiltMap<String, JsonObject?>? value,
) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final result = <String, Object?>{};
  for (final entry in value.entries) {
    result[entry.key] = _plainJsonValue(entry.value?.value);
  }
  return result;
}

Map<String, String>? _plainStringMap(BuiltMap<String, String>? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return Map<String, String>.from(value.asMap());
}

Map<String, Object?>? _plainStringObjectMap(BuiltMap<String, String>? value) {
  final plain = _plainStringMap(value);
  if (plain == null || plain.isEmpty) {
    return null;
  }

  return Map<String, Object?>.from(plain);
}

Object? _plainJsonValue(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is JsonObject) {
    return _plainJsonValue(value.value);
  }
  if (value is BuiltList) {
    return value.map(_plainJsonValue).toList(growable: false);
  }
  if (value is BuiltMap) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      result[entry.key.toString()] = _plainJsonValue(entry.value);
    }
    return result;
  }
  if (value is List) {
    return value.map(_plainJsonValue).toList(growable: false);
  }
  if (value is Map) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      result[entry.key.toString()] = _plainJsonValue(entry.value);
    }
    return result;
  }
  return value.toString();
}

T _deserializeGenerated<T>(Serializer<T> serializer, Object? value) {
  final deserialized = sdk.standardSerializers.deserializeWith(
    serializer,
    value,
  );
  if (deserialized == null) {
    throw const FormatException('Failed to deserialize generated SDK payload.');
  }
  return deserialized;
}

Map<String, Object?> _serializeGenerated<T>(Serializer<T> serializer, T value) {
  final serialized = sdk.standardSerializers.serializeWith(serializer, value);
  return attriaxObjectMapOrEmpty(serialized);
}
