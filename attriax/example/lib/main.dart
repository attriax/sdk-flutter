import 'dart:async';

import 'package:flutter/material.dart';
import 'package:attriax/attriax.dart';

import 'example_attriax_sdk.dart';

const String exampleAppToken = 'ax_your_app_token';

void ensureExampleAppConfigured({required String appToken}) {
  if (appToken.startsWith('ax_your_')) {
    throw StateError(
      'Replace the example Attriax app token before running this app.',
    );
  }
}

// ── SDK instance (application-level singleton) ────────────────────────────────
//
// Create the Attriax instance as a top-level variable. Calling init() here
// would be premature because Flutter bindings are not yet ready. Instead,
// call init() in main() after WidgetsFlutterBinding.ensureInitialized().

final Attriax attriax = Attriax(
  config: const AttriaxConfig(
    appToken: exampleAppToken,
    sdkMetadata: <String, Object?>{
      'surface': 'package_example',
      'purpose': 'docs_and_demo',
    },
  ),
);

final ExampleAttriaxSdk exampleSdk = LiveExampleAttriaxSdk(attriax);

final GlobalKey<NavigatorState> _exampleNavigatorKey =
    GlobalKey<NavigatorState>();

class _ExampleRouteDestination {
  const _ExampleRouteDestination({
    required this.routeName,
    required this.title,
    required this.description,
  });

  final String routeName;
  final String title;
  final String description;
}

class _ExampleDeepLinkPageArgs {
  const _ExampleDeepLinkPageArgs({
    required this.deepLink,
    required this.navigationSource,
    required this.title,
    required this.description,
  });

  final AttriaxDeepLink deepLink;
  final String navigationSource;
  final String title;
  final String description;
}

_ExampleRouteDestination _resolveExampleRoute(AttriaxDeepLink deepLink) {
  final segments = deepLink.path
      .split('/')
      .where((segment) => segment.trim().isNotEmpty)
      .toList(growable: false);

  if (segments.isEmpty) {
    return const _ExampleRouteDestination(
      routeName: '/deep-link',
      title: 'Deep Link Screen',
      description: 'Fallback destination for unmatched route patterns.',
    );
  }

  switch (segments.first) {
    case 'promo':
      return const _ExampleRouteDestination(
        routeName: '/promo',
        title: 'Promo Screen',
        description:
            'This simulates opening a campaign or promotion screen from a matched deep link.',
      );
    case 'profile':
      return const _ExampleRouteDestination(
        routeName: '/profile',
        title: 'Profile Screen',
        description:
            'This simulates routing into a user-specific area after deep-link matching succeeds.',
      );
    default:
      return const _ExampleRouteDestination(
        routeName: '/deep-link',
        title: 'Deep Link Screen',
        description: 'Fallback destination for unmatched route patterns.',
      );
  }
}

void _openExampleDeepLink(AttriaxDeepLink deepLink, {required String source}) {
  final navigator = _exampleNavigatorKey.currentState;
  if (navigator == null) {
    return;
  }

  final destination = _resolveExampleRoute(deepLink);
  navigator.pushNamed(
    destination.routeName,
    arguments: _ExampleDeepLinkPageArgs(
      deepLink: deepLink,
      navigationSource: source,
      title: destination.title,
      description: destination.description,
    ),
  );
}

Route<void> _onGenerateExampleRoute(
  RouteSettings settings, {
  required ExampleAttriaxSdk sdk,
}) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute<void>(
        builder: (_) => ExampleHomePage(sdk: sdk),
        settings: settings,
      );
    case '/promo':
    case '/profile':
    case '/deep-link':
      final args = settings.arguments as _ExampleDeepLinkPageArgs?;
      return MaterialPageRoute<void>(
        builder: (_) => _ExampleDeepLinkDestinationPage(args: args),
        settings: settings,
      );
    default:
      return MaterialPageRoute<void>(
        builder: (_) => ExampleHomePage(sdk: sdk),
        settings: settings,
      );
  }
}

// ── Entry point ───────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ensureExampleAppConfigured(appToken: exampleAppToken);

  // Recommended: await initialization during startup so the SDK has restored
  // persisted state, collected context, and started listeners before the UI.
  // If your app must remain non-blocking, you can intentionally choose
  // unawaited(attriax.init()) instead.
  await exampleSdk.init();

  runApp(AttriaxPackageExampleApp());
}

