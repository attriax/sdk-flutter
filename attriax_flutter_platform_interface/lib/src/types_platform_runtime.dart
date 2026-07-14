part of 'types.dart';

class AttriaxNativeContext {
  const AttriaxNativeContext({
    this.installReferrer,
    this.androidId,
    this.advertisingId,
    this.metadata = const <String, Object?>{},
  });

  factory AttriaxNativeContext.fromJson(Map<String, Object?> json) {
    final metadata =
        _jsonObject(json['metadata']) ??
        <String, Object?>{
          for (final entry in json.entries)
            if (entry.key != 'installReferrer' &&
                entry.key != 'androidId' &&
                entry.key != 'advertisingId')
              entry.key: _normalizeJsonValue(entry.value),
        };

    return AttriaxNativeContext(
      installReferrer: _jsonString(json['installReferrer']),
      androidId: _jsonString(json['androidId']),
      advertisingId: _jsonString(json['advertisingId']),
      metadata: metadata,
    );
  }

  factory AttriaxNativeContext.fromPayload(Object? payload) =>
      AttriaxNativeContext.fromJson(_jsonObjectOrEmpty(payload));

  final String? installReferrer;
  final String? androidId;
  final String? advertisingId;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    if (installReferrer != null) 'installReferrer': installReferrer,
    if (androidId != null) 'androidId': androidId,
    if (advertisingId != null) 'advertisingId': advertisingId,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

class AttriaxInstallReferrerContext {
  const AttriaxInstallReferrerContext({
    this.installReferrer,
    this.metadata = const <String, Object?>{},
  });

  factory AttriaxInstallReferrerContext.fromJson(Map<String, Object?> json) {
    final metadata =
        _jsonObject(json['metadata']) ??
        <String, Object?>{
          for (final entry in json.entries)
            if (entry.key != 'installReferrer')
              entry.key: _normalizeJsonValue(entry.value),
        };

    return AttriaxInstallReferrerContext(
      installReferrer: _jsonString(json['installReferrer']),
      metadata: metadata,
    );
  }

  factory AttriaxInstallReferrerContext.fromPayload(Object? payload) =>
      AttriaxInstallReferrerContext.fromJson(_jsonObjectOrEmpty(payload));

  final String? installReferrer;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    if (installReferrer != null) 'installReferrer': installReferrer,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

class AttriaxPendingCrashReport {
  const AttriaxPendingCrashReport({
    required this.source,
    required this.isFatal,
    required this.exceptionType,
    required this.message,
    required this.stackTrace,
    this.occurredAt,
    this.reason,
    this.metadata = const <String, Object?>{},
  });

  factory AttriaxPendingCrashReport.fromJson(Map<String, Object?> json) {
    final metadata =
        _jsonObject(json['metadata']) ??
        <String, Object?>{
          for (final entry in json.entries)
            if (entry.key != 'source' &&
                entry.key != 'isFatal' &&
                entry.key != 'exceptionType' &&
                entry.key != 'message' &&
                entry.key != 'stackTrace' &&
                entry.key != 'occurredAt' &&
                entry.key != 'reason')
              entry.key: _normalizeJsonValue(entry.value),
        };

    return AttriaxPendingCrashReport(
      source: _jsonString(json['source']) ?? 'native',
      isFatal: _jsonBool(json['isFatal']) ?? true,
      exceptionType: _jsonString(json['exceptionType']) ?? 'UnknownError',
      message: _jsonString(json['message']) ?? 'Unknown crash',
      stackTrace: _jsonString(json['stackTrace']) ?? '',
      occurredAt: _jsonDateTime(json['occurredAt']),
      reason: _jsonString(json['reason']),
      metadata: metadata,
    );
  }

  factory AttriaxPendingCrashReport.fromPayload(Object? payload) {
    final json = _jsonObject(payload);
    if (json == null || json.isEmpty) {
      throw const FormatException('Pending crash report payload is empty.');
    }

    return AttriaxPendingCrashReport.fromJson(json);
  }

