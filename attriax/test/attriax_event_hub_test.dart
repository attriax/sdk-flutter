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
      final rawEventFuture = hub.rawDeepLinks.first;
      final rawEvent = hub.emitPendingDeepLink(
        uri: Uri.parse('https://example.com/promo/spring-launch'),
        receivedAt: receivedAt,
        isInitialLink: true,
      );

      final emittedRawEvent = await rawEventFuture;
      final resolution = AttriaxDeepLinkEvent(
        uri: Uri.parse('https://example.com/promo/spring-launch'),
        clickedAt: receivedAt,
        consumedAt: DateTime.utc(2026, 4, 24, 0, 0, 1),
        found: true,
        trigger: AttriaxDeepLinkTrigger.coldStart,
        isAttriaxSubDomain: false,
        rawEvent: emittedRawEvent,
        data: const <String, String>{'campaign': 'spring-launch'},
      );

      hub.resolvePendingDeepLink(event: rawEvent, resolution: resolution);

      final resolved = await hub.waitForResolution(rawEvent);
      expect(emittedRawEvent.uri.path, '/promo/spring-launch');
      expect(emittedRawEvent.isInitial, isTrue);
      expect(resolved, same(resolution));
      expect(resolved.found, isTrue);
      expect(resolved.data?['campaign'], 'spring-launch');
    });

    test(
      'resolves a pending deep link with found false for external links',
      () async {
        final receivedAt = DateTime.utc(2026, 4, 24);

        final rawEvent = hub.emitPendingDeepLink(
          uri: Uri.parse('https://example.com/unknown/path'),
          receivedAt: receivedAt,
          isInitialLink: false,
        );
        final resolution = AttriaxDeepLinkEvent(
          uri: Uri.parse('https://example.com/unknown/path'),
          clickedAt: receivedAt,
          consumedAt: DateTime.utc(2026, 4, 24, 0, 0, 1),
          found: false,
          trigger: AttriaxDeepLinkTrigger.foreground,
          isAttriaxSubDomain: false,
          rawEvent: rawEvent,
        );

        hub.resolvePendingDeepLink(event: rawEvent, resolution: resolution);

        final resolved = await hub.waitForResolution(rawEvent);
        expect(resolved.isForeground, isTrue);
        expect(resolved.found, isFalse);
        expect(resolved.data, isNull);
      },
    );

    test('emits an already resolved deep link immediately', () async {
      final resolution = AttriaxDeepLinkEvent(
        uri: Uri.parse('https://demo.attriax.com/promo/deferred'),
        clickedAt: DateTime.utc(2026, 4, 20),
        consumedAt: DateTime.utc(2026, 4, 24),
        found: true,
        trigger: AttriaxDeepLinkTrigger.deferred,
        isAttriaxSubDomain: true,
        data: const <String, String>{'campaign': 'deferred'},
      );

      final emittedEventFuture = hub.deepLinks.first;
      hub.emitResolvedDeepLink(event: resolution);

      final emittedEvent = await emittedEventFuture;

      expect(emittedEvent.isDeferred, isTrue);
      expect(emittedEvent.isAttriaxSubDomain, isTrue);
      expect(emittedEvent, same(resolution));
    });

    test(
      'stores the raw initial deep link as soon as it is captured',
      () async {
        final emittedEvent = hub.emitPendingDeepLink(
          uri: Uri.parse('https://demo.attriax.com/promo/spring-launch'),
          receivedAt: DateTime.utc(2026, 4, 24),
          isInitialLink: true,
        );

        expect(hub.rawInitialDeepLinkValue, same(emittedEvent));
      },
    );

    test(
      'completes the initial resolved deep link when the result is emitted',
      () async {
        final rawEvent = hub.emitPendingDeepLink(
          uri: Uri.parse('https://example.com/promo/launch'),
          receivedAt: DateTime.utc(2026, 4, 29, 10),
          isInitialLink: true,
        );
        final resolvedEvent = AttriaxDeepLinkEvent(
          uri: Uri.parse('https://example.com/promo/launch'),
          clickedAt: DateTime.utc(2026, 4, 29, 10),
          consumedAt: DateTime.utc(2026, 4, 29, 10, 0, 1),
          found: true,
          trigger: AttriaxDeepLinkTrigger.coldStart,
          isAttriaxSubDomain: false,
          rawEvent: rawEvent,
        );

        hub.emitResolvedDeepLink(event: resolvedEvent);

        final result = await hub.initialDeepLink;
        expect(result, same(resolvedEvent));
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
