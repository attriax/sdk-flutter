import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

import 'attriax_app_open_monitor.dart';
import 'attriax_deep_link_manager.dart';
import 'attriax_platform_install_referrer_manager.dart';
import 'attriax_preferences_store.dart';
import 'referrers/attriax_deep_link_referrer_mapper.dart';
import 'referrers/attriax_raw_install_referrer_normalizer.dart';

class AttriaxReferrerManager {
  AttriaxReferrerManager({
    required AttriaxInstallReferrerDetailsStore preferencesStore,
    required AttriaxAppOpenMonitor appOpenMonitor,
    required AttriaxDeepLinkManager deepLinkManager,
    required AttriaxPlatformInstallReferrerManager
    platformInstallReferrerManager,
    String? Function()? currentSessionIdProvider,
  }) : _preferencesStore = preferencesStore,
       _appOpenMonitor = appOpenMonitor,
       _deepLinkManager = deepLinkManager,
       _platformInstallReferrerManager = platformInstallReferrerManager,
       _currentSessionIdProvider = currentSessionIdProvider ?? _noSessionId;

  final AttriaxInstallReferrerDetailsStore _preferencesStore;
  final AttriaxAppOpenMonitor _appOpenMonitor;
  final AttriaxDeepLinkManager _deepLinkManager;
  final AttriaxPlatformInstallReferrerManager _platformInstallReferrerManager;
  final String? Function() _currentSessionIdProvider;

  bool _didInit = false;
  bool _enabled = false;
  bool _localInstallReferrerOnly = false;
  String? _observedSessionId;

  Completer<AttriaxInstallReferrerDetails?>? _originalInstallCompleter;
  AttriaxInstallReferrerDetails? _originalInstallValue;
  bool _originalInstallLoaded = false;
  Object? _originalInstallError;
  StackTrace? _originalInstallStackTrace;

  Completer<AttriaxInstallReferrerDetails?>? _reinstallCompleter;
  AttriaxInstallReferrerDetails? _reinstallValue;
  bool _reinstallLoaded = false;
  Object? _reinstallError;
  StackTrace? _reinstallStackTrace;

  Completer<AttriaxDeepLinkReferrerDetails?>? _sessionReferrerCompleter;
  AttriaxDeepLinkReferrerDetails? _sessionReferrerValue;
  bool _sessionReferrerResolved = false;
  Object? _sessionReferrerError;
  StackTrace? _sessionReferrerStackTrace;

  AttriaxDeepLinkReferrerDetails? _latestDeepLinkValue;
  Object? _latestDeepLinkError;
  StackTrace? _latestDeepLinkStackTrace;

  Future<void>? _installObservationFuture;
  int _installObservationGeneration = 0;
  Future<void>? _sessionStartupObservationFuture;
  int _sessionObservationGeneration = 0;
  StreamSubscription<AttriaxDeepLinkEvent>? _deepLinkSubscription;

  Future<void> init({required bool enabled}) async {
    _didInit = true;
    _enabled = enabled;
    _localInstallReferrerOnly = false;
    await _restoreStoredInstallReferrers();
    _ensureDeepLinkSubscription();
    _syncSessionScope(forceReset: true);

    if (!_enabled) {
      return;
    }

    _ensureInstallObservationStarted();
    _ensureSessionStartupObservationStarted();
  }

  Future<void> prepareForEnabledState() async {
    final wasLocalInstallReferrerOnly = _localInstallReferrerOnly;
    _enabled = true;
    _localInstallReferrerOnly = false;
    _installObservationGeneration += 1;
    _installObservationFuture = null;
    if (wasLocalInstallReferrerOnly) {
      _resetInstallReferrerResolution();
    }
    await _restoreStoredInstallReferrers();
    _ensureDeepLinkSubscription();
    _syncSessionScope();
    _ensureInstallObservationStarted();
    _ensureSessionStartupObservationStarted();
  }

  void prepareForReenable() {
    _enabled = true;
    _localInstallReferrerOnly = false;
    _installObservationGeneration += 1;
    _installObservationFuture = null;
    _ensureDeepLinkSubscription();
    _syncSessionScope();
    _ensureInstallObservationStarted();
    _ensureSessionStartupObservationStarted();
  }

  void handleDisabled() {
    _enabled = false;
    _localInstallReferrerOnly = false;
  }

  Future<void> prepareForDeniedAttributionState() async {
    _enabled = true;
    _localInstallReferrerOnly = true;
    _installObservationGeneration += 1;
    _installObservationFuture = null;
    await _platformInstallReferrerManager.clearStoredReferrer();
    _setOriginalInstallValue(null);
    _setReinstallValue(null);
    await Future.wait(<Future<void>>[
      _preferencesStore.clearStoredInstallReferrerDetails(),
      _preferencesStore.clearStoredReinstallReferrerDetails(),
    ]);
    _ensureDeepLinkSubscription();
    _syncSessionScope();
    _ensureInstallObservationStarted();
    _ensureSessionStartupObservationStarted();
  }

