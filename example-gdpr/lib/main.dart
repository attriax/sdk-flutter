import 'dart:async';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

const String _defaultProjectToken = String.fromEnvironment(
  'ATTRIAX_PROJECT_TOKEN',
  defaultValue: 'ax_4961d1f22e274281919b1b021ec2eb48',
);
const String _defaultApiBaseUrl = String.fromEnvironment(
  'ATTRIAX_API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);
const String _dockerApiBaseUrl = 'http://localhost:33000';
const String _defaultUserId = 'gdpr-demo-user';
const String _defaultUserName = 'GDPR Demo User';
const String _defaultEventName = 'gdpr_example_event';
const String _defaultPageName = '/gdpr-example';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleGdprApp());
}

class ExampleGdprApp extends StatelessWidget {
  const ExampleGdprApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attriax GDPR Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        useMaterial3: true,
      ),
      home: const ExampleGdprHomePage(),
    );
  }
}

class ExampleGdprHomePage extends StatefulWidget {
  const ExampleGdprHomePage({super.key});

  @override
  State<ExampleGdprHomePage> createState() => _ExampleGdprHomePageState();
}

class _ExampleGdprHomePageState extends State<ExampleGdprHomePage> {
  late final TextEditingController _projectTokenController =
      TextEditingController(text: _defaultProjectToken);
  late final TextEditingController _apiBaseUrlController =
      TextEditingController(text: _defaultApiBaseUrl);
  late final TextEditingController _eventNameController = TextEditingController(
    text: _defaultEventName,
  );
  late final TextEditingController _pageNameController = TextEditingController(
    text: _defaultPageName,
  );
  late final TextEditingController _userIdController = TextEditingController(
    text: _defaultUserId,
  );
  late final TextEditingController _userNameController = TextEditingController(
    text: _defaultUserName,
  );

  Attriax? _sdk;
  bool _busy = false;
  bool _sdkEnabled = true;
  bool _trackingEnabled = true;
  bool _anonymousTrackingEnabled = true;
  bool _analyticsConsent = true;
  bool _attributionConsent = true;
  bool _adEventsConsent = true;
  bool? _lastLocalNeedsConsent;
  bool? _lastRemoteNeedsConsent;
  String? _lastError;
  String _lastResult = 'Idle. Set the config you want, then press Init SDK.';

  bool get _hasInitializedSdk => _sdk?.isInitialized ?? false;

  @override
  void dispose() {
    _projectTokenController.dispose();
    _apiBaseUrlController.dispose();
    _eventNameController.dispose();
    _pageNameController.dispose();
    _userIdController.dispose();
    _userNameController.dispose();
    final sdk = _sdk;
    if (sdk != null) {
      unawaited(sdk.dispose());
    }
    super.dispose();
  }

