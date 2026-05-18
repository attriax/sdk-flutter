import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _processAttriaxStartup(Attriax attriax) async {
  final initialDeepLink = await attriax.deepLinks.waitForInitialDeepLink();
  final originalInstallReferrer = await attriax.referrer
      .getOriginalInstallReferrer();
  final sessionReferrer = await attriax.referrer.getSessionReferrer(
    timeout: const Duration(seconds: 5),
    safe: true,
  );

  debugPrint('Original install referrer: ${originalInstallReferrer?.campaign}');
  debugPrint('Session referrer: ${sessionReferrer?.uri.toString() ?? 'none'}');
  debugPrint(
    'Initial deep link: ${initialDeepLink?.uri.toString() ?? 'none'} (found: ${initialDeepLink?.found ?? false})',
  );
}

void _wireResolvedDeepLinks(
  Attriax attriax,
  GlobalKey<NavigatorState> navigatorKey,
) {
  attriax.deepLinks.stream.listen((event) {
    if (!event.found) {
      return;
    }

    navigatorKey.currentState?.pushNamed(
      '/deep-link',
      arguments: <String, Object?>{
        'uri': event.uri.toString(),
        'data': event.data,
      },
    );
  });
}

void main() {
  test('README deep-link examples compile against the public API', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    expect(_processAttriaxStartup, isNotNull);
    expect(_wireResolvedDeepLinks, isNotNull);
    expect(navigatorKey, isNotNull);
  });
}