  Future<String?> waitForRawInstallReferrer() async {
    if (!_didInit) {
      return Future<String?>.error(
        StateError('Attriax SDK not initialized. Call init() first.'),
      );
    }

    final value = await _platformInstallReferrerManager
        .loadRawInstallReferrer();
    return attriaxNormalizeRawInstallReferrer(value);
  }

  Future<AttriaxInstallReferrerDetails?> waitForOriginalInstallReferrer() {
    if (!_didInit) {
      return Future<AttriaxInstallReferrerDetails?>.error(
        StateError('Attriax SDK not initialized. Call init() first.'),
      );
    }

    final error = _originalInstallError;
    if (error != null) {
      return Future<AttriaxInstallReferrerDetails?>.error(
        error,
        _originalInstallStackTrace,
      );
    }

    if (_originalInstallLoaded) {
      return Future<AttriaxInstallReferrerDetails?>.value(
        _originalInstallValue,
      );
    }

    _ensureInstallObservationStarted();
    return (_originalInstallCompleter ??=
            Completer<AttriaxInstallReferrerDetails?>())
        .future;
  }

  Future<AttriaxInstallReferrerDetails?> waitForReinstallReferrer() {
    if (!_didInit) {
      return Future<AttriaxInstallReferrerDetails?>.error(
        StateError('Attriax SDK not initialized. Call init() first.'),
      );
    }

    final error = _reinstallError;
    if (error != null) {
      return Future<AttriaxInstallReferrerDetails?>.error(
        error,
        _reinstallStackTrace,
      );
    }

    if (_reinstallLoaded) {
      return Future<AttriaxInstallReferrerDetails?>.value(_reinstallValue);
    }

    _ensureInstallObservationStarted();
    return (_reinstallCompleter ??= Completer<AttriaxInstallReferrerDetails?>())
        .future;
  }

  Future<AttriaxDeepLinkReferrerDetails?> waitForSessionReferrer() {
    if (!_didInit) {
      return Future<AttriaxDeepLinkReferrerDetails?>.error(
        StateError('Attriax SDK not initialized. Call init() first.'),
      );
    }

    _syncSessionScope();

    final error = _sessionReferrerError;
    if (error != null) {
      return Future<AttriaxDeepLinkReferrerDetails?>.error(
        error,
        _sessionReferrerStackTrace,
      );
    }

    if (_sessionReferrerResolved) {
      return Future<AttriaxDeepLinkReferrerDetails?>.value(
        _sessionReferrerValue,
      );
    }

    _ensureSessionStartupObservationStarted();
    return (_sessionReferrerCompleter ??=
            Completer<AttriaxDeepLinkReferrerDetails?>())
        .future;
  }

  Future<AttriaxDeepLinkReferrerDetails?> waitForLatestDeepLinkReferrer() {
    if (!_didInit) {
      return Future<AttriaxDeepLinkReferrerDetails?>.error(
        StateError('Attriax SDK not initialized. Call init() first.'),
      );
    }

    _syncSessionScope();

    final error = _latestDeepLinkError;
    if (error != null) {
      return Future<AttriaxDeepLinkReferrerDetails?>.error(
        error,
        _latestDeepLinkStackTrace,
      );
    }

    final value = _latestDeepLinkValue;
    if (value != null) {
      return Future<AttriaxDeepLinkReferrerDetails?>.value(value);
    }

    return Future<AttriaxDeepLinkReferrerDetails?>.value();
  }

  Future<void> reset() async {
    _didInit = false;
    _enabled = false;
    _completePendingInstallWaiters();
    _completePendingSessionWaiters();
    _installObservationGeneration += 1;
    _sessionObservationGeneration += 1;
    _installObservationFuture = null;
    _sessionStartupObservationFuture = null;
    _observedSessionId = null;
    _originalInstallCompleter = null;
    _originalInstallValue = null;
    _originalInstallLoaded = false;
    _originalInstallError = null;
    _originalInstallStackTrace = null;
    _reinstallCompleter = null;
    _reinstallValue = null;
    _reinstallLoaded = false;
    _reinstallError = null;
    _reinstallStackTrace = null;
    _resetSessionScopedState();
    await _deepLinkSubscription?.cancel();
    _deepLinkSubscription = null;
  }

  Future<void> dispose() async {
    _completePendingInstallWaiters();
    _completePendingSessionWaiters();
    await _deepLinkSubscription?.cancel();
    _deepLinkSubscription = null;
  }

