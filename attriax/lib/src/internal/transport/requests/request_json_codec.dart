part of '../../attriax_api_models.dart';

AttriaxApiRequest attriaxApiRequestFromJson(
  String kindName,
  Map<String, Object?> rawBody,
) {
  final body = _attriaxMigrateLegacyProjectToken(rawBody);
  switch (kindName) {
    case 'open':
      // The attestation envelope (Epic 7.3b) is attached as an extra field the
      // generated SdkV1OpenDto does not model, so it must be carried across the
      // queue-restore boundary explicitly or a restored open request would drop
      // it. The server tolerates a stale nonce (it degrades to
      // `attestation_missing`), so preserving it is safe.
      return AttriaxOpenRequest(
        _parseGeneratedPayload(body, sdk.SdkV1OpenDto.fromJson),
        attestation: attriaxObjectMap(body['attestation']),
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

/// Queues persisted by SDK builds that predate the `projectToken` rename stored
/// the project token under the deprecated `appToken` key. Normalize those
/// legacy on-disk entries to `projectToken` so restored requests carry the
/// field the current transport, batching, and consent-rewrite paths expect. New
/// queues already use `projectToken`, so this is a no-op for them.
Map<String, Object?> _attriaxMigrateLegacyProjectToken(
  Map<String, Object?> body,
) {
  if (attriaxStringValue(body['projectToken']) != null) {
    return body;
  }

  final legacyAppToken = attriaxStringValue(body['appToken']);
  if (legacyAppToken == null) {
    return body;
  }

  return <String, Object?>{...body, 'projectToken': legacyAppToken}
    ..remove('appToken');
}
