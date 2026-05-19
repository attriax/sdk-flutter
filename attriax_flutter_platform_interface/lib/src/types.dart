const String attriaxSdkApiVersion = 'v1';
const String attriaxSdkPackageVersion = '0.2.0';

/// Attribution classification returned by Attriax.
enum AttributionType {
  /// Attribution derived from platform install-referrer data.
  referrer,

  /// Attribution derived from probabilistic fingerprint matching.
  fingerprint,

  /// Attribution derived from external provider resolutions.
  external,

  /// Attribution assigned when no attributable source was found.
  organic,
}

enum AttriaxPlatformType { ios, android, web, windows, macos, linux, unknown }

enum AttriaxDeepLinkResolutionStatus { matched, unmatched, invalid }

enum AttriaxResolvedUrlOpenMode { inApp, external, unknown }

/// Describes what caused a deep-link event to be emitted.
enum AttriaxDeepLinkTrigger {
  /// The app launched from a fully stopped state because of this link.
  coldStart,

  /// The link arrived while the app was already running.
  foreground,

  /// The link click happened before install and resolved on first launch.
  deferred,
}

enum AttriaxInstallState { existing, newInstall, reinstall, appDataClear }

enum AttriaxSynchronizationState {
  initializing,
  synchronizing,
  deferred,
  synchronized,
  offline,
  failed,
  disabled,
}

enum AttriaxTrackingAuthorizationStatus {
  notSupported,
  disabled,
  notDetermined,
  restricted,
  denied,
  authorized,
  timedOut,
  unknown,
}

enum AttriaxRevenueReceiptValidationStatus {
  verified,
  rejected,
  pending,
  unconfigured,
  providerError,
  passthrough,
}

enum AttriaxSkanCoarseValue { low, medium, high }

enum AttriaxSkanRuleOperator { exists, eq, notEq, gt, gte, lt, lte, contains }

enum AttriaxSkanUpdateStatus {
  updated,
  skipped,
  alreadyAtOrAboveValue,
  invalidValue,
  disabled,
  notSupported,
  error,
}

class AttriaxSkanConfig {
  const AttriaxSkanConfig({
    this.enabled = true,
    this.registerFirstLaunchValue = true,
  });

  final bool enabled;
  final bool registerFirstLaunchValue;

  Map<String, Object?> toJson() => <String, Object?>{
    'enabled': enabled,
    'registerFirstLaunchValue': registerFirstLaunchValue,
  };
}

class AttriaxSkanCondition {
  const AttriaxSkanCondition({
    required this.id,
    required this.paramKey,
    this.operator = AttriaxSkanRuleOperator.eq,
    this.value,
  });

  factory AttriaxSkanCondition.fromJson(Map<String, Object?> json) =>
      AttriaxSkanCondition(
        id: _requireJsonString(json, 'id'),
        paramKey: _requireJsonString(json, 'paramKey'),
        operator:
            _attriaxSkanRuleOperatorFromJson(_jsonString(json['operator'])) ??
            AttriaxSkanRuleOperator.eq,
        value: _normalizeJsonValue(json['value']),
      );

  final String id;
  final String paramKey;
  final AttriaxSkanRuleOperator operator;
  final Object? value;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'paramKey': paramKey,
    'operator': _skanRuleOperatorToJson(operator),
    if (value != null) 'value': _normalizeJsonValue(value),
  };
}

class AttriaxSkanEvent {
  const AttriaxSkanEvent({
    required this.id,
    required this.eventName,
    this.displayName,
    this.coarseValue,
    this.lockWindow = false,
    this.conditions = const <AttriaxSkanCondition>[],
  });

  factory AttriaxSkanEvent.fromJson(Map<String, Object?> json) {
    final rawConditions = json['conditions'];
    final conditions = rawConditions is List
        ? rawConditions
              .whereType<Map>()
              .map(
                (condition) => AttriaxSkanCondition.fromJson(
                  condition.map(
                    (key, value) =>
                        MapEntry(key.toString(), _normalizeJsonValue(value)),
                  ),
                ),
              )
              .toList(growable: false)
        : const <AttriaxSkanCondition>[];

    return AttriaxSkanEvent(
      id: _requireJsonString(json, 'id'),
      eventName: _requireJsonString(json, 'eventName'),
      displayName: _jsonString(json['displayName']),
      coarseValue: _attriaxSkanCoarseValueFromJson(
        _jsonString(json['coarseValue']),
      ),
      lockWindow: _jsonBool(json['lockWindow']) ?? false,
      conditions: conditions,
    );
  }

  final String id;
  final String eventName;
  final String? displayName;
  final AttriaxSkanCoarseValue? coarseValue;
  final bool lockWindow;
  final List<AttriaxSkanCondition> conditions;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'eventName': eventName,
    if (displayName != null) 'displayName': displayName,
    if (coarseValue != null) 'coarseValue': coarseValue!.name,
    if (lockWindow) 'lockWindow': true,
    if (conditions.isNotEmpty)
      'conditions': conditions.map((condition) => condition.toJson()).toList(),
  };
}

class AttriaxSkanWindow1Group {
  const AttriaxSkanWindow1Group({
    required this.id,
    required this.startBit,
    required this.bitCount,
    this.displayName,
    this.events = const <AttriaxSkanEvent>[],
  });

  factory AttriaxSkanWindow1Group.fromJson(Map<String, Object?> json) {
    final rawEvents = json['events'];
    final events = rawEvents is List
        ? rawEvents
              .whereType<Map>()
              .map(
                (event) => AttriaxSkanEvent.fromJson(
                  event.map(
                    (key, value) =>
                        MapEntry(key.toString(), _normalizeJsonValue(value)),
                  ),
                ),
              )
              .toList(growable: false)
        : const <AttriaxSkanEvent>[];

    return AttriaxSkanWindow1Group(
      id: _requireJsonString(json, 'id'),
      startBit: _requireJsonInt(json, 'startBit'),
      bitCount: _requireJsonInt(json, 'bitCount'),
      displayName: _jsonString(json['displayName']),
      events: events,
    );
  }

  final String id;
  final int startBit;
  final int bitCount;
  final String? displayName;
  final List<AttriaxSkanEvent> events;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'startBit': startBit,
    'bitCount': bitCount,
    if (displayName != null) 'displayName': displayName,
    'events': events.map((event) => event.toJson()).toList(growable: false),
  };
}

class AttriaxSkanCoarseWindowEvent {
  const AttriaxSkanCoarseWindowEvent({
    required this.id,
    required this.eventName,
    required this.coarseValue,
    this.displayName,
    this.lockWindow = false,
    this.conditions = const <AttriaxSkanCondition>[],
  });

  factory AttriaxSkanCoarseWindowEvent.fromJson(Map<String, Object?> json) {
    final rawConditions = json['conditions'];
    final conditions = rawConditions is List
        ? rawConditions
              .whereType<Map>()
              .map(
                (condition) => AttriaxSkanCondition.fromJson(
                  condition.map(
                    (key, value) =>
                        MapEntry(key.toString(), _normalizeJsonValue(value)),
                  ),
                ),
              )
              .toList(growable: false)
        : const <AttriaxSkanCondition>[];

    return AttriaxSkanCoarseWindowEvent(
      id: _requireJsonString(json, 'id'),
      eventName: _requireJsonString(json, 'eventName'),
      coarseValue:
          _attriaxSkanCoarseValueFromJson(_jsonString(json['coarseValue'])) ??
          AttriaxSkanCoarseValue.low,
      displayName: _jsonString(json['displayName']),
      lockWindow: _jsonBool(json['lockWindow']) ?? false,
      conditions: conditions,
    );
  }

