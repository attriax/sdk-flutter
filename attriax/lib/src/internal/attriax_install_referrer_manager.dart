import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

import 'attriax_app_open_manager.dart';
import 'attriax_preferences_store.dart';

class AttriaxInstallReferrerManager {
  AttriaxInstallReferrerManager({
    required AttriaxPreferencesStore preferencesStore,
    required AttriaxAppOpenManager appOpenManager,
  }) : _preferencesStore = preferencesStore,
       _appOpenManager = appOpenManager;

  final AttriaxPreferencesStore _preferencesStore;
  final AttriaxAppOpenManager _appOpenManager;

  Completer<AttriaxInstallReferrerDetails?>? _completer;
  AttriaxInstallReferrerDetails? _value;
  bool _isLoaded = false;
  bool _completedForDisabled = false;
  Future<void>? _observationFuture;
  int _observationGeneration = 0;

  Future<AttriaxInstallReferrerDetails?> get future =>
      _completer?.future ??
      Future<AttriaxInstallReferrerDetails?>.error(
        StateError('Attriax SDK not initialized. Call init() first.'),
      );

  bool get isLoaded => _isLoaded;
  AttriaxInstallReferrerDetails? get value => _value;

  Future<void> init({required bool enabled}) async {
    _ensureCompleter();
    final stored = await _preferencesStore.readStoredInstallReferrerDetails();
    _value ??= stored.value;
    _isLoaded = _isLoaded || stored.isLoaded;

    if (!enabled) {
      completeDisabled();
      return;
    }

    if (_isLoaded) {
      _reopenCompleterIfNeeded();
      _complete(_value);
      return;
    }

    _reopenCompleterIfNeeded();
    _ensureObservationStarted();
  }

  Future<void> prepareForEnabledState() async {
    if (!_isLoaded) {
      final stored = await _preferencesStore.readStoredInstallReferrerDetails();
      _value ??= stored.value;
      _isLoaded = _isLoaded || stored.isLoaded;
    }

    if (_isLoaded) {
      _reopenCompleterIfNeeded();
      _complete(_value);
      return;
    }

    _reopenCompleterIfNeeded();
    _ensureObservationStarted();
  }

  void prepareForReenable() {
    if (_isLoaded) {
      return;
    }

    _reopenCompleterIfNeeded();
    _ensureObservationStarted();
  }

  void reset() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }

    _observationGeneration += 1;
    _completer = null;
    _value = null;
    _isLoaded = false;
    _completedForDisabled = false;
    _observationFuture = null;
  }

  void completeDisabled() {
    _complete(null, disabledResult: true);
  }

  void dispose() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }
  }

  Future<void> _observeAppOpen(int generation) async {
    try {
      final result = await _appOpenManager.waitForScheduledResult();
      if (generation != _observationGeneration) {
        return;
      }

      final details = result?.installReferrer;
      _value = details;
      _isLoaded = true;
      await _preferencesStore.setStoredInstallReferrerDetails(
        isLoaded: true,
        details: details,
      );
      _complete(details);
    } catch (_) {
      if (generation != _observationGeneration) {
        return;
      }

      _value = null;
      _isLoaded = true;
      await _preferencesStore.setStoredInstallReferrerDetails(
        isLoaded: true,
        details: null,
      );
      _complete(null);
    }
  }

  void _ensureObservationStarted() {
    if (_isLoaded || _observationFuture != null) {
      return;
    }

    final generation = _observationGeneration;
    final observation = _observeAppOpen(generation);
    _observationFuture = observation;
    observation.whenComplete(() {
      if (identical(_observationFuture, observation)) {
        _observationFuture = null;
      }
    });
  }

  void _ensureCompleter() {
    _completer ??= Completer<AttriaxInstallReferrerDetails?>();
  }

  void _complete(
    AttriaxInstallReferrerDetails? details, {
    bool disabledResult = false,
  }) {
    if (_completer == null || _completer!.isCompleted) {
      return;
    }

    _completedForDisabled = disabledResult;
    _completer!.complete(details);
  }

  void _reopenCompleterIfNeeded() {
    if (_completer == null ||
        (_completer!.isCompleted && _completedForDisabled)) {
      _completer = Completer<AttriaxInstallReferrerDetails?>();
      _completedForDisabled = false;
    }
  }
}
