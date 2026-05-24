import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import '../attriax_analytics_keys.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';

const String _attriaxRetentionEventName = '_attriax_retention';
const int _skanFineValueBitCount = 6;
const int _skanWindow1MaxDay = 2;
const int _skanWindow2MaxDay = 7;
const int _skanWindow3MaxDay = 35;
const int _microsPerUnit = 1000000;

typedef AttriaxSkanUsdRevenueConverter =
    Future<int?> Function({
      required int amountMicros,
      required String currency,
      required DateTime clientOccurredAt,
    });

class AttriaxSkanManager {
  AttriaxSkanManager({
    required AttriaxConfig config,
    required AttriaxSkanStore preferencesStore,
    required AttriaxPlatform platform,
    required AttriaxPlatformType platformType,
    required AttriaxClock clock,
    required AttriaxLogger logger,
    AttriaxSkanUsdRevenueConverter? usdRevenueConverter,
  }) : _config = config,
       _preferencesStore = preferencesStore,
       _platform = platform,
       _platformType = platformType,
       _clock = clock,
       _logger = logger,
       _usdRevenueConverter = usdRevenueConverter;

  final AttriaxConfig _config;
  final AttriaxSkanStore _preferencesStore;
  final AttriaxPlatform _platform;
  final AttriaxPlatformType _platformType;
  final AttriaxClock _clock;
  final AttriaxLogger _logger;
  final AttriaxSkanUsdRevenueConverter? _usdRevenueConverter;

  AttriaxSkanState? _state;

  bool get _supportsSkan => _platformType == AttriaxPlatformType.ios;

  AttriaxSkanState? get state => _supportsSkan ? _state : null;

  AttriaxSkanConfig get _effectiveConfig =>
      _config.skan ?? const AttriaxSkanConfig();

  Future<void> init({required bool isFirstLaunch}) async {
    if (!_supportsSkan) {
      await reset();
      return;
    }

    final config = _effectiveConfig;
    final restoredState = await _preferencesStore.readSkanState();
    _state = (restoredState ?? AttriaxSkanState(enabled: config.enabled))
        .copyWith(
          enabled: config.enabled,
          installAnchorAt:
              restoredState?.installAnchorAt ??
              (isFirstLaunch ? _clock.now().toUtc() : null),
          schemaVersion:
              restoredState?.schemaVersion ?? restoredState?.schema?.version,
          schema: restoredState?.schema,
        );

    await _persistState();

    if (!config.enabled) {
      return;
    }

    if (!config.registerFirstLaunchValue || !isFirstLaunch) {
      await _evaluateRetentionMilestones();
      return;
    }

    final currentState = _state;
    if (currentState != null && currentState.firstLaunchValueRegistered) {
      await _evaluateRetentionMilestones();
      return;
    }

    await updateConversionValue(fineValue: 0);
    await _evaluateRetentionMilestones();
  }

  Future<void> reset() async {
    _state = null;
    await _preferencesStore.setSkanState(state: null);
  }

  Future<void> applyAppOpenResult(AttriaxAppOpenResult? result) async {
    if (!_supportsSkan) {
      await reset();
      return;
    }

    final currentState = _ensureState();
    final runtimeConfiguration = result?.skan;
    final installState = result?.installState ?? AttriaxInstallState.existing;
    final nextSchema = runtimeConfiguration?.schema ?? currentState.schema;
    final nextSchemaVersion = nextSchema?.version ?? currentState.schemaVersion;
    final schemaVersionChanged =
        nextSchemaVersion != null &&
        nextSchemaVersion != currentState.schemaVersion;

    var nextState = currentState.copyWith(
      enabled: runtimeConfiguration?.enabled ?? currentState.enabled,
      schemaVersion: nextSchemaVersion,
      schema: nextSchema,
      completedRetentionDays: schemaVersionChanged
          ? const <int>[]
          : currentState.completedRetentionDays,
    );

    if (installState != AttriaxInstallState.existing) {
      final installAnchorAt =
          result?.acceptedAt?.toUtc() ?? _clock.now().toUtc();
      nextState = nextState.copyWith(
        clearFineValue: true,
        clearCoarseValue: true,
        lockWindow: false,
        firstLaunchValueRegistered: false,
        lastUpdatedAt: installAnchorAt,
        installAnchorAt: installAnchorAt,
        completedRetentionDays: const <int>[],
        purchaseRevenueUsdMicros: 0,
        purchaseCount: 0,
        adShowCount: 0,
      );
    } else if (nextState.installAnchorAt == null &&
        result?.acceptedAt != null) {
      nextState = nextState.copyWith(
        installAnchorAt: result!.acceptedAt!.toUtc(),
      );
    }

    _state = nextState;
    await _persistState();

    if (installState != AttriaxInstallState.existing &&
        _effectiveConfig.registerFirstLaunchValue &&
        nextState.enabled &&
        !nextState.firstLaunchValueRegistered) {
      await updateConversionValue(fineValue: 0);
    }

    await _evaluateRetentionMilestones();
  }