  final String id;
  final String eventName;
  final AttriaxSkanCoarseValue coarseValue;
  final String? displayName;
  final bool lockWindow;
  final List<AttriaxSkanCondition> conditions;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'eventName': eventName,
    'coarseValue': coarseValue.name,
    if (displayName != null) 'displayName': displayName,
    if (lockWindow) 'lockWindow': true,
    if (conditions.isNotEmpty)
      'conditions': conditions.map((condition) => condition.toJson()).toList(),
  };
}

class AttriaxSkanWindow1 {
  const AttriaxSkanWindow1({this.groups = const <AttriaxSkanWindow1Group>[]});

  factory AttriaxSkanWindow1.fromJson(Map<String, Object?> json) {
    final rawGroups = json['groups'];
    final groups = rawGroups is List
        ? rawGroups
              .whereType<Map>()
              .map(
                (group) => AttriaxSkanWindow1Group.fromJson(
                  group.map(
                    (key, value) =>
                        MapEntry(key.toString(), _normalizeJsonValue(value)),
                  ),
                ),
              )
              .toList(growable: false)
        : const <AttriaxSkanWindow1Group>[];

    return AttriaxSkanWindow1(groups: groups);
  }

  final List<AttriaxSkanWindow1Group> groups;

  Map<String, Object?> toJson() => <String, Object?>{
    'groups': groups.map((group) => group.toJson()).toList(growable: false),
  };
}

class AttriaxSkanCoarseWindow {
  const AttriaxSkanCoarseWindow({
    this.events = const <AttriaxSkanCoarseWindowEvent>[],
  });

  factory AttriaxSkanCoarseWindow.fromJson(Map<String, Object?> json) {
    final rawEvents = json['events'];
    final events = rawEvents is List
        ? rawEvents
              .whereType<Map>()
              .map(
                (event) => AttriaxSkanCoarseWindowEvent.fromJson(
                  event.map(
                    (key, value) =>
                        MapEntry(key.toString(), _normalizeJsonValue(value)),
                  ),
                ),
              )
              .toList(growable: false)
        : const <AttriaxSkanCoarseWindowEvent>[];

    return AttriaxSkanCoarseWindow(events: events);
  }

  final List<AttriaxSkanCoarseWindowEvent> events;

  Map<String, Object?> toJson() => <String, Object?>{
    'events': events.map((event) => event.toJson()).toList(growable: false),
  };
}

class AttriaxSkanSchema {
  const AttriaxSkanSchema({
    required this.version,
    this.updatedAt,
    this.window1 = const AttriaxSkanWindow1(),
    this.window2 = const AttriaxSkanCoarseWindow(),
    this.window3 = const AttriaxSkanCoarseWindow(),
  });

  factory AttriaxSkanSchema.fromJson(Map<String, Object?> json) {
    final window1Json = _jsonObject(json['window1']);
    final window2Json = _jsonObject(json['window2']);
    final window3Json = _jsonObject(json['window3']);

    return AttriaxSkanSchema(
      version: _requireJsonInt(json, 'version'),
      updatedAt: _jsonDateTime(json['updatedAt']),
      window1: window1Json == null
          ? const AttriaxSkanWindow1()
          : AttriaxSkanWindow1.fromJson(window1Json),
      window2: window2Json == null
          ? const AttriaxSkanCoarseWindow()
          : AttriaxSkanCoarseWindow.fromJson(window2Json),
      window3: window3Json == null
          ? const AttriaxSkanCoarseWindow()
          : AttriaxSkanCoarseWindow.fromJson(window3Json),
    );
  }

  final int version;
  final DateTime? updatedAt;
  final AttriaxSkanWindow1 window1;
  final AttriaxSkanCoarseWindow window2;
  final AttriaxSkanCoarseWindow window3;

  Map<String, Object?> toJson() => <String, Object?>{
    'version': version,
    if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
    'window1': window1.toJson(),
    'window2': window2.toJson(),
    'window3': window3.toJson(),
  };
}

class AttriaxSkanRuntimeConfiguration {
  const AttriaxSkanRuntimeConfiguration({required this.enabled, this.schema});

  factory AttriaxSkanRuntimeConfiguration.fromJson(Map<String, Object?> json) {
    final schemaJson = _jsonObject(json['schema']);

    return AttriaxSkanRuntimeConfiguration(
      enabled: _jsonBool(json['enabled']) ?? true,
      schema: schemaJson == null
          ? null
          : AttriaxSkanSchema.fromJson(schemaJson),
    );
  }

  final bool enabled;
  final AttriaxSkanSchema? schema;

  Map<String, Object?> toJson() => <String, Object?>{
    'enabled': enabled,
    if (schema != null) 'schema': schema!.toJson(),
  };
}

class AttriaxSkanState {
  const AttriaxSkanState({
    required this.enabled,
    this.schemaVersion,
    this.schema,
    this.fineValue,
    this.coarseValue,
    this.lockWindow = false,
    this.firstLaunchValueRegistered = false,
    this.lastUpdatedAt,
    this.installAnchorAt,
    this.completedRetentionDays = const <int>[],
    this.purchaseRevenueUsdMicros = 0,
    this.purchaseCount = 0,
    this.adShowCount = 0,
  });

  factory AttriaxSkanState.fromJson(Map<String, Object?> json) {
    final schemaJson = _jsonObject(json['schema']);
    final rawCompletedRetentionDays = json['completedRetentionDays'];
    final completedRetentionDays = rawCompletedRetentionDays is List
        ? rawCompletedRetentionDays
              .map(_jsonInt)
              .whereType<int>()
              .toList(growable: false)
        : const <int>[];

    return AttriaxSkanState(
      enabled: _jsonBool(json['enabled']) ?? false,
      schemaVersion:
          _jsonInt(json['schemaVersion']) ?? _jsonInt(schemaJson?['version']),
      schema: schemaJson == null
          ? null
          : AttriaxSkanSchema.fromJson(schemaJson),
      fineValue: _jsonInt(json['fineValue']),
      coarseValue: _attriaxSkanCoarseValueFromJson(
        _jsonString(json['coarseValue']),
      ),
      lockWindow: _jsonBool(json['lockWindow']) ?? false,
      firstLaunchValueRegistered:
          _jsonBool(json['firstLaunchValueRegistered']) ?? false,
      lastUpdatedAt: _jsonDateTime(json['lastUpdatedAt']),
      installAnchorAt: _jsonDateTime(json['installAnchorAt']),
      completedRetentionDays: completedRetentionDays,
      purchaseRevenueUsdMicros: _jsonInt(json['purchaseRevenueUsdMicros']) ?? 0,
      purchaseCount: _jsonInt(json['purchaseCount']) ?? 0,
      adShowCount: _jsonInt(json['adShowCount']) ?? 0,
    );
  }

  factory AttriaxSkanState.fromPayload(Object? payload) =>
      AttriaxSkanState.fromJson(_jsonObjectOrEmpty(payload));

  final bool enabled;
  final int? schemaVersion;
  final AttriaxSkanSchema? schema;
  final int? fineValue;
  final AttriaxSkanCoarseValue? coarseValue;
  final bool lockWindow;
  final bool firstLaunchValueRegistered;
  final DateTime? lastUpdatedAt;
  final DateTime? installAnchorAt;
  final List<int> completedRetentionDays;
  final int purchaseRevenueUsdMicros;
  final int purchaseCount;
  final int adShowCount;

