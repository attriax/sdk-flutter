import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';

class AttriaxPlatformInstallReferrerManager {
  AttriaxPlatformInstallReferrerManager({
    required AttriaxPlatformType platformType,
    required AttriaxPlatform platform,
    required AttriaxLogger logger,
    required AttriaxPlatformInstallReferrerStore preferencesStore,
    required Duration installReferrerTimeout,
    required Duration installReferrerRetryDelay,
  }) : _platformType = platformType,
       _platform = platform,
       _logger = logger,
       _preferencesStore = preferencesStore,
       _installReferrerTimeout = installReferrerTimeout,
       _installReferrerRetryDelay = installReferrerRetryDelay;

  final AttriaxPlatformType _platformType;
  final AttriaxPlatform _platform;
  final AttriaxLogger _logger;
  final AttriaxPlatformInstallReferrerStore _preferencesStore;
  final Duration _installReferrerTimeout;
  final Duration _installReferrerRetryDelay;

  bool _didInit = false;
  Future<void>? _initializationFuture;
  bool _isLoaded = false;
  String? _value;
  AttriaxInstallReferrerContext _lastContext =
      const AttriaxInstallReferrerContext();
  Future<AttriaxInstallReferrerContext>? _loadFuture;

  bool get isSupported => _platformType == AttriaxPlatformType.android;
  bool get isLoaded => _isLoaded;
  String? get value => _value;

  Future<AttriaxInstallReferrerContext> buildInitialContext() async {
    await _ensureInitialized();
    if (!isSupported) {
      return const AttriaxInstallReferrerContext();
    }

    return _cachedContext(_value) ?? const AttriaxInstallReferrerContext();
  }

  Future<AttriaxInstallReferrerContext> load() async {
    await _ensureInitialized();
    if (!isSupported) {
      return const AttriaxInstallReferrerContext();
    }

    final inFlight = _loadFuture;
    if (inFlight != null) {
      return inFlight;
    }

    if (_isLoaded) {
      return _lastContext;
    }

    final loadFuture = _loadInternal();
    _loadFuture = loadFuture;
    return loadFuture.whenComplete(() {
      if (identical(_loadFuture, loadFuture)) {
        _loadFuture = null;
      }
    });
  }

  Future<AttriaxInstallReferrerContext> reload() async {
    await _ensureInitialized();
    if (!isSupported) {
      return const AttriaxInstallReferrerContext();
    }

    final loadFuture = _loadInternal();
    _loadFuture = loadFuture;
    return loadFuture.whenComplete(() {
      if (identical(_loadFuture, loadFuture)) {
        _loadFuture = null;
      }
    });
  }

  Future<String?> loadRawInstallReferrer() async {
    await _ensureInitialized();
    if (!isSupported) {
      return null;
    }

    final context = await _loadInternal(
      persistResult: false,
      updateCachedState: false,
    );
    return _emptyToNull(context.installReferrer);
  }

  Future<void> clearStoredReferrer() async {
    _isLoaded = false;
    _value = null;
    _lastContext = const AttriaxInstallReferrerContext();
    _loadFuture = null;
    await _preferencesStore.clearStoredPlatformInstallReferrer();
  }

  Future<void> persistResolvedReferrer(String installReferrer) async {
    final normalized = _emptyToNull(installReferrer);
    if (normalized == null) {
      return;
    }

    _value = normalized;
    _isLoaded = true;
    _lastContext =
        _cachedContext(normalized) ?? const AttriaxInstallReferrerContext();
    await _preferencesStore.setStoredPlatformInstallReferrer(
      isLoaded: true,
      value: normalized,
    );
  }

  Future<void> _ensureInitialized() async {
    if (_didInit) {
      return;
    }

    final inFlight = _initializationFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final initFuture = _loadStoredState();
    _initializationFuture = initFuture;
    return initFuture.whenComplete(() {
      if (identical(_initializationFuture, initFuture)) {
        _initializationFuture = null;
      }
    });
  }

  Future<void> _loadStoredState() async {
    _didInit = true;
    if (!isSupported) {
      _isLoaded = false;
      _value = null;
      _lastContext = const AttriaxInstallReferrerContext();
      return;
    }

    final stored = await _preferencesStore.readStoredPlatformInstallReferrer();
    _isLoaded = stored.isLoaded;
    _value = stored.value;
    _lastContext =
        _cachedContext(stored.value) ?? const AttriaxInstallReferrerContext();
  }

  Future<AttriaxInstallReferrerContext> _loadInternal({
    bool persistResult = true,
    bool updateCachedState = true,
  }) async {
    final first = await _fetchOnce(attempt: 1);
    if (_hasReferrer(first)) {
      return _finishLoad(
        first,
        persistResult: persistResult,
        updateCachedState: updateCachedState,
      );
    }

    _logInfo('Install referrer attempt 1 returned no referrer; retrying.');
    await Future<void>.delayed(_installReferrerRetryDelay);
    final second = await _fetchOnce(attempt: 2);
    if (_hasReferrer(second)) {
      return _finishLoad(second);
    }

    final mergedMetadata = <String, dynamic>{
      ...first.metadata,
      ...second.metadata,
      'installReferrerStatus':
          (second.metadata['installReferrerStatus'] ??
                  first.metadata['installReferrerStatus'] ??
                  'empty')
              .toString(),
      'installReferrerAttempts': 2,
    };
    _logWarning('Install referrer unavailable after 2 attempts.');
    return _finishLoad(
      AttriaxInstallReferrerContext(metadata: mergedMetadata),
      persistResult: persistResult,
      updateCachedState: updateCachedState,
    );
  }

  Future<AttriaxInstallReferrerContext> _finishLoad(
    AttriaxInstallReferrerContext context, {
    bool persistResult = true,
    bool updateCachedState = true,
  }) async {
    final normalizedValue = _emptyToNull(context.installReferrer);
    if (updateCachedState) {
      _value = normalizedValue;
      _isLoaded = true;
      _lastContext = context;
    }
    if (persistResult) {
      await _preferencesStore.setStoredPlatformInstallReferrer(
        isLoaded: true,
        value: normalizedValue,
      );
    }
    return context;
  }

  Future<AttriaxInstallReferrerContext> _fetchOnce({
    required int attempt,
  }) async {
    try {
      return await _platform.collectInstallReferrer().timeout(
        _installReferrerTimeout,
        onTimeout: () {
          _logWarning(
            'Install referrer attempt $attempt timed out after '
            '${_installReferrerTimeout.inSeconds}s.',
          );
          return AttriaxInstallReferrerContext(
            metadata: {
              'installReferrerStatus': 'timeout_flutter',
              'installReferrerAttempt': attempt,
            },
          );
        },
      );
    } catch (error, stackTrace) {
      _logWarning(
        'Install referrer attempt $attempt failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return AttriaxInstallReferrerContext(
        metadata: {
          'installReferrerStatus': 'error_flutter',
          'installReferrerAttempt': attempt,
          'installReferrerError': error.toString(),
        },
      );
    }
  }

  AttriaxInstallReferrerContext? _cachedContext(String? cachedReferrer) {
    if (cachedReferrer == null) {
      return null;
    }

    return AttriaxInstallReferrerContext(
      installReferrer: cachedReferrer,
      metadata: const {'source': 'flutter_cached_install_referrer'},
    );
  }

  bool _hasReferrer(AttriaxInstallReferrerContext context) =>
      context.installReferrer != null && context.installReferrer!.isNotEmpty;

  String? _emptyToNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  void _logInfo(String message) {
    _logger.verbose(message);
  }

  void _logWarning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.warning(message, error: error, stackTrace: stackTrace);
  }
}
