import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

class AttriaxTrackingAuthorizationManager {
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

    final request = _platform.requestTrackingAuthorization(timeout: timeout);
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

  Future<void> _waitForTrackingAuthorizationSignal({
    required Completer<void> signal,
    required Duration delay,
  }) async {
    final delayCompleter = Completer<void>();
    final timer = Timer(delay, () {
      if (!delayCompleter.isCompleted) {
        delayCompleter.complete();
      }
    });

    try {
      await Future.any<void>(<Future<void>>[
        delayCompleter.future,
        signal.future,
      ]);
    } finally {
      timer.cancel();
      _clearTrackingAuthorizationRequestSignal(signal);
    }
  }

  void _clearTrackingAuthorizationRequestSignal(Completer<void> signal) {
    if (identical(_trackingAuthorizationRequestSignal, signal)) {
      _trackingAuthorizationRequestSignal = null;
    }
  }
}
