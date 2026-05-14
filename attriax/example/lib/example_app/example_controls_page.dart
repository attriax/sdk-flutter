import 'package:flutter/material.dart';

import 'example_app_controller.dart';
import 'example_app_widgets.dart';

class ExampleControlsPage extends StatefulWidget {
  const ExampleControlsPage({super.key, required this.controller});

  static const String routeName = '/controls';

  final ExampleAppController controller;

  @override
  State<ExampleControlsPage> createState() => _ExampleControlsPageState();
}

class _ExampleControlsPageState extends State<ExampleControlsPage> {
  late final TextEditingController _userIdController = TextEditingController(
    text: 'user_demo_42',
  );
  late final TextEditingController _userNameController = TextEditingController(
    text: 'Taylor',
  );

  @override
  void dispose() {
    _userIdController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return ExamplePageScaffold(
          title: 'Controls',
          subtitle:
              'Move operational toggles and identification helpers away from the overview screen so the main page stays focused on state.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExampleSectionCard(
                title: 'Runtime flags',
                subtitle:
                    'These map directly to attriax.enabled and attriax.eventsEnabled.',
                child: Column(
                  children: <Widget>[
                    SwitchListTile.adaptive(
                      value: widget.controller.enabled,
                      onChanged: (value) => widget.controller.toggleSdk(value),
                      title: const Text('SDK enabled'),
                      subtitle: const Text(
                        'Disable this to stop tracking, synchronization, and deep-link handling.',
                      ),
                    ),
                    SwitchListTile.adaptive(
                      value: widget.controller.eventsEnabled,
                      onChanged: (value) =>
                          widget.controller.toggleEvents(value),
                      title: const Text('Custom events enabled'),
                      subtitle: const Text(
                        'This only affects recordEvent()/recordPageView()/revenue helpers, not the whole SDK.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Identify a user',
                subtitle:
                    'Call setUser() after sign-in and clear it when the user signs out.',
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: 'External user ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _userNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: () => widget.controller.setExampleUser(
                            _userIdController.text.trim(),
                            _userNameController.text.trim(),
                          ),
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('setUser'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: widget.controller.clearExampleUser,
                          icon: const Icon(Icons.person_off_outlined),
                          label: const Text('Clear user'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'User properties',
                subtitle:
                    'Use user properties for stable traits you want automatically attached to future events.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    ExampleActionButton(
                      label: 'setUserProperties',
                      onPressed: widget.controller.setExampleUserProperties,
                    ),
                    ExampleActionButton(
                      label: 'clearUserProperties',
                      onPressed: widget.controller.clearExampleUserProperties,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Crash testing',
                subtitle:
                    'Use this when you need a real native fatal for QA or crash-reporting verification. The example host currently wires this on Android.',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    key: const ValueKey<String>('native_crash_button'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final triggered = await widget.controller
                          .triggerNativeCrashTest();
                      if (!mounted || triggered) {
                        return;
                      }

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Native crash testing is only available on the Android example host right now.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('Trigger native crash'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