  final String source;
  final bool isFatal;
  final String exceptionType;
  final String message;
  final String stackTrace;
  final DateTime? occurredAt;
  final String? reason;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    'source': source,
    'isFatal': isFatal,
    'exceptionType': exceptionType,
    'message': message,
    'stackTrace': stackTrace,
    if (occurredAt != null) 'occurredAt': occurredAt!.toUtc().toIso8601String(),
    if (reason != null) 'reason': reason,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

/// SDK version and metadata snapshot captured during initialization.
class AttriaxSdkSnapshot {
  const AttriaxSdkSnapshot({
    required this.apiVersion,
    required this.packageVersion,
    this.metadata = const <String, Object?>{},
  });

  factory AttriaxSdkSnapshot.fromJson(Map<String, Object?> json) =>
      AttriaxSdkSnapshot(
        apiVersion: _jsonString(json['apiVersion']) ?? attriaxSdkApiVersion,
        packageVersion:
            _jsonString(json['packageVersion']) ?? attriaxSdkPackageVersion,
        metadata: _jsonObject(json['metadata']) ?? const <String, Object?>{},
      );

  factory AttriaxSdkSnapshot.fromPayload(Object? payload) =>
      AttriaxSdkSnapshot.fromJson(_jsonObjectOrEmpty(payload));

  final String apiVersion;
  final String packageVersion;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    'apiVersion': apiVersion,
    'packageVersion': packageVersion,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

class AttriaxAppSnapshot {
  const AttriaxAppSnapshot({this.version, this.buildNumber, this.packageName});

  final String? version;
  final String? buildNumber;
  final String? packageName;

  Map<String, Object?> toJson() => <String, Object?>{
    if (version != null) 'version': version,
    if (buildNumber != null) 'buildNumber': buildNumber,
    if (packageName != null) 'packageName': packageName,
  };
}

class AttriaxDeviceSnapshot {
  const AttriaxDeviceSnapshot({
    this.model,
    this.name,
    this.brand,
    this.manufacturer,
    this.hardware,
    this.osVersion,
    this.language,
    this.timezone,
    this.screenResolution,
    this.screenWidth,
    this.screenHeight,
    this.devicePixelRatio,
    this.colorDepth,
    this.advertisingId,
    this.androidId,
    this.isPhysicalDevice,
    this.supportedAbis = const <String>[],
    this.metadata = const <String, Object?>{},
  });

  final String? model;
  final String? name;
  final String? brand;
  final String? manufacturer;
  final String? hardware;
  final String? osVersion;
  final String? language;
  final String? timezone;
  final String? screenResolution;
  final int? screenWidth;
  final int? screenHeight;
  final double? devicePixelRatio;
  final int? colorDepth;
  final String? advertisingId;
  final String? androidId;
  final bool? isPhysicalDevice;
  final List<String> supportedAbis;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    if (model != null) 'model': model,
    if (name != null) 'name': name,
    if (brand != null) 'brand': brand,
    if (manufacturer != null) 'manufacturer': manufacturer,
    if (hardware != null) 'hardware': hardware,
    if (osVersion != null) 'osVersion': osVersion,
    if (language != null) 'language': language,
    if (timezone != null) 'timezone': timezone,
    if (screenResolution != null) 'screenResolution': screenResolution,
    if (screenWidth != null) 'screenWidth': screenWidth,
    if (screenHeight != null) 'screenHeight': screenHeight,
    if (devicePixelRatio != null) 'devicePixelRatio': devicePixelRatio,
    if (colorDepth != null) 'colorDepth': colorDepth,
    if (advertisingId != null) 'advertisingId': advertisingId,
    if (androidId != null) 'androidId': androidId,
    if (isPhysicalDevice != null) 'isPhysicalDevice': isPhysicalDevice,
    if (supportedAbis.isNotEmpty) 'supportedAbis': supportedAbis,
    if (metadata.isNotEmpty) 'metadata': _normalizeJsonMap(metadata),
  };
}

class AttriaxContextSnapshot {
  const AttriaxContextSnapshot({
    required this.platform,
    required this.deviceId,
    required this.isFirstLaunch,
    required this.sdk,
    required this.app,
    required this.device,
  });

  final AttriaxPlatformType platform;
  final String? deviceId;
  final bool isFirstLaunch;

  final AttriaxSdkSnapshot sdk;
  final AttriaxAppSnapshot app;
  final AttriaxDeviceSnapshot device;
}
