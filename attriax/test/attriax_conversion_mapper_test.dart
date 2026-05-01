import 'package:attriax/src/internal/attriax_conversion_mapper.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxConversionMapper', () {
    const mapper = AttriaxConversionMapper();

    test('maps consumedAt and occurredAt on matched resolutions', () {
      final acceptedAt = DateTime.utc(2026, 4, 29, 12);
      final consumedAt = DateTime.utc(2026, 4, 29, 12, 0, 1);
      final result = AttriaxDeepLinkResolutionResult(
        matched: true,
        status: AttriaxDeepLinkResolutionStatus.matched,
        isFirstLaunch: true,
        requestVersion: 'v1',
        acceptedAt: acceptedAt,
        consumedAt: consumedAt,
        deepLink: const AttriaxDeepLink(path: 'promo/spring-launch'),
      );

      final resolution = mapper.buildEvent(
        result,
        rawEvent: null,
        isDeferred: false,
      );

      expect(resolution, isNotNull);
      expect(resolution!.consumedAt, consumedAt);
      expect(resolution.occurredAt, acceptedAt);
    });

    test('preserves status, requestVersion, and acceptedAt on failures', () {
      final acceptedAt = DateTime.utc(2026, 4, 29, 12, 0, 1);
      final result = AttriaxDeepLinkResolutionResult(
        matched: false,
        status: AttriaxDeepLinkResolutionStatus.unmatched,
        isFirstLaunch: false,
        reason: 'no_match',
        requestVersion: 'v1',
        acceptedAt: acceptedAt,
      );

      final failure = mapper.buildFailure(result, rawEvent: null);

      expect(failure.reason, 'no_match');
      expect(failure.status, AttriaxDeepLinkResolutionStatus.unmatched);
      expect(failure.requestVersion, 'v1');
      expect(failure.acceptedAt, acceptedAt);
      expect(failure.occurredAt, acceptedAt);
    });
  });
}
