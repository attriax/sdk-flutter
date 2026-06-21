import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import '../attriax_analytics_keys.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';
import 'skan/attriax_skan_conversion_updater.dart';
import 'skan/attriax_skan_event_augmenter.dart';
import 'skan/attriax_skan_event_resolution.dart';
import 'skan/attriax_skan_rules.dart';

const String _attriaxRetentionEventName = '_attriax_retention';

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
       _platformType = platformType,
       _clock = clock,
       _logger = logger,
       _conversionUpdater = AttriaxSkanConversionUpdater(
         platform: platform,
         platformType: platformType,
         clock: clock,
       ),
       _eventAugmenter = AttriaxSkanEventAugmenter(
         clock: clock,
         logger: logger,
         usdRevenueConverter: usdRevenueConverter,
       );

  final AttriaxConfig _config;
  final AttriaxSkanStore _preferencesStore;
  final AttriaxPlatformType _platformType;
  final AttriaxClock _clock;
  final AttriaxLogger _logger;
  final AttriaxSkanConversionUpdater _conversionUpdater;
  final AttriaxSkanEventAugmenter _eventAugmenter;

  AttriaxSkanState? _state;

  // Serializes all state-mutating operations. The SKAN state is read, mutated
  // and persisted across `await` boundaries (event augmentation, the native
  // bridge call); without this lock two concurrent tracked events could each
  // read the same `_state`, mutate independently, and the second persist would
  // clobber the first (lost purchase/ad counter increments). Internal helpers
  // call the `*Unlocked` variants so the lock is never re-entered.
  Future<void> _operationLock = Future<void>.value();

  bool get _supportsSkan => attriaxPlatformSupportsSkan(_platformType);

  AttriaxSkanState? get state => _supportsSkan ? _state : null;

  AttriaxSkanConfig get _effectiveConfig =>
      _config.skan ?? const AttriaxSkanConfig();

  Future<void> init({required bool isFirstLaunch}) =>
      _withLock(() => _initUnlocked(isFirstLaunch: isFirstLaunch));

  Future<void> _initUnlocked({required bool isFirstLaunch}) async {
    if (!_supportsSkan) {
      await _resetUnlocked();
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

    await _updateConversionValueUnlocked(
      fineValue: 0,
      markFirstLaunchValueRegistered: true,
    );
    await _evaluateRetentionMilestones();
  }

  Future<void> reset() => _withLock(_resetUnlocked);

  Future<void> _resetUnlocked() async {
    _state = null;
    await _preferencesStore.setSkanState(state: null);
  }

  Future<void> applyAppOpenResult(AttriaxAppOpenResult? result) =>
      _withLock(() => _applyAppOpenResultUnlocked(result));

  Future<void> _applyAppOpenResultUnlocked(AttriaxAppOpenResult? result) async {
    if (!_supportsSkan) {
      await _resetUnlocked();
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
      await _updateConversionValueUnlocked(
        fineValue: 0,
        markFirstLaunchValueRegistered: true,
      );
    }

    await _evaluateRetentionMilestones();
  }

  Future<AttriaxSkanUpdateResult> updateConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
    bool markFirstLaunchValueRegistered = false,
  }) => _withLock(
    () => _updateConversionValueUnlocked(
      fineValue: fineValue,
      coarseValue: coarseValue,
      lockWindow: lockWindow,
      markFirstLaunchValueRegistered: markFirstLaunchValueRegistered,
    ),
  );

  Future<AttriaxSkanUpdateResult> _updateConversionValueUnlocked({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
    bool markFirstLaunchValueRegistered = false,
  }) async {
    final update = await _conversionUpdater.update(
      currentState: _supportsSkan ? _ensureState() : null,
      fineValue: fineValue,
      coarseValue: coarseValue,
      lockWindow: lockWindow,
      markFirstLaunchValueRegistered: markFirstLaunchValueRegistered,
    );
    final nextState = update.nextState;
    if (nextState != null) {
      _state = nextState;
      await _persistState();
    }

    return update.result;
  }

  Future<AttriaxSkanUpdateResult?> handleTrackedEvent(
    String eventName, {
    Map<String, Object?>? eventData,
  }) => !_supportsSkan
      ? Future<AttriaxSkanUpdateResult?>.value()
      : _withLock(
          () =>
              _applyEventCandidates(eventName: eventName, eventData: eventData),
        );

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
      SkanActiveWindow.window1 => _applyWindow1Groups(
        currentState: currentState,
        eventName: normalizedEventName,
        eventData: payload,
        groups: schema.window1.groups,
      ),
      SkanActiveWindow.window2 => _applyCoarseWindowEvents(
        currentState: currentState,
        eventName: normalizedEventName,
        eventData: payload,
        events: schema.window2.events,
      ),
      SkanActiveWindow.window3 => _applyCoarseWindowEvents(
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
    final update = resolveWindow1SkanUpdate(
      currentState: currentState,
      eventName: eventName,
      eventData: eventData,
      groups: groups,
    );
    if (update == null) {
      return null;
    }

    return _updateConversionValueUnlocked(
      fineValue: update.fineValue,
      coarseValue: update.coarseValue,
      lockWindow: update.lockWindow,
    );
  }

  Future<AttriaxSkanUpdateResult?> _applyCoarseWindowEvents({
    required AttriaxSkanState currentState,
    required String eventName,
    required Map<String, Object?> eventData,
    required List<AttriaxSkanCoarseWindowEvent> events,
  }) async {
    final update = resolveCoarseWindowSkanUpdate(
      currentState: currentState,
      eventName: eventName,
      eventData: eventData,
      events: events,
    );
    if (update == null) {
      return null;
    }

    return _updateConversionValueUnlocked(
      fineValue: update.fineValue,
      coarseValue: update.coarseValue,
      lockWindow: update.lockWindow,
    );
  }

  SkanActiveWindow? _activeWindowForState(AttriaxSkanState state) {
    final installAnchorAt = state.installAnchorAt;
    if (installAnchorAt == null) {
      return SkanActiveWindow.window1;
    }

    final currentDay = skanRetentionDay(installAnchorAt, _clock.now().toUtc());
    return activeSkanWindowForDay(currentDay);
  }

  Future<Map<String, Object?>> _augmentLocalEventData({
    required String eventName,
    required Map<String, Object?> eventData,
  }) async {
    final augmentation = await _eventAugmenter.augment(
      eventName: eventName,
      eventData: eventData,
      state: _ensureState(),
    );
    if (augmentation.stateChanged) {
      _state = augmentation.state;
      await _persistState();
    }

    return augmentation.eventData;
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

    final actualDay = skanRetentionDay(installAnchorAt, _clock.now().toUtc());
    final activeWindow = activeSkanWindowForDay(actualDay);
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

      final milestoneWindow = activeSkanWindowForDay(day);
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

      final milestoneWindow = activeSkanWindowForDay(day);
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

      final number = coerceSkanNumber(condition.value);
      if (number == null) {
        continue;
      }

      final day = number.toInt();
      if (day >= 0 && day.toDouble() == number) {
        days.add(day);
      }
    }
  }

  Future<void> _persistState() async {
    await _preferencesStore.setSkanState(state: _state);
    _logger.verbose('Updated local SKAN state: ${_state?.toJson()}');
  }

  /// Runs [action] after any in-flight SKAN operation completes, so the
  /// read-modify-persist cycle on [_state] is never interleaved.
  Future<T> _withLock<T>(Future<T> Function() action) {
    final completer = Completer<void>();
    final previous = _operationLock;
    _operationLock = completer.future;

    return previous.then((_) => action()).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
  }
}