  AttriaxSkanState copyWith({
    bool? enabled,
    int? schemaVersion,
    bool clearSchemaVersion = false,
    AttriaxSkanSchema? schema,
    bool clearSchema = false,
    int? fineValue,
    bool clearFineValue = false,
    AttriaxSkanCoarseValue? coarseValue,
    bool clearCoarseValue = false,
    bool? lockWindow,
    bool? firstLaunchValueRegistered,
    DateTime? lastUpdatedAt,
    bool clearLastUpdatedAt = false,
    DateTime? installAnchorAt,
    bool clearInstallAnchorAt = false,
    List<int>? completedRetentionDays,
    int? purchaseRevenueUsdMicros,
    int? purchaseCount,
    int? adShowCount,
  }) => AttriaxSkanState(
    enabled: enabled ?? this.enabled,
    schemaVersion: clearSchemaVersion
        ? null
        : (schemaVersion ?? this.schemaVersion),
    schema: clearSchema ? null : (schema ?? this.schema),
    fineValue: clearFineValue ? null : (fineValue ?? this.fineValue),
    coarseValue: clearCoarseValue ? null : (coarseValue ?? this.coarseValue),
    lockWindow: lockWindow ?? this.lockWindow,
    firstLaunchValueRegistered:
        firstLaunchValueRegistered ?? this.firstLaunchValueRegistered,
    lastUpdatedAt: clearLastUpdatedAt
        ? null
        : (lastUpdatedAt ?? this.lastUpdatedAt),
    installAnchorAt: clearInstallAnchorAt
        ? null
        : (installAnchorAt ?? this.installAnchorAt),
    completedRetentionDays:
        completedRetentionDays ?? this.completedRetentionDays,
    purchaseRevenueUsdMicros:
        purchaseRevenueUsdMicros ?? this.purchaseRevenueUsdMicros,
    purchaseCount: purchaseCount ?? this.purchaseCount,
    adShowCount: adShowCount ?? this.adShowCount,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'enabled': enabled,
    if (schemaVersion != null) 'schemaVersion': schemaVersion,
    if (schema != null) 'schema': schema!.toJson(),
    if (fineValue != null) 'fineValue': fineValue,
    if (coarseValue != null) 'coarseValue': coarseValue!.name,
    'lockWindow': lockWindow,
    'firstLaunchValueRegistered': firstLaunchValueRegistered,
    if (lastUpdatedAt != null)
      'lastUpdatedAt': lastUpdatedAt!.toUtc().toIso8601String(),
    if (installAnchorAt != null)
      'installAnchorAt': installAnchorAt!.toUtc().toIso8601String(),
    if (completedRetentionDays.isNotEmpty)
      'completedRetentionDays': completedRetentionDays,
    if (purchaseRevenueUsdMicros != 0)
      'purchaseRevenueUsdMicros': purchaseRevenueUsdMicros,
    if (purchaseCount != 0) 'purchaseCount': purchaseCount,
    if (adShowCount != 0) 'adShowCount': adShowCount,
  };
}

class AttriaxSkanUpdateResult {
  const AttriaxSkanUpdateResult({
    required this.status,
    this.message,
    this.fineValue,
    this.coarseValue,
    this.lockWindow,
    this.state,
  });

  factory AttriaxSkanUpdateResult.fromJson(Map<String, Object?> json) =>
      AttriaxSkanUpdateResult(
        status:
            _attriaxSkanUpdateStatusFromJson(_jsonString(json['status'])) ??
            AttriaxSkanUpdateStatus.error,
        message: _jsonString(json['message']),
        fineValue: _jsonInt(json['fineValue']),
        coarseValue: _attriaxSkanCoarseValueFromJson(
          _jsonString(json['coarseValue']),
        ),
        lockWindow: _jsonBool(json['lockWindow']),
        state: _jsonObject(json['state']) == null
            ? null
            : AttriaxSkanState.fromJson(_jsonObject(json['state'])!),
      );

  factory AttriaxSkanUpdateResult.fromPayload(Object? payload) =>
      AttriaxSkanUpdateResult.fromJson(_jsonObjectOrEmpty(payload));

  final AttriaxSkanUpdateStatus status;
  final String? message;
  final int? fineValue;
  final AttriaxSkanCoarseValue? coarseValue;
  final bool? lockWindow;
  final AttriaxSkanState? state;

  Map<String, Object?> toJson() => <String, Object?>{
    'status': _skanUpdateStatusToJson(status),
    if (message != null) 'message': message,
    if (fineValue != null) 'fineValue': fineValue,
    if (coarseValue != null) 'coarseValue': coarseValue!.name,
    if (lockWindow != null) 'lockWindow': lockWindow,
    if (state != null) 'state': state!.toJson(),
  };
}

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
  final String deviceId;
  final bool isFirstLaunch;

  final AttriaxSdkSnapshot sdk;
  final AttriaxAppSnapshot app;
  final AttriaxDeviceSnapshot device;
}

class AttriaxUtmParameters {
  const AttriaxUtmParameters({
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
  });

  factory AttriaxUtmParameters.fromJson(Map<String, Object?> json) =>
      AttriaxUtmParameters(
        source: _jsonString(json['source']),
        medium: _jsonString(json['medium']),
        campaign: _jsonString(json['campaign']),
        term: _jsonString(json['term']),
        content: _jsonString(json['content']),
      );

  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;

  bool get isEmpty =>
      source == null &&
      medium == null &&
      campaign == null &&
      term == null &&
      content == null;

  Map<String, Object?> toJson() => <String, Object?>{
    if (source != null) 'source': source,
    if (medium != null) 'medium': medium,
    if (campaign != null) 'campaign': campaign,
    if (term != null) 'term': term,
    if (content != null) 'content': content,
  };
}

class AttriaxDeepLink {
  const AttriaxDeepLink({required this.path, this.data, this.uri, this.utm});

  factory AttriaxDeepLink.fromJson(Map<String, Object?> json) {
    final utmJson = _jsonObject(json['utm']);

    return AttriaxDeepLink(
      path: _requireJsonString(json, 'path'),
      data: _jsonObject(json['data']),
      uri: _jsonUri(json['uri']),
      utm: utmJson == null ? null : AttriaxUtmParameters.fromJson(utmJson),
    );
  }

  final String path;
  final Map<String, Object?>? data;
  final Uri? uri;
  final AttriaxUtmParameters? utm;

  Map<String, Object?> toJson() => <String, Object?>{
    'path': path,
    if (data != null && data!.isNotEmpty) 'data': _normalizeJsonMap(data!),
    if (uri != null) 'uri': uri.toString(),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
  };
}

class AttriaxResolvedUrlAction {
  const AttriaxResolvedUrlAction({required this.uri, required this.openMode});

  factory AttriaxResolvedUrlAction.fromJson(Map<String, Object?> json) {
    final uri = _jsonUri(json['url'] ?? json['uri']);
    if (uri == null) {
      throw const FormatException('Missing or invalid "url".');
    }

    return AttriaxResolvedUrlAction(
      uri: uri,
      openMode: _parseResolvedUrlOpenMode(_jsonString(json['openMode'])),
    );
  }

  final Uri uri;
  final AttriaxResolvedUrlOpenMode openMode;

