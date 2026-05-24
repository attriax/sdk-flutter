import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_sdk_runtime_config.dart';
import 'package:attriax_flutter/src/internal/attriax_sdk_runtime_config_coordinator.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxSdkRuntimeConfigCoordinator', () {
    test(
      'returns defaults without a remote request when context is missing',
      () async {
        var fetchCalls = 0;
        var onLoadedCalls = 0;

        final coordinator = _createCoordinator(
          context: null,
          fetchRuntimeConfig: (_) async {
            fetchCalls += 1;
            return const AttriaxSdkRuntimeConfig(
              clipboardAttributionEnabled: true,
            );
          },
          onLoaded: (_) {
            onLoadedCalls += 1;
          },
        );

        final result = await coordinator.ensureLoaded();

        expect(fetchCalls, 0);
        expect(onLoadedCalls, 0);
        expect(result.requestVersion, 'v1');
        expect(result.acceptedAt, isNull);
        expect(result.clipboardAttributionEnabled, isFalse);
        expect(coordinator.current.clipboardAttributionEnabled, isFalse);
      },
    );

    test(
      'deduplicates in-flight loads and caches the resolved config',
      () async {
        final completer = Completer<AttriaxSdkRuntimeConfig>();
        var fetchCalls = 0;
        final loaded = <AttriaxSdkRuntimeConfig>[];

        final coordinator = _createCoordinator(
          context: _androidContext,
          fetchRuntimeConfig: (_) {
            fetchCalls += 1;
            return completer.future;
          },
          onLoaded: loaded.add,
        );

        final firstLoad = coordinator.ensureLoaded();
        final secondLoad = coordinator.ensureLoaded();

        expect(fetchCalls, 1);

        completer.complete(
          const AttriaxSdkRuntimeConfig(
            requestVersion: 'v2',
            clipboardAttributionEnabled: true,
          ),
        );

        final firstResult = await firstLoad;
        final secondResult = await secondLoad;
        final thirdResult = await coordinator.ensureLoaded();

        expect(firstResult.requestVersion, 'v2');
        expect(secondResult.clipboardAttributionEnabled, isTrue);
        expect(thirdResult.requestVersion, 'v2');
        expect(fetchCalls, 1);
        expect(loaded, hasLength(1));
        expect(loaded.single.requestVersion, 'v2');
        expect(coordinator.current.requestVersion, 'v2');
      },
    );

    test('falls back to defaults when the remote request fails', () async {
      var fetchCalls = 0;
      final loaded = <AttriaxSdkRuntimeConfig>[];

      final coordinator = _createCoordinator(
        context: _androidContext,
        fetchRuntimeConfig: (_) async {
          fetchCalls += 1;
          throw StateError('boom');
        },
        onLoaded: loaded.add,
      );

      final result = await coordinator.ensureLoaded();

      expect(fetchCalls, 1);
      expect(result.requestVersion, 'v1');
      expect(result.clipboardAttributionEnabled, isFalse);
      expect(loaded, hasLength(1));
      expect(loaded.single.clipboardAttributionEnabled, isFalse);
    });
  });
}

AttriaxSdkRuntimeConfigCoordinator _createCoordinator({
  required AttriaxContextSnapshot? context,
  required AttriaxSdkRuntimeConfigFetcher fetchRuntimeConfig,
  AttriaxSdkRuntimeConfigLoadedCallback? onLoaded,
}) => AttriaxSdkRuntimeConfigCoordinator(
  config: const AttriaxConfig(appToken: 'ax_test_token'),
  contextSnapshot: () => context,
  fetchRuntimeConfig: fetchRuntimeConfig,
  logger: AttriaxLogger(enableDebugLogs: false),
  onLoaded: onLoaded,
);

const AttriaxContextSnapshot _androidContext = AttriaxContextSnapshot(
  platform: AttriaxPlatformType.android,
  deviceId: 'device_123',
  isFirstLaunch: true,
  sdk: AttriaxSdkSnapshot(apiVersion: '2025-01-01', packageVersion: '1.2.3'),
  app: AttriaxAppSnapshot(
    version: '1.0.0',
    buildNumber: '1',
    packageName: 'com.attriax.test',
  ),
  device: AttriaxDeviceSnapshot(model: 'Pixel 9'),
);
