import 'package:attriax_platform_interface/attriax_platform_interface.dart';

import 'attriax_preferences_store.dart';

class AttriaxContextInstallReferrer {
  AttriaxContextInstallReferrer({
    required AttriaxPlatform platform,
    AttriaxPreferencesStore? preferencesStore,
    required Duration installReferrerTimeout,
    required Duration installReferrerRetryDelay,
  }) : _platform = platform,
       _preferencesStore = preferencesStore ?? AttriaxPreferencesStore(),
       _installReferrerTimeout = installReferrerTimeout,
       _installReferrerRetryDelay = installReferrerRetryDelay;

  static const installReferrerStorageKey = 'attriax.install_referrer';

  final AttriaxPlatform _platform;
  final AttriaxPreferencesStore _preferencesStore;
  final Duration _installReferrerTimeout;
  final Duration _installReferrerRetryDelay;
  String? _cachedInstallReferrer;
  bool _loadedInstallReferrerCache = false;

  Future<AttriaxInstallReferrerContext> buildInitialContext(
    AttriaxPlatformType platformType,
  ) async {
    if (platformType != AttriaxPlatformType.android) {
      return const AttriaxInstallReferrerContext();
    }

    final cachedReferrer = await _readPersistedInstallReferrer();
    return _cachedContext(cachedReferrer) ??
        const AttriaxInstallReferrerContext();
  }

  Future<AttriaxInstallReferrerContext> collectContext(
    AttriaxPlatformType platformType,
  ) async {
    if (platformType != AttriaxPlatformType.android) {
      return const AttriaxInstallReferrerContext();
    }

    final cachedReferrer = await _readPersistedInstallReferrer();
    final cachedContext = _cachedContext(cachedReferrer);
    if (cachedContext != null) {
      return cachedContext;
    }

    final first = await _fetchOnce(attempt: 1);
    if (_hasReferrer(first)) {
      return first;
    }

    await Future<void>.delayed(_installReferrerRetryDelay);
    final second = await _fetchOnce(attempt: 2);
    if (_hasReferrer(second)) {
      return second;
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
    return AttriaxInstallReferrerContext(metadata: mergedMetadata);
  }

  Future<void> persistResolvedReferrer(String installReferrer) async {
    if (_cachedInstallReferrer == installReferrer) {
      return;
    }

    _cachedInstallReferrer = installReferrer;
    _loadedInstallReferrerCache = true;
    await _preferencesStore.setStoredPlatformInstallReferrer(
      isLoaded: true,
      value: installReferrer,
    );
  }

  Future<AttriaxInstallReferrerContext> _fetchOnce({
    required int attempt,
  }) async {
    try {
      return await _platform.collectInstallReferrer().timeout(
        _installReferrerTimeout,
        onTimeout: () => AttriaxInstallReferrerContext(
          metadata: {
            'installReferrerStatus': 'timeout_flutter',
            'installReferrerAttempt': attempt,
          },
        ),
      );
    } catch (error) {
      return AttriaxInstallReferrerContext(
        metadata: {
          'installReferrerStatus': 'error_flutter',
          'installReferrerAttempt': attempt,
          'installReferrerError': error.toString(),
        },
      );
    }
  }

  Future<String?> _readPersistedInstallReferrer() async {
    if (_loadedInstallReferrerCache) {
      return _cachedInstallReferrer;
    }

    _loadedInstallReferrerCache = true;
    final stored = await _preferencesStore.readStoredPlatformInstallReferrer();
    _cachedInstallReferrer = _emptyToNull(stored.value);
    return _cachedInstallReferrer;
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
}