  Map<String, Object?> toJson() => <String, Object?>{
    'url': uri.toString(),
    'openMode': openMode.name,
  };
}

/// Structured install-referrer details resolved by Attriax.
class AttriaxInstallReferrerDetails {
  const AttriaxInstallReferrerDetails({
    required this.attributionType,
    required this.precision,
    this.rawPlatformInstallReferrer,
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
    this.adNetwork,
    this.adClickId,
    this.deepLinkUrl,
    this.deepLinkUri,
    this.deepLinkData,
    this.registeredAt,
    this.installBeginTimestampSeconds,
    this.referrerClickTimestampSeconds,
    this.googlePlayInstantParam,
  });

  factory AttriaxInstallReferrerDetails.fromJson(Map<String, Object?> json) {
    final deepLinkDataJson = _jsonStringMap(json['deepLinkData']);

    return AttriaxInstallReferrerDetails(
      rawPlatformInstallReferrer: _jsonString(
        json['rawPlatformInstallReferrer'],
      ),
      source: _jsonString(json['source']),
      medium: _jsonString(json['medium']),
      campaign: _jsonString(json['campaign']),
      term: _jsonString(json['term']),
      content: _jsonString(json['content']),
      adNetwork: _jsonString(json['adNetwork']),
      adClickId: _jsonString(json['adClickId']),
      attributionType: _parseAttributionType(
        _jsonString(json['attributionType']),
      ),
      deepLinkUrl: _jsonString(json['deepLinkUrl']),
      deepLinkUri:
          _jsonUri(json['deepLinkUri']) ?? _jsonUri(json['deepLinkUrl']),
      deepLinkData: deepLinkDataJson,
      registeredAt: _jsonDateTime(json['registeredAt']),
      installBeginTimestampSeconds: _jsonInt(
        json['installBeginTimestampSeconds'],
      ),
      referrerClickTimestampSeconds: _jsonInt(
        json['referrerClickTimestampSeconds'],
      ),
      googlePlayInstantParam: _jsonBool(json['googlePlayInstantParam']),
      precision: _jsonDouble(json['precision']) ?? 0,
    );
  }

  /// Raw platform install-referrer string cached by the SDK.
  final String? rawPlatformInstallReferrer;

  /// Resolved UTM source extracted from the install referrer.
  final String? source;

  /// Resolved UTM medium extracted from the install referrer.
  final String? medium;

  /// Resolved UTM campaign extracted from the install referrer.
  final String? campaign;

  /// Resolved UTM term extracted from the install referrer.
  final String? term;

  /// Resolved UTM content extracted from the install referrer.
  final String? content;

  /// Detected ad-network identifier inferred from the referrer.
  final String? adNetwork;

  /// Detected ad click identifier such as `gclid` or `fbclid`.
  final String? adClickId;

  /// Attribution classification for the install-referrer payload.
  ///
  /// Current platform install-referrer parsing reports
  /// [AttributionType.referrer]. [AttributionType.external] is reserved for
  /// future provider-based payloads.
  final AttributionType attributionType;

  /// Full tracked short-link URL associated with the resolved deep link.
  @Deprecated('Use deepLinkUri instead.')
  final String? deepLinkUrl;

  /// Full tracked short-link URI associated with the resolved deep link.
  final Uri? deepLinkUri;

  /// Resolved deep-link payload data associated with the startup referrer.
  final Map<String, String>? deepLinkData;

  /// When the backend registered this startup referrer snapshot.
  final DateTime? registeredAt;

  /// Play install begin timestamp, when the current platform reports one.
  final int? installBeginTimestampSeconds;

  /// Play referrer click timestamp, when the current platform reports one.
  final int? referrerClickTimestampSeconds;

  /// Google Play instant-app flag, when the current platform reports one.
  final bool? googlePlayInstantParam;

  AttriaxUtmParameters? get utm {
    final value = AttriaxUtmParameters(
      source: source,
      medium: medium,
      campaign: campaign,
      term: term,
      content: content,
    );
    return value.isEmpty ? null : value;
  }

  /// Confidence score from `0.0` to `1.0` for the resolved install referrer.
  ///
  /// Higher values mean Attriax has stronger evidence for the returned
  /// install-referrer interpretation.
  final double precision;

  Map<String, Object?> toJson() => <String, Object?>{
    if (rawPlatformInstallReferrer != null)
      'rawPlatformInstallReferrer': rawPlatformInstallReferrer,
    if (source != null) 'source': source,
    if (medium != null) 'medium': medium,
    if (campaign != null) 'campaign': campaign,
    if (term != null) 'term': term,
    if (content != null) 'content': content,
    if (adNetwork != null) 'adNetwork': adNetwork,
    if (adClickId != null) 'adClickId': adClickId,
    'attributionType': attributionType.name,
    if (deepLinkUri != null) 'deepLinkUri': deepLinkUri.toString(),
    if (deepLinkUrl != null) 'deepLinkUrl': deepLinkUrl,
    if (deepLinkData != null && deepLinkData!.isNotEmpty)
      'deepLinkData': Map<String, String>.from(deepLinkData!),
    if (registeredAt != null) 'registeredAt': registeredAt!.toIso8601String(),
    if (installBeginTimestampSeconds != null)
      'installBeginTimestampSeconds': installBeginTimestampSeconds,
    if (referrerClickTimestampSeconds != null)
      'referrerClickTimestampSeconds': referrerClickTimestampSeconds,
    if (googlePlayInstantParam != null)
      'googlePlayInstantParam': googlePlayInstantParam,
    'precision': precision,
  };
}

class AttriaxDynamicLinkRecord {
  const AttriaxDynamicLinkRecord({
    required this.id,
    required this.path,
    required this.shortUrl,
    this.name,
    this.destinationUrl,
    this.group,
    this.prefix,
    this.data,
    this.previewTitle,
    this.previewDescription,
    this.previewImagePath,
    this.iosRedirect,
    this.androidRedirect,
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
    this.utmTerm,
    this.utmContent,
    this.createdAt,
  });

  factory AttriaxDynamicLinkRecord.fromJson(Map<String, Object?> json) =>
      AttriaxDynamicLinkRecord(
        id: _requireJsonString(json, 'id'),
        path: _requireJsonString(json, 'path'),
        shortUrl: _requireJsonString(json, 'shortUrl'),
        name: _jsonString(json['name']),
        destinationUrl: _jsonString(json['destinationUrl']),
        group: _jsonString(json['group']),
        prefix: _jsonString(json['prefix']),
        data: _jsonObject(json['data']),
        previewTitle: _jsonString(json['previewTitle']),
        previewDescription: _jsonString(json['previewDescription']),
        previewImagePath: _jsonString(json['previewImagePath']),
        iosRedirect: _jsonBool(json['iosRedirect']),
        androidRedirect: _jsonBool(json['androidRedirect']),
        utmSource: _jsonString(json['utmSource']),
        utmMedium: _jsonString(json['utmMedium']),
        utmCampaign: _jsonString(json['utmCampaign']),
        utmTerm: _jsonString(json['utmTerm']),
        utmContent: _jsonString(json['utmContent']),
        createdAt: _jsonDateTime(json['createdAt']),
      );