  Future<void> _runAction(Future<String> Function() action) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _lastError = null;
    });

    try {
      final message = await action();
      if (!mounted) {
        return;
      }

      setState(() {
        _lastResult = message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _lastError = '$error';
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
      });
    }
  }

  Attriax _requireInitializedSdk() {
    final sdk = _sdk;
    if (sdk == null || !sdk.isInitialized) {
      throw StateError('Initialize the SDK first.');
    }

    return sdk;
  }

  AttriaxConfig _buildConfig() {
    final projectToken = _projectTokenController.text.trim();
    final apiBaseUrl = _apiBaseUrlController.text.trim();
    if (projectToken.isEmpty) {
      throw StateError('Project token is required.');
    }
    if (apiBaseUrl.isEmpty) {
      throw StateError('API base URL is required.');
    }

    return AttriaxConfig(
      projectToken: projectToken,
      apiBaseUrl: apiBaseUrl,
      enableDebugLogs: true,
      gdprEnabled: true,
      anonymousTracking: _anonymousTrackingEnabled,
      sdkMetadata: const <String, Object?>{
        'surface': 'example_gdpr',
        'purpose': 'manual_gdpr_testing',
      },
    );
  }

  Future<void> _initSdk() async {
    await _runAction(() async {
      final previousSdk = _sdk;
      if (mounted) {
        setState(() {
          _sdk = null;
          _lastLocalNeedsConsent = null;
          _lastRemoteNeedsConsent = null;
        });
      }

      await previousSdk?.dispose();

      final nextSdk = Attriax(config: _buildConfig());
      nextSdk.enabled = _sdkEnabled;
      nextSdk.tracking.enabled = _trackingEnabled;
      nextSdk.tracking.anonymousTrackingEnabled = _anonymousTrackingEnabled;
      await nextSdk.init();

      final currentState = _formatConsentState(nextSdk.consent.gdpr.state);
      final message =
          'SDK initialized against ${_apiBaseUrlController.text.trim()}. Current GDPR state: $currentState.';

      if (!mounted) {
        await nextSdk.dispose();
        return message;
      }

      setState(() {
        _sdk = nextSdk;
      });

      return message;
    });
  }

  Future<void> _disposeSdk() async {
    final sdk = _sdk;
    if (sdk == null) {
      return;
    }

    await _runAction(() async {
      if (mounted) {
        setState(() {
          _sdk = null;
          _lastLocalNeedsConsent = null;
          _lastRemoteNeedsConsent = null;
        });
      }

      await sdk.dispose();
      return 'SDK disposed. Press Init SDK to create a fresh instance.';
    });
  }

  Future<void> _applyRuntimeToggles() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      sdk.enabled = _sdkEnabled;
      sdk.tracking.enabled = _trackingEnabled;
      sdk.tracking.anonymousTrackingEnabled = _anonymousTrackingEnabled;
      return 'Runtime toggles updated.';
    });
  }

  Future<void> _checkNeedsConsent({required bool localOnly}) async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      final needsConsent = await sdk.consent.gdpr.needsConsent(
        localOnly: localOnly,
      );

      if (mounted) {
        setState(() {
          if (localOnly) {
            _lastLocalNeedsConsent = needsConsent;
          } else {
            _lastRemoteNeedsConsent = needsConsent;
          }
        });
      }

      return localOnly
          ? 'Local consent check returned $needsConsent.'
          : 'Remote consent check returned $needsConsent.';
    });
  }

  Future<void> _applyConsentValues() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      sdk.consent.gdpr.setConsent(
        analytics: _analyticsConsent,
        attribution: _attributionConsent,
        adEvents: _adEventsConsent,
      );
      return 'Applied consent values: ${_formatConsentValues(sdk.consent.gdpr.values)}.';
    });
  }

  Future<void> _grantAllConsent() async {
    if (mounted) {
      setState(() {
        _analyticsConsent = true;
        _attributionConsent = true;
        _adEventsConsent = true;
      });
    }
    await _applyConsentValues();
  }

  Future<void> _denyAllConsent() async {
    if (mounted) {
      setState(() {
        _analyticsConsent = false;
        _attributionConsent = false;
        _adEventsConsent = false;
      });
    }
    await _applyConsentValues();
  }

  Future<void> _setConsentNotRequired() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      sdk.consent.gdpr.setNotRequired();
      return 'Marked GDPR consent as not required for this install.';
    });
  }

  Future<void> _resetConsent() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      sdk.consent.gdpr.reset();
      return 'Local GDPR consent state cleared.';
    });
  }

  Future<void> _requestDataErasure() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      await sdk.consent.gdpr.requestDataErasure();
      return 'Remote GDPR data erasure completed. The SDK instance is now back in a pre-init state.';
    });
  }

  Future<void> _recordEvent() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      final eventName = _eventNameController.text.trim();
      if (eventName.isEmpty) {
        throw StateError('Event name is required.');
      }

      sdk.tracking.recordEvent(
        eventName,
        eventData: const <String, Object?>{'surface': 'example_gdpr'},
        flushImmediately: true,
      );
      return 'Recorded event "$eventName".';
    });
  }

  Future<void> _recordPageView() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      final pageName = _pageNameController.text.trim();
      if (pageName.isEmpty) {
        throw StateError('Page name is required.');
      }

      sdk.tracking.recordPageView(
        pageName,
        pageClass: 'ExampleGdprPage',
        source: 'manual_example_gdpr',
        flushImmediately: true,
      );
      return 'Recorded page view for "$pageName".';
    });
  }

  Future<void> _setDemoUser() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      final userId = _userIdController.text.trim();
      final userName = _userNameController.text.trim();
      if (userId.isEmpty) {
        throw StateError('User ID is required.');
      }

      sdk.tracking.setUser(
        userId,
        userName: userName.isEmpty ? null : userName,
      );
      return 'Associated the demo user "$userId".';
    });
  }

  Future<void> _clearUser() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      sdk.tracking.setUser(null);
      return 'Cleared the current demo user.';
    });
  }

  Future<void> _resetSdk() async {
    await _runAction(() async {
      final sdk = _requireInitializedSdk();
      await sdk.reset();
      return 'SDK storage cleared. Press Init SDK to start again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final consent = _sdk?.consent.gdpr;

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Attriax GDPR Example')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manual GDPR controls for local Attriax API testing',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'This example does not initialize on startup. Press Init SDK when you want to start. Local and remote GDPR checks stay manual so you can control exactly when consent detection runs. Unknown and pending GDPR states still send anonymous-capable session and analytics traffic immediately.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Configuration',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _projectTokenController,
                        decoration: const InputDecoration(
                          labelText: 'Project token',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_busy,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apiBaseUrlController,
                        decoration: const InputDecoration(
                          labelText: 'API base URL',
                          helperText:
                              'Use http://localhost:3000 for a locally started API, or http://localhost:33000 for the Docker-exposed host port.',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_busy,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () {
                                    _apiBaseUrlController.text =
                                        _defaultApiBaseUrl;
                                  },
                            child: const Text('Use localhost:3000'),
                          ),
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () {
                                    _apiBaseUrlController.text =
                                        _dockerApiBaseUrl;
                                  },
                            child: const Text('Use localhost:33000'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('SDK enabled after init'),
                        value: _sdkEnabled,
                        onChanged: _busy
                            ? null
                            : (bool value) {
                                setState(() {
                                  _sdkEnabled = value;
                                });
                              },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tracking enabled after init'),
                        value: _trackingEnabled,
                        onChanged: _busy
                            ? null
                            : (bool value) {
                                setState(() {
                                  _trackingEnabled = value;
                                });
                              },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Anonymous tracking enabled'),
                        subtitle: const Text(
                          'When on, anonymous-capable GDPR traffic can be sent without device identity before consent resolves.',
                        ),
                        value: _anonymousTrackingEnabled,
                        onChanged: _busy
                            ? null
                            : (bool value) {
                                setState(() {
                                  _anonymousTrackingEnabled = value;
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            onPressed: _busy ? null : _initSdk,
                            child: const Text('Init SDK'),
                          ),
                          OutlinedButton(
                            onPressed: _busy || _sdk == null
                                ? null
                                : _disposeSdk,
                            child: const Text('Dispose SDK'),
                          ),
                          OutlinedButton(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _applyRuntimeToggles,
                            child: const Text('Apply runtime toggles'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Status',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatusTile(
                        label: 'SDK instance',
                        value: _sdk == null ? 'not created' : 'created',
                      ),
                      _StatusTile(
                        label: 'Initialized',
                        value: _formatBool(_hasInitializedSdk),
                      ),
                      _StatusTile(
                        label: 'SDK enabled',
                        value: _formatBool(_sdk?.enabled),
                      ),
                      _StatusTile(
                        label: 'Tracking enabled',
                        value: _formatBool(_sdk?.tracking.enabled),
                      ),
                      _StatusTile(
                        label: 'Anonymous tracking',
                        value: _formatBool(
                          _sdk?.tracking.anonymousTrackingEnabled ??
                              _anonymousTrackingEnabled,
                        ),
                      ),
                      _StatusTile(
                        label: 'Consent state',
                        value: _formatConsentState(consent?.state),
                      ),
                      _StatusTile(
                        label: 'Waiting for consent',
                        value: _formatBool(consent?.isWaitingForConsent),
                      ),
                      _StatusTile(
                        label: 'Consent values',
                        value: _formatConsentValues(consent?.values),
                        wide: true,
                      ),
                      _StatusTile(
                        label: 'Device ID',
                        value: _sdk?.deviceId ?? 'not available',
                        wide: true,
                      ),
                      _StatusTile(
                        label: 'Last local check',
                        value: _formatNullableCheck(_lastLocalNeedsConsent),
                      ),
                      _StatusTile(
                        label: 'Last remote check',
                        value: _formatNullableCheck(_lastRemoteNeedsConsent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Consent Checks',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: _busy || !_hasInitializedSdk
                            ? null
                            : () {
                                unawaited(_checkNeedsConsent(localOnly: true));
                              },
                        child: const Text('Check local consent'),
                      ),
                      FilledButton.tonal(
                        onPressed: _busy || !_hasInitializedSdk
                            ? null
                            : () {
                                unawaited(_checkNeedsConsent(localOnly: false));
                              },
                        child: const Text('Check remote consent'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Consent Actions',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Analytics consent'),
                        value: _analyticsConsent,
                        onChanged: _busy
                            ? null
                            : (bool? value) {
                                setState(() {
                                  _analyticsConsent = value ?? false;
                                });
                              },
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Attribution consent'),
                        value: _attributionConsent,
                        onChanged: _busy
                            ? null
                            : (bool? value) {
                                setState(() {
                                  _attributionConsent = value ?? false;
                                });
                              },
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Ad events consent'),
                        value: _adEventsConsent,
                        onChanged: _busy
                            ? null
                            : (bool? value) {
                                setState(() {
                                  _adEventsConsent = value ?? false;
                                });
                              },
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _applyConsentValues,
                            child: const Text('Apply consent'),
                          ),
                          FilledButton.tonal(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _grantAllConsent,
                            child: const Text('Grant all'),
                          ),
                          FilledButton.tonal(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _denyAllConsent,
                            child: const Text('Deny all'),
                          ),
                          OutlinedButton(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _setConsentNotRequired,
                            child: const Text('Set not required'),
                          ),
                          OutlinedButton(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _resetConsent,
                            child: const Text('Reset consent'),
                          ),
                          OutlinedButton(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _requestDataErasure,
                            child: const Text('Request data erasure'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Traffic And Identity',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _eventNameController,
                        decoration: const InputDecoration(
                          labelText: 'Event name',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_busy,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pageNameController,
                        decoration: const InputDecoration(
                          labelText: 'Page name',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_busy,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _recordEvent,
                            child: const Text('Record demo event'),
                          ),
                          FilledButton.tonal(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _recordPageView,
                            child: const Text('Record page view'),
                          ),
                          OutlinedButton(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _resetSdk,
                            child: const Text('Reset SDK'),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      TextField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          labelText: 'Demo user ID',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_busy,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _userNameController,
                        decoration: const InputDecoration(
                          labelText: 'Demo user name',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_busy,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _setDemoUser,
                            child: const Text('Set demo user'),
                          ),
                          OutlinedButton(
                            onPressed: _busy || !_hasInitializedSdk
                                ? null
                                : _clearUser,
                            child: const Text('Clear user'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Latest Result',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_lastResult),
                      if (_lastError != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          _lastError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.value,
    this.wide = false,
  });

  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: wide ? 280 : 140),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatBool(bool? value) {
  if (value == null) {
    return 'unknown';
  }

  return value ? 'yes' : 'no';
}

String _formatNullableCheck(bool? value) {
  if (value == null) {
    return 'not checked';
  }

  return value ? 'required' : 'not required';
}

String _formatConsentState(AttriaxGdprConsentState? state) {
  switch (state) {
    case AttriaxGdprConsentState.unknown:
      return 'unknown';
    case AttriaxGdprConsentState.notRequired:
      return 'not required';
    case AttriaxGdprConsentState.pending:
      return 'pending';
    case AttriaxGdprConsentState.granted:
      return 'granted';
    case null:
      return 'not available';
  }
}

String _formatConsentValues(AttriaxGdprConsentValues? values) {
  if (values == null) {
    return 'not set';
  }

  return 'analytics=${values.analytics}, attribution=${values.attribution}, adEvents=${values.adEvents}';
}
