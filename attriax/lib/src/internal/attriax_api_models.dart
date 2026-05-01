import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_sdk_client/attriax_sdk_client.dart' as sdk;
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

final class AttriaxIdentifyRequest extends AttriaxApiRequest {
  const AttriaxIdentifyRequest(this.payload);

  final sdk.SdkIdentifyDto payload;

  @override
  String get kindName => 'identify';

  @override
  String get label => 'identify';

  @override
  Map<String, Object?> toQueueBody() =>
      _serializeGenerated(sdk.SdkIdentifyDto.serializer, payload);
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
    case 'identify':
      return AttriaxIdentifyRequest(
        _deserializeGenerated(sdk.SdkIdentifyDto.serializer, body),
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
}) {
  final requestDto = sdk.SdkV1OpenDto(
    (builder) => builder
      ..app.replace(_generatedAppVersionContext(context.app))
      ..appToken = config.appToken
      ..device.replace(_generatedDeviceContext(context.device))
      ..deviceId = context.deviceId
      ..deviceIdSource = deviceIdSource
      ..installReferrer = attriaxStringValue(context.rawPlatformInstallReferrer)
      ..isFirstLaunch = context.isFirstLaunch
      ..platform = _generatedPlatform(context.platform)
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
}) {
  final requestDto = sdk.SdkEventDto(
    (builder) => builder
      ..appToken = appToken
      ..deviceId = deviceId
      ..deviceIdSource = deviceIdSource
      ..eventName = eventName
      ..eventData = _generatedJsonObjectMap(eventData)?.toBuilder(),
  );

  return AttriaxTrackEventRequest(requestDto);
}

AttriaxIdentifyRequest attriaxBuildIdentifyRequest({
  required String appToken,
  required String deviceId,
  required String deviceIdSource,
  required String? externalUserId,
  String? externalUserName,
}) {
  final requestDto = sdk.SdkIdentifyDto(
    (builder) => builder
      ..appToken = appToken
      ..deviceId = deviceId
      ..deviceIdSource = deviceIdSource
      ..externalUserId = attriaxStringValue(externalUserId)
      ..externalUserName = attriaxStringValue(externalUserName),
  );

  return AttriaxIdentifyRequest(requestDto);
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
  bool? iosRedirect,
  bool? androidRedirect,
  String? previewTitle,
  String? previewDescription,
  String? previewImagePath,
  String? utmSource,
  String? utmMedium,
  String? utmCampaign,
  String? utmTerm,
  String? utmContent,
  Map<String, Object?>? data,
}) {
  final requestDto = sdk.SdkCreateDynamicLinkDto(
    (builder) => builder
      ..androidRedirect = androidRedirect
      ..appToken = appToken
      ..data = _generatedJsonObjectMap(data)?.toBuilder()
      ..destinationUrl = attriaxStringValue(destinationUrl)
      ..group = attriaxStringValue(group)
      ..iosRedirect = iosRedirect
      ..name = attriaxStringValue(name)
      ..prefix = attriaxStringValue(prefix)
      ..previewDescription = attriaxStringValue(previewDescription)
      ..previewImagePath = attriaxStringValue(previewImagePath)
        ..previewTitle = attriaxStringValue(previewTitle)
        ..utmCampaign = attriaxStringValue(utmCampaign)
        ..utmContent = attriaxStringValue(utmContent)
        ..utmMedium = attriaxStringValue(utmMedium)
        ..utmSource = attriaxStringValue(utmSource)
        ..utmTerm = attriaxStringValue(utmTerm),
  );

  return AttriaxCreateDynamicLinkRequest(requestDto);
}

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

AttriaxAckResponse attriaxAckResponseFromGenerated(
  sdk.SdkAcknowledgeResponseEnvelopeDto envelope,
) => AttriaxAckResponse(success: envelope.data.success);

AttriaxOpenApiResponse attriaxOpenResponseFromGenerated(
  sdk.SdkV1OpenResponseEnvelopeDto envelope,
) => AttriaxOpenApiResponse(result: _mapOpenResult(envelope.data));

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
        ..hardware = attriaxStringValue(device.hardware)
        ..isPhysicalDevice = device.isPhysicalDevice
        ..language = attriaxStringValue(device.language)
        ..manufacturer = attriaxStringValue(device.manufacturer)
        ..metadata = _generatedJsonObjectMap(device.metadata)?.toBuilder()
        ..model = attriaxStringValue(device.model)
        ..name = attriaxStringValue(device.name)
        ..osVersion = attriaxStringValue(device.osVersion)
        ..screenResolution = attriaxStringValue(device.screenResolution)
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
      requestVersion: response.requestVersion,
      acceptedAt: response.acceptedAt,
      deepLink: _mapDeepLink(response.deepLink),
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
        data: _plainJsonObjectMap(deepLink.data),
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
        deepLinkData: _plainJsonObjectMap(details.deepLinkData),
        precision: details.precision.toDouble(),
      );

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

  return BuiltMap<String, JsonObject?>(
    value.map(
      (key, nestedValue) =>
          MapEntry(key, JsonObject(attriaxNormalizeJsonValue(nestedValue))),
    ),
  );
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
