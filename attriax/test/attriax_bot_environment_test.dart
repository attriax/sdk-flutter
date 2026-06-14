import 'package:attriax_flutter/src/internal/attriax_bot_environment_stub.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxBotEnvironmentSnapshot', () {
    test('default constructor produces a non-bot snapshot', () {
      const snapshot = AttriaxBotEnvironmentSnapshot();

      expect(snapshot.isBot, isFalse);
      expect(snapshot.detectedVia, isNull);
    });

    test('constructor accepts isBot and detectedVia', () {
      const snapshot = AttriaxBotEnvironmentSnapshot(
        isBot: true,
        detectedVia: 'webdriver',
      );

      expect(snapshot.isBot, isTrue);
      expect(snapshot.detectedVia, 'webdriver');
    });
  });

  group('currentAttriaxBotEnvironment stub', () {
    test('always returns a non-bot snapshot on non-web platforms', () {
      final snapshot = currentAttriaxBotEnvironment();

      expect(snapshot.isBot, isFalse);
      expect(snapshot.detectedVia, isNull);
    });
  });

  group('AttriaxBotEnvironmentSnapshot.detectFromUserAgent', () {
    test('detects Googlebot user agent', () {
      const ua =
          'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)';

      expect(
        AttriaxBotEnvironmentSnapshot.detectFromUserAgent(ua),
        'user_agent',
      );
    });

    test('detects curl user agent', () {
      const ua = 'curl/7.68.0';

      expect(
        AttriaxBotEnvironmentSnapshot.detectFromUserAgent(ua),
        'user_agent',
      );
    });

    test('returns null for a normal Chrome user agent', () {
      const ua =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';

      expect(AttriaxBotEnvironmentSnapshot.detectFromUserAgent(ua), isNull);
    });

    test('matches case-insensitively', () {
      expect(
        AttriaxBotEnvironmentSnapshot.detectFromUserAgent('GOOGLEBOT'),
        'user_agent',
      );
      expect(
        AttriaxBotEnvironmentSnapshot.detectFromUserAgent('Wget/1.20.3'),
        'user_agent',
      );
      expect(
        AttriaxBotEnvironmentSnapshot.detectFromUserAgent('WhatsApp/2.21'),
        'user_agent',
      );
    });

    test('returns null for null user agent', () {
      expect(AttriaxBotEnvironmentSnapshot.detectFromUserAgent(null), isNull);
    });

    test('returns null for empty user agent', () {
      expect(AttriaxBotEnvironmentSnapshot.detectFromUserAgent(''), isNull);
    });
  });
}
