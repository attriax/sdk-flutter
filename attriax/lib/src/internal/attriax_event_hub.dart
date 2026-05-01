import 'dart:async';
import 'dart:collection';

import 'package:attriax_platform_interface/attriax_platform_interface.dart';

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
  final HashMap<AttriaxRawDeepLinkEvent, Completer<AttriaxDeepLinkResult>>
  _pendingDeepLinkResults =
      HashMap<
        AttriaxRawDeepLinkEvent,
        Completer<AttriaxDeepLinkResult>
      >.identity();
  final Completer<AttriaxDeepLinkResult?> _initialDeepLinkResult =
      Completer<AttriaxDeepLinkResult?>();
  AttriaxDeepLinkResult? _initialDeepLinkValue;
  AttriaxDeepLinkResult? _latestDeepLink;
  bool _hasPendingInitialDeepLink = false;

  // ---------- streams ------------------------------------------------------- //

  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinkController.stream;
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _synchronizationStateController.stream;
  Future<AttriaxDeepLinkResult?> get initialDeepLink =>
      _initialDeepLinkResult.future;
  AttriaxDeepLinkResult? get initialDeepLinkValue => _initialDeepLinkValue;
  bool get isInitialDeepLinkResolved => _initialDeepLinkResult.isCompleted;
  AttriaxDeepLinkResult? get latestDeepLink => _latestDeepLink;

  // ---------- emit ---------------------------------------------------------- //

  AttriaxDeepLinkEvent emitPendingDeepLink(AttriaxRawDeepLinkEvent rawEvent) {
    final completer = Completer<AttriaxDeepLinkResult>();
    _pendingDeepLinkResults[rawEvent] = completer;
    if (rawEvent.isInitialLink) {
      _hasPendingInitialDeepLink = true;
    }

    final event = AttriaxDeepLinkEvent(
      rawEvent: rawEvent,
      resultFuture: completer.future,
    );
    _deepLinkController.add(event);
    return event;
  }

  void resolvePendingDeepLink({
    required AttriaxRawDeepLinkEvent rawEvent,
    required AttriaxDeepLinkResolution resolution,
  }) {
    _completePendingDeepLink(
      rawEvent: rawEvent,
      result: AttriaxDeepLinkResult(rawEvent: rawEvent, resolution: resolution),
    );
  }

  void failPendingDeepLink({
    required AttriaxRawDeepLinkEvent rawEvent,
    required AttriaxDeepLinkResolutionFailure failure,
  }) {
    _completePendingDeepLink(
      rawEvent: rawEvent,
      result: AttriaxDeepLinkResult(rawEvent: rawEvent, failure: failure),
    );
  }

  void emitResolvedDeepLink({
    AttriaxRawDeepLinkEvent? rawEvent,
    AttriaxDeepLinkResolution? resolution,
    AttriaxDeepLinkResolutionFailure? failure,
  }) {
    final result = AttriaxDeepLinkResult(
      rawEvent: rawEvent,
      resolution: resolution,
      failure: failure,
    );
    _latestDeepLink = result;
    if (rawEvent?.isInitialLink ?? false) {
      _completeInitialDeepLink(result);
    }
    _deepLinkController.add(
      AttriaxDeepLinkEvent(
        rawEvent: rawEvent,
        resultFuture: Future.value(result),
      ),
    );
  }

  void completeInitialDeepLinkIfAbsent() {
    if (_hasPendingInitialDeepLink || _initialDeepLinkResult.isCompleted) {
      return;
    }
    _initialDeepLinkResult.complete(null);
  }

  void emitSynchronizationState(AttriaxSynchronizationState state) {
    _synchronizationStateController.add(state);
  }

  Future<void> dispose() async {
    final now = DateTime.now().toUtc();
    for (final entry in _pendingDeepLinkResults.entries.toList(
      growable: false,
    )) {
      if (!entry.value.isCompleted) {
        final result = AttriaxDeepLinkResult(
          rawEvent: entry.key,
          failure: AttriaxDeepLinkResolutionFailure(
            reason:
                'Attriax SDK disposed before deep-link resolution completed.',
            rawEvent: entry.key,
            isFirstLaunch: entry.key.isFirstLaunch,
            occurredAt: now,
          ),
        );
        _latestDeepLink = result;
        entry.value.complete(result);
      }
    }
    _pendingDeepLinkResults.clear();
    if (!_initialDeepLinkResult.isCompleted) {
      _initialDeepLinkResult.complete(null);
    }
    await _deepLinkController.close();
    await _synchronizationStateController.close();
  }

  void _completePendingDeepLink({
    required AttriaxRawDeepLinkEvent rawEvent,
    required AttriaxDeepLinkResult result,
  }) {
    final completer = _pendingDeepLinkResults.remove(rawEvent);
    if (completer == null) {
      return;
    }
    if (!completer.isCompleted) {
      _latestDeepLink = result;
      completer.complete(result);
    }
    if (rawEvent.isInitialLink) {
      _hasPendingInitialDeepLink = false;
      _completeInitialDeepLink(result);
    }
  }

  void _completeInitialDeepLink(AttriaxDeepLinkResult result) {
    _initialDeepLinkValue = result;
    if (_initialDeepLinkResult.isCompleted) {
      return;
    }
    _initialDeepLinkResult.complete(result);
  }
}
