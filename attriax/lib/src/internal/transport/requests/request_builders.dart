part of '../../attriax_api_models.dart';

AttriaxOpenRequest attriaxBuildOpenRequest({
  required AttriaxConfig config,
  required AttriaxContextSnapshot context,
  required String deviceIdSource,
  AttriaxInstallReferrerContext? platformInstallReferrerContext,
  String? installReferrerOverride,
  Map<String, Object?> deviceMetadataOverrides = const <String, Object?>{},
  String? sessionId,
  DateTime? sessionStartedAt,
  Map<String, Object?>? attestation,
}) {
  final deviceId = context.deviceId;
  if (deviceId == null || deviceId.isEmpty) {
    throw StateError('Attriax open requests require an identified device id.');
  }

  final installReferrerMetadata =
      platformInstallReferrerContext?.metadata ?? const <String, Object?>{};
  final requestDto = sdk.SdkV1OpenDto(
    app: _generatedAppVersionContext(context.app),
    projectToken: config.projectToken,
    device: _generatedDeviceContext(
      context.device,
      metadataOverrides: deviceMetadataOverrides,
    ),
    deviceId: deviceId,
    deviceIdSource: deviceIdSource,
    googlePlayInstantParam: attriaxBoolValue(
      installReferrerMetadata['googlePlayInstantParam'],
    ),
    installBeginTimestampSeconds: _attriaxIntValue(
      installReferrerMetadata['installBeginTimestampSeconds'],
    ),
    installReferrer:
        attriaxStringValue(installReferrerOverride) ??
        attriaxStringValue(platformInstallReferrerContext?.installReferrer),
    isFirstLaunch: context.isFirstLaunch,
    platform: _generatedPlatform(context.platform),
    referrerClickTimestampSeconds: _attriaxIntValue(
      installReferrerMetadata['referrerClickTimestampSeconds'],
    ),
    sdk: _generatedSdkVersionContext(context.sdk),
    sessionId: attriaxStringValue(sessionId),
    sessionStartedAt: sessionStartedAt?.toUtc(),
  );

  return AttriaxOpenRequest(requestDto, attestation: attestation);
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
  required String eventName,
  required String projectToken,
  String? deviceId,
  String? deviceIdSource,
  Map<String, Object?>? eventData,
  String? sessionId,
  int? sessionRelativeTimeMs,
  DateTime? clientOccurredAt,
}) {
  final requestDto = sdk.SdkEventDto(
    projectToken: projectToken,
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
  required AttriaxContextSnapshot context,
  required String source,
  required bool isFatal,
  required String exceptionType,
  required String message,
  required String stackTrace,
  required String projectToken,
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
      projectToken: projectToken,
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

AttriaxTrackNotificationRequest attriaxBuildTrackNotificationRequest({
  required AttriaxNotificationEventType type,
  required String notificationId,
  required AttriaxPlatformType platform,
  required String projectToken,
  String? deviceId,
  String? deviceIdSource,
  String? linkId,
  String? campaignId,
  String? title,
  AttriaxNotificationEventSource? source,
  String? sessionId,
  DateTime? clientOccurredAt,
  Map<String, Object?>? metadata,
}) {
  final normalizedNotificationId = notificationId.trim();
  if (normalizedNotificationId.isEmpty) {
    throw ArgumentError.value(
      notificationId,
      'notificationId',
      'notificationId must not be empty.',
    );
  }

  final requestDto = sdk.SdkNotificationDto(
    projectToken: projectToken,
    campaignId: attriaxStringValue(campaignId),
    deviceId: attriaxStringValue(deviceId),
    deviceIdSource: attriaxStringValue(deviceIdSource),
    linkId: attriaxStringValue(linkId),
    metadata: _generatedOptionalJsonObjectMap(metadata),
    notificationId: normalizedNotificationId,
    occurredAt: clientOccurredAt?.toUtc(),
    platform: _generatedPlatform(platform),
    sessionId: attriaxStringValue(sessionId),
    source_: source == null ? null : _generatedNotificationEventSource(source),
    title: attriaxStringValue(title),
    type: _generatedNotificationEventType(type),
  );

  return AttriaxTrackNotificationRequest(requestDto);
}

sdk.NotificationEventType _generatedNotificationEventType(
  AttriaxNotificationEventType type,
) => switch (type) {
  AttriaxNotificationEventType.received => sdk.NotificationEventType.received,
  AttriaxNotificationEventType.opened => sdk.NotificationEventType.opened,
  AttriaxNotificationEventType.dismissed => sdk.NotificationEventType.dismissed,
};

sdk.NotificationEventSource _generatedNotificationEventSource(
  AttriaxNotificationEventSource source,
) => switch (source) {
  AttriaxNotificationEventSource.fcm => sdk.NotificationEventSource.fcm,
  AttriaxNotificationEventSource.apns => sdk.NotificationEventSource.apns,
  AttriaxNotificationEventSource.other => sdk.NotificationEventSource.other,
};

AttriaxTrackSessionRequest attriaxBuildTrackSessionRequest({
  required AttriaxSessionSnapshot session,
  required AttriaxSessionLifecycleKind kind,
  required String projectToken,
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
      projectToken: projectToken,
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
  projectToken: payload.projectToken,
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
  required String deviceId,
  required String deviceIdSource,
  required String projectToken,
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
    projectToken: projectToken,
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
  required AttriaxPlatformType platform,
  required String source,
  required bool isFirstLaunch,
  required String projectToken,
  String? deviceId,
  String? deviceIdSource,
  String? rawUrl,
  String? linkPath,
  Map<String, Object?>? metadata,
}) {
  final requestDto = sdk.SdkV1DeepLinkResolveDto(
    projectToken: projectToken,
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
  required String projectToken,
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
    projectToken: projectToken,
    data: _generatedOptionalJsonObjectMap(data),
    destinationUrl: attriaxStringValue(destinationUrl),
    group: attriaxStringValue(group),
    iosRedirect: redirects?.ios,
    name: attriaxStringValue(name),
    prefix: attriaxStringValue(prefix),
    previewDescription: attriaxStringValue(socialPreview?.description),
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
  required String projectToken,
  required String? deviceId,
  required DateTime clientOccurredAt,
  required String receipt,
  String? provider,
  String? environment,
  String? transactionId,
  String? productId,
  bool? test,
}) => <String, Object?>{
  'projectToken': projectToken,
  'deviceId': ?deviceId,
  'clientOccurredAt': clientOccurredAt.toUtc().toIso8601String(),
  'receipt': receipt,
  'provider': ?attriaxStringValue(provider),
  'environment': ?attriaxStringValue(environment),
  'transactionId': ?attriaxStringValue(transactionId),
  'productId': ?attriaxStringValue(productId),
  'test': ?test,
};

Map<String, Object?> attriaxBuildRegisterUninstallTokenRequest({
  required String deviceId,
  required String deviceIdSource,
  required AttriaxPlatformType platform,
  required String provider,
  required String projectToken,
  String? token,
  Map<String, Object?>? metadata,
}) => <String, Object?>{
  'projectToken': projectToken,
  'deviceId': deviceId,
  'deviceIdSource': deviceIdSource,
  'platform': _uninstallTrackingPlatformName(platform),
  'provider': provider,
  'token': ?attriaxStringValue(token),
  'metadata': ?metadata,
};

AttriaxRegisterUninstallTokenRequest
attriaxBuildRegisterUninstallTokenQueueRequest({
  required String deviceId,
  required String deviceIdSource,
  required AttriaxPlatformType platform,
  required String provider,
  required String projectToken,
  String? token,
  Map<String, Object?>? metadata,
}) => AttriaxRegisterUninstallTokenRequest(
  attriaxBuildRegisterUninstallTokenRequest(
    projectToken: projectToken,
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
