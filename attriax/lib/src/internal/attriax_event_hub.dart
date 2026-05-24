import 'dart:async';
import 'dart:collection';

import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

/// Owns all broadcast stream controllers for the Attriax SDK.
///
/// Components emit events through this hub rather than holding their own
/// controllers, keeping stream ownership in one place.
class AttriaxEventHub {
  final StreamController<AttriaxRawDeepLinkEvent> _rawDeepLinkController =
      StreamController<AttriaxRawDeepLinkEvent>.broadcast();
  final StreamController<AttriaxDeepLinkEvent> _deepLinkController =
      StreamController<AttriaxDeepLinkEvent>.broadcast();
  final StreamController<AttriaxSynchronizationState>
  _synchronizationStateController =
      StreamController<AttriaxSynchronizationState>.broadcast();
  final HashMap<AttriaxRawDeepLinkEvent, Completer<AttriaxDeepLinkEvent>>
  _pendingDeepLinkResults =
      HashMap<
        AttriaxRawDeepLinkEvent,
        Completer<AttriaxDeepLinkEvent>
      >.identity();
  Completer<AttriaxDeepLinkEvent?> _initialDeepLinkResult =
      Completer<AttriaxDeepLinkEvent?>();
  AttriaxRawDeepLinkEvent? _rawInitialDeepLinkValue;
  AttriaxDeepLinkEvent? _initialDeepLinkValue;
  AttriaxDeepLinkEvent? _latestDeepLink;
  bool _hasPendingInitialDeepLink = false;
  bool _initialLinkProbeCompleted = false;

  // ---------- streams ------------------------------------------------------- //

  Stream<AttriaxRawDeepLinkEvent> get rawDeepLinks =>
      _rawDeepLinkController.stream;
  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinkController.stream;
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _synchronizationStateController.stream;
  Future<AttriaxDeepLinkEvent?> get initialDeepLink =>
      _initialDeepLinkResult.future;
  AttriaxRawDeepLinkEvent? get rawInitialDeepLinkValue =>
      _rawInitialDeepLinkValue;
  AttriaxDeepLinkEvent? get initialDeepLinkValue => _initialDeepLinkValue;
  bool get isInitialDeepLinkResolved => _initialDeepLinkResult.isCompleted;
  AttriaxDeepLinkEvent? get latestDeepLink => _latestDeepLink;

  // ---------- emit ---------------------------------------------------------- //

  AttriaxRawDeepLinkEvent emitPendingDeepLink({
    required Uri uri,
    required DateTime receivedAt,
    required bool isInitialLink,
  }) {
    final event = stagePendingDeepLink(
      uri: uri,
      receivedAt: receivedAt,
      isInitialLink: isInitialLink,
    );
    publishPendingDeepLink(event: event, isInitialLink: isInitialLink);
    return event;
  }

  AttriaxRawDeepLinkEvent stagePendingDeepLink({
    required Uri uri,
    required DateTime receivedAt,
    required bool isInitialLink,
  }) {
    final completer = Completer<AttriaxDeepLinkEvent>();
    final event = AttriaxRawDeepLinkEvent(
      uri: uri,
      receivedAt: receivedAt,
      isInitial: isInitialLink,
    );
    _pendingDeepLinkResults[event] = completer;
    if (isInitialLink) {
      _hasPendingInitialDeepLink = true;
    }
    return event;
  }

  void publishPendingDeepLink({
    required AttriaxRawDeepLinkEvent event,
    required bool isInitialLink,
  }) {
    if (isInitialLink) {
      _rawInitialDeepLinkValue = event;
    }
    _rawDeepLinkController.add(event);
  }

  Future<AttriaxDeepLinkEvent> waitForResolution(
    AttriaxRawDeepLinkEvent event,
  ) {
    final completer = _pendingDeepLinkResults[event];
    if (completer != null) {
      return completer.future;
    }

    return Future<AttriaxDeepLinkEvent>.error(
      StateError(
        'No pending or completed resolution exists for this raw deep link.',
      ),
    );
  }

  void resolvePendingDeepLink({
    required AttriaxRawDeepLinkEvent event,
    required AttriaxDeepLinkEvent resolution,
  }) {
    final completer = _pendingDeepLinkResults[event];
    if (completer == null || completer.isCompleted) {
      return;
    }

    completer.complete(resolution);
    if (event.isInitial) {
      _hasPendingInitialDeepLink = false;
    }
  }

  void failPendingDeepLink({
    required AttriaxRawDeepLinkEvent event,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final completer = _pendingDeepLinkResults[event];
    if (completer == null || completer.isCompleted) {
      return;
    }

    _completeWithError(completer, error, stackTrace: stackTrace);
    if (event.isInitial) {
      _hasPendingInitialDeepLink = false;
      if (!_initialDeepLinkResult.isCompleted) {
        _initialDeepLinkResult.completeError(error, stackTrace);
      }
    }
  }

  void dropPendingDeepLink({required AttriaxRawDeepLinkEvent event}) {
    _pendingDeepLinkResults.remove(event);
    if (!event.isInitial) {
      return;
    }

    _hasPendingInitialDeepLink = false;
    if (_initialLinkProbeCompleted && !_initialDeepLinkResult.isCompleted) {
      _initialDeepLinkResult.complete(null);
    }
  }

  AttriaxDeepLinkEvent emitResolvedDeepLink({
    required AttriaxDeepLinkEvent event,
  }) {
    _latestDeepLink = event;
    if (event.isColdStart) {
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
    _rawInitialDeepLinkValue = null;
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
    await _rawDeepLinkController.close();
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
    Completer<AttriaxDeepLinkEvent> completer,
    Object error, {
    StackTrace? stackTrace,
  }) {
    unawaited(
      completer.future.then<void>((_) {}, onError: (Object _, StackTrace _) {}),
    );
    completer.completeError(error, stackTrace);
  }
}
