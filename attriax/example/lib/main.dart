import 'dart:async';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

import 'example_app_configuration.dart';
import 'example_attriax_sdk.dart';

const String exampleDefaultAppToken = 'ax_your_app_token';

const String exampleAppToken = String.fromEnvironment(
  'ATTRIAX_APP_TOKEN',
  defaultValue: exampleDefaultAppToken,
);

bool isExampleAppConfigured({required String appToken}) =>
    !appToken.startsWith('ax_your_');

void ensureExampleAppConfigured({required String appToken}) {
  if (!isExampleAppConfigured(appToken: appToken)) {
    throw StateError(
      'Replace the example Attriax app token before running this app.',
    );
  }
}

Attriax _createExampleAttriax(ExampleAppConfiguration configuration) {
  ensureExampleAppConfigured(appToken: configuration.appToken);
  final apiBaseUrl = configuration.normalizedApiBaseUrl;

  return Attriax(
    config: apiBaseUrl == null
        ? AttriaxConfig(
            appToken: configuration.appToken,
            sdkMetadata: const <String, Object?>{
              'surface': 'package_example',
              'purpose': 'docs_and_demo',
            },
          )
        : AttriaxConfig(
            appToken: configuration.appToken,
            apiBaseUrl: apiBaseUrl,
            sdkMetadata: const <String, Object?>{
              'surface': 'package_example',
              'purpose': 'docs_and_demo',
            },
          ),
  );
}

LiveExampleAttriaxSdk _createExampleSdk(
  ExampleAppConfiguration configuration,
) => LiveExampleAttriaxSdk(_createExampleAttriax(configuration));

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

String _maskExampleAppToken(String appToken) {
  if (appToken.length <= 8) {
    return appToken;
  }

  return '${appToken.substring(0, 4)}...${appToken.substring(appToken.length - 4)}';
}

Route<void> _onGenerateExampleRoute(
  RouteSettings settings, {
  required ExampleAttriaxSdk sdk,
  ExampleAppConfiguration? configuration,
  Future<void> Function()? onResetConfiguration,
}) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute<void>(
        builder: (_) => ExampleHomePage(
          sdk: sdk,
          configuration: configuration,
          onResetConfiguration: onResetConfiguration,
        ),
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
        builder: (_) => ExampleHomePage(
          sdk: sdk,
          configuration: configuration,
          onResetConfiguration: onResetConfiguration,
        ),
        settings: settings,
      );
  }
}

// ── Entry point ───────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configurationStore = ExampleAppConfigurationStore();
  final storedConfiguration = await configurationStore.load();
  final initialConfiguration =
      storedConfiguration ??
      (isExampleAppConfigured(appToken: exampleAppToken)
          ? ExampleAppConfiguration(appToken: exampleAppToken)
          : null);

  ExampleAttriaxSdk? initialSdk;
  String? initialBootstrapError;
  if (initialConfiguration != null) {
    try {
      initialSdk = _createExampleSdk(initialConfiguration);
      // Recommended: await initialization during startup so the SDK has
      // restored persisted state, collected context, and started listeners
      // before the UI. If your app must remain non-blocking, you can
      // intentionally choose unawaited(attriax.init()) instead.
      await initialSdk.init();
    } catch (error) {
      initialBootstrapError =
          'Saved configuration failed to initialize: ${_formatSetupError(error)}';
      await initialSdk?.dispose();
      initialSdk = null;
    }
  }

  runApp(
    AttriaxPackageExampleApp(
      sdk: initialSdk,
      ownsProvidedSdk: initialSdk != null,
      initialConfiguration: initialConfiguration,
      configurationStore: configurationStore,
      initialBootstrapError: initialBootstrapError,
    ),
  );
}

// ── App widget ────────────────────────────────────────────────────────────────

class AttriaxPackageExampleApp extends StatefulWidget {
  const AttriaxPackageExampleApp({
    super.key,
    this.sdk,
    this.ownsProvidedSdk = false,
    this.initialConfiguration,
    this.configurationStore,
    this.initialBootstrapError,
  });