  Future<AttriaxSkanUpdateResult> updateConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    if (!_supportsSkan) {
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.notSupported,
        message: 'SKAdNetwork updates are only supported on iOS.',
        state: state,
      );
    }

    final currentState = _ensureState();

    if (!currentState.enabled) {
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.disabled,
        message: 'SKAdNetwork is disabled for this SDK instance.',
        state: currentState,
      );
    }

    if (fineValue < 0 || fineValue > 63) {
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.invalidValue,
        message: 'fineValue must be between 0 and 63.',
        state: currentState,
      );
    }

    final nextFineValue = currentState.fineValue == null
        ? fineValue
        : (fineValue > currentState.fineValue!
              ? fineValue
              : currentState.fineValue!);
    final nextCoarseValue = _maxCoarseValue(
      currentState.coarseValue,
      coarseValue ?? _deriveCoarseValue(nextFineValue),
    );
    final nextLockWindow = currentState.lockWindow || lockWindow;

    final nextState = currentState.copyWith(
      fineValue: nextFineValue,
      coarseValue: nextCoarseValue,
      lockWindow: nextLockWindow,
      firstLaunchValueRegistered:
          currentState.firstLaunchValueRegistered || nextFineValue == 0,
      lastUpdatedAt: _clock.now().toUtc(),
    );

    if (currentState.fineValue == nextState.fineValue &&
        currentState.coarseValue == nextState.coarseValue &&
        currentState.lockWindow == nextState.lockWindow) {
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.alreadyAtOrAboveValue,
        message:
            'The requested conversion value does not advance the stored SKAN state.',
        fineValue: currentState.fineValue,
        coarseValue: currentState.coarseValue,
        lockWindow: currentState.lockWindow,
        state: currentState,
      );
    }

    final bridgeResult = await _platform.updateSkanConversionValue(
      fineValue: nextFineValue,
      coarseValue: nextCoarseValue,
      lockWindow: nextLockWindow,
    );

    if (bridgeResult.status == AttriaxSkanUpdateStatus.updated ||
        bridgeResult.status == AttriaxSkanUpdateStatus.skipped) {
      _state = nextState;
      await _persistState();
      return AttriaxSkanUpdateResult(
        status: bridgeResult.status,
        message: bridgeResult.message,
        fineValue: nextState.fineValue,
        coarseValue: nextState.coarseValue,
        lockWindow: nextState.lockWindow,
        state: nextState,
      );
    }

    return AttriaxSkanUpdateResult(
      status: bridgeResult.status,
      message: bridgeResult.message,
      fineValue: bridgeResult.fineValue,
      coarseValue: bridgeResult.coarseValue,
      lockWindow: bridgeResult.lockWindow,
      state: currentState,
    );
  }

  Future<AttriaxSkanUpdateResult?> handleTrackedEvent(
    String eventName, {
    Map<String, Object?>? eventData,
  }) async => !_supportsSkan
      ? null
      : _applyEventCandidates(eventName: eventName, eventData: eventData);

  AttriaxSkanState _ensureState() {
    final existingState = _state;
    if (existingState != null) {
      return existingState;
    }

    return AttriaxSkanState(enabled: _effectiveConfig.enabled);
  }

  Future<AttriaxSkanUpdateResult?> _applyEventCandidates({
    required String eventName,
    Map<String, Object?>? eventData,
  }) async {
    final normalizedEventName = eventName.trim();
    if (normalizedEventName.isEmpty) {
      return null;
    }

    var currentState = _ensureState();
    final schema = currentState.schema;
    if (!currentState.enabled || schema == null) {
      return null;
    }

    final payload = await _augmentLocalEventData(
      eventName: normalizedEventName,
      eventData: eventData ?? const <String, Object?>{},
    );
    currentState = _ensureState();
    final activeWindow = _activeWindowForState(currentState);
    if (activeWindow == null) {
      return null;
    }

    return switch (activeWindow) {
      _SkanActiveWindow.window1 => _applyWindow1Groups(
        currentState: currentState,
        eventName: normalizedEventName,
        eventData: payload,
        groups: schema.window1.groups,
      ),
      _SkanActiveWindow.window2 => _applyCoarseWindowEvents(
        currentState: currentState,
        eventName: normalizedEventName,
        eventData: payload,
        events: schema.window2.events,
      ),
      _SkanActiveWindow.window3 => _applyCoarseWindowEvents(
        currentState: currentState,
        eventName: normalizedEventName,
        eventData: payload,
        events: schema.window3.events,
      ),
    };
  }

  Future<AttriaxSkanUpdateResult?> _applyWindow1Groups({
    required AttriaxSkanState currentState,
    required String eventName,
    required Map<String, Object?> eventData,
    required List<AttriaxSkanWindow1Group> groups,
  }) async {
    if (groups.isEmpty) {
      return null;
    }

    var nextFineValue = currentState.fineValue ?? 0;
    var nextCoarseValue = currentState.coarseValue;
    var nextLockWindow = currentState.lockWindow;
    var matchedAnyGroup = false;

    for (final group in groups) {
      if (!_isValidBitRange(group.startBit, group.bitCount)) {
        continue;
      }

      final match = _matchedWindow1Event(
        group: group,
        eventName: eventName,
        eventData: eventData,
      );
      if (match == null) {
        continue;
      }

      matchedAnyGroup = true;
      final currentSegmentValue = _extractBitRangeValue(
        nextFineValue,
        startBit: group.startBit,
        bitCount: group.bitCount,
      );
      final nextSegmentValue = match.rank > currentSegmentValue
          ? match.rank
          : currentSegmentValue;
      nextFineValue = _replaceBitRangeValue(
        nextFineValue,
        startBit: group.startBit,
        bitCount: group.bitCount,
        value: nextSegmentValue,
      );
      nextCoarseValue = _maxCoarseValue(
        nextCoarseValue,
        match.event.coarseValue,
      );
      nextLockWindow = nextLockWindow || match.event.lockWindow;
    }

    if (!matchedAnyGroup) {
      return null;
    }

    return updateConversionValue(
      fineValue: nextFineValue,
      coarseValue: nextCoarseValue,
      lockWindow: nextLockWindow,
    );
  }

  Future<AttriaxSkanUpdateResult?> _applyCoarseWindowEvents({
    required AttriaxSkanState currentState,
    required String eventName,
    required Map<String, Object?> eventData,
    required List<AttriaxSkanCoarseWindowEvent> events,
  }) async {
    if (events.isEmpty) {
      return null;
    }

    var nextCoarseValue = currentState.coarseValue;
    var nextLockWindow = currentState.lockWindow;
    var matchedAnyEvent = false;

    for (final event in events) {
      if (event.eventName != eventName ||
          !_matchesConditions(event.conditions, eventData)) {
        continue;
      }

      matchedAnyEvent = true;
      nextCoarseValue = _maxCoarseValue(nextCoarseValue, event.coarseValue);
      nextLockWindow = nextLockWindow || event.lockWindow;
    }

    if (!matchedAnyEvent) {
      return null;
    }

    return updateConversionValue(
      fineValue: currentState.fineValue ?? 0,
      coarseValue: nextCoarseValue,
      lockWindow: nextLockWindow,
    );
  }

  _SkanActiveWindow? _activeWindowForState(AttriaxSkanState state) {
    final installAnchorAt = state.installAnchorAt;
    if (installAnchorAt == null) {
      return _SkanActiveWindow.window1;
    }

    final currentDay = _retentionDay(installAnchorAt, _clock.now().toUtc());
    return _activeWindowForDay(currentDay);
  }

  _SkanActiveWindow? _activeWindowForDay(int day) {
    if (day < 0) {
      return null;
    }
    if (day <= _skanWindow1MaxDay) {
      return _SkanActiveWindow.window1;
    }
    if (day <= _skanWindow2MaxDay) {
      return _SkanActiveWindow.window2;
    }
    if (day <= _skanWindow3MaxDay) {
      return _SkanActiveWindow.window3;
    }

    return null;
  }

  _SkanWindow1Match? _matchedWindow1Event({
    required AttriaxSkanWindow1Group group,
    required String eventName,
    required Map<String, Object?> eventData,
  }) {
    _SkanWindow1Match? match;

    for (var index = 0; index < group.events.length; index += 1) {
      final event = group.events[index];
      if (event.eventName != eventName ||
          !_matchesConditions(event.conditions, eventData)) {
        continue;
      }

      match = _SkanWindow1Match(rank: index + 1, event: event);
    }

    return match;
  }

  Future<Map<String, Object?>> _augmentLocalEventData({
    required String eventName,
    required Map<String, Object?> eventData,
  }) async {
    if (eventName == AttriaxAnalyticsEventKeys.purchase) {
      return _augmentPurchaseEventData(eventData);
    }

    if (eventName == AttriaxAnalyticsEventKeys.adShow) {
      return _augmentAdShowEventData(eventData);
    }

    return eventData;
  }

  Future<Map<String, Object?>> _augmentPurchaseEventData(
    Map<String, Object?> eventData,
  ) async {
    final currentState = _ensureState();
    final usdMicros = await _resolvePurchaseUsdMicros(eventData);
    final nextRevenueUsdMicros =
        currentState.purchaseRevenueUsdMicros + (usdMicros ?? 0);
    final nextPurchaseCount = currentState.purchaseCount + 1;

    _state = currentState.copyWith(
      purchaseRevenueUsdMicros: nextRevenueUsdMicros,
      purchaseCount: nextPurchaseCount,
    );
    await _persistState();

    return <String, Object?>{
      ...eventData,
      AttriaxAnalyticsParamKeys.revenue: nextRevenueUsdMicros / _microsPerUnit,
      'count': nextPurchaseCount,
    };
  }

  Future<Map<String, Object?>> _augmentAdShowEventData(
    Map<String, Object?> eventData,
  ) async {
    final currentState = _ensureState();
    final nextAdShowCount = currentState.adShowCount + 1;

    _state = currentState.copyWith(adShowCount: nextAdShowCount);
    await _persistState();

    return <String, Object?>{
      ...eventData,
      'shown': nextAdShowCount,
      'count': nextAdShowCount,
    };
  }

  Future<int?> _resolvePurchaseUsdMicros(Map<String, Object?> eventData) async {
    final revenue = _coerceNumber(eventData[AttriaxAnalyticsParamKeys.revenue]);
    if (revenue == null) {
      return null;
    }

    final revenueInMicros =
        _readBool(eventData['revenueInMicros']) ??
        _readBool(eventData['revenue_in_micros']) ??
        false;
    final amountMicros = _toMicros(revenue, alreadyMicros: revenueInMicros);
    final currency =
        _readString(
          eventData[AttriaxAnalyticsParamKeys.currency],
        )?.toUpperCase() ??
        'USD';
    if (currency == 'USD') {
      return amountMicros;
    }

    final converter = _usdRevenueConverter;
    if (converter == null) {
      _logger.warning(
        'Skipping non-USD purchase revenue for SKAN because no USD conversion transport is available.',
      );
      return null;
    }

    try {
      return await converter(
        amountMicros: amountMicros,
        currency: currency,
        clientOccurredAt: _clock.now().toUtc(),
      );
    } catch (error) {
      _logger.warning(
        'Failed to convert purchase revenue to USD for SKAN.',
        error: error,
      );
      // If we unable to get a conversion, we optimistically treat the revenue as $1 USD to avoid missing out on potential SKAN value updates
      return 1;
    }
  }

  String? _readString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return null;
  }

  bool? _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }

    return null;
  }

  int _toMicros(double value, {required bool alreadyMicros}) =>
      (alreadyMicros ? value : value * _microsPerUnit).round();

  bool _matchesConditions(
    List<AttriaxSkanCondition> conditions,
    Map<String, Object?> eventData,
  ) {
    if (conditions.isEmpty) {
      return true;
    }

    for (final condition in conditions) {
      final hasValue = eventData.containsKey(condition.paramKey);
      final actualValue = hasValue ? eventData[condition.paramKey] : null;

      if (!_conditionMatches(
        condition: condition,
        actualValue: actualValue,
        hasValue: hasValue,
      )) {
        return false;
      }
    }

    return true;
  }

  bool _conditionMatches({
    required AttriaxSkanCondition condition,
    required Object? actualValue,
    required bool hasValue,
  }) {
    switch (condition.operator) {
      case AttriaxSkanRuleOperator.exists:
        return hasValue && actualValue != null;
      case AttriaxSkanRuleOperator.eq:
        return hasValue && _valuesEqual(actualValue, condition.value);
      case AttriaxSkanRuleOperator.notEq:
        return hasValue && !_valuesEqual(actualValue, condition.value);
      case AttriaxSkanRuleOperator.gt:
      case AttriaxSkanRuleOperator.gte:
      case AttriaxSkanRuleOperator.lt:
      case AttriaxSkanRuleOperator.lte:
        final actualNumber = _coerceNumber(actualValue);
        final expectedNumber = _coerceNumber(condition.value);
        if (!hasValue || actualNumber == null || expectedNumber == null) {
          return false;
        }

        return switch (condition.operator) {
          AttriaxSkanRuleOperator.gt => actualNumber > expectedNumber,
          AttriaxSkanRuleOperator.gte => actualNumber >= expectedNumber,
          AttriaxSkanRuleOperator.lt => actualNumber < expectedNumber,
          AttriaxSkanRuleOperator.lte => actualNumber <= expectedNumber,
          _ => false,
        };
      case AttriaxSkanRuleOperator.contains:
        if (!hasValue || actualValue == null || condition.value == null) {
          return false;
        }

        final expectedValue = condition.value;
        if (actualValue is String && expectedValue is String) {
          return actualValue.toLowerCase().contains(
            expectedValue.toLowerCase(),
          );
        }

        if (actualValue is List) {
          return actualValue.any(
            (value) => _valuesEqual(value, condition.value),
          );
        }

        return false;
    }
  }

  bool _valuesEqual(Object? left, Object? right) {
    final leftNumber = _coerceNumber(left);
    final rightNumber = _coerceNumber(right);
    if (leftNumber != null && rightNumber != null) {
      return leftNumber == rightNumber;
    }

    return left?.toString() == right?.toString();
  }

  double? _coerceNumber(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }

    return null;
  }

  bool _isValidBitRange(int startBit, int bitCount) =>
      startBit >= 0 &&
      bitCount > 0 &&
      startBit + bitCount <= _skanFineValueBitCount;

  int _extractBitRangeValue(
    int fineValue, {
    required int startBit,
    required int bitCount,
  }) {
    final mask = (1 << bitCount) - 1;
    return (fineValue >> startBit) & mask;
  }

  int _replaceBitRangeValue(
    int fineValue, {
    required int startBit,
    required int bitCount,
    required int value,
  }) {
    final maxValue = (1 << bitCount) - 1;
    final clampedValue = value < 0 ? 0 : (value > maxValue ? maxValue : value);
    final mask = maxValue << startBit;
    return (fineValue & ~mask) | ((clampedValue << startBit) & mask);
  }

  Future<AttriaxSkanUpdateResult?> _evaluateRetentionMilestones() async {
    final currentState = _ensureState();
    final schema = currentState.schema;
    final installAnchorAt = currentState.installAnchorAt;

    if (!currentState.enabled || schema == null || installAnchorAt == null) {
      return null;
    }

    final configuredDays = _configuredRetentionDays(
      schema,
    ).toList(growable: false)..sort();
    if (configuredDays.isEmpty) {
      return null;
    }

    final actualDay = _retentionDay(installAnchorAt, _clock.now().toUtc());
    final activeWindow = _activeWindowForDay(actualDay);
    final completedDays = currentState.completedRetentionDays.toSet();
    var stateChanged = false;

    if (activeWindow == null) {
      for (final day in configuredDays.where(
        (value) => value <= actualDay && !completedDays.contains(value),
      )) {
        completedDays.add(day);
        stateChanged = true;
      }

      if (stateChanged) {
        _state = currentState.copyWith(
          completedRetentionDays: completedDays.toList(growable: false)..sort(),
        );
        await _persistState();
      }

      return null;
    }

    for (final day in configuredDays) {
      if (day > actualDay || completedDays.contains(day)) {
        continue;
      }

      final milestoneWindow = _activeWindowForDay(day);
      if (milestoneWindow == null ||
          milestoneWindow.index < activeWindow.index) {
        completedDays.add(day);
        stateChanged = true;
      }
    }

    AttriaxSkanUpdateResult? latestResult;
    for (final day in configuredDays) {
      if (day > actualDay || completedDays.contains(day)) {
        continue;
      }

      final milestoneWindow = _activeWindowForDay(day);
      if (milestoneWindow != activeWindow) {
        continue;
      }

      latestResult = await _applyEventCandidates(
        eventName: _attriaxRetentionEventName,
        eventData: <String, Object?>{
          AttriaxAnalyticsParamKeys.day: day,
          AttriaxAnalyticsParamKeys.actualDay: actualDay,
        },
      );
      completedDays.add(day);
      stateChanged = true;
    }

    if (stateChanged) {
      _state = _ensureState().copyWith(
        completedRetentionDays: completedDays.toList(growable: false)..sort(),
      );
      await _persistState();
    }

    return latestResult;
  }

  Set<int> _configuredRetentionDays(AttriaxSkanSchema schema) {
    final days = <int>{};

    for (final group in schema.window1.groups) {
      for (final event in group.events) {
        _addRetentionDaysFromConditions(
          days,
          event.eventName,
          event.conditions,
        );
      }
    }

    for (final event in schema.window2.events) {
      _addRetentionDaysFromConditions(days, event.eventName, event.conditions);
    }

    for (final event in schema.window3.events) {
      _addRetentionDaysFromConditions(days, event.eventName, event.conditions);
    }

    return days;
  }

  void _addRetentionDaysFromConditions(
    Set<int> days,
    String eventName,
    List<AttriaxSkanCondition> conditions,
  ) {
    if (eventName != _attriaxRetentionEventName) {
      return;
    }

    for (final condition in conditions) {
      if (condition.paramKey != AttriaxAnalyticsParamKeys.day ||
          condition.operator != AttriaxSkanRuleOperator.eq) {
        continue;
      }

      final number = _coerceNumber(condition.value);
      if (number == null) {
        continue;
      }

      final day = number.toInt();
      if (day >= 0 && day.toDouble() == number) {
        days.add(day);
      }
    }
  }

  int _retentionDay(DateTime installAnchorAt, DateTime now) {
    final normalizedInstallDay = DateTime.utc(
      installAnchorAt.year,
      installAnchorAt.month,
      installAnchorAt.day,
    );
    final normalizedCurrentDay = DateTime.utc(now.year, now.month, now.day);
    final difference = normalizedCurrentDay
        .difference(normalizedInstallDay)
        .inDays;
    return difference < 0 ? 0 : difference;
  }

  AttriaxSkanCoarseValue _deriveCoarseValue(int fineValue) {
    if (fineValue >= 40) {
      return AttriaxSkanCoarseValue.high;
    }
    if (fineValue >= 20) {
      return AttriaxSkanCoarseValue.medium;
    }

    return AttriaxSkanCoarseValue.low;
  }

  AttriaxSkanCoarseValue? _maxCoarseValue(
    AttriaxSkanCoarseValue? current,
    AttriaxSkanCoarseValue? next,
  ) {
    if (current == null) {
      return next;
    }
    if (next == null) {
      return current;
    }

    return current.index >= next.index ? current : next;
  }

  Future<void> _persistState() async {
    await _preferencesStore.setSkanState(state: _state);
    _logger.verbose('Updated local SKAN state: ${_state?.toJson()}');
  }
}

enum _SkanActiveWindow { window1, window2, window3 }

class _SkanWindow1Match {
  const _SkanWindow1Match({required this.rank, required this.event});

  final int rank;
  final AttriaxSkanEvent event;
}
