import 'package:attriax_platform_interface/attriax_platform_interface.dart';

import 'attriax_json_utils.dart';

enum AttriaxRequestKind {
  open,
  trackEvent,
  identify,
  resolveDeepLink,
  createDynamicLink,
}

AttriaxRequestKind attriaxRequestKindFromName(String name) {
  switch (name) {
    case 'open':
      return AttriaxRequestKind.open;
    case 'trackEvent':
      return AttriaxRequestKind.trackEvent;
    case 'identify':
      return AttriaxRequestKind.identify;
    case 'resolveDeepLink':
      return AttriaxRequestKind.resolveDeepLink;
    case 'createDynamicLink':
      return AttriaxRequestKind.createDynamicLink;
  }

  throw FormatException('Unsupported Attriax request kind: $name');
}

abstract class AttriaxApiRequest {
  const AttriaxApiRequest();

  AttriaxRequestKind get kind;

  String get path;

  Map<String, Object?> toJson();
}

class AttriaxOpenRequest extends AttriaxApiRequest {
  const AttriaxOpenRequest({
    required this.appToken,
    required this.platform,
    required this.deviceId,
    required this.isFirstLaunch,
    required this.sdk,
    required this.app,
    required this.device,
    this.installReferrer,
  });

  factory AttriaxOpenRequest.fromContext({
    required AttriaxConfig config,
    required AttriaxContextSnapshot context,
  }) => AttriaxOpenRequest(
    appToken: config.appToken,
    platform: context.platform,
    deviceId: context.deviceId,
    isFirstLaunch: context.isFirstLaunch,
    installReferrer: context.installReferrer,
    sdk: context.sdk,
    app: context.app,
    device: context.device,
  );

  final String appToken;
  final AttriaxPlatformType platform;
  final String deviceId;
  final bool isFirstLaunch;
  final String? installReferrer;
  final AttriaxSdkSnapshot sdk;
  final AttriaxAppSnapshot app;
  final AttriaxDeviceSnapshot device;

  @override
  AttriaxRequestKind get kind => AttriaxRequestKind.open;

  @override
  String get path => '/api/sdk/v1/open';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'appToken': appToken,
    'platform': platform.name,
    'deviceId': deviceId,
    'isFirstLaunch': isFirstLaunch,
    if (installReferrer != null) 'installReferrer': installReferrer,
    'sdk': sdk.toJson(),
    'app': app.toJson(),
    'device': device.toJson(),
  };
}

class AttriaxTrackEventRequest extends AttriaxApiRequest {
  const AttriaxTrackEventRequest({
    required this.appToken,
    required this.deviceId,
    required this.eventName,
    this.eventData,
    this.linkId,
  });

  final String appToken;
  final String deviceId;
  final String eventName;
  final Map<String, Object?>? eventData;
  final String? linkId;

  @override
  AttriaxRequestKind get kind => AttriaxRequestKind.trackEvent;

  @override
  String get path => '/api/sdk/v1/events';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'appToken': appToken,
    'deviceId': deviceId,
    'eventName': eventName,
    if (eventData != null && eventData!.isNotEmpty)
      'eventData': attriaxNormalizeJsonMap(eventData!),
    if (linkId != null) 'linkId': linkId,
  };
}

class AttriaxIdentifyRequest extends AttriaxApiRequest {
  const AttriaxIdentifyRequest({
    required this.appToken,
    required this.deviceId,
    required this.externalUserId,
    this.externalUserName,
  });

  final String appToken;
  final String deviceId;
  final String externalUserId;
  final String? externalUserName;

  @override
  AttriaxRequestKind get kind => AttriaxRequestKind.identify;

  @override
  String get path => '/api/sdk/v1/identify';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'appToken': appToken,
    'deviceId': deviceId,
    'externalUserId': externalUserId,
    if (externalUserName != null) 'externalUserName': externalUserName,
  };
}

class AttriaxResolveDeepLinkRequest extends AttriaxApiRequest {
  const AttriaxResolveDeepLinkRequest({
    required this.appToken,
    required this.deviceId,
    required this.platform,
    required this.source,
    required this.isFirstLaunch,
    this.rawUrl,
    this.linkPath,
    this.metadata,
  });

  final String appToken;
  final String deviceId;
  final AttriaxPlatformType platform;
  final String? rawUrl;
  final String? linkPath;
  final String source;
  final bool isFirstLaunch;
  final Map<String, Object?>? metadata;

  @override
  AttriaxRequestKind get kind => AttriaxRequestKind.resolveDeepLink;

