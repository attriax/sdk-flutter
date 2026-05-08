import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_platform_install_referrer_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxPlatformInstallReferrerManager', () {
    late SharedPreferences prefs;
    late AttriaxPreferencesStore preferencesStore;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      preferencesStore = AttriaxPreferencesStore(prefsOverride: prefs);
    });

    test('shares a single in-flight load across concurrent callers', () async {
      final platform = _FakePlatform(
        installReferrerResponses:
            <Future<AttriaxInstallReferrerContext> Function()>[
              () async {
                await Future<void>.delayed(const Duration(milliseconds: 10));
                return const AttriaxInstallReferrerContext(
                  installReferrer: 'utm_source=play_store',
                  metadata: <String, Object?>{'installReferrerStatus': 'ok'},
                );
              },
            ],
      );
      final manager = AttriaxPlatformInstallReferrerManager(
        platformType: AttriaxPlatformType.android,
        platform: platform,
        logger: AttriaxLogger(enableDebugLogs: false),
        preferencesStore: preferencesStore,
        installReferrerTimeout: const Duration(seconds: 1),
        installReferrerRetryDelay: Duration.zero,
      );

      final results = await Future.wait(<Future<AttriaxInstallReferrerContext>>[
        manager.load(),
        manager.load(),
      ]);

      expect(platform.installReferrerCalls, 1);
      expect(results[0].installReferrer, 'utm_source=play_store');
      expect(results[1].installReferrer, 'utm_source=play_store');
      expect(manager.isLoaded, isTrue);
      expect(manager.value, 'utm_source=play_store');
    });

    test('persists a loaded null result after both attempts fail', () async {
      final platform = _FakePlatform(
        installReferrerResponses:
            <Future<AttriaxInstallReferrerContext> Function()>[
              () async => const AttriaxInstallReferrerContext(
                metadata: <String, Object?>{
                  'installReferrerStatus': 'service_unavailable',
                },
              ),
              () async => const AttriaxInstallReferrerContext(
                metadata: <String, Object?>{
                  'installReferrerStatus': 'timeout_flutter',
                },
              ),
            ],
      );
      final manager = AttriaxPlatformInstallReferrerManager(
        platformType: AttriaxPlatformType.android,
        platform: platform,
        logger: AttriaxLogger(enableDebugLogs: false),
        preferencesStore: preferencesStore,
        installReferrerTimeout: const Duration(seconds: 1),
        installReferrerRetryDelay: Duration.zero,
      );

      final context = await manager.load();

      expect(context.installReferrer, isNull);
      expect(context.metadata['installReferrerAttempts'], 2);
      expect(manager.isLoaded, isTrue);
      expect(manager.value, isNull);

      final stored = await preferencesStore.readStoredPlatformInstallReferrer();
      expect(stored.isLoaded, isTrue);
      expect(stored.value, isNull);
    });

    test(
      'uses the persisted install referrer before calling the platform',
      () async {
        await preferencesStore.setStoredPlatformInstallReferrer(
          isLoaded: true,
          value: 'utm_source=cached_play_store',
        );
        final platform = _FakePlatform(
          installReferrerResponses:
              <Future<AttriaxInstallReferrerContext> Function()>[],
        );
        final manager = AttriaxPlatformInstallReferrerManager(
          platformType: AttriaxPlatformType.android,
          platform: platform,
          logger: AttriaxLogger(enableDebugLogs: false),
          preferencesStore: preferencesStore,
          installReferrerTimeout: const Duration(seconds: 1),
          installReferrerRetryDelay: Duration.zero,
        );

        final context = await manager.load();

        expect(platform.installReferrerCalls, 0);
        expect(context.installReferrer, 'utm_source=cached_play_store');
        expect(context.metadata['source'], 'flutter_cached_install_referrer');
      },
    );

    test('retries once and returns the successful referrer payload', () async {
      final platform = _FakePlatform(
        installReferrerResponses:
            <Future<AttriaxInstallReferrerContext> Function()>[
              () async => const AttriaxInstallReferrerContext(
                metadata: <String, Object?>{
                  'installReferrerStatus': 'service_unavailable',
                },
              ),
              () async => const AttriaxInstallReferrerContext(
                installReferrer: 'utm_source=play_store',
                metadata: <String, Object?>{'installReferrerStatus': 'ok'},
              ),
            ],
      );
      final manager = AttriaxPlatformInstallReferrerManager(
        platformType: AttriaxPlatformType.android,
        platform: platform,
        logger: AttriaxLogger(enableDebugLogs: false),
        preferencesStore: preferencesStore,
        installReferrerTimeout: const Duration(seconds: 1),
        installReferrerRetryDelay: Duration.zero,
      );

      final context = await manager.load();

      expect(platform.installReferrerCalls, 2);
      expect(context.installReferrer, 'utm_source=play_store');
      expect(context.metadata['installReferrerStatus'], 'ok');
    });
  });
}

class _FakePlatform extends AttriaxPlatform {
  _FakePlatform({required this.installReferrerResponses});

  final List<Future<AttriaxInstallReferrerContext> Function()>
  installReferrerResponses;
  int installReferrerCalls = 0;

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async {
    final callIndex = installReferrerCalls;
    installReferrerCalls += 1;
    if (callIndex >= installReferrerResponses.length) {
      return const AttriaxInstallReferrerContext();
    }

    return installReferrerResponses[callIndex]();
  }
}
