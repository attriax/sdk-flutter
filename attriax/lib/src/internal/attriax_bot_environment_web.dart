import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'attriax_bot_environment_stub.dart';

extension type _NavigatorWithWebDriver._(JSObject _) implements JSObject {
  external JSBoolean? get webdriver;
}

AttriaxBotEnvironmentSnapshot currentAttriaxBotEnvironment() {
  try {
    final navigator = _NavigatorWithWebDriver._(
      web.window.navigator as JSObject,
    );
    if (navigator.webdriver?.toDart ?? false) {
      return const AttriaxBotEnvironmentSnapshot(
        isBot: true,
        detectedVia: 'webdriver',
      );
    }
  } catch (_) {
    // ignore
  }

  try {
    final screen = web.window.screen;
    if (screen.width == 0 || screen.height == 0) {
      return const AttriaxBotEnvironmentSnapshot(
        isBot: true,
        detectedVia: 'headless',
      );
    }
  } catch (_) {
    // ignore
  }

  final detectedVia = AttriaxBotEnvironmentSnapshot.detectFromUserAgent(
    web.window.navigator.userAgent,
  );
  if (detectedVia != null) {
    return AttriaxBotEnvironmentSnapshot(isBot: true, detectedVia: detectedVia);
  }

  return const AttriaxBotEnvironmentSnapshot();
}