  final String id;
  final String path;
  final String shortUrl;
  final String? name;
  final String? destinationUrl;
  final String? group;
  final String? prefix;
  final Map<String, Object?>? data;
  final String? previewTitle;
  final String? previewDescription;
  final String? previewImagePath;
  final bool? iosRedirect;
  final bool? androidRedirect;
  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;
  final String? utmTerm;
  final String? utmContent;
  final DateTime? createdAt;
}

class AttriaxDynamicLinkSocialPreview {
  const AttriaxDynamicLinkSocialPreview({
    this.title,
    this.description,
    this.imagePath,
  });

  final String? title;
  final String? description;
  final String? imagePath;
}

class AttriaxDynamicLinkRedirects {
  const AttriaxDynamicLinkRedirects({this.ios, this.android});

  final bool? ios;
  final bool? android;
}

class AttriaxDynamicLinkUtms {
  const AttriaxDynamicLinkUtms({
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
  });

  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;
}

class AttriaxCreateDynamicLinkResult {
  const AttriaxCreateDynamicLinkResult({
    required this.link,
    this.requestVersion,
    this.acceptedAt,
  });

  factory AttriaxCreateDynamicLinkResult.fromJson(Map<String, Object?> json) {
    final linkJson = _jsonObject(json['link']);
    if (linkJson == null) {
      throw const FormatException('Missing or invalid "link".');
    }

    return AttriaxCreateDynamicLinkResult(
      link: AttriaxDynamicLinkRecord.fromJson(linkJson),
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
    );
  }

  final AttriaxDynamicLinkRecord link;
  final String? requestVersion;
  final DateTime? acceptedAt;
}

class AttriaxRevenueReceiptValidationResult {
  const AttriaxRevenueReceiptValidationResult({
    required this.validationId,
    required this.status,
    required this.publicReceipt,
    this.requestVersion,
    this.acceptedAt,
    this.provider,
    this.environment,
    this.transactionId,
    this.originalTransactionId,
    this.productId,
    this.failureReason,
    this.expiresAt,
    this.providerResult,
  });

  factory AttriaxRevenueReceiptValidationResult.fromJson(
    Map<String, Object?> json,
  ) => AttriaxRevenueReceiptValidationResult(
    requestVersion: _jsonString(json['requestVersion']),
    acceptedAt: _jsonDateTime(json['acceptedAt']),
    validationId: _requireJsonString(json, 'validationId'),
    status: _parseRevenueReceiptValidationStatus(_jsonString(json['status'])),
    provider: _jsonString(json['provider']),
    environment: _jsonString(json['environment']),
    transactionId: _jsonString(json['transactionId']),
    originalTransactionId: _jsonString(json['originalTransactionId']),
    productId: _jsonString(json['productId']),
    failureReason: _jsonString(json['failureReason']),
    expiresAt: _jsonDateTime(json['expiresAt']),
    providerResult: _jsonObject(json['providerResult']),
    publicReceipt:
        _jsonObject(json['publicReceipt']) ?? const <String, Object?>{},
  );

  final String validationId;
  final AttriaxRevenueReceiptValidationStatus status;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final String? provider;
  final String? environment;
  final String? transactionId;
  final String? originalTransactionId;
  final String? productId;
  final String? failureReason;
  final DateTime? expiresAt;
  final Map<String, Object?>? providerResult;
  final Map<String, Object?> publicReceipt;
}

class AttriaxRawDeepLinkEvent {
  const AttriaxRawDeepLinkEvent({
    required this.uri,
    required this.receivedAt,
    required this.isInitial,
  });

  factory AttriaxRawDeepLinkEvent.fromJson(
    Map<String, Object?> json,
  ) => AttriaxRawDeepLinkEvent(
    uri: _jsonUri(json['uri']) ?? Uri(path: _jsonString(json['path']) ?? '/'),
    receivedAt: _requireJsonDateTime(json, 'receivedAt'),
    isInitial: _jsonBool(json['isInitial']) ?? false,
  );

  /// The full URI captured directly from the native deep-link source.
  final Uri uri;

  /// Local timestamp when the SDK observed the raw deep-link input.
  final DateTime receivedAt;

  /// Whether this raw event came from the launch link captured during startup.
  final bool isInitial;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'receivedAt': receivedAt.toIso8601String(),
    'isInitial': isInitial,
  };
}

class AttriaxDeepLinkReferrerDetails {
  const AttriaxDeepLinkReferrerDetails({
    required this.uri,
    required this.receivedAt,
    required this.clickedAt,
    required this.consumedAt,
    required this.trigger,
    required this.isAttriaxDomain,
    required this.found,
    this.data,
    this.utm,
    this.browserAction,
    this.handledBySdk = false,
  });

  final Uri uri;
  final DateTime receivedAt;
  final DateTime clickedAt;
  final DateTime consumedAt;
  final AttriaxDeepLinkTrigger trigger;
  final bool isAttriaxDomain;
  final bool found;
  final Map<String, String>? data;
  final AttriaxUtmParameters? utm;
  final AttriaxResolvedUrlAction? browserAction;
  final bool handledBySdk;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'receivedAt': receivedAt.toIso8601String(),
    'clickedAt': clickedAt.toIso8601String(),
    'consumedAt': consumedAt.toIso8601String(),
    'trigger': trigger.name,
    'isAttriaxDomain': isAttriaxDomain,
    'found': found,
    if (data != null && data!.isNotEmpty)
      'data': Map<String, String>.from(data!),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
    if (browserAction != null) 'browserAction': browserAction!.toJson(),
    'handledBySdk': handledBySdk,
  };
}

class AttriaxDeepLinkEvent {
  const AttriaxDeepLinkEvent({
    required this.uri,
    required this.clickedAt,
    required this.consumedAt,
    required this.found,
    required this.trigger,
    required this.isAttriaxSubDomain,
    this.rawEvent,
    this.data,
    this.utm,
    this.browserAction,
    this.handledBySdk = false,
  });

  factory AttriaxDeepLinkEvent.fromJson(Map<String, Object?> json) {
    final utmJson = _jsonObject(json['utm']);
    final browserActionJson = _jsonObject(json['browserAction']);
    final rawEventJson = _jsonObject(json['rawEvent']);

    return AttriaxDeepLinkEvent(
      uri: _jsonUri(json['uri']) ?? Uri(path: _jsonString(json['path']) ?? '/'),
      clickedAt: _requireJsonDateTime(json, 'clickedAt'),
      consumedAt: _requireJsonDateTime(json, 'consumedAt'),
      found: _jsonBool(json['found']) ?? false,
      trigger: _parseDeepLinkTrigger(_jsonString(json['trigger'])),
      isAttriaxSubDomain:
          _jsonBool(json['isAttriaxSubDomain']) ??
          _jsonBool(json['isAttriaxDomain']) ??
          false,
      rawEvent: rawEventJson == null
          ? null
          : AttriaxRawDeepLinkEvent.fromJson(rawEventJson),
      data: _jsonStringMap(json['data']),
      utm: utmJson == null ? null : AttriaxUtmParameters.fromJson(utmJson),
      browserAction: browserActionJson == null
          ? null
          : AttriaxResolvedUrlAction.fromJson(browserActionJson),
      handledBySdk: _jsonBool(json['handledBySdk']) ?? false,
    );
  }

  /// Canonical referrer URI when Attriax resolved one, or the incoming URI.
  final Uri uri;

  /// The original click timestamp.
  final DateTime clickedAt;

  /// The timestamp when Attriax processed and consumed the deep-link event.
  final DateTime consumedAt;

  /// Whether Attriax matched this event to a registered link.
  final bool found;

