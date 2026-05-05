import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';

import 'attriax_api_models.dart';
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
  Timer? _deferredFlushTimer;
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
    await _queueManager.enqueue(queued);
    setState(AttriaxSynchronizationState.synchronizing);
    _logger.verbose('Queued ${attriaxApiRequestLabel(request)} request.');
    if (flushImmediately || _eventFlushInterval == Duration.zero) {
      scheduleFlush();
      return;
    }

    _scheduleDeferredFlush();
  }

  /// Schedules a flush unless one is already running. Rapid back-to-back calls
  /// collapse into a single additional iteration after the current one ends.
  void scheduleFlush() {
    _deferredFlushTimer?.cancel();
    _deferredFlushTimer = null;
    if (_isSynchronizationRefreshScheduled) {
      _needsSynchronizationRefresh = true;
      return;
    }
    _isSynchronizationRefreshScheduled = true;
    unawaited(_runSynchronizationRefreshLoop());
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

    final pending = await _queueManager.readAll();
    if (_lastFlushHadFailure) {
      setState(AttriaxSynchronizationState.failed);
      return;
    }

    setState(
      pending.isEmpty
          ? AttriaxSynchronizationState.synchronized
          : AttriaxSynchronizationState.synchronizing,
    );
  }

  void _scheduleDeferredFlush() {
    if (_deferredFlushTimer != null) {
      return;
    }

    _deferredFlushTimer = Timer(_eventFlushInterval, () {
      _deferredFlushTimer = null;
      if (!_active) {
        return;
      }
      scheduleFlush();
    });
  }
}
