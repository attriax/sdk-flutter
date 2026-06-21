part of 'types.dart';

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