  /// Describes how this deep-link event was triggered.
  final AttriaxDeepLinkTrigger trigger;

  /// Whether the resolved URI belongs to an Attriax-managed subdomain.
  final bool isAttriaxSubDomain;

  /// Raw deep-link input that started this resolution, when available.
  final AttriaxRawDeepLinkEvent? rawEvent;

  /// Dashboard-configured key-value payload for matched links.
  final Map<String, String>? data;

  /// Resolved UTM parameters associated with the matched link.
  final AttriaxUtmParameters? utm;

  /// Browser destination returned by Attriax for SDK-managed handling.
  final AttriaxResolvedUrlAction? browserAction;

  /// Whether the SDK already handled the link by opening a browser.
  final bool handledBySdk;

  bool get isDeferred => trigger == AttriaxDeepLinkTrigger.deferred;

  bool get isColdStart => trigger == AttriaxDeepLinkTrigger.coldStart;

  bool get isForeground => trigger == AttriaxDeepLinkTrigger.foreground;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'clickedAt': clickedAt.toIso8601String(),
    'consumedAt': consumedAt.toIso8601String(),
    'found': found,
    'trigger': trigger.name,
    'isAttriaxSubDomain': isAttriaxSubDomain,
    if (rawEvent != null) 'rawEvent': rawEvent!.toJson(),
    if (data != null && data!.isNotEmpty)
      'data': Map<String, String>.from(data!),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
    if (browserAction != null) 'browserAction': browserAction!.toJson(),
    'handledBySdk': handledBySdk,
  };
}

class AttriaxDeepLinkResolutionResult {
  const AttriaxDeepLinkResolutionResult({
    required this.matched,
    required this.status,
    required this.isFirstLaunch,
    this.reason,
    this.deepLink,
    this.browserAction,
    this.requestVersion,
    this.acceptedAt,
    this.consumedAt,
  });

  factory AttriaxDeepLinkResolutionResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);
    final browserActionJson = _jsonObject(json['browserAction']);

    return AttriaxDeepLinkResolutionResult(
      matched: _jsonBool(json['matched']) ?? false,
      status: _parseResolutionStatus(_jsonString(json['status'])),
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      reason: _jsonString(json['reason']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
      browserAction: browserActionJson != null
          ? AttriaxResolvedUrlAction.fromJson(browserActionJson)
          : null,
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
      consumedAt: _jsonDateTime(json['consumedAt']),
    );
  }

  final bool matched;
  final AttriaxDeepLinkResolutionStatus status;
  final bool isFirstLaunch;
  final String? reason;
  final AttriaxDeepLink? deepLink;
  final AttriaxResolvedUrlAction? browserAction;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final DateTime? consumedAt;
}

/// Internal runtime result for the initial app-open tracking request.
class AttriaxAppOpenResult {
  const AttriaxAppOpenResult({
    required this.userId,
    required this.isNewUser,
    required this.isFirstLaunch,
    this.installState = AttriaxInstallState.existing,
    this.requestVersion,
    this.acceptedAt,
    this.deepLink,
    this.deepLinkClickedAt,
    this.deepLinkConsumedAt,
    this.originalInstallReferrer,
    this.reinstallReferrer,
    this.installReferrer,
    this.skan,
  });

  factory AttriaxAppOpenResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);
    final installReferrerJson = _jsonObject(json['installReferrer']);
    final originalInstallReferrerJson = _jsonObject(
      json['originalInstallReferrer'],
    );
    final reinstallReferrerJson = _jsonObject(json['reinstallReferrer']);
    final skanJson = _jsonObject(json['skan']);

    return AttriaxAppOpenResult(
      userId: _requireJsonString(json, 'userId'),
      isNewUser: _jsonBool(json['isNewUser']) ?? false,
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      installState: _parseInstallState(_jsonString(json['installState'])),
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
      deepLinkClickedAt: _jsonDateTime(json['deepLinkClickedAt']),
      deepLinkConsumedAt: _jsonDateTime(json['deepLinkConsumedAt']),
      originalInstallReferrer: originalInstallReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(originalInstallReferrerJson)
          : null,
      reinstallReferrer: reinstallReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(reinstallReferrerJson)
          : null,
      installReferrer: installReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(installReferrerJson)
          : null,
      skan: skanJson == null
          ? null
          : AttriaxSkanRuntimeConfiguration.fromJson(skanJson),
    );
  }

  final String userId;
  final bool isNewUser;
  final bool isFirstLaunch;
  final AttriaxInstallState installState;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final AttriaxDeepLink? deepLink;
  final DateTime? deepLinkClickedAt;
  final DateTime? deepLinkConsumedAt;
  final AttriaxInstallReferrerDetails? originalInstallReferrer;
  final AttriaxInstallReferrerDetails? reinstallReferrer;
  final AttriaxInstallReferrerDetails? installReferrer;
  final AttriaxSkanRuntimeConfiguration? skan;
}

/// Public app-open summary exposed after app-open tracking completes.
class AttriaxAppOpen {
  const AttriaxAppOpen({
    required this.isNewUser,
    required this.isFirstLaunch,
    this.deepLink,
  });

  /// Whether Attriax created a new backend user for this app open.
  final bool isNewUser;

  /// Whether this app open belongs to the installation's first launch.
  final bool isFirstLaunch;

  /// Deferred deep link matched during the app-open flow, when available.
  final AttriaxDeepLink? deepLink;
}

typedef AttriaxInitResult = AttriaxAppOpen;

// ignore: one_member_abstracts
abstract interface class AttriaxClock {
  DateTime now();
}

final class AttriaxSystemClock implements AttriaxClock {
  const AttriaxSystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

final class AttriaxMutableClock implements AttriaxClock {
  AttriaxMutableClock(this.currentTime);

  DateTime currentTime;

  @override
  DateTime now() => currentTime;
}

/// Snapshot of the current SDK session tracked locally by Attriax.
class AttriaxSessionSnapshot {
  const AttriaxSessionSnapshot({
    required this.id,
    required this.deviceId,
    required this.platform,
    required this.isFirstLaunch,
    required this.startedAt,
    required this.lastActivityAt,
    required this.heartbeatInterval,
    this.locale,
    this.appVersion,
    this.appBuildNumber,
    this.appPackageName,
    this.sdkPackageVersion,
  });

  factory AttriaxSessionSnapshot.fromJson(Map<String, Object?> json) {
    final heartbeatIntervalMs = _requireJsonInt(json, 'heartbeatIntervalMs');

    return AttriaxSessionSnapshot(
      id: _requireJsonString(json, 'id'),
      deviceId: _requireJsonString(json, 'deviceId'),
      platform: _parsePlatformType(_jsonString(json['platform'])),
      locale: _jsonString(json['locale']),
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      startedAt: _requireJsonDateTime(json, 'startedAt').toUtc(),
      lastActivityAt: _requireJsonDateTime(json, 'lastActivityAt').toUtc(),
      heartbeatInterval: Duration(milliseconds: heartbeatIntervalMs),
      appVersion: _jsonString(json['appVersion']),
      appBuildNumber: _jsonString(json['appBuildNumber']),
      appPackageName: _jsonString(json['appPackageName']),
      sdkPackageVersion: _jsonString(json['sdkPackageVersion']),
    );
  }

