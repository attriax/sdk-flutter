import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_context_services.dart';
import 'attriax_native_context_metadata.dart';

class AttriaxPlatformDeviceIdentityResolver
    implements AttriaxContextDeviceIdentityResolver {
  AttriaxPlatformDeviceIdentityResolver({
    required AttriaxPlatformType platformType,
    AttriaxNativeContextMetadata metadata =
        const AttriaxNativeContextMetadata(),
  }) : _platformType = platformType,
       _metadata = metadata;

  final AttriaxPlatformType _platformType;
  final AttriaxNativeContextMetadata _metadata;

  @override
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) async => AttriaxResolvedDeviceId(
    value: fallbackDeviceId,
    source: attriaxPersistentStorageDeviceIdSource,
    isFallback: true,
  );

  @override
  Future<String?> resolveDeviceTimezone() async =>
      _metadata.emptyToNull(DateTime.now().timeZoneName);

  AttriaxResolvedDeviceId? resolveFromNativeContext(
    AttriaxNativeContext nativeContext,
  ) {
    final rawData = _metadata.loadRawDeviceData(nativeContext);
    switch (_platformType) {
      case AttriaxPlatformType.android:
        final androidId = _metadata.emptyToNull(nativeContext.androidId);
        if (androidId != null) {
          return AttriaxResolvedDeviceId(
            value: androidId,
            source: 'android_ssaid',
          );
        }

        final advertisingId = _metadata.emptyToNull(
          nativeContext.advertisingId,
        );
        if (advertisingId != null) {
          return AttriaxResolvedDeviceId(
            value: advertisingId,
            source: 'android_gaid',
          );
        }

        return null;
      case AttriaxPlatformType.ios:
        return _resolveFirstAvailable(<({String? value, String source})>[
          (
            value: _metadata.readString(
              nativeContext.metadata,
              'keychainDeviceId',
            ),
            source: 'ios_keychain',
          ),
          (
            value: _metadata.readString(
              nativeContext.metadata,
              'vendorIdentifier',
            ),
            source: 'ios_idfv',
          ),
        ]);
      case AttriaxPlatformType.windows:
        return _resolveFirstAvailable(<({String? value, String source})>[
          (
            value: _metadata.readString(rawData, 'deviceId'),
            source: 'windows_machine_guid',
          ),
        ]);
      case AttriaxPlatformType.linux:
        return _resolveFirstAvailable(<({String? value, String source})>[
          (
            value: _metadata.readString(rawData, 'machineId'),
            source: 'linux_machine_id',
          ),
        ]);
      case AttriaxPlatformType.macos:
        return _resolveFirstAvailable(<({String? value, String source})>[
          (
            value: _metadata.readString(rawData, 'systemGUID'),
            source: 'macos_platform_uuid',
          ),
          (
            value: _metadata.readString(
              nativeContext.metadata,
              'keychainDeviceId',
            ),
            source: 'macos_keychain',
          ),
        ]);
      case AttriaxPlatformType.web:
      case AttriaxPlatformType.unknown:
        return null;
    }
  }

  String? resolveTimezoneFromNativeContext(
    AttriaxNativeContext nativeContext,
  ) => _metadata.nativeTimezone(nativeContext);

  AttriaxResolvedDeviceId? _resolveFirstAvailable(
    Iterable<({String? value, String source})> candidates,
  ) {
    for (final candidate in candidates) {
      final normalizedValue = _metadata.emptyToNull(candidate.value);
      if (normalizedValue == null) {
        continue;
      }

      return AttriaxResolvedDeviceId(
        value: normalizedValue,
        source: candidate.source,
      );
    }

    return null;
  }
}
