import 'package:flutter/material.dart';

import 'example_app_controller.dart';
import 'example_app_formatters.dart';
import 'example_app_widgets.dart';

class ExamplePushTokensPage extends StatelessWidget {
  const ExamplePushTokensPage({super.key, required this.controller});

  static const String routeName = '/push-tokens';

  final ExampleAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ExamplePageScaffold(
          title: 'Token Registration',
          subtitle:
              'This page replaces the old manual token fields with live Firebase Messaging status and Attriax registration state.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExampleSectionCard(
                title: 'Current token state',
                subtitle:
                    'The example checks Firebase, reads FCM/APNs tokens when available, and sends them through the Attriax uninstall-token APIs.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'Phase',
                      value: describeExamplePushPhase(
                        controller.pushTokenSnapshot.phase,
                      ),
                    ),
                    ExampleKeyValueRow(
                      label: 'Permission',
                      value: controller.pushTokenSnapshot.permissionStatus,
                    ),
                    ExampleKeyValueRow(
                      label: 'Summary',
                      value: controller.pushTokenSnapshot.summary,
                    ),
                    ExampleKeyValueRow(
                      label: 'Listening for refresh',
                      value: controller.pushTokenSnapshot.listeningForRefresh
                          ? 'Yes'
                          : 'No',
                    ),
                    if (controller.pushTokenSnapshot.lastUpdatedAt != null)
                      ExampleKeyValueRow(
                        label: 'Last updated',
                        value: formatExampleTimestamp(
                          controller.pushTokenSnapshot.lastUpdatedAt!,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Token values',
                subtitle:
                    'The example keeps the values visible for diagnostics, but registration itself happens automatically through the Firebase bridge.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'FCM token',
                      value: controller.pushTokenSnapshot.fcmToken == null
                          ? 'Unavailable'
                          : controller.pushTokenSnapshot.fcmToken!,
                    ),
                    ExampleKeyValueRow(
                      label: 'APNs token',
                      value: controller.pushTokenSnapshot.supportsApns
                          ? (controller.pushTokenSnapshot.apnsToken == null
                                ? 'Unavailable'
                                : controller.pushTokenSnapshot.apnsToken!)
                          : 'Not applicable on this platform',
                    ),
                    if (controller.pushTokenSnapshot.errorMessage !=
                        null) ...<Widget>[
                      const SizedBox(height: 12),
                      SelectableText(
                        controller.pushTokenSnapshot.errorMessage!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Actions',
                subtitle:
                    'Use these buttons to request permission when needed and refresh the live token state without typing fake values into the app.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () => controller.refreshPushTokenStatus(
                        requestPermission: true,
                      ),
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Request permission and sync'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: controller.refreshPushTokenStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh status'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Setup guidance',
                subtitle:
                    'The example reports live state, but Firebase project setup still belongs to the host app.',
                child: Text(controller.pushTokenSnapshot.setupHint),
              ),
            ],
          ),
        );
      },
    );
  }
}