  final String id;
  final String deviceId;
  final AttriaxPlatformType platform;
  final String? locale;
  final bool isFirstLaunch;
  final DateTime startedAt;
  final DateTime lastActivityAt;
  final Duration heartbeatInterval;
  final String? appVersion;
  final String? appBuildNumber;
  final String? appPackageName;
  final String? sdkPackageVersion;

  AttriaxSessionSnapshot copyWith({
    String? id,
    String? deviceId,
    AttriaxPlatformType? platform,
    String? locale,
    bool? isFirstLaunch,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    Duration? heartbeatInterval,
    String? appVersion,
    String? appBuildNumber,
    String? appPackageName,
    String? sdkPackageVersion,
  }) => AttriaxSessionSnapshot(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    platform: platform ?? this.platform,
    locale: locale ?? this.locale,
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    startedAt: startedAt ?? this.startedAt,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    heartbeatInterval: heartbeatInterval ?? this.heartbeatInterval,
    appVersion: appVersion ?? this.appVersion,
    appBuildNumber: appBuildNumber ?? this.appBuildNumber,
    appPackageName: appPackageName ?? this.appPackageName,
    sdkPackageVersion: sdkPackageVersion ?? this.sdkPackageVersion,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'deviceId': deviceId,
    'platform': platform.name,
    if (locale != null) 'locale': locale,
    'isFirstLaunch': isFirstLaunch,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'lastActivityAt': lastActivityAt.toUtc().toIso8601String(),
    'heartbeatIntervalMs': heartbeatInterval.inMilliseconds,
    if (appVersion != null) 'appVersion': appVersion,
    if (appBuildNumber != null) 'appBuildNumber': appBuildNumber,
    if (appPackageName != null) 'appPackageName': appPackageName,
    if (sdkPackageVersion != null) 'sdkPackageVersion': sdkPackageVersion,
  };
}

/// Immutable configuration used to construct an Attriax SDK instance.
class AttriaxConfig {
  /// Creates an SDK configuration with optional app/build metadata.
  const AttriaxConfig({
    required this.appToken,
    this.apiBaseUrl = 'https://api.attriax.com',
    this.appVersion,
    this.appBuildNumber,
    this.appPackageName,
    this.sdkMetadata = const <String, Object?>{},
    this.clock,
    this.enableDebugLogs,
    this.requestTimeout = const Duration(seconds: 12),
    this.maxQueueSize = 500,
    this.eventFlushInterval = const Duration(seconds: 60),
    this.flushEventsImmediatelyOnFirstLaunch = true,
    this.collectAdvertisingId = true,
    this.automaticCrashReportingEnabled = true,
    this.requestTrackingAuthorizationOnInit = false,
    this.trackingAuthorizationStatusTimeout = const Duration(seconds: 60),
    this.automaticBrowserHandling = true,
    this.sessionTrackingEnabled = true,
    this.sessionHeartbeatInterval = const Duration(minutes: 5),
    this.firstLaunchSessionHeartbeatInterval = const Duration(seconds: 30),
    this.skan,
  });

  /// Application token issued by Attriax for the current app.
  final String appToken;

  /// Base URL for the Attriax API.
  ///
  /// Leave this at the production default unless you are targeting a local,
  /// staging, or self-hosted Attriax environment.
  final String apiBaseUrl;

  /// Optional app version string attached to SDK requests.
  final String? appVersion;

  /// Optional app build number attached to SDK requests.
  final String? appBuildNumber;

  /// Optional application package identifier attached to SDK requests.
  final String? appPackageName;

  /// Extra SDK metadata sent with requests as a normalized JSON object.
  final Map<String, Object?> sdkMetadata;

  /// Optional clock implementation used by the SDK for time-sensitive behavior.
  final AttriaxClock? clock;

  /// Overrides whether verbose SDK logs are emitted.
  ///
  /// When `null`, the SDK defaults to debug logging in debug builds and a more
  /// restrictive log level in release builds.
  final bool? enableDebugLogs;

  /// Per-request timeout applied to outbound Attriax API calls.
  final Duration requestTimeout;

  /// Maximum number of queued requests persisted locally for retry.
  final int maxQueueSize;

  /// Minimum delay between automatic flushes of regular queued events.
  ///
  /// Non-important events are buffered locally after first launch and flushed
  /// when this interval elapses, unless a later important request drains the
  /// queue sooner. Set this to `Duration.zero` to keep immediate event flushes.
  final Duration eventFlushInterval;

  /// Whether regular events should still flush immediately during first launch.
  ///
  /// When `true`, event requests keep the current eager delivery behavior for
  /// the installation's first launch session. Later launches use
  /// [eventFlushInterval] unless a caller marks an event as important.
  final bool flushEventsImmediatelyOnFirstLaunch;

  /// Whether native platform collectors may include advertising identifiers.
  ///
  /// Android uses this to control GAID collection. Apple platforms use it with
  /// App Tracking Transparency authorization to control SDK-managed IDFA
  /// collection. Host apps may still call the public ATT status/request APIs
  /// even when this is false.
  final bool collectAdvertisingId;

  /// Whether Attriax installs automatic Flutter/native crash handlers.
  ///
  /// Manual `Attriax.recordError` calls remain available when this is false.
  final bool automaticCrashReportingEnabled;

  /// Whether the SDK should request ATT authorization during startup.
  ///
  /// When this is `true` and [collectAdvertisingId] is enabled, the SDK calls
  /// ATT during initialization and waits for the user-driven result before it
  /// collects native context.
  final bool requestTrackingAuthorizationOnInit;

  /// Maximum time to poll ATT status during startup when
  /// [requestTrackingAuthorizationOnInit] is `false`.
  ///
  /// This wait is only used while initialization is collecting native context.
  /// Explicit `Attriax.requestTrackingAuthorization` calls do not use this
  /// timeout unless the caller passes one directly.
  final Duration trackingAuthorizationStatusTimeout;

  /// Whether the SDK opens backend-provided browser actions automatically.
  final bool automaticBrowserHandling;

  /// Enables automatic session lifecycle tracking and session enrichment.
  final bool sessionTrackingEnabled;

  /// Heartbeat interval used for established sessions after first launch.
  final Duration sessionHeartbeatInterval;

  /// Heartbeat interval used during the installation's first launch session.
  final Duration firstLaunchSessionHeartbeatInterval;

