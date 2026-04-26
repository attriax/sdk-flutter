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

  // ---------- streams ------------------------------------------------------- //

  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinkController.stream;
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _synchronizationStateController.stream;

  // ---------- emit ---------------------------------------------------------- //

  AttriaxDeepLinkEvent emitPendingDeepLink(AttriaxRawDeepLinkEvent rawEvent) {
    final completer = Completer<AttriaxDeepLinkResult>();
    _pendingDeepLinkResults[rawEvent] = completer;

    final event = AttriaxDeepLinkEvent(
      rawEvent: rawEvent,
      resultFuture: completer.future,
    );
    _deepLinkController.add(event);
    return event;
  }

  void resolvePendingDeepLink({
    required AttriaxRawDeepLinkEvent rawEvent,
    required AttriaxDeepLinkConversionEvent conversion,
  }) {
    _completePendingDeepLink(
      rawEvent: rawEvent,
      result: AttriaxDeepLinkResult(rawEvent: rawEvent, conversion: conversion),
    );
  }

  void failPendingDeepLink({
    required AttriaxRawDeepLinkEvent rawEvent,
    required AttriaxDeepLinkConversionFailure failure,
  }) {
    _completePendingDeepLink(
      rawEvent: rawEvent,
      result: AttriaxDeepLinkResult(rawEvent: rawEvent, failure: failure),
    );
  }

  void emitResolvedDeepLink({
    AttriaxRawDeepLinkEvent? rawEvent,
    AttriaxDeepLinkConversionEvent? conversion,
    AttriaxDeepLinkConversionFailure? failure,
  }) {
    final result = AttriaxDeepLinkResult(
      rawEvent: rawEvent,
      conversion: conversion,
      failure: failure,
    );
    _deepLinkController.add(
      AttriaxDeepLinkEvent(
        rawEvent: rawEvent,
        resultFuture: Future.value(result),
      ),
    );
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
        entry.value.complete(
          AttriaxDeepLinkResult(
            rawEvent: entry.key,
            failure: AttriaxDeepLinkConversionFailure(
              reason:
                  'Attriax SDK disposed before deep-link resolution completed.',
              rawEvent: entry.key,
              isFirstLaunch: entry.key.isFirstLaunch,
              occurredAt: now,
            ),
          ),
        );
      }
    }
    _pendingDeepLinkResults.clear();
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
      completer.complete(result);
    }
  }
}
