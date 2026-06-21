part of '../../attriax_api_models.dart';

AttriaxApiRequest attriaxAnonymizeRequestForConsent(
  AttriaxApiRequest request,
) => switch (request) {
  AttriaxTrackEventRequest(:final payload) => AttriaxTrackEventRequest(
    sdk.SdkEventDto(
      projectToken: payload.projectToken,
      clientOccurredAt: payload.clientOccurredAt,
      eventData: payload.eventData,
      eventName: payload.eventName,
      sessionId: payload.sessionId,
      sessionRelativeTimeMs: payload.sessionRelativeTimeMs,
    ),
  ),
  AttriaxTrackCrashRequest(:final payload) => AttriaxTrackCrashRequest(
    AttriaxCrashReportPayload(
      projectToken: payload.projectToken,
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
      projectToken: payload.projectToken,
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
        projectToken: payload.projectToken,
        isFirstLaunch: payload.isFirstLaunch,
        linkPath: payload.linkPath,
        metadata: payload.metadata,
        platform: payload.platform,
        rawUrl: payload.rawUrl,
        source_: payload.source_,
      ),
    ),
  AttriaxTrackNotificationRequest(:final payload) =>
    AttriaxTrackNotificationRequest(
      sdk.SdkNotificationDto(
        projectToken: payload.projectToken,
        campaignId: payload.campaignId,
        linkId: payload.linkId,
        metadata: payload.metadata,
        notificationId: payload.notificationId,
        occurredAt: payload.occurredAt,
        platform: payload.platform,
        sessionId: payload.sessionId,
        source_: payload.source_,
        title: payload.title,
        type: payload.type,
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
        projectToken: payload.projectToken,
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
        projectToken: payload.projectToken,
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
        projectToken: payload.projectToken,
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
        projectToken: payload.projectToken,
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
  AttriaxTrackNotificationRequest(:final payload)
      when payload.deviceId == null =>
    AttriaxTrackNotificationRequest(
      sdk.SdkNotificationDto(
        projectToken: payload.projectToken,
        campaignId: payload.campaignId,
        deviceId: deviceId,
        deviceIdSource: deviceIdSource,
        linkId: payload.linkId,
        metadata: payload.metadata,
        notificationId: payload.notificationId,
        occurredAt: payload.occurredAt,
        platform: payload.platform,
        sessionId: payload.sessionId,
        source_: payload.source_,
        title: payload.title,
        type: payload.type,
      ),
    ),
  _ => null,
};