  Future<void> _restoreStoredInstallReferrers() async {
    if (!_originalInstallLoaded && _originalInstallError == null) {
      final stored = await _preferencesStore.readStoredInstallReferrerDetails();
      _originalInstallLoaded = stored.isLoaded;
      _originalInstallValue ??= stored.value;
    }

    if (!_reinstallLoaded && _reinstallError == null) {
      final stored = await _preferencesStore
          .readStoredReinstallReferrerDetails();
      _reinstallLoaded = stored.isLoaded;
      _reinstallValue ??= stored.value;
    }
  }

  Future<void> _observeInstallReferrers(int generation) async {
    try {
      if (_localInstallReferrerOnly) {
        if (generation != _installObservationGeneration) {
          return;
        }

        _setOriginalInstallValue(null);
        _setReinstallValue(null);
        return;
      }

      final result = await _appOpenMonitor.waitForTrackedResult();
      if (generation != _installObservationGeneration) {
        return;
      }

      final originalInstallReferrer = result?.originalInstallReferrer;
      final reinstallReferrer = result?.reinstallReferrer;
      _setOriginalInstallValue(originalInstallReferrer);
      _setReinstallValue(reinstallReferrer);
      await Future.wait(<Future<void>>[
        _preferencesStore.setStoredInstallReferrerDetails(
          isLoaded: true,
          details: originalInstallReferrer,
        ),
        _preferencesStore.setStoredReinstallReferrerDetails(
          isLoaded: true,
          details: reinstallReferrer,
        ),
      ]);
    } catch (error, stackTrace) {
      if (generation != _installObservationGeneration) {
        return;
      }

      _setOriginalInstallError(error, stackTrace);
      _setReinstallError(error, stackTrace);
    }
  }

  Future<void> _observeSessionStartupOutcome(
    int generation,
    String? sessionId,
  ) async {
    try {
      final initialDeepLink = await _deepLinkManager.waitForInitialDeepLink();
      if (!_isSessionObservationCurrent(generation, sessionId)) {
        return;
      }

      if (initialDeepLink != null) {
        return;
      }

      if (_localInstallReferrerOnly) {
        _setSessionReferrerValue(null);
        return;
      }

      await _appOpenMonitor.waitForTrackedResult();
      if (!_isSessionObservationCurrent(generation, sessionId) ||
          _sessionReferrerResolved) {
        return;
      }

      _setSessionReferrerValue(null);
    } catch (_) {
      if (!_isSessionObservationCurrent(generation, sessionId) ||
          _sessionReferrerResolved) {
        return;
      }

      // A failure while observing startup (e.g. a transient app-open delivery
      // error or an initial deep-link resolution error) means we could not
      // determine a session referrer, not that the public read should throw.
      // Resolve to "no referrer" so getSessionReferrer() returns null rather
      // than surfacing a delivery error to the app.
      _setSessionReferrerValue(null);
    }
  }

  Future<void> _handleDeepLinkEvent(AttriaxDeepLinkEvent event) async {
    _syncSessionScope();
    final generation = _sessionObservationGeneration;
    final sessionId = _observedSessionId;

    try {
      if (!_isSessionObservationCurrent(generation, sessionId)) {
        return;
      }

      final details = attriaxDeepLinkReferrerDetailsFromEvent(event);
      _setLatestDeepLinkValue(details);
      if (!_sessionReferrerResolved &&
          attriaxIsSessionOpeningDeepLinkEvent(event)) {
        _setSessionReferrerValue(details);
      }
    } catch (error, stackTrace) {
      if (!_isSessionObservationCurrent(generation, sessionId)) {
        return;
      }

      _setLatestDeepLinkError(error, stackTrace);
      if (!_sessionReferrerResolved &&
          attriaxIsSessionOpeningDeepLinkEvent(event)) {
        _setSessionReferrerError(error, stackTrace);
      }
    }
  }

  void _ensureInstallObservationStarted() {
    if (!_enabled ||
        _installObservationFuture != null ||
        _areInstallReferrersResolved) {
      return;
    }

    final generation = _installObservationGeneration;
    final observation = _observeInstallReferrers(generation);
    _installObservationFuture = observation;
    observation.whenComplete(() {
      if (identical(_installObservationFuture, observation)) {
        _installObservationFuture = null;
      }
    });
  }

  void _ensureSessionStartupObservationStarted() {
    if (!_enabled ||
        _sessionReferrerResolved ||
        _sessionStartupObservationFuture != null) {
      return;
    }

    final generation = _sessionObservationGeneration;
    final sessionId = _observedSessionId;
    final observation = _observeSessionStartupOutcome(generation, sessionId);
    _sessionStartupObservationFuture = observation;
    observation.whenComplete(() {
      if (identical(_sessionStartupObservationFuture, observation)) {
        _sessionStartupObservationFuture = null;
      }
    });
  }

