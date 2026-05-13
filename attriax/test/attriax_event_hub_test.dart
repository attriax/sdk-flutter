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
      final receivedAt = DateTime.utc(2026, 4, 24);
      final resolution = AttriaxDeepLinkResolution(
        uri: Uri.parse('https://example.com/promo/spring-launch'),
        clickedAt: receivedAt,
        consumedAt: DateTime.utc(2026, 4, 24, 0, 0, 1),
        found: true,
        data: const <String, String>{'campaign': 'spring-launch'},
      );

      final emittedEventFuture = hub.deepLinks.first;
      hub.emitPendingDeepLink(
        uri: Uri.parse('https://example.com/promo/spring-launch'),
        receivedAt: receivedAt,
        trigger: AttriaxDeepLinkTrigger.coldStart,
        isInitialLink: true,
        isAttriaxDomain: false,
      );

      final emittedEvent = await emittedEventFuture;
      hub.resolvePendingDeepLink(event: emittedEvent, resolution: resolution);

      final resolved = await emittedEvent.resolve();
      expect(emittedEvent.uri.path, '/promo/spring-launch');
      expect(emittedEvent.isColdStart, isTrue);
      expect(emittedEvent.isDeferred, isFalse);
      expect(resolved, same(resolution));
      expect(resolved.found, isTrue);
      expect(resolved.data?['campaign'], 'spring-launch');
    });

    test(
      'resolves a pending deep link with found false for external links',
      () async {
        final receivedAt = DateTime.utc(2026, 4, 24);
        final resolution = AttriaxDeepLinkResolution(
          uri: Uri.parse('https://example.com/unknown/path'),
          clickedAt: receivedAt,
          consumedAt: DateTime.utc(2026, 4, 24, 0, 0, 1),
          found: false,
        );

        final emittedEventFuture = hub.deepLinks.first;
        hub.emitPendingDeepLink(
          uri: Uri.parse('https://example.com/unknown/path'),
          receivedAt: receivedAt,
          trigger: AttriaxDeepLinkTrigger.foreground,
          isInitialLink: false,
          isAttriaxDomain: false,
        );

        final emittedEvent = await emittedEventFuture;
        hub.resolvePendingDeepLink(event: emittedEvent, resolution: resolution);

        final resolved = await emittedEvent.resolve();
        expect(emittedEvent.isForeground, isTrue);
        expect(resolved.found, isFalse);
        expect(resolved.data, isNull);
      },
    );

    test('emits an already resolved deep link immediately', () async {
      final resolution = AttriaxDeepLinkResolution(
        uri: Uri.parse('https://demo.attriax.com/promo/deferred'),
        clickedAt: DateTime.utc(2026, 4, 20),
        consumedAt: DateTime.utc(2026, 4, 24),
        found: true,
        data: const <String, String>{'campaign': 'deferred'},
      );

      final emittedEventFuture = hub.deepLinks.first;
      hub.emitResolvedDeepLink(
        uri: Uri.parse('https://demo.attriax.com/promo/deferred'),
        receivedAt: DateTime.utc(2026, 4, 24),
        trigger: AttriaxDeepLinkTrigger.deferred,
        resolution: resolution,
        isAttriaxDomain: true,
      );

      final emittedEvent = await emittedEventFuture;
      final result = await emittedEvent.resolve();

      expect(emittedEvent.isDeferred, isTrue);
      expect(emittedEvent.isAttriaxDomain, isTrue);
      expect(result, same(resolution));
    });

    test('marks Attriax subdomain deep links with isAttriaxDomain', () async {
      final emittedEvent = hub.emitPendingDeepLink(
        uri: Uri.parse('https://demo.attriax.com/promo/spring-launch'),
        receivedAt: DateTime.utc(2026, 4, 24),
        trigger: AttriaxDeepLinkTrigger.coldStart,
        isInitialLink: true,
        isAttriaxDomain: true,
      );

      expect(emittedEvent.isAttriaxDomain, isTrue);
    });

    test('leaves custom-domain deep links with isAttriax false', () async {
      final emittedEvent = hub.emitPendingDeepLink(
        uri: Uri.parse('https://app.example.com/promo/spring-launch'),
        receivedAt: DateTime.utc(2026, 4, 24),
        trigger: AttriaxDeepLinkTrigger.coldStart,
        isInitialLink: true,
        isAttriaxDomain: false,
      );

      expect(emittedEvent.isAttriaxDomain, isFalse);
    });

    test(
      'exposes the initial deep-link event as soon as it is captured',
      () async {
        final initialEvent = hub.emitPendingDeepLink(
          uri: Uri.parse('https://example.com/promo/launch'),
          receivedAt: DateTime.utc(2026, 4, 29, 10),
          trigger: AttriaxDeepLinkTrigger.coldStart,
          isInitialLink: true,
          isAttriaxDomain: false,
        );

        final result = await hub.initialDeepLink;
        expect(result, same(initialEvent));
      },
    );

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