// ── App widget ────────────────────────────────────────────────────────────────

class AttriaxPackageExampleApp extends StatelessWidget {
  AttriaxPackageExampleApp({super.key, ExampleAttriaxSdk? sdk})
    : sdk = sdk ?? exampleSdk;

  final ExampleAttriaxSdk sdk;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attriax Example',
      navigatorKey: _exampleNavigatorKey,
      navigatorObservers: sdk.buildNavigatorObservers(),
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0F766E),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) =>
          _onGenerateExampleRoute(settings, sdk: sdk),
      initialRoute: '/',
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key, required this.sdk});

  final ExampleAttriaxSdk sdk;

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final TextEditingController _manualPathController = TextEditingController(
    text: 'promo/spring-launch',
  );
  StreamSubscription<AttriaxDeepLinkEvent>? _deepLinkSubscription;
  StreamSubscription<AttriaxSynchronizationState>? _synchronizationSubscription;

  bool _sdkEnabled = true;
  bool _eventsEnabled = true;
  String _status = 'SDK initialized.';
  AttriaxAppOpenResult? _appOpenResult;
  AttriaxDynamicLinkRecord? _lastCreatedDynamicLink;
  AttriaxRawDeepLinkEvent? _lastRawDeepLink;
  AttriaxDeepLinkConversionEvent? _lastConversion;
  AttriaxDeepLinkConversionFailure? _lastFailure;

  @override
  void initState() {
    super.initState();

    _deepLinkSubscription = widget.sdk.deepLinks.listen(_handleDeepLinkEvent);
    _synchronizationSubscription = widget.sdk.synchronizationStates.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    if (widget.sdk.isInitialized) {
      _syncStateFromSdk();
    }
  }

  @override
  void dispose() {
    unawaited(_deepLinkSubscription?.cancel() ?? Future<void>.value());
    unawaited(_synchronizationSubscription?.cancel() ?? Future<void>.value());
    _manualPathController.dispose();
    super.dispose();
  }

  void _syncStateFromSdk() {
    setState(() {
      _sdkEnabled = widget.sdk.enabled;
      _eventsEnabled = widget.sdk.eventsEnabled;
      _status = widget.sdk.enabled
          ? 'Initialized. App open tracking is running.'
          : 'Initialized in disabled mode.';
    });
  }

  Future<void> _handleDeepLinkEvent(AttriaxDeepLinkEvent event) async {
    final rawEvent = event.rawEvent;
    if (rawEvent != null && mounted) {
      setState(() {
        _lastRawDeepLink = rawEvent;
        _status =
            'Received raw deep link: ${rawEvent.linkPath ?? rawEvent.uri}';
      });
    }

    try {
      final result = await event.waitForConversionResult();
      if (!mounted) {
        return;
      }

      final conversion = result.conversion;
      if (conversion != null) {
        setState(() {
          _lastConversion = conversion;
          _lastFailure = null;
          _status = 'Matched deep link: ${conversion.deepLink.path}';
        });

        _openExampleDeepLink(
          conversion.deepLink,
          source: conversion.isDeferred
              ? 'deferred_app_open'
              : 'matched_conversion',
        );
        return;
      }

      final failure = result.failure;
      if (failure != null) {
        setState(() {
          _lastFailure = failure;
          _status = 'Deep link conversion failed: ${failure.reason}';
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = 'Deep link processing failed: $error';
      });
    }
  }

  Future<void> _waitForAppOpenTracking() async {
    setState(() => _status = 'Waiting for app open tracking...');
    try {
      final result = await widget.sdk.waitForAppOpenTracking();
      if (!mounted) return;
      setState(() {
        _appOpenResult = result;
        _status = result == null
            ? 'App open tracking was not scheduled.'
            : 'App open tracked: ${result.attributionType.name}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'App open tracking failed: $error');
    }
  }

  Future<void> _trackSampleEvent() async {
    await widget.sdk.trackEvent(
      'purchase_completed',
      eventData: const <String, Object?>{
        'value': 99,
        'currency': 'USD',
        'plan': 'pro',
      },
    );
    if (!mounted) return;
    setState(() => _status = 'Queued purchase_completed event.');
  }

  Future<void> _identifySampleUser() async {
    await widget.sdk.identify(
      'demo-user-123',
      externalUserName: 'Package Example User',
    );
    if (!mounted) return;
    setState(() => _status = 'Queued identify for demo-user-123.');
  }

  Future<void> _createSampleDynamicLink() async {
    final result = await widget.sdk.createDynamicLink(
      name: 'Package example dynamic link',
      destinationUrl: 'https://attriax.com/invite',
      group: 'package-example',
      previewTitle: 'Open the Attriax example app',
      previewDescription:
          'Example-generated dynamic link with an attached campaign payload.',
      data: const <String, Object?>{
        'source': 'flutter_package_example',
        'campaign': 'dynamic-link-demo',
      },
    );

    if (!mounted) return;
    setState(() {
      _lastCreatedDynamicLink = result.link;
      _status = 'Created dynamic link: ${result.link.shortUrl}';
    });
  }

  Future<void> _reportManualConversion() async {
    final event = await widget.sdk.recordDeepLinkConversion(
      linkPath: _manualPathController.text,
      source: 'package_example_manual',
      metadata: const <String, Object?>{'acceptedBy': 'example_button'},
    );
    if (!mounted) return;
    setState(() {
      _status = event == null
          ? 'Manual conversion sent. No immediate match.'
          : 'Manual conversion matched ${event.deepLink.path}.';
    });
  }

  void _toggleSdk(bool value) {
    setState(() => _sdkEnabled = value);
    widget.sdk.enabled = value;
    setState(() => _status = 'SDK enabled set to $value.');
  }

  void _toggleEvents(bool value) {
    setState(() => _eventsEnabled = value);
    widget.sdk.eventsEnabled = value;
    setState(() => _status = 'Custom event sending set to $value.');
  }

  void _previewNavigation(String path) {
    _openExampleDeepLink(
      AttriaxDeepLink(
        path: path,
        name: 'Preview route',
        data: <String, Object?>{'preview': true, 'path': path},
      ),
      source: 'local_preview',
    );

    setState(() {
      _status = 'Previewed app navigation for $path.';
    });
  }

  String _synchronizationLabel(AttriaxSynchronizationState state) {
    switch (state) {
      case AttriaxSynchronizationState.initializing:
        return 'Initializing';
      case AttriaxSynchronizationState.synchronizing:
        return 'Synchronizing';
      case AttriaxSynchronizationState.synchronized:
        return 'Synchronized';
      case AttriaxSynchronizationState.offline:
        return 'Offline';
      case AttriaxSynchronizationState.failed:
        return 'Failed';
      case AttriaxSynchronizationState.disabled:
        return 'Disabled';
    }
  }

  Color _synchronizationColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (widget.sdk.synchronizationState) {
      case AttriaxSynchronizationState.synchronized:
        return scheme.primaryContainer;
      case AttriaxSynchronizationState.initializing:
      case AttriaxSynchronizationState.synchronizing:
        return scheme.secondaryContainer;
      case AttriaxSynchronizationState.offline:
      case AttriaxSynchronizationState.failed:
        return scheme.errorContainer;
      case AttriaxSynchronizationState.disabled:
        return scheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final synchronizationState = widget.sdk.synchronizationState;

    return Scaffold(
      appBar: AppBar(title: const Text('Attriax Example')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Minimal Integration Example',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This is the public example shipped with the package. '
                        'It demonstrates the recommended init-in-main pattern, '
                        'SDK synchronization state, deep-link streams, and '
                        'how to navigate to real app screens when a link is matched.',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Replace the placeholder app token in AttriaxConfig '
                        'with your real Attriax app token before expecting '
                        'successful synchronization.',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('SDK Status', style: textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _synchronizationColor(context),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Synchronization: ${_synchronizationLabel(synchronizationState)}',
                          style: textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(_status),
                      const SizedBox(height: 8),
                      Text('Initialized: ${widget.sdk.isInitialized}'),
                      Text('Synchronized: ${widget.sdk.isSynchronized}'),
                      Text('SDK enabled: ${widget.sdk.enabled}'),
                      Text('Events enabled: ${widget.sdk.eventsEnabled}'),
                      Text('First launch: ${widget.sdk.isFirstLaunch}'),
                      Text('Device ID: ${widget.sdk.deviceId ?? 'pending…'}'),
                      if (_appOpenResult != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          'Attribution type: '
                          '${_appOpenResult!.attributionType.name}',
                        ),
                        Text('New user: ${_appOpenResult!.isNewUser}'),
                        if (_appOpenResult!.deepLink != null)
                          Text(
                            'Deferred deep link: '
                            '${_appOpenResult!.deepLink!.path}',
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Router Demo', style: textTheme.titleMedium),
                      const SizedBox(height: 12),
                      const Text(
                        'In real usage, the deepLinks stream decides which screen '
                        'to open. These buttons call the same navigation helper '
                        'used by the SDK listener so you can preview the flow '
                        'without waiting for a backend match.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          FilledButton.tonal(
                            onPressed: () =>
                                _previewNavigation('promo/spring-launch'),
                            child: const Text('Preview promo route'),
                          ),
                          FilledButton.tonal(
                            onPressed: () =>
                                _previewNavigation('profile/demo-user-123'),
                            child: const Text('Preview profile route'),
                          ),
                          FilledButton.tonal(
                            onPressed: () =>
                                _previewNavigation('custom/anything-else'),
                            child: const Text('Preview fallback route'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Controls', style: textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('SDK enabled'),
                        value: _sdkEnabled,
                        onChanged: _toggleSdk,
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Custom event sending enabled'),
                        value: _eventsEnabled,
                        onChanged: _toggleEvents,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: widget.sdk.isInitialized
                            ? _waitForAppOpenTracking
                            : null,
                        child: const Text('Wait for app open tracking result'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Actions', style: textTheme.titleMedium),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: widget.sdk.isInitialized
                            ? _trackSampleEvent
                            : null,
                        child: const Text('Queue purchase_completed event'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: widget.sdk.isInitialized
                            ? _identifySampleUser
                            : null,
                        child: const Text('Queue identify (demo-user-123)'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: widget.sdk.isInitialized
                            ? _createSampleDynamicLink
                            : null,
                        child: const Text('Create sample dynamic link'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _manualPathController,
                        decoration: const InputDecoration(
                          labelText: 'Manual deep link path',
                          helperText:
                              'Use when another router handles the incoming link.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: widget.sdk.isInitialized
                            ? _reportManualConversion
                            : null,
                        child: const Text('Report manual deep-link conversion'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Latest Deep Link State',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Last raw link: ${_lastRawDeepLink?.linkPath ?? _lastRawDeepLink?.uri.toString() ?? 'none'}',
                      ),
                      Text(
                        'Last conversion: ${_lastConversion?.deepLink.path ?? 'none'}',
                      ),
                      Text(
                        'Last created short URL: ${_lastCreatedDynamicLink?.shortUrl ?? 'none'}',
                      ),
                      Text('Last failure: ${_lastFailure?.reason ?? 'none'}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleDeepLinkDestinationPage extends StatelessWidget {
  const _ExampleDeepLinkDestinationPage({required this.args});

  final _ExampleDeepLinkPageArgs? args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deepLink = args?.deepLink;
    final metadata = deepLink?.data ?? const <String, Object?>{};

    return Scaffold(
      appBar: AppBar(title: Text(args?.title ?? 'Deep Link Screen')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    args?.title ?? 'Deep Link Screen',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(args?.description ?? 'No deep-link payload available.'),
                  const SizedBox(height: 16),
                  Text('Matched path: ${deepLink?.path ?? 'none'}'),
                  Text(
                    'Navigation source: ${args?.navigationSource ?? 'unknown'}',
                  ),
                  Text('Link ID: ${deepLink?.linkId ?? 'n/a'}'),
                  Text('Destination URL: ${deepLink?.destinationUrl ?? 'n/a'}'),
                  const SizedBox(height: 16),
                  Text('Metadata', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (metadata.isEmpty)
                    const Text('No metadata was attached to this deep link.')
                  else
                    for (final entry in metadata.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('${entry.key}: ${entry.value}'),
                      ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to example home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
