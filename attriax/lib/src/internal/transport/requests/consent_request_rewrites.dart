// ignore_for_file: deprecated_member_use

part of '../../attriax_api_models.dart';

AttriaxApiRequest attriaxAnonymizeRequestForConsent(
  AttriaxApiRequest request,
) => switch (request) {
  AttriaxTrackEventRequest(:final payload) => AttriaxTrackEventRequest(
    sdk.SdkEventDto(
      appToken: _attriaxResolveCompatibleToken(
        context: 'Attriax anonymized event request',
        projectToken: payload.projectToken,
        appToken: payload.appToken,
      ),
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
        appToken: _attriaxResolveCompatibleToken(
          context: 'Attriax anonymized deep-link request',
          projectToken: payload.projectToken,
          appToken: payload.appToken,
        ),
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
        appToken: _attriaxResolveCompatibleToken(
          context: 'Attriax identified event request',
          projectToken: payload.projectToken,
          appToken: payload.appToken,
        ),
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
        appToken: _attriaxResolveCompatibleToken(
          context: 'Attriax identified deep-link request',
          projectToken: payload.projectToken,
          appToken: payload.appToken,
        ),
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
