import 'dart:async';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

import 'example_app_configuration.dart';

class AttriaxIntegrationExampleApp extends StatefulWidget {
  const AttriaxIntegrationExampleApp({
    super.key,
    required this.sdk,
    this.ownsSdk = false,
    this.bootstrapError,
  });

  final Attriax sdk;
  final bool ownsSdk;
  final String? bootstrapError;

  @override
  State<AttriaxIntegrationExampleApp> createState() =>
      _AttriaxIntegrationExampleAppState();
}

class _AttriaxIntegrationExampleAppState
    extends State<AttriaxIntegrationExampleApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<AttriaxSynchronizationState>? _syncSubscription;
  StreamSubscription<AttriaxRawDeepLinkEvent>? _deepLinkSubscription;

  late AttriaxSynchronizationState _synchronizationState;
  String _statusMessage =
      'SDK initialized. Send one demo event or open the sample checkout page.';
  String _latestDeepLinkLabel = 'No deep link received yet.';
  String _lastRecordedEventLabel = 'Not sent yet.';
  bool _isRecordingEvent = false;

  @override
  void initState() {
    super.initState();
    _synchronizationState = widget.sdk.synchronization.state;

    if (widget.bootstrapError != null) {
      _statusMessage = widget.bootstrapError!;
      return;
    }

    _latestDeepLinkLabel = _describeDeepLink(
      widget.sdk.deepLinks.rawInitialDeepLink,
    );
    if (!widget.sdk.deepLinks.initialDeepLinkResolved) {
      _statusMessage =
          'SDK initialized. Waiting for any initial or deferred deep link.';
    }

    _syncSubscription = widget.sdk.synchronization.states.listen((state) {
      if (!mounted) {
        return;
      }

      setState(() {
        _synchronizationState = state;
      });
    });
    _deepLinkSubscription = widget.sdk.deepLinks.rawStream.listen((event) {
      if (!mounted) {
        return;
      }

      setState(() {
        _latestDeepLinkLabel = _describeDeepLink(event);
        _statusMessage =
            'Received a deep link. Route the resolved destination inside your app code.';
      });
    });
  }

  @override
  void dispose() {
    final syncSubscription = _syncSubscription;
    if (syncSubscription != null) {
      unawaited(syncSubscription.cancel());
    }

    final deepLinkSubscription = _deepLinkSubscription;
    if (deepLinkSubscription != null) {
      unawaited(deepLinkSubscription.cancel());
    }

    if (widget.ownsSdk) {
      unawaited(widget.sdk.dispose());
    }
    super.dispose();
  }

  Future<void> _recordDemoEvent() async {
    if (_isRecordingEvent) {
      return;
    }

    setState(() {
      _isRecordingEvent = true;
      _statusMessage = 'Sending integration_checkout_started...';
    });

    try {
      widget.sdk.tracking.recordEvent(
        'integration_checkout_started',
        eventData: const <String, Object?>{
          'source': 'flutter_package_example',
          'screen': 'home',
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _lastRecordedEventLabel = 'integration_checkout_started';
        _statusMessage =
            'Sent integration_checkout_started. Check the Attriax dashboard for this app.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'Demo event failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRecordingEvent = false;
        });
      }
    }
  }

  void _openCheckoutScreen() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => const _IntegrationExampleCheckoutPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bootstrapError = widget.bootstrapError;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Attriax Integration Example',
      navigatorObservers: bootstrapError == null
          ? <NavigatorObserver>[AttriaxNavigationObserver(attriax: widget.sdk)]
          : const <NavigatorObserver>[],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6E5E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6FAF8),
      ),
      home: bootstrapError == null
          ? AttriaxIntegrationExampleHome(
              synchronizationState: _synchronizationState,
              statusMessage: _statusMessage,
              latestDeepLinkLabel: _latestDeepLinkLabel,
              lastRecordedEventLabel: _lastRecordedEventLabel,
              currentTokenLabel: maskExampleSecret(exampleProjectToken),
              configurationHelpText: exampleConfigurationHelpText(),
              isRecordingEvent: _isRecordingEvent,
              onOpenCheckout: _openCheckoutScreen,
              onRecordExampleEvent: () {
                unawaited(_recordDemoEvent());
              },
            )
          : AttriaxIntegrationExampleSetupPage(
              errorMessage: bootstrapError,
              currentTokenLabel: maskExampleSecret(exampleProjectToken),
              configurationHelpText: exampleConfigurationHelpText(),
            ),
    );
  }
}