  void _ensureDeepLinkSubscription() {
    _deepLinkSubscription ??= _deepLinkManager.stream.listen((event) {
      unawaited(_handleDeepLinkEvent(event));
    });
  }

  bool get _areInstallReferrersResolved {
    final originalResolved =
        _originalInstallLoaded || _originalInstallError != null;
    final reinstallResolved = _reinstallLoaded || _reinstallError != null;
    return originalResolved && reinstallResolved;
  }

  void _resetInstallReferrerResolution() {
    _originalInstallCompleter = null;
    _originalInstallValue = null;
    _originalInstallLoaded = false;
    _originalInstallError = null;
    _originalInstallStackTrace = null;
    _reinstallCompleter = null;
    _reinstallValue = null;
    _reinstallLoaded = false;
    _reinstallError = null;
    _reinstallStackTrace = null;
  }

  bool _isSessionObservationCurrent(int generation, String? sessionId) =>
      generation == _sessionObservationGeneration &&
      sessionId == _observedSessionId;

  void _syncSessionScope({bool forceReset = false}) {
    final currentSessionId = _currentSessionIdProvider();
    if (!forceReset && currentSessionId == _observedSessionId) {
      return;
    }

    _observedSessionId = currentSessionId;
    _sessionObservationGeneration += 1;
    _sessionStartupObservationFuture = null;
    _completePendingSessionWaiters();
    _resetSessionScopedState();

    if (_enabled) {
      _ensureSessionStartupObservationStarted();
    }
  }

  void _resetSessionScopedState() {
    _sessionReferrerCompleter = null;
    _sessionReferrerValue = null;
    _sessionReferrerResolved = false;
    _sessionReferrerError = null;
    _sessionReferrerStackTrace = null;
    _latestDeepLinkValue = null;
    _latestDeepLinkError = null;
    _latestDeepLinkStackTrace = null;
  }

  void _completePendingInstallWaiters() {
    final originalInstallCompleter = _originalInstallCompleter;
    if (originalInstallCompleter != null &&
        !originalInstallCompleter.isCompleted) {
      originalInstallCompleter.complete(null);
    }

    final reinstallCompleter = _reinstallCompleter;
    if (reinstallCompleter != null && !reinstallCompleter.isCompleted) {
      reinstallCompleter.complete(null);
    }
  }

  void _completePendingSessionWaiters() {
    final sessionReferrerCompleter = _sessionReferrerCompleter;
    if (sessionReferrerCompleter != null &&
        !sessionReferrerCompleter.isCompleted) {
      sessionReferrerCompleter.complete(null);
    }
  }

  void _setOriginalInstallValue(AttriaxInstallReferrerDetails? value) {
    _originalInstallValue = value;
    _originalInstallLoaded = true;
    _originalInstallError = null;
    _originalInstallStackTrace = null;
    final completer = _originalInstallCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(value);
    }
  }

  void _setOriginalInstallError(Object error, StackTrace stackTrace) {
    _originalInstallValue = null;
    _originalInstallLoaded = false;
    _originalInstallError = error;
    _originalInstallStackTrace = stackTrace;
    final completer = _originalInstallCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }

  void _setReinstallValue(AttriaxInstallReferrerDetails? value) {
    _reinstallValue = value;
    _reinstallLoaded = true;
    _reinstallError = null;
    _reinstallStackTrace = null;
    final completer = _reinstallCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(value);
    }
  }

  void _setReinstallError(Object error, StackTrace stackTrace) {
    _reinstallValue = null;
    _reinstallLoaded = false;
    _reinstallError = error;
    _reinstallStackTrace = stackTrace;
    final completer = _reinstallCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }

  void _setSessionReferrerValue(AttriaxDeepLinkReferrerDetails? value) {
    _sessionReferrerValue = value;
    _sessionReferrerResolved = true;
    _sessionReferrerError = null;
    _sessionReferrerStackTrace = null;
    final completer = _sessionReferrerCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(value);
    }
  }

  void _setSessionReferrerError(Object error, StackTrace stackTrace) {
    _sessionReferrerValue = null;
    _sessionReferrerResolved = false;
    _sessionReferrerError = error;
    _sessionReferrerStackTrace = stackTrace;
    final completer = _sessionReferrerCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }

  void _setLatestDeepLinkValue(AttriaxDeepLinkReferrerDetails value) {
    _latestDeepLinkValue = value;
    _latestDeepLinkError = null;
    _latestDeepLinkStackTrace = null;
  }

  void _setLatestDeepLinkError(Object error, StackTrace stackTrace) {
    _latestDeepLinkValue = null;
    _latestDeepLinkError = error;
    _latestDeepLinkStackTrace = stackTrace;
  }
}

String? _noSessionId() => null;
