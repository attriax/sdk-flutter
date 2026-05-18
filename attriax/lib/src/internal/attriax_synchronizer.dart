import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

import 'attriax_api_models.dart';
import 'attriax_app_open_monitor.dart';
import 'attriax_generated_transport.dart';
import 'attriax_id_generator.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';
import 'attriax_queue.dart';
import 'attriax_request_dispatcher.dart';

/// Manages the outbound request queue, flush scheduling, synchronization
/// state, and connectivity monitoring for the Attriax SDK.
class AttriaxSynchronizer {
  AttriaxSynchronizer({
    required AttriaxGeneratedTransport transport,
    required Connectivity connectivity,
    required AttriaxAppOpenMonitor appOpenMonitor,
    required AttriaxPreferencesStore preferencesStore,
    required int maxQueueSize,
    required Duration eventFlushInterval,
    required AttriaxLogger logger,
    void Function(AttriaxApiRequest request, int statusCode)?
    onRequestDelivered,
    void Function(AttriaxApiRequest request, Object error)? onRequestFailed,
  }) : _connectivity = connectivity,
       _eventFlushInterval = eventFlushInterval,
       _logger = logger {
    _queueManager = AttriaxQueueManager(
      preferencesStore: preferencesStore,
      maxQueueSize: maxQueueSize,
    );
    _dispatcher = AttriaxRequestDispatcher(
      transport: transport,
      connectivity: connectivity,
      appOpenMonitor: appOpenMonitor,
      queueManager: _queueManager,
      logger: logger,
      onDelivered: onRequestDelivered,
      onFailed: (kind, error) {
        _lastFlushHadFailure = true;
        onRequestFailed?.call(kind, error);
      },
    );
  }

  final Connectivity _connectivity;
  final Duration _eventFlushInterval;
  final AttriaxLogger _logger;
  late final AttriaxQueueManager _queueManager;
  late final AttriaxRequestDispatcher _dispatcher;

  /// Set to `false` via [deactivate] when the SDK is disabled so that
  /// in-flight flush loops terminate early.
  bool _active = true;
  AttriaxSynchronizationState _state = AttriaxSynchronizationState.initializing;
  bool _isSynchronizationRefreshScheduled = false;
  bool _needsSynchronizationRefresh = false;
  bool _lastFlushHadFailure = false;
  Future<void>? _synchronizationRefreshFuture;
  Future<void> _queueOperationLock = Future<void>.value();
  Timer? _deferredFlushTimer;
  DateTime? _scheduledFlushAt;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Invoked whenever [synchronizationState] transitions to a new value.
  void Function(AttriaxSynchronizationState state)? onStateChanged;

  AttriaxSynchronizationState get synchronizationState => _state;

  // ---------- public API ---------------------------------------------------- //

