// ignore_for_file: deprecated_member_use

part of '../../attriax_api_models.dart';

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

sdk.DeviceContextDto _generatedDeviceContext(
  AttriaxDeviceSnapshot device, {
  Map<String, Object?> metadataOverrides = const <String, Object?>{},
}) {
  final metadata = <String, Object?>{...device.metadata, ...metadataOverrides};

  return sdk.DeviceContextDto(
    advertisingId: attriaxStringValue(device.advertisingId),
    androidId: attriaxStringValue(device.androidId),
    brand: attriaxStringValue(device.brand),
    colorDepth: device.colorDepth,
    devicePixelRatio: device.devicePixelRatio,
    hardware: attriaxStringValue(device.hardware),
    isPhysicalDevice: device.isPhysicalDevice,
    language: attriaxStringValue(device.language),
    manufacturer: attriaxStringValue(device.manufacturer),
    metadata: _generatedOptionalJsonObjectMap(metadata),
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
}

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