  final ExampleAttriaxSdk? sdk;
  final bool ownsProvidedSdk;
  final ExampleAppConfiguration? initialConfiguration;
  final ExampleAppConfigurationStore? configurationStore;
  final String? initialBootstrapError;

  @override
  State<AttriaxPackageExampleApp> createState() =>
      _AttriaxPackageExampleAppState();
}

class _AttriaxPackageExampleAppState extends State<AttriaxPackageExampleApp> {
  ExampleAttriaxSdk? _sdk;
  bool _ownsSdk = false;
  bool _isInitializing = false;
  String? _bootstrapError;
  ExampleAppConfiguration? _configuration;

  ExampleAppConfigurationStore get _configurationStore =>
      widget.configurationStore ?? ExampleAppConfigurationStore();

  @override
  void initState() {
    super.initState();
    _sdk = widget.sdk;
    _ownsSdk = widget.ownsProvidedSdk;
    _bootstrapError = widget.initialBootstrapError;
    _configuration = widget.initialConfiguration;
  }

  @override
  void dispose() {
    if (_ownsSdk) {
      unawaited(_sdk?.dispose() ?? Future<void>.value());
    }
    super.dispose();
  }

  Future<void> _applyConfiguration(
    ExampleAppConfiguration configuration,
  ) async {
    setState(() {
      _isInitializing = true;
      _bootstrapError = null;
    });

    LiveExampleAttriaxSdk? nextSdk;
    try {
      nextSdk = _createExampleSdk(configuration);
      await nextSdk.init();
      await _configurationStore.save(configuration);

      final previousSdk = _ownsSdk ? _sdk : null;
      if (!mounted) {
        await nextSdk.dispose();
        return;
      }

      setState(() {
        _sdk = nextSdk;
        _ownsSdk = true;
        _configuration = configuration;
        _isInitializing = false;
      });

      await previousSdk?.dispose();
    } catch (error) {
      await nextSdk?.dispose();
      if (!mounted) {
        return;
      }

      setState(() {
        _bootstrapError = 'Initialization failed: ${_formatSetupError(error)}';
        _isInitializing = false;
      });
    }
  }

  Future<void> _resetConfiguration() async {
    final previousSdk = _ownsSdk ? _sdk : null;
    _exampleNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    await _configurationStore.clear();
    if (!mounted) {
      await previousSdk?.dispose();
      return;
    }

    setState(() {
      _sdk = null;
      _ownsSdk = false;
      _configuration = null;
      _bootstrapError = null;
      _isInitializing = false;
    });

    await previousSdk?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sdk = _sdk;

    if (sdk == null) {
      return MaterialApp(
        title: 'Attriax Example',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF0F766E),
          useMaterial3: true,
        ),
        home: ExampleSetupPage(
          initialConfiguration: _configuration,
          isInitializing: _isInitializing,
          bootstrapError: _bootstrapError,
          onApplyConfiguration: _applyConfiguration,
        ),
      );
    }

    return MaterialApp(
      title: 'Attriax Example',
      navigatorKey: _exampleNavigatorKey,
      navigatorObservers: sdk.buildNavigatorObservers(),
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0F766E),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) => _onGenerateExampleRoute(
        settings,
        sdk: sdk,
        configuration: _configuration,
        onResetConfiguration: _ownsSdk ? _resetConfiguration : null,
      ),
      initialRoute: '/',
    );
  }
}

class ExampleSetupPage extends StatefulWidget {
  const ExampleSetupPage({
    super.key,
    required this.onApplyConfiguration,
    this.initialConfiguration,
    this.isInitializing = false,
    this.bootstrapError,
  });

  final Future<void> Function(ExampleAppConfiguration configuration)
  onApplyConfiguration;
  final ExampleAppConfiguration? initialConfiguration;
  final bool isInitializing;
  final String? bootstrapError;

  @override
  State<ExampleSetupPage> createState() => _ExampleSetupPageState();
}

