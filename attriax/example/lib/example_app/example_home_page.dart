import 'package:flutter/material.dart';

import '../example_app_configuration.dart';
import 'example_app_controller.dart';
import 'example_app_formatters.dart';
import 'example_app_widgets.dart';
import 'example_controls_page.dart';
import 'example_deep_links_page.dart';
import 'example_events_page.dart';
import 'example_game_page.dart';
import 'example_push_tokens_page.dart';
import 'example_recent_activity_page.dart';

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key, required this.controller});

  final ExampleAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ExamplePageScaffold(
          title: 'Attriax Flutter Example',
          subtitle:
              'One application-wide SDK instance, awaited init() in main(), and focused pages for the major Attriax surfaces.',
          actions: <Widget>[
            FilledButton.tonalIcon(
              onPressed: controller.isRefreshing ? null : controller.refreshAll,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExampleSectionCard(
                title: 'Current SDK state',
                subtitle: controller.statusMessage,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    ExampleMetricChip(
                      label: 'Initialized',
                      value: controller.isInitialized ? 'Yes' : 'No',
                    ),
                    ExampleMetricChip(
                      label: 'Sync state',
                      value: describeExampleSynchronizationState(
                        controller.synchronizationState,
                      ),
                    ),
                    ExampleMetricChip(
                      label: 'SDK enabled',
                      value: controller.enabled ? 'Yes' : 'No',
                    ),
                    ExampleMetricChip(
                      label: 'Events enabled',
                      value: controller.eventsEnabled ? 'Yes' : 'No',
                    ),
                    ExampleMetricChip(
                      label: 'GDPR state',
                      value: controller.consentStateLabel,
                    ),
                    ExampleMetricChip(
                      label: 'Waiting for consent',
                      value: controller.isWaitingForConsent ? 'Yes' : 'No',
                    ),
                    ExampleMetricChip(
                      label: 'First launch',
                      value: controller.isFirstLaunch ? 'Yes' : 'No',
                    ),
                    ExampleMetricChip(
                      label: 'Device ID',
                      value: controller.deviceId == null
                          ? 'Unavailable'
                          : maskExampleSecret(controller.deviceId!),
                    ),
                    ExampleMetricChip(
                      label: 'App token',
                      value: maskExampleSecret(exampleAppToken),
                    ),
                    ExampleMetricChip(
                      label: 'Package version',
                      value:
                          controller.sdkSnapshot?.packageVersion ??
                          'Unavailable',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'GDPR consent',
                subtitle:
                    'The example runs with gdprEnabled enabled so you can inspect consent state before tracking starts.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'Current state',
                      value: controller.consentStateLabel,
                    ),
                    ExampleKeyValueRow(
                      label: 'Current values',
                      value: controller.consentValuesLabel,
                    ),
                    ExampleKeyValueRow(
                      label: 'Tracking blocked',
                      value: controller.isWaitingForConsent ? 'Yes' : 'No',
                    ),
                    if (controller.isWaitingForConsent) ...<Widget>[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          FilledButton.icon(
                            onPressed: () => controller.applyConsentSelection(
                              analytics: true,
                              attribution: true,
                              adEvents: false,
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Accept analytics'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => controller.applyConsentSelection(
                              analytics: false,
                              attribution: false,
                              adEvents: false,
                            ),
                            icon: const Icon(Icons.block_outlined),
                            label: const Text('Reject analytics'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => controller.refreshConsentStatus(),
                            icon: const Icon(Icons.travel_explore_outlined),
                            label: const Text('Check remote need'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(
                              context,
                            ).pushNamed(ExampleControlsPage.routeName),
                            icon: const Icon(Icons.tune),
                            label: const Text('Open Controls'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Navigate the example',
                subtitle:
                    'Each page demonstrates a focused part of the SDK instead of one large demo screen.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    ExampleNavigationTile(
                      title: 'Deep links',
                      subtitle:
                          'Inspect startup and live deep links, build a demo link, and manually record paths.',
                      icon: Icons.link,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(ExampleDeepLinksPage.routeName),
                    ),
                    ExampleNavigationTile(
                      title: 'Token registration',
                      subtitle:
                          'Shows the live FCM/APNs registration surface that replaces the old manual send/clear buttons.',
                      icon: Icons.notifications_active_outlined,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(ExamplePushTokensPage.routeName),
                    ),
                    ExampleNavigationTile(
                      title: 'Events',
                      subtitle:
                          'Send custom events, page views, ad events, purchases, refunds, and a receipt validation call.',
                      icon: Icons.insights_outlined,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(ExampleEventsPage.routeName),
                    ),
                    ExampleNavigationTile(
                      title: 'Controls',
                      subtitle:
                          'Toggle runtime flags, resolve GDPR consent, and exercise identification and user-property helpers.',
                      icon: Icons.tune,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(ExampleControlsPage.routeName),
                    ),
                    ExampleNavigationTile(
                      title: 'Mini games',
                      subtitle:
                          'Three no-dependencies Flutter games that log player names, milestones, and best scores through Attriax.',
                      icon: Icons.sports_esports_outlined,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(ExampleGamePage.routeName),
                    ),
                    ExampleNavigationTile(
                      title: 'Recent activity',
                      subtitle:
                          'Open the live breadcrumb log instead of keeping it on the home screen.',
                      icon: Icons.history,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(ExampleRecentActivityPage.routeName),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Latest attribution snapshot',
                subtitle:
                    'These values mirror what the SDK knows right now about startup attribution and deep-link activity.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'Original install referrer',
                      value: describeExampleInstallReferrer(
                        controller.originalInstallReferrer,
                      ),
                    ),
                    ExampleKeyValueRow(
                      label: 'Reinstall referrer',
                      value: describeExampleInstallReferrer(
                        controller.reinstallReferrer,
                      ),
                    ),
                    ExampleKeyValueRow(
                      label: 'Initial deep link',
                      value: controller.initialDeepLink == null
                          ? 'None yet'
                          : controller.initialDeepLink!.uri.toString(),
                    ),
                    ExampleKeyValueRow(
                      label: 'Latest deep link',
                      value: controller.latestDeepLink == null
                          ? 'None yet'
                          : controller.latestDeepLink!.uri.toString(),
                    ),
                    ExampleKeyValueRow(
                      label: 'Latest resolution',
                      value: describeExampleResolution(
                        controller.latestResolution,
                      ),
                    ),
                    ExampleKeyValueRow(
                      label: 'Token sync',
                      value: controller.pushTokenSnapshot.summary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