  /// Optional SKAdNetwork configuration for Apple-platform conversion updates.
  ///
  /// Leave this `null` to use the default SKAN behavior: enabled with schema
  /// loading from the dashboard-managed app-open response and the latest saved
  /// local fallback when the network request has not completed yet.
  final AttriaxSkanConfig? skan;
}

String _skanUpdateStatusToJson(AttriaxSkanUpdateStatus value) =>
    switch (value) {
      AttriaxSkanUpdateStatus.updated => 'updated',
      AttriaxSkanUpdateStatus.skipped => 'skipped',
      AttriaxSkanUpdateStatus.alreadyAtOrAboveValue =>
        'already_at_or_above_value',
      AttriaxSkanUpdateStatus.invalidValue => 'invalid_value',
      AttriaxSkanUpdateStatus.disabled => 'disabled',
      AttriaxSkanUpdateStatus.notSupported => 'not_supported',
      AttriaxSkanUpdateStatus.error => 'error',
    };

String _skanRuleOperatorToJson(AttriaxSkanRuleOperator value) =>
    switch (value) {
      AttriaxSkanRuleOperator.exists => 'exists',
      AttriaxSkanRuleOperator.eq => 'eq',
      AttriaxSkanRuleOperator.notEq => 'not_eq',
      AttriaxSkanRuleOperator.gt => 'gt',
      AttriaxSkanRuleOperator.gte => 'gte',
      AttriaxSkanRuleOperator.lt => 'lt',
      AttriaxSkanRuleOperator.lte => 'lte',
      AttriaxSkanRuleOperator.contains => 'contains',
    };

AttriaxSkanRuleOperator? _attriaxSkanRuleOperatorFromJson(String? value) =>
    switch (value) {
      'exists' => AttriaxSkanRuleOperator.exists,
      'eq' => AttriaxSkanRuleOperator.eq,
      'not_eq' => AttriaxSkanRuleOperator.notEq,
      'gt' => AttriaxSkanRuleOperator.gt,
      'gte' => AttriaxSkanRuleOperator.gte,
      'lt' => AttriaxSkanRuleOperator.lt,
      'lte' => AttriaxSkanRuleOperator.lte,
      'contains' => AttriaxSkanRuleOperator.contains,
      _ => null,
    };

AttriaxSkanCoarseValue? _attriaxSkanCoarseValueFromJson(String? value) =>
    switch (value) {
      'low' => AttriaxSkanCoarseValue.low,
      'medium' => AttriaxSkanCoarseValue.medium,
      'high' => AttriaxSkanCoarseValue.high,
      _ => null,
    };

AttriaxSkanUpdateStatus? _attriaxSkanUpdateStatusFromJson(String? value) =>
    switch (value) {
      'updated' => AttriaxSkanUpdateStatus.updated,
      'skipped' => AttriaxSkanUpdateStatus.skipped,
      'already_at_or_above_value' =>
        AttriaxSkanUpdateStatus.alreadyAtOrAboveValue,
      'invalid_value' => AttriaxSkanUpdateStatus.invalidValue,
      'disabled' => AttriaxSkanUpdateStatus.disabled,
      'not_supported' => AttriaxSkanUpdateStatus.notSupported,
      'error' => AttriaxSkanUpdateStatus.error,
      _ => null,
    };

Map<String, Object?> _jsonObjectOrEmpty(Object? value) =>
    _jsonObject(value) ?? const <String, Object?>{};

Map<String, Object?>? _jsonObject(Object? value) {
  if (value is! Map) {
    return null;
  }

  return value.map(
    (key, nestedValue) =>
        MapEntry(key.toString(), _normalizeJsonValue(nestedValue)),
  );
}

Map<String, Object?> _normalizeJsonMap(Map<String, Object?> input) =>
    input.map((key, value) => MapEntry(key, _normalizeJsonValue(value)));

Object? _normalizeJsonValue(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is List) {
    return value.map(_normalizeJsonValue).toList(growable: false);
  }
  if (value is Map) {
    return value.map(
      (key, nestedValue) =>
          MapEntry(key.toString(), _normalizeJsonValue(nestedValue)),
    );
  }
  return value.toString();
}

String? _jsonString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  return null;
}

String _requireJsonString(Map<String, Object?> json, String key) {
  final value = _jsonString(json[key]);
  if (value == null) {
    throw FormatException('Missing or invalid "$key".');
  }
  return value;
}

bool? _jsonBool(Object? value) => value is bool ? value : null;

int? _jsonInt(Object? value) => value is num ? value.toInt() : null;

double? _jsonDouble(Object? value) => value is num ? value.toDouble() : null;

DateTime? _jsonDateTime(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

Uri? _jsonUri(Object? value) {
  final stringValue = _jsonString(value);
  if (stringValue == null) {
    return null;
  }

  return Uri.tryParse(stringValue);
}

Map<String, String>? _jsonStringMap(Object? value) {
  final json = _jsonObject(value);
  if (json == null || json.isEmpty) {
    return null;
  }

  return <String, String>{
    for (final entry in json.entries)
      entry.key: entry.value == null ? '' : entry.value.toString(),
  };
}

DateTime _requireJsonDateTime(Map<String, Object?> json, String key) {
  final value = _jsonDateTime(json[key]);
  if (value == null) {
    throw FormatException('Missing or invalid "$key".');
  }
  return value;
}

int _requireJsonInt(Map<String, Object?> json, String key) {
  final value = _jsonInt(json[key]);
  if (value == null) {
    throw FormatException('Missing or invalid "$key".');
  }
  return value;
}

AttributionType _parseAttributionType(String? value) {
  switch (value) {
    case 'referrer':
      return AttributionType.referrer;
    case 'fingerprint':
      return AttributionType.fingerprint;
    case 'external':
      return AttributionType.external;
    case 'organic':
    default:
      return AttributionType.organic;
  }
}

AttriaxInstallState _parseInstallState(String? value) {
  switch (value) {
    case 'new_install':
      return AttriaxInstallState.newInstall;
    case 'reinstall':
      return AttriaxInstallState.reinstall;
    case 'app_data_clear':
      return AttriaxInstallState.appDataClear;
    case 'existing':
    default:
      return AttriaxInstallState.existing;
  }
}

AttriaxDeepLinkResolutionStatus _parseResolutionStatus(String? value) {
  switch (value) {
    case 'matched':
      return AttriaxDeepLinkResolutionStatus.matched;
    case 'unmatched':
      return AttriaxDeepLinkResolutionStatus.unmatched;
    case 'invalid':
    default:
      return AttriaxDeepLinkResolutionStatus.invalid;
  }
}

AttriaxDeepLinkTrigger _parseDeepLinkTrigger(String? value) {
  switch (value) {
    case 'coldStart':
      return AttriaxDeepLinkTrigger.coldStart;
    case 'deferred':
      return AttriaxDeepLinkTrigger.deferred;
    case 'foreground':
    default:
      return AttriaxDeepLinkTrigger.foreground;
  }
}

AttriaxResolvedUrlOpenMode _parseResolvedUrlOpenMode(String? value) {
  switch (value) {
    case 'in_app':
    case 'inApp':
      return AttriaxResolvedUrlOpenMode.inApp;
    case 'external':
      return AttriaxResolvedUrlOpenMode.external;
    case 'unknown':
    default:
      return AttriaxResolvedUrlOpenMode.unknown;
  }
}

AttriaxRevenueReceiptValidationStatus _parseRevenueReceiptValidationStatus(
  String? value,
) {
  switch (value) {
    case 'verified':
      return AttriaxRevenueReceiptValidationStatus.verified;
    case 'pending':
      return AttriaxRevenueReceiptValidationStatus.pending;
    case 'unconfigured':
      return AttriaxRevenueReceiptValidationStatus.unconfigured;
    case 'provider_error':
      return AttriaxRevenueReceiptValidationStatus.providerError;
    case 'passthrough':
      return AttriaxRevenueReceiptValidationStatus.passthrough;
    case 'rejected':
    default:
      return AttriaxRevenueReceiptValidationStatus.rejected;
  }
}

AttriaxPlatformType _parsePlatformType(String? value) {
  switch (value) {
    case 'ios':
      return AttriaxPlatformType.ios;
    case 'android':
      return AttriaxPlatformType.android;
    case 'web':
      return AttriaxPlatformType.web;
    case 'windows':
      return AttriaxPlatformType.windows;
    case 'macos':
      return AttriaxPlatformType.macos;
    case 'linux':
      return AttriaxPlatformType.linux;
    case 'unknown':
    default:
      return AttriaxPlatformType.unknown;
  }
}
