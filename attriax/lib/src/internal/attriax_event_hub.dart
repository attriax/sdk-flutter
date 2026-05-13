import 'dart:async';
import 'dart:collection';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

/// Owns all broadcast stream controllers for the Attriax SDK.
///
/// Components emit events through this hub rather than holding their own
/// controllers, keeping stream ownership in one place.
class AttriaxEventHub {
  final StreamController<AttriaxDeepLinkEvent> _deepLinkController =
      StreamController<AttriaxDeepLinkEvent>.broadcast();
  final StreamController<AttriaxSynchronizationState>
  _synchronizationStateController =
      StreamController<AttriaxSynchronizationState>.broadcast();
  final HashMap<AttriaxDeepLinkEvent, Completer<AttriaxDeepLinkResolution>>
  _pendingDeepLinkResults =
      HashMap<
        AttriaxDeepLinkEvent,
        Completer<AttriaxDeepLinkResolution>
      >.identity();
  Completer<AttriaxDeepLinkEvent?> _initialDeepLinkResult =
      Completer<AttriaxDeepLinkEvent?>();
  AttriaxDeepLinkEvent? _initialDeepLinkValue;
  AttriaxDeepLinkEvent? _latestDeepLink;
  bool _hasPendingInitialDeepLink = false;
  bool _initialLinkProbeCompleted = false;

  // ---------- streams ------------------------------------------------------- //

  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinkController.stream;
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _synchronizationStateController.stream;
  Future<AttriaxDeepLinkEvent?> get initialDeepLink =>
      _initialDeepLinkResult.future;
  AttriaxDeepLinkEvent? get initialDeepLinkValue => _initialDeepLinkValue;
  bool get isInitialDeepLinkResolved => _initialDeepLinkResult.isCompleted;
  AttriaxDeepLinkEvent? get latestDeepLink => _latestDeepLink;

  // ---------- emit ---------------------------------------------------------- //

  AttriaxDeepLinkEvent emitPendingDeepLink({
    required Uri uri,
    required DateTime receivedAt,
    required AttriaxDeepLinkTrigger trigger,
    required bool isInitialLink,
    required bool isAttriaxDomain,
  }) {
    final event = stagePendingDeepLink(
      uri: uri,
      receivedAt: receivedAt,
      trigger: trigger,
      isInitialLink: isInitialLink,
      isAttriaxDomain: isAttriaxDomain,
    );
    publishPendingDeepLink(event: event, isInitialLink: isInitialLink);
    return event;
  }

  AttriaxDeepLinkEvent stagePendingDeepLink({
    required Uri uri,
    required DateTime receivedAt,
    required AttriaxDeepLinkTrigger trigger,
    required bool isInitialLink,
    required bool isAttriaxDomain,
  }) {
    final completer = Completer<AttriaxDeepLinkResolution>();
    final event = AttriaxDeepLinkEvent(
      uri: uri,
      receivedAt: receivedAt,
      trigger: trigger,
      isAttriaxDomain: isAttriaxDomain,
      resolutionFuture: completer.future,
    );
    _pendingDeepLinkResults[event] = completer;
    if (isInitialLink) {
      _hasPendingInitialDeepLink = true;
    }
    return event;
  }

  void publishPendingDeepLink({
    required AttriaxDeepLinkEvent event,
    required bool isInitialLink,
  }) {
    _latestDeepLink = event;
    if (isInitialLink) {
      _completeInitialDeepLink(event);
    }
    _deepLinkController.add(event);
  }

  void resolvePendingDeepLink({
    required AttriaxDeepLinkEvent event,
    required AttriaxDeepLinkResolution resolution,
  }) {
    final completer = _pendingDeepLinkResults.remove(event);
    if (completer == null || completer.isCompleted) {
      return;
    }

    completer.complete(resolution);
    if (event.isColdStart) {
      _hasPendingInitialDeepLink = false;
    }
  }

  void failPendingDeepLink({
    required AttriaxDeepLinkEvent event,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final completer = _pendingDeepLinkResults.remove(event);
    if (completer == null || completer.isCompleted) {
      return;
    }

    _completeWithError(completer, error, stackTrace: stackTrace);
    if (event.isColdStart) {
      _hasPendingInitialDeepLink = false;
    }
  }

  void dropPendingDeepLink({required AttriaxDeepLinkEvent event}) {
    _pendingDeepLinkResults.remove(event);
    if (!event.isColdStart) {
      return;
    }

    _hasPendingInitialDeepLink = false;
    if (_initialLinkProbeCompleted && !_initialDeepLinkResult.isCompleted) {
      _initialDeepLinkResult.complete(null);
    }
  }

  AttriaxDeepLinkEvent emitResolvedDeepLink({
    required Uri uri,
    required DateTime receivedAt,
    required AttriaxDeepLinkTrigger trigger,
    required AttriaxDeepLinkResolution resolution,
    required bool isAttriaxDomain,
  }) {
    final event = AttriaxDeepLinkEvent(
      uri: uri,
      receivedAt: receivedAt,
      trigger: trigger,
      isAttriaxDomain: isAttriaxDomain,
      resolutionFuture: Future<AttriaxDeepLinkResolution>.value(resolution),
    );
    _latestDeepLink = event;
    if (trigger == AttriaxDeepLinkTrigger.coldStart) {
      _completeInitialDeepLink(event);
    }
    _deepLinkController.add(event);
    return event;
  }

  void completeInitialDeepLinkIfAbsent() {
    _initialLinkProbeCompleted = true;
    if (_hasPendingInitialDeepLink || _initialDeepLinkResult.isCompleted) {
      return;
    }
    _initialDeepLinkResult.complete(null);
  }

  void emitSynchronizationState(AttriaxSynchronizationState state) {
    _synchronizationStateController.add(state);
  }

  void reset() {
    for (final entry in _pendingDeepLinkResults.entries.toList(
      growable: false,
    )) {
      if (!entry.value.isCompleted) {
        _completeWithError(
          entry.value,
          StateError(
            'Attriax SDK state was reset before deep-link resolution completed.',
          ),
        );
      }
    }
    _pendingDeepLinkResults.clear();
    if (!_initialDeepLinkResult.isCompleted) {
      _initialDeepLinkResult.complete(null);
    }
    _initialDeepLinkResult = Completer<AttriaxDeepLinkEvent?>();
    _initialDeepLinkValue = null;
    _latestDeepLink = null;
    _hasPendingInitialDeepLink = false;
    _initialLinkProbeCompleted = false;
  }

  Future<void> dispose() async {
    for (final entry in _pendingDeepLinkResults.entries.toList(
      growable: false,
    )) {
      if (!entry.value.isCompleted) {
        _completeWithError(
          entry.value,
          StateError(
            'Attriax SDK disposed before deep-link resolution completed.',
          ),
        );
      }
    }
    _pendingDeepLinkResults.clear();
    if (!_initialDeepLinkResult.isCompleted) {
      _initialDeepLinkResult.complete(null);
    }
    await _deepLinkController.close();
    await _synchronizationStateController.close();
  }

  void _completeInitialDeepLink(AttriaxDeepLinkEvent event) {
    _initialDeepLinkValue = event;
    if (_initialDeepLinkResult.isCompleted) {
      return;
    }
    _initialDeepLinkResult.complete(event);
  }

  void _completeWithError(
    Completer<AttriaxDeepLinkResolution> completer,
    Object error, {
    StackTrace? stackTrace,
  }) {
    unawaited(
      completer.future.then<void>(
        (_) {},
        onError: (Object _, StackTrace __) {},
      ),
    );
    completer.completeError(error, stackTrace);
  }
}
