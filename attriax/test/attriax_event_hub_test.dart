import 'package:flutter_test/flutter_test.dart';
import 'package:attriax_flutter/src/internal/attriax_event_hub.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

void main() {
  group('AttriaxEventHub', () {
    late AttriaxEventHub hub;

    setUp(() {
      hub = AttriaxEventHub();
    });

    tearDown(() async {
      await hub.dispose();
    });

    test('resolves a pending deep link with a matched resolution', () async {
      final rawEvent = AttriaxRawDeepLinkEvent(
        uri: Uri.parse('https://example.com/promo/spring-launch'),
        linkPath: 'promo/spring-launch',
        isFirstLaunch: true,
        isInitialLink: true,
        occurredAt: DateTime.utc(2026, 4, 24),
      );
      final resolution = AttriaxDeepLinkResolution(
        deepLink: const AttriaxDeepLink(path: 'promo/spring-launch'),
        rawEvent: rawEvent,
        isFirstLaunch: true,
        isDeferred: false,
        occurredAt: DateTime.utc(2026, 4, 24, 0, 0, 1),
      );

      final emittedEventFuture = hub.deepLinks.first;
      hub.emitPendingDeepLink(rawEvent);

      final emittedEvent = await emittedEventFuture;
      hub.resolvePendingDeepLink(rawEvent: rawEvent, resolution: resolution);

      final result = await emittedEvent.resolve();
      expect(result.isMatched, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.rawEvent, same(rawEvent));
      expect(result.resolution, same(resolution));
      expect(result.failure, isNull);
    });

    test('resolves a pending deep link with a failure', () async {
      final rawEvent = AttriaxRawDeepLinkEvent(
        uri: Uri.parse('https://example.com/unknown/path'),
        linkPath: 'unknown/path',
        isFirstLaunch: false,
        isInitialLink: false,
        occurredAt: DateTime.utc(2026, 4, 24),
      );
      final failure = AttriaxDeepLinkResolutionFailure(
        reason: 'unmatched',
        rawEvent: rawEvent,
        isFirstLaunch: false,
        occurredAt: DateTime.utc(2026, 4, 24, 0, 0, 1),
      );

      final emittedEventFuture = hub.deepLinks.first;
      hub.emitPendingDeepLink(rawEvent);

      final emittedEvent = await emittedEventFuture;
      hub.failPendingDeepLink(rawEvent: rawEvent, failure: failure);

      final result = await emittedEvent.resolve();
      expect(result.isMatched, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.rawEvent, same(rawEvent));
      expect(result.resolution, isNull);
      expect(result.failure, same(failure));
    });

    test('emits an already resolved deep link immediately', () async {
      final resolution = AttriaxDeepLinkResolution(
        deepLink: const AttriaxDeepLink(path: 'promo/deferred'),
        isFirstLaunch: true,
        isDeferred: true,
        occurredAt: DateTime.utc(2026, 4, 24),
      );

      final emittedEventFuture = hub.deepLinks.first;
      hub.emitResolvedDeepLink(resolution: resolution);

      final emittedEvent = await emittedEventFuture;
      final result = await emittedEvent.resolve();

      expect(emittedEvent.rawEvent, isNull);
      expect(result.isMatched, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.resolution, same(resolution));
      expect(result.failure, isNull);
    });

    test('exposes the resolved initial deep link result', () async {
      final rawEvent = AttriaxRawDeepLinkEvent(
        uri: Uri.parse('https://example.com/promo/launch'),
        linkPath: 'promo/launch',
        isFirstLaunch: true,
        isInitialLink: true,
        occurredAt: DateTime.utc(2026, 4, 29, 10),
      );
      final resolution = AttriaxDeepLinkResolution(
        deepLink: const AttriaxDeepLink(path: 'promo/launch'),
        rawEvent: rawEvent,
        isFirstLaunch: true,
        isDeferred: false,
        occurredAt: DateTime.utc(2026, 4, 29, 10, 0, 1),
      );

      hub.emitPendingDeepLink(rawEvent);
      hub.resolvePendingDeepLink(rawEvent: rawEvent, resolution: resolution);

      final result = await hub.initialDeepLink;
      expect(result?.resolution, same(resolution));
    });

    test(
      'completes initialDeepLink with null when no launch link exists',
      () async {
        hub.completeInitialDeepLinkIfAbsent();

        final result = await hub.initialDeepLink;
        expect(result, isNull);
      },
    );
  });
}
