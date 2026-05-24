import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:attriax_flutter_example/integration_example_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the minimal integration example surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AttriaxIntegrationExampleHome(
          synchronizationState: AttriaxSynchronizationState.synchronized,
          statusMessage:
              'SDK initialized. Send one demo event or open the sample checkout page.',
          latestDeepLinkLabel:
              'https://example-test.attriax.com/example/deep-link-success',
          lastRecordedEventLabel: 'integration_checkout_started',
          currentTokenLabel: 'ax_b62...e561',
          configurationHelpText:
              'Edit lib/example_app_configuration.dart to set the app token or deep-link demo defaults.',
          isRecordingEvent: false,
          onOpenCheckout: _noop,
          onRecordExampleEvent: _noop,
        ),
      ),
    );

    expect(find.text('Attriax Flutter integration example'), findsOneWidget);
    expect(find.text('Minimal package example'), findsOneWidget);
    expect(find.text('Record demo event'), findsOneWidget);
    expect(find.text('Open checkout screen'), findsOneWidget);
    expect(
      find.textContaining('Awaited init() before runApp().'),
      findsOneWidget,
    );
    expect(find.textContaining('integration_checkout_started'), findsOneWidget);
    expect(find.textContaining('example-test.attriax.com'), findsOneWidget);
  });

  testWidgets('renders setup guidance when bootstrap cannot continue', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AttriaxIntegrationExampleSetupPage(
          errorMessage: 'Set a real Attriax app token before running this app.',
          currentTokenLabel: 'ax_you...oken',
          configurationHelpText:
              'Edit lib/example_app_configuration.dart to set the app token or deep-link demo defaults.',
        ),
      ),
    );

    expect(find.text('Finish example setup'), findsOneWidget);
    expect(find.textContaining('real Attriax app token'), findsWidgets);
    expect(find.textContaining('Current token: ax_you...oken'), findsOneWidget);
  });
}

void _noop() {}