  /// Serialises [request], registers its [onSuccess]/[onError] handlers, adds
  /// it to the persistent queue, and triggers a flush.
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool flushImmediately = true,
  }) async {
    final queued = AttriaxQueuedRequest(
      id: attriaxGenerateId(),
      request: request,
      createdAt: DateTime.now().toUtc(),
    );
    _dispatcher.registerHandlers(
      queued.id,
      onSuccess: onSuccess,
      onError: onError,
    );
    await _withQueueOperationLock(() => _queueManager.enqueue(queued));
    setState(AttriaxSynchronizationState.synchronizing);
    _logger.verbose('Queued ${attriaxApiRequestLabel(request)} request.');
    if (flushImmediately || _eventFlushInterval == Duration.zero) {
      scheduleFlush();
      return;
    }

    setState(AttriaxSynchronizationState.deferred);
    _scheduleDeferredFlush();
  }

  /// Schedules a flush unless one is already running. Rapid back-to-back calls
  /// collapse into a single additional iteration after the current one ends.
  void scheduleFlush() {
    _deferredFlushTimer?.cancel();
    _deferredFlushTimer = null;
    _scheduledFlushAt = null;
    if (_isSynchronizationRefreshScheduled) {
      _needsSynchronizationRefresh = true;
      return;
    }
    _isSynchronizationRefreshScheduled = true;
    final refreshLoop = _runSynchronizationRefreshLoop();
    _synchronizationRefreshFuture = refreshLoop;
    unawaited(
      refreshLoop.whenComplete(() {
        if (identical(_synchronizationRefreshFuture, refreshLoop)) {
          _synchronizationRefreshFuture = null;
        }
      }),
    );
  }

  /// Transitions to [nextState] and notifies [onStateChanged].
  /// Emits nothing when the state has not changed.
  void setState(AttriaxSynchronizationState nextState) {
    if (_state == nextState) {
      return;
    }
    _state = nextState;
    onStateChanged?.call(nextState);
  }

  /// Starts listening for connectivity changes. [onRestored] is called when
  /// the device comes back online while the synchronizer is active.
  void startConnectivitySubscription({required void Function() onRestored}) {
    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen(
      (results) {
        if (results.every((r) => r == ConnectivityResult.none)) {
          setState(AttriaxSynchronizationState.offline);
          return;
        }
        if (_active) {
          _logger.verbose('Connectivity restored; flushing request queue.');
          setState(AttriaxSynchronizationState.synchronizing);
          onRestored();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning(
          'Connectivity stream error',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> stopConnectivitySubscription() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Marks the synchronizer inactive so that in-flight flush loops exit early.
  void deactivate() {
    _active = false;
    _deferredFlushTimer?.cancel();
    _deferredFlushTimer = null;
  }

  /// Marks the synchronizer active again after re-enabling the SDK.
  void activate() => _active = true;

  Future<void> dispose() async {
    _active = false;
    _deferredFlushTimer?.cancel();
    _deferredFlushTimer = null;
    await stopConnectivitySubscription();
    final inFlightRefresh = _synchronizationRefreshFuture;
    if (inFlightRefresh != null) {
      await inFlightRefresh;
    }
  }

  Future<void> reset({required Object error}) async {
    _active = false;
    _deferredFlushTimer?.cancel();
    _deferredFlushTimer = null;
    _scheduledFlushAt = null;
    await stopConnectivitySubscription();
    final inFlightRefresh = _synchronizationRefreshFuture;
    if (inFlightRefresh != null) {
      await inFlightRefresh;
    }

    _dispatcher.clearPending(error: error);
    await _withQueueOperationLock(
      () => _queueManager.writeAll(const <AttriaxQueuedRequest>[]),
    );

    _needsSynchronizationRefresh = false;
    _isSynchronizationRefreshScheduled = false;
    _lastFlushHadFailure = false;
    _active = true;
    setState(AttriaxSynchronizationState.initializing);
  }

  // ---------- private ------------------------------------------------------- //

  Future<void> _runSynchronizationRefreshLoop() async {
    try {
      do {
        _needsSynchronizationRefresh = false;
        await _flushQueueAndRefreshSynchronization();
      } while (_needsSynchronizationRefresh);
    } finally {
      _isSynchronizationRefreshScheduled = false;
    }
  }

  Future<void> _flushQueueAndRefreshSynchronization() async {
    await _withQueueOperationLock(() async {
      if (!_active) {
        return;
      }

      final connectivity = await _connectivity.checkConnectivity();
      if (connectivity.every((r) => r == ConnectivityResult.none)) {
        setState(AttriaxSynchronizationState.offline);
        return;
      }

      _lastFlushHadFailure = false;
      await _dispatcher.flush();

      if (!_active) {
        setState(AttriaxSynchronizationState.disabled);
        return;
      }

      final queueStatus = await _queueManager.readStatus();
      final nextRetryAt = queueStatus.nextRetryAt;
      if (nextRetryAt != null && nextRetryAt.isAfter(DateTime.now().toUtc())) {
        _scheduleFlushAt(nextRetryAt);
        setState(AttriaxSynchronizationState.deferred);
        return;
      }

      if (_lastFlushHadFailure) {
        setState(AttriaxSynchronizationState.failed);
        return;
      }

      setState(
        queueStatus.pendingRequestCount == 0
            ? AttriaxSynchronizationState.synchronized
            : AttriaxSynchronizationState.deferred,
      );
    });
  }

  void _scheduleDeferredFlush() {
    if (_eventFlushInterval == Duration.zero) {
      return;
    }

    _scheduleFlushAt(DateTime.now().toUtc().add(_eventFlushInterval));
  }

  void _scheduleFlushAt(DateTime scheduledAt) {
    final existing = _scheduledFlushAt;
    if (existing != null && !scheduledAt.isBefore(existing)) {
      return;
    }

    _deferredFlushTimer?.cancel();
    _scheduledFlushAt = scheduledAt;
    final delay = scheduledAt.difference(DateTime.now().toUtc());
    _deferredFlushTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      _deferredFlushTimer = null;
      _scheduledFlushAt = null;
      if (!_active) {
        return;
      }
      scheduleFlush();
    });
  }

  Future<T> _withQueueOperationLock<T>(Future<T> Function() action) {
    final completer = Completer<void>();
    final previous = _queueOperationLock;
    _queueOperationLock = completer.future;

    return previous.then((_) => action()).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
  }
}