class AttriaxIntegrationExampleHome extends StatelessWidget {
  const AttriaxIntegrationExampleHome({
    super.key,
    required this.synchronizationState,
    required this.statusMessage,
    required this.latestDeepLinkLabel,
    required this.lastRecordedEventLabel,
    required this.currentTokenLabel,
    required this.configurationHelpText,
    required this.isRecordingEvent,
    required this.onOpenCheckout,
    required this.onRecordExampleEvent,
  });

  final AttriaxSynchronizationState synchronizationState;
  final String statusMessage;
  final String latestDeepLinkLabel;
  final String lastRecordedEventLabel;
  final String currentTokenLabel;
  final String configurationHelpText;
  final bool isRecordingEvent;
  final VoidCallback onOpenCheckout;
  final VoidCallback onRecordExampleEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Attriax Flutter integration example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Minimal package example', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'This app demonstrates the smallest useful integration shape: one SDK instance, awaited init(), navigation tracking, deep-link observation, and a sample event.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _ExampleCard(
              title: 'What this app demonstrates',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  _ExampleBullet('Awaited init() before runApp().'),
                  _ExampleBullet('One application-level Attriax instance.'),
                  _ExampleBullet(
                    'AttriaxNavigationObserver attached to MaterialApp.',
                  ),
                  _ExampleBullet(
                    'A deep-link stream listener for resolved startup and deferred links.',
                  ),
                  _ExampleBullet(
                    'A single demo event you can trigger from the UI.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ExampleCard(
              title: 'Current example state',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ExampleKeyValue(
                    label: 'Synchronization state',
                    value: synchronizationState.name,
                  ),
                  _ExampleKeyValue(
                    label: 'Current project token',
                    value: currentTokenLabel,
                  ),
                  _ExampleKeyValue(
                    label: 'Latest deep link',
                    value: latestDeepLinkLabel,
                  ),
                  _ExampleKeyValue(
                    label: 'Last recorded demo event',
                    value: lastRecordedEventLabel,
                  ),
                  const SizedBox(height: 12),
                  Text(statusMessage, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ExampleCard(
              title: 'Try the integration',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FilledButton(
                    key: const ValueKey('recordDemoEventButton'),
                    onPressed: isRecordingEvent ? null : onRecordExampleEvent,
                    child: Text(
                      isRecordingEvent
                          ? 'Sending demo event...'
                          : 'Record demo event',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const ValueKey('openCheckoutScreenButton'),
                    onPressed: onOpenCheckout,
                    child: const Text('Open checkout screen'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ExampleCard(
              title: 'Configuration',
              child: Text(configurationHelpText),
            ),
          ],
        ),
      ),
    );
  }
}

class AttriaxIntegrationExampleSetupPage extends StatelessWidget {
  const AttriaxIntegrationExampleSetupPage({
    super.key,
    required this.errorMessage,
    required this.currentTokenLabel,
    required this.configurationHelpText,
  });

  final String errorMessage;
  final String currentTokenLabel;
  final String configurationHelpText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finish example setup')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'This minimal example only boots when a real Attriax project token is configured.',
            ),
            const SizedBox(height: 12),
            Text(errorMessage),
            const SizedBox(height: 12),
            Text('Current project token: $currentTokenLabel'),
            const SizedBox(height: 12),
            Text(configurationHelpText),
          ],
        ),
      ),
    );
  }
}

class _IntegrationExampleCheckoutPage extends StatelessWidget {
  const _IntegrationExampleCheckoutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout screen',
          key: ValueKey('checkoutScreenTitle'),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'This second route exists so the example shows where to attach AttriaxNavigationObserver in a real app.',
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ExampleBullet extends StatelessWidget {
  const _ExampleBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ExampleKeyValue extends StatelessWidget {
  const _ExampleKeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }
}

String _describeDeepLink(AttriaxRawDeepLinkEvent? event) =>
    event?.uri.toString() ?? 'No deep link received yet.';
