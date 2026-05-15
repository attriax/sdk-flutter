import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

class AttriaxTrackingAuthorizationManager {
  static const Duration _pendingTrackingAuthorizationPollInterval = Duration(
    milliseconds: 250,
  );

  AttriaxTrackingAuthorizationManager({
    required AttriaxConfig config,
    required AttriaxPlatform platform,
    required AttriaxPlatformType platformType,
  }) : _config = config,
       _platform = platform,
       _platformType = platformType;

  final AttriaxConfig _config;
  final AttriaxPlatform _platform;
  final AttriaxPlatformType _platformType;
  Future<AttriaxTrackingAuthorizationStatus>? _trackingAuthorizationRequest;
  Future<AttriaxTrackingAuthorizationStatus>? _trackingAuthorizationStartupWait;
  AttriaxTrackingAuthorizationStatus? _cachedTrackingAuthorizationStatus;
  bool _didResolveStartupTrackingAuthorization = false;
  Completer<void>? _trackingAuthorizationRequestSignal;

  Future<AttriaxTrackingAuthorizationStatus>
  getTrackingAuthorizationStatus() async {
    final status = await _platform.getTrackingAuthorizationStatus();
    _cacheTrackingAuthorizationStatus(status);
    return status;
  }

  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) async {
    final inFlightRequest = _trackingAuthorizationRequest;
    if (inFlightRequest != null) {
      return inFlightRequest;
    }

    final request = _requestTrackingAuthorization(timeout: timeout);
    _trackingAuthorizationRequest = request;
    _signalTrackingAuthorizationRequest();

    try {
      final status = await request;
      _cacheTrackingAuthorizationStatus(status);
      return status;
    } finally {
      if (identical(_trackingAuthorizationRequest, request)) {
        _trackingAuthorizationRequest = null;
      }
    }
  }

  Future<AttriaxTrackingAuthorizationStatus> _requestTrackingAuthorization({
    Duration? timeout,
  }) async {
    if (_platformType != AttriaxPlatformType.ios) {
      return _platform.requestTrackingAuthorization(timeout: timeout);
    }

    final requestSignal = Completer<void>();
    AttriaxTrackingAuthorizationStatus? requestStatus;
    Object? requestError;
    StackTrace? requestStackTrace;

    unawaited(
      _platform
          .requestTrackingAuthorization(timeout: timeout)
          .then<void>(
            (status) {
              requestStatus = status;
            },
            onError: (Object error, StackTrace stackTrace) {
              requestError = error;
              requestStackTrace = stackTrace;
            },
          )
          .whenComplete(() {
            if (!requestSignal.isCompleted) {
              requestSignal.complete();
            }
          }),
    );

    var remaining = timeout;
    final initialDelay = _trackingAuthorizationPollDelay(remaining);
    if (!requestSignal.isCompleted) {
      await _waitForFutureOrDelay(
        future: requestSignal.future,
        delay: initialDelay,
      );

      if (remaining != null) {
        remaining -= initialDelay;
      }
    }

    while (true) {
      if (requestSignal.isCompleted) {
        if (requestError != null) {
          Error.throwWithStackTrace(requestError!, requestStackTrace!);
        }

        final completedStatus = requestStatus;
        if (completedStatus != null &&
            completedStatus !=
                AttriaxTrackingAuthorizationStatus.notDetermined) {
          return completedStatus;
        }
      }

      final status = await getTrackingAuthorizationStatus();
      if (_isResolvedTrackingAuthorizationStatus(status)) {
        return status;
      }

      if (remaining != null && remaining <= Duration.zero) {
        return AttriaxTrackingAuthorizationStatus.timedOut;
      }

      final delay = _trackingAuthorizationPollDelay(remaining);
      if (requestSignal.isCompleted) {
        await Future<void>.delayed(delay);
      } else {
        await _waitForFutureOrDelay(future: requestSignal.future, delay: delay);
      }

      if (remaining != null) {
        remaining -= delay;
      }
    }
  }

  Future<AttriaxTrackingAuthorizationStatus>
  waitForTrackingAuthorizationIfNeeded() async {
    if (_platformType != AttriaxPlatformType.ios) {
      return AttriaxTrackingAuthorizationStatus.notSupported;
    }

    if (!_config.collectAdvertisingId) {
      return AttriaxTrackingAuthorizationStatus.disabled;
    }

    return _waitForTrackingAuthorizationDuringStartup();
  }

  Future<AttriaxTrackingAuthorizationStatus>
  _waitForTrackingAuthorizationDuringStartup() async {
    final inFlightWait = _trackingAuthorizationStartupWait;
    if (inFlightWait != null) {
      return inFlightWait;
    }

    final cachedStatus = _cachedTrackingAuthorizationStatus;
    if (_isResolvedTrackingAuthorizationStatus(cachedStatus)) {
      return cachedStatus!;
    }

    if (_didResolveStartupTrackingAuthorization) {
      return cachedStatus ?? AttriaxTrackingAuthorizationStatus.notDetermined;
    }

    late final Future<AttriaxTrackingAuthorizationStatus> wait;
    if (_config.requestTrackingAuthorizationOnInit) {
      wait = _trackingAuthorizationRequest ?? requestTrackingAuthorization();
    } else {
      wait = _pollTrackingAuthorizationStatus();
    }
    _trackingAuthorizationStartupWait = wait;

    try {
      return await wait;
    } finally {
      _didResolveStartupTrackingAuthorization = true;
      if (identical(_trackingAuthorizationStartupWait, wait)) {
        _trackingAuthorizationStartupWait = null;
      }
    }
  }

  Future<AttriaxTrackingAuthorizationStatus>
  _pollTrackingAuthorizationStatus() async {
    final timeout = _config.trackingAuthorizationStatusTimeout;
    final deadline = DateTime.now().add(timeout);

    while (true) {
      final inFlightRequest = _trackingAuthorizationRequest;
      if (inFlightRequest != null) {
        return inFlightRequest;
      }

      final cachedStatus = _cachedTrackingAuthorizationStatus;
      if (_isResolvedTrackingAuthorizationStatus(cachedStatus)) {
        return cachedStatus!;
      }

      final status = await getTrackingAuthorizationStatus();
      if (_isResolvedTrackingAuthorizationStatus(status)) {
        return status;
      }

      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        return AttriaxTrackingAuthorizationStatus.timedOut;
      }

      final signal = Completer<void>();
      _trackingAuthorizationRequestSignal = signal;

      if (_trackingAuthorizationRequest != null) {
        _clearTrackingAuthorizationRequestSignal(signal);
        continue;
      }

      final delay = remaining < const Duration(seconds: 1)
          ? remaining
          : const Duration(seconds: 1);

      await _waitForTrackingAuthorizationSignal(signal: signal, delay: delay);
    }
  }

  bool _isResolvedTrackingAuthorizationStatus(
    AttriaxTrackingAuthorizationStatus? status,
  ) {
    if (status == null) {
      return false;
    }

    return status != AttriaxTrackingAuthorizationStatus.notDetermined &&
        status != AttriaxTrackingAuthorizationStatus.timedOut;
  }

  void _cacheTrackingAuthorizationStatus(
    AttriaxTrackingAuthorizationStatus status,
  ) {
    if (status != AttriaxTrackingAuthorizationStatus.timedOut) {
      _cachedTrackingAuthorizationStatus = status;
    }
  }

  void _signalTrackingAuthorizationRequest() {
    final signal = _trackingAuthorizationRequestSignal;
    if (signal != null && !signal.isCompleted) {
      signal.complete();
    }
  }

  Duration _trackingAuthorizationPollDelay(Duration? remaining) {
    if (remaining == null) {
      return _pendingTrackingAuthorizationPollInterval;
    }

    return remaining < _pendingTrackingAuthorizationPollInterval
        ? remaining
        : _pendingTrackingAuthorizationPollInterval;
  }

  Future<void> _waitForTrackingAuthorizationSignal({
    required Completer<void> signal,
    required Duration delay,
  }) async {
    try {
      await _waitForFutureOrDelay(future: signal.future, delay: delay);
    } finally {
      _clearTrackingAuthorizationRequestSignal(signal);
    }
  }

  Future<void> _waitForFutureOrDelay({
    required Future<void> future,
    required Duration delay,
  }) async {
    final delayCompleter = Completer<void>();
    final timer = Timer(delay, () {
      if (!delayCompleter.isCompleted) {
        delayCompleter.complete();
      }
    });

    try {
      await Future.any<void>(<Future<void>>[delayCompleter.future, future]);
    } finally {
      timer.cancel();
    }
  }

  void _clearTrackingAuthorizationRequestSignal(Completer<void> signal) {
    if (identical(_trackingAuthorizationRequestSignal, signal)) {
      _trackingAuthorizationRequestSignal = null;
    }
  }
}
