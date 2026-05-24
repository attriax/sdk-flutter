import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_logger.dart';
import 'attriax_sdk_runtime_config.dart';

typedef AttriaxSdkRuntimeConfigContextSnapshotProvider =
    AttriaxContextSnapshot? Function();
typedef AttriaxSdkRuntimeConfigFetcher =
    Future<AttriaxSdkRuntimeConfig> Function(Map<String, Object?> payload);
typedef AttriaxSdkRuntimeConfigLoadedCallback =
    FutureOr<void> Function(AttriaxSdkRuntimeConfig runtimeConfig);

class AttriaxSdkRuntimeConfigCoordinator {
  AttriaxSdkRuntimeConfigCoordinator({
    required AttriaxConfig config,
    required AttriaxSdkRuntimeConfigContextSnapshotProvider contextSnapshot,
    required AttriaxSdkRuntimeConfigFetcher fetchRuntimeConfig,
    required AttriaxLogger logger,
    AttriaxSdkRuntimeConfigLoadedCallback? onLoaded,
  }) : _config = config,
       _contextSnapshot = contextSnapshot,
       _fetchRuntimeConfig = fetchRuntimeConfig,
       _logger = logger,
       _onLoaded = onLoaded;

  final AttriaxConfig _config;
  final AttriaxSdkRuntimeConfigContextSnapshotProvider _contextSnapshot;
  final AttriaxSdkRuntimeConfigFetcher _fetchRuntimeConfig;
  final AttriaxLogger _logger;
  final AttriaxSdkRuntimeConfigLoadedCallback? _onLoaded;

  Future<AttriaxSdkRuntimeConfig>? _inFlight;
  AttriaxSdkRuntimeConfig _current = const AttriaxSdkRuntimeConfig();
  bool _didResolve = false;

  AttriaxSdkRuntimeConfig get current => _current;

  void reset() {
    _inFlight = null;
    _current = const AttriaxSdkRuntimeConfig();
    _didResolve = false;
  }

  void primeForLaunch({required bool isInitialized, required bool isEnabled}) {
    if (!isInitialized || !isEnabled || _didResolve || _inFlight != null) {
      return;
    }

    unawaited(ensureLoaded());
  }

  Future<AttriaxSdkRuntimeConfig> ensureLoaded() {
    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }

    if (_didResolve) {
      return Future<AttriaxSdkRuntimeConfig>.value(_current);
    }

    final loading = _load();
    late final Future<AttriaxSdkRuntimeConfig> trackedLoading;
    trackedLoading = loading.whenComplete(() {
      if (identical(_inFlight, trackedLoading)) {
        _inFlight = null;
      }
    });
    _inFlight = trackedLoading;
    return trackedLoading;
  }

  Future<AttriaxSdkRuntimeConfig> _load() async {
    final context = _contextSnapshot();
    if (context == null) {
      _current = const AttriaxSdkRuntimeConfig();
      _didResolve = true;
      return _current;
    }

    AttriaxSdkRuntimeConfig runtimeConfig;
    try {
      runtimeConfig = await _fetchRuntimeConfig(
        attriaxBuildSdkRuntimeConfigRequest(config: _config, context: context),
      );
    } catch (error, stackTrace) {
      _logger.warning(
        'Attriax SDK config request failed. Using in-memory defaults for this launch.',
        error: error,
        stackTrace: stackTrace,
      );
      runtimeConfig = const AttriaxSdkRuntimeConfig();
    }

    _current = runtimeConfig;
    _didResolve = true;
    await _onLoaded?.call(runtimeConfig);
    return runtimeConfig;
  }
}
