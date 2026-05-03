import 'package:attriax_platform_interface/attriax_platform_interface.dart';

import 'attriax_context_collector.dart';
import 'attriax_id_generator.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';

/// Owns the in-memory Attriax runtime context and device identity state.
class AttriaxContextManager {
  AttriaxContextManager({
    required AttriaxContextCollector contextCollector,
    required AttriaxPreferencesStore preferencesStore,
    required AttriaxLogger logger,
  }) : _contextCollector = contextCollector,
       _preferencesStore = preferencesStore,
       _logger = logger;

  final AttriaxContextCollector _contextCollector;
  final AttriaxPreferencesStore _preferencesStore;
  final AttriaxLogger _logger;

  String? _deviceId;
  String? _deviceIdSource;
  bool _isFirstLaunch = false;
  AttriaxContextSnapshot? _snapshot;

  String? get deviceId => _deviceId;
  bool get isFirstLaunch => _isFirstLaunch;
  AttriaxSdkSnapshot? get sdkSnapshot => _snapshot?.sdk;
  AttriaxContextSnapshot? get snapshot => _snapshot;

  String get requiredDeviceId {
    final value = _deviceId;
    if (value == null || value.isEmpty) {
      throw StateError('Attriax context not initialized. Call init() first.');
    }

    return value;
  }

  AttriaxContextSnapshot get requiredSnapshot {
    final value = _snapshot;
    if (value == null) {
      throw StateError('Attriax context not initialized. Call init() first.');
    }

    return value;
  }

  Future<void> init() async {
    final storedDeviceData = await _preferencesStore.restoreDeviceData(
      deviceIdFactory: attriaxGenerateId,
    );

    _deviceId ??= storedDeviceData.deviceId;
    _deviceIdSource ??= storedDeviceData.deviceIdSource;

    late final AttriaxResolvedDeviceId resolvedDeviceId;
    if (_deviceIdSource != null) {
      resolvedDeviceId = AttriaxResolvedDeviceId(
        value: requiredDeviceId,
        source: _deviceIdSource!,
        isFallback:
            _deviceIdSource == attriaxPersistentStorageDeviceIdSource,
      );
    } else if (storedDeviceData.hasPersistedDeviceId) {
      resolvedDeviceId = AttriaxResolvedDeviceId(
        value: requiredDeviceId,
        source: attriaxPersistentStorageDeviceIdSource,
        isFallback: true,
      );
    } else {
      resolvedDeviceId = await _contextCollector.resolvePreferredDeviceId(
        fallbackDeviceId: requiredDeviceId,
      );
    }

    if (_deviceId != resolvedDeviceId.value) {
      _deviceId = resolvedDeviceId.value;
    }
    _deviceIdSource = resolvedDeviceId.source;
    await _preferencesStore.setResolvedDeviceIdentity(
      deviceId: requiredDeviceId,
      deviceIdSource: _deviceIdSource,
    );
    _logger.verbose(
      'Using device ID (${resolvedDeviceId.source}): $requiredDeviceId',
    );

    _isFirstLaunch = storedDeviceData.isFirstLaunch;
    _snapshot = await _contextCollector.collectContextSnapshot(
      deviceId: requiredDeviceId,
      isFirstLaunch: _isFirstLaunch,
    );
  }

  Future<AttriaxContextSnapshot> ensureResolvedForAppOpen() =>
      Future<AttriaxContextSnapshot>.value(requiredSnapshot);

  String requireDeviceIdSource() {
    final source = _deviceIdSource?.trim();
    if (source == null || source.isEmpty) {
      return attriaxPersistentStorageDeviceIdSource;
    }

    return source;
  }
}