  @override
  String get path => '/api/sdk/v1/deep-links/resolve';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'appToken': appToken,
    'deviceId': deviceId,
    'platform': platform.name,
    if (rawUrl != null) 'rawUrl': rawUrl,
    if (linkPath != null) 'linkPath': linkPath,
    'source': source,
    'isFirstLaunch': isFirstLaunch,
    if (metadata != null && metadata!.isNotEmpty)
      'metadata': attriaxNormalizeJsonMap(metadata!),
  };
}

class AttriaxCreateDynamicLinkRequest extends AttriaxApiRequest {
  const AttriaxCreateDynamicLinkRequest({
    required this.appToken,
    this.name,
    this.destinationUrl,
    this.group,
    this.prefix,
    this.iosRedirect,
    this.androidRedirect,
    this.previewTitle,
    this.previewDescription,
    this.previewImagePath,
    this.data,
  });

  final String appToken;
  final String? name;
  final String? destinationUrl;
  final String? group;
  final String? prefix;
  final bool? iosRedirect;
  final bool? androidRedirect;
  final String? previewTitle;
  final String? previewDescription;
  final String? previewImagePath;
  final Map<String, Object?>? data;

  @override
  AttriaxRequestKind get kind => AttriaxRequestKind.createDynamicLink;

  @override
  String get path => '/api/sdk/v1/dynamic-links';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'appToken': appToken,
    if (name != null) 'name': name,
    if (destinationUrl != null) 'destinationUrl': destinationUrl,
    if (group != null) 'group': group,
    if (prefix != null) 'prefix': prefix,
    if (iosRedirect != null) 'iosRedirect': iosRedirect,
    if (androidRedirect != null) 'androidRedirect': androidRedirect,
    if (previewTitle != null) 'previewTitle': previewTitle,
    if (previewDescription != null) 'previewDescription': previewDescription,
    if (previewImagePath != null) 'previewImagePath': previewImagePath,
    if (data != null && data!.isNotEmpty)
      'data': attriaxNormalizeJsonMap(data!),
  };
}

abstract class AttriaxApiResponse {
  const AttriaxApiResponse();
}

class AttriaxAckResponse extends AttriaxApiResponse {
  const AttriaxAckResponse({required this.success});

  factory AttriaxAckResponse.fromJson(Map<String, Object?> json) =>
      AttriaxAckResponse(success: attriaxBoolValue(json['success']) ?? false);

  final bool success;
}

class AttriaxOpenApiResponse extends AttriaxApiResponse {
  const AttriaxOpenApiResponse({required this.result});

  factory AttriaxOpenApiResponse.fromJson(Map<String, Object?> json) =>
      AttriaxOpenApiResponse(result: AttriaxAppOpenResult.fromJson(json));

  final AttriaxAppOpenResult result;
}

class AttriaxResolveDeepLinkApiResponse extends AttriaxApiResponse {
  const AttriaxResolveDeepLinkApiResponse({required this.result});

  factory AttriaxResolveDeepLinkApiResponse.fromJson(
    Map<String, Object?> json,
  ) => AttriaxResolveDeepLinkApiResponse(
    result: AttriaxDeepLinkResolutionResult.fromJson(json),
  );

  final AttriaxDeepLinkResolutionResult result;
}

class AttriaxCreateDynamicLinkApiResponse extends AttriaxApiResponse {
  const AttriaxCreateDynamicLinkApiResponse({required this.result});

  factory AttriaxCreateDynamicLinkApiResponse.fromJson(
    Map<String, Object?> json,
  ) => AttriaxCreateDynamicLinkApiResponse(
    result: AttriaxCreateDynamicLinkResult.fromJson(json),
  );

  final AttriaxCreateDynamicLinkResult result;
}

final class AttriaxApiResponseCodec {
  AttriaxApiResponseCodec._();

  static AttriaxApiResponse decode(
    AttriaxRequestKind requestKind,
    Map<String, Object?> json,
  ) => switch (requestKind) {
    AttriaxRequestKind.open => AttriaxOpenApiResponse.fromJson(json),
    AttriaxRequestKind.trackEvent => AttriaxAckResponse.fromJson(json),
    AttriaxRequestKind.identify => AttriaxAckResponse.fromJson(json),
    AttriaxRequestKind.resolveDeepLink =>
      AttriaxResolveDeepLinkApiResponse.fromJson(json),
    AttriaxRequestKind.createDynamicLink =>
      AttriaxCreateDynamicLinkApiResponse.fromJson(json),
  };
}
