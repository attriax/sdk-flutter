part of '../../attriax_api_models.dart';

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
    case 'trackNotification':
      return AttriaxTrackNotificationRequest(
        _parseGeneratedPayload(body, sdk.SdkNotificationDto.fromJson),
      );
    case 'trackSession':
      return AttriaxTrackSessionRequest(
        AttriaxSessionLifecyclePayload.fromJson(body),
      );
    case 'user':
    // 'identify' is a legacy queue-kind alias for 'user'. New requests are
    // always written as 'user' (see AttriaxUserRequest.kindName), but a queue
    // persisted by an older SDK build may still contain 'identify' entries, so
    // this case must remain to keep that on-disk queue restorable. Do not
    // remove it as "dead code".
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
