import 'dart:async';

import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';

abstract interface class AttriaxRuntimeSettingsView {
  bool get isEnabled;
  bool get areEventsEnabled;
}

class AttriaxRuntimeSettingsState implements AttriaxRuntimeSettingsView {
  AttriaxRuntimeSettingsState({
    required AttriaxPreferencesStore preferencesStore,
    required AttriaxLogger logger,
  }) : _preferencesStore = preferencesStore,
       _logger = logger;

  final AttriaxPreferencesStore _preferencesStore;
  final AttriaxLogger _logger;

  bool _isEnabled = true;
  bool _areEventsEnabled = true;
  bool? _requestedEnabledOverride;
  bool? _requestedEventsEnabledOverride;
  Future<void> _enabledTransition = Future<void>.value();
  Future<void> _eventsEnabledTransition = Future<void>.value();

  @override
  bool get isEnabled => _isEnabled;
  @override
  bool get areEventsEnabled => _areEventsEnabled;
  bool? get requestedEnabledOverride => _requestedEnabledOverride;
  bool? get requestedEventsEnabledOverride => _requestedEventsEnabledOverride;

  void restore({required bool enabled, required bool eventsEnabled}) {
    _isEnabled = enabled;
    _areEventsEnabled = eventsEnabled;
    _requestedEnabledOverride = enabled;
    _requestedEventsEnabledOverride = eventsEnabled;
  }

  void setEnabled({
    required bool enabled,
    required bool initialized,
    required Future<void> Function(bool enabled) applyState,
    void Function()? onPreparingToEnable,
  }) {
    _requestedEnabledOverride = enabled;
    if (_isEnabled == enabled && initialized) {
      _enabledTransition = _enabledTransition.then(
        (_) => _persistEnabledPreference(enabled),
      );
      return;
    }

    _isEnabled = enabled;
    if (enabled) {
      onPreparingToEnable?.call();
    }

    _enabledTransition = _enabledTransition
        .then((_) => _persistEnabledPreference(enabled))
        .then((_) => applyState(enabled))
        .catchError((Object error, StackTrace stackTrace) {
          _logger.error(
            'Failed to update Attriax enabled state.',
            error: error,
            stackTrace: stackTrace,
          );
        });
  }

  void setEventsEnabled({required bool enabled}) {
    _requestedEventsEnabledOverride = enabled;
    _areEventsEnabled = enabled;
    _logger.verbose(
      'Attriax custom events ${enabled ? 'enabled' : 'disabled'}.',
    );

    _eventsEnabledTransition = _eventsEnabledTransition
        .then((_) => _persistEventsEnabledPreference(enabled))
        .catchError((Object error, StackTrace stackTrace) {
          _logger.error(
            'Failed to update Attriax event preference state.',
            error: error,
            stackTrace: stackTrace,
          );
        });
  }

  Future<void> _persistEnabledPreference(bool enabled) async {
    try {
      await _preferencesStore.setSdkEnabled(enabled: enabled);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to persist the Attriax enabled preference.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _persistEventsEnabledPreference(bool enabled) async {
    try {
      await _preferencesStore.setEventsEnabled(enabled: enabled);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to persist the Attriax event preference.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
