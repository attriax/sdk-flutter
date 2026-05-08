import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

class AttriaxInstallReferrerState {
  Completer<AttriaxInstallReferrerDetails?>? _completer;
  AttriaxInstallReferrerDetails? _cachedDetails;
  bool _completedForDisabled = false;
  bool _resolutionStarted = false;

  Future<AttriaxInstallReferrerDetails?> get future =>
      _completer?.future ??
      Future<AttriaxInstallReferrerDetails?>.error(
        StateError('Attriax SDK not initialized. Call init() first.'),
      );

  AttriaxInstallReferrerDetails? get cachedDetails => _cachedDetails;

  bool get hasPendingCompletion =>
      _completer != null && !_completer!.isCompleted;

  void ensureCompleter() {
    _completer ??= Completer<AttriaxInstallReferrerDetails?>();
  }

  void loadCached(AttriaxInstallReferrerDetails? details) {
    _cachedDetails ??= details;
  }

  void prepareForEnabledState() {
    if (_cachedDetails != null) {
      _reopenCompleterIfNeeded();
      complete(_cachedDetails);
      return;
    }

    _reopenCompleterIfNeeded();
  }

  void prepareForReenable() {
    _reopenCompleterIfNeeded();
  }

  bool markResolutionStarted() {
    if (_resolutionStarted) {
      return false;
    }

    _resolutionStarted = true;
    return true;
  }

  void cache(AttriaxInstallReferrerDetails? details) {
    if (details != null) {
      _cachedDetails = details;
    }
  }

  void complete(
    AttriaxInstallReferrerDetails? details, {
    bool disabledResult = false,
  }) {
    if (_completer == null || _completer!.isCompleted) {
      return;
    }

    cache(details);
    _completedForDisabled = disabledResult;
    _completer!.complete(details);
  }

  void completeCachedIfEnabled({required bool enabled}) {
    if (enabled && _cachedDetails != null && hasPendingCompletion) {
      complete(_cachedDetails);
    }
  }

  void _reopenCompleterIfNeeded() {
    if (_completer == null ||
        (_completer!.isCompleted && _completedForDisabled)) {
      _completer = Completer<AttriaxInstallReferrerDetails?>();
      _completedForDisabled = false;
    }
  }
}
