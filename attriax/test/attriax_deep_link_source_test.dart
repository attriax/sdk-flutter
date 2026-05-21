import 'package:attriax_flutter/src/attriax_deep_link_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('createDefaultAttriaxDeepLinkSource', () {
    test('returns no automatic deep links on Windows', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final source = createDefaultAttriaxDeepLinkSource();

      expect(await source.getInitialLink(), isNull);
      await expectLater(source.uriLinkStream.toList(), completion(isEmpty));
    });

    test('returns no automatic deep links on macOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final source = createDefaultAttriaxDeepLinkSource();

      expect(await source.getInitialLink(), isNull);
      await expectLater(source.uriLinkStream.toList(), completion(isEmpty));
    });
  });

  group('attriaxShouldIgnoreAutomaticWebInitialUri', () {
    test('ignores Flutter web hash-router URLs at the site root', () {
      expect(
        attriaxShouldIgnoreAutomaticWebInitialUri(
          Uri.parse('http://127.0.0.1:7357/#/controls'),
        ),
        isTrue,
      );
      expect(
        attriaxShouldIgnoreAutomaticWebInitialUri(
          Uri.parse('https://example.com/?debug=true#/deeplinks/result'),
        ),
        isTrue,
      );
    });

    test('keeps actual path-based web deep links', () {
      expect(
        attriaxShouldIgnoreAutomaticWebInitialUri(
          Uri.parse('https://example.attriax.com/campaign/spring-launch'),
        ),
        isFalse,
      );
      expect(
        attriaxShouldIgnoreAutomaticWebInitialUri(
          Uri.parse('myapp://promo/spring-launch'),
        ),
        isFalse,
      );
    });
  });
}