class _ExampleSetupPageState extends State<ExampleSetupPage> {
  late final TextEditingController _appTokenController = TextEditingController(
    text: widget.initialConfiguration?.appToken ?? exampleAppToken,
  );
  late final TextEditingController _apiBaseUrlController =
      TextEditingController(
        text: widget.initialConfiguration?.displayApiBaseUrl ?? '',
      );
  String? _validationError;

  @override
  void dispose() {
    _appTokenController.dispose();
    _apiBaseUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final appToken = _appTokenController.text.trim();

    try {
      ensureExampleAppConfigured(appToken: appToken);

      final configuration = ExampleAppConfiguration(
        appToken: appToken,
        apiBaseUrl: normalizeExampleApiBaseUrl(_apiBaseUrlController.text),
      );

      setState(() {
        _validationError = null;
      });
      await widget.onApplyConfiguration(configuration);
    } catch (error) {
      setState(() {
        _validationError = _formatSetupError(error);
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = _validationError ?? widget.bootstrapError;

    return Scaffold(
      appBar: AppBar(title: const Text('Attriax Example Setup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Configure the public example',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This example no longer requires dart-defines or source edits. '
                    'Enter a real Attriax app token on first launch and the app '
                    'will store it locally on this device for later runs.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _appTokenController,
                    enabled: !widget.isInitializing,
                    decoration: const InputDecoration(
                      labelText: 'Attriax app token',
                      helperText:
                          'Required. Replace the placeholder token before initializing.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiBaseUrlController,
                    enabled: !widget.isInitializing,
                    decoration: const InputDecoration(
                      labelText: 'API base URL',
                      helperText:
                          'Optional. Leave blank to use the production default.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorText != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      errorText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: widget.isInitializing ? null : _submit,
                    child: Text(
                      widget.isInitializing
                          ? 'Initializing SDK...'
                          : 'Save configuration and initialize',
                    ),
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

String _formatSetupError(Object error) {
  if (error is ArgumentError) {
    return error.message?.toString() ?? error.toString();
  }

  final description = error.toString();
  const badStatePrefix = 'Bad state: ';
  if (description.startsWith(badStatePrefix)) {
    return description.substring(badStatePrefix.length);
  }

  return description;
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({
    super.key,
    required this.sdk,
    this.configuration,
    this.onResetConfiguration,
  });

  final ExampleAttriaxSdk sdk;
  final ExampleAppConfiguration? configuration;
  final Future<void> Function()? onResetConfiguration;

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
  AttriaxInstallReferrerDetails? _startupInstallReferrer;
  AttriaxDeepLinkResult? _startupInitialDeepLink;
  AttriaxDynamicLinkRecord? _lastCreatedDynamicLink;
  AttriaxRawDeepLinkEvent? _lastRawDeepLink;
  AttriaxDeepLinkResolution? _lastResolution;
  AttriaxDeepLinkResolutionFailure? _lastFailure;

  @override
  void initState() {
    super.initState();

    _deepLinkSubscription = widget.sdk.deepLinks.stream.listen(
      _handleDeepLinkEvent,
    );
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
          ? 'Initialized. Startup attribution is available via installReferrer and deepLinks.'
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
      final result = await event.resolve();
      if (!mounted) {
        return;
      }

      final resolution = result.resolution;
      if (resolution != null) {
        setState(() {
          _lastResolution = resolution;
          _lastFailure = null;
          _status = 'Matched deep link: ${resolution.deepLink.path}';
        });

        _openExampleDeepLink(
          resolution.deepLink,
          source: resolution.isDeferred
              ? 'deferred_app_open'
              : 'matched_conversion',
        );
        return;
      }

      final failure = result.failure;
      if (failure != null) {
        setState(() {
          _lastFailure = failure;
          _status = 'Deep link resolution failed: ${failure.reason}';
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

  Future<void> _loadStartupAttribution() async {
    setState(() => _status = 'Loading startup attribution...');
    try {
      final initialDeepLink = await widget.sdk.deepLinks
          .waitForInitialDeepLink();
      final installReferrer = await widget.sdk.installReferrer;
      if (!mounted) return;
      setState(() {
        _startupInstallReferrer = installReferrer;
        _startupInitialDeepLink = initialDeepLink;
        _lastRawDeepLink = initialDeepLink?.rawEvent ?? _lastRawDeepLink;
        _lastResolution = initialDeepLink?.resolution ?? _lastResolution;
        _lastFailure = initialDeepLink?.failure;
        _status = installReferrer == null && initialDeepLink == null
            ? 'Startup attribution loaded. No install referrer or initial deep link found.'
            : 'Startup attribution loaded.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Startup attribution failed: $error');
    }
  }

  Future<void> _recordSampleEvent() async {
    await widget.sdk.recordEvent(
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

  Future<void> _setSampleUser() async {
    await widget.sdk.setUser('demo-user-123', userName: 'Package Example User');
    if (!mounted) return;
    setState(() => _status = 'Queued setUser for demo-user-123.');
  }

  Future<void> _createSampleDynamicLink() async {
    final result = await widget.sdk.createDynamicLink(
      name: 'Package example dynamic link',
      destinationUrl: 'https://attriax.com/invite',
      group: 'package-example',
      socialPreview: const AttriaxDynamicLinkSocialPreview(
        title: 'Open the Attriax example app',
        description:
            'Example-generated dynamic link with an attached campaign payload.',
      ),
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

  Future<void> _recordManualDeepLink() async {
    final event = await widget.sdk.recordDeepLink(
      linkPath: _manualPathController.text,
      source: 'package_example_manual',
      metadata: const <String, Object?>{'acceptedBy': 'example_button'},
    );
    if (!mounted) return;
    setState(() {
      _lastRawDeepLink = event?.rawEvent ?? _lastRawDeepLink;
      _lastResolution = event ?? _lastResolution;
      if (event != null) {
        _lastFailure = null;
      }
      _status = event == null
          ? 'Manual deep-link resolution sent. No immediate match.'
          : 'Manual deep-link resolution matched ${event.deepLink.path}.';
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
      case AttriaxSynchronizationState.deferred:
        return 'Deferred';
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
      case AttriaxSynchronizationState.deferred:
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
    final configuration = widget.configuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attriax Example'),
        actions: <Widget>[
          if (widget.onResetConfiguration != null)
            IconButton(
              onPressed: widget.onResetConfiguration,
              tooltip: 'Reset saved example configuration',
              icon: const Icon(Icons.tune),
            ),
        ],
      ),
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
                        'It demonstrates the recommended awaited init flow, '
                        'SDK synchronization state, deep-link streams, and '
                        'how to navigate to real app screens when a link is matched.',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use the setup screen to save a real app token on '
                        'first launch. The example stores it locally so you '
                        'do not need dart-defines or source edits for each run.',
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
                      Text(
                        'Configured app token: ${configuration == null ? 'test or injected SDK' : _maskExampleAppToken(configuration.appToken)}',
                      ),
                      Text(
                        'API base URL: ${configuration?.displayApiBaseUrl ?? 'production default'}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Install referrer campaign: ${_startupInstallReferrer?.campaign ?? 'none'}',
                      ),
                      Text(
                        'Initial deep link: ${_startupInitialDeepLink?.resolution?.deepLink.path ?? _startupInitialDeepLink?.rawEvent?.linkPath ?? _startupInitialDeepLink?.rawEvent?.uri.toString() ?? 'none'}',
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
                            ? _loadStartupAttribution
                            : null,
                        child: const Text('Load startup attribution result'),
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
                            ? _recordSampleEvent
                            : null,
                        child: const Text('Queue purchase_completed event'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: widget.sdk.isInitialized
                            ? _setSampleUser
                            : null,
                        child: const Text('Queue setUser (demo-user-123)'),
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
                            ? _recordManualDeepLink
                            : null,
                        child: const Text('Report manual deep link'),
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
                        'Last resolution: ${_lastResolution?.deepLink.path ?? 'none'}',
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
