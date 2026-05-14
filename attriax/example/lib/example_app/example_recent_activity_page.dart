import 'package:flutter/material.dart';

import 'example_app_controller.dart';
import 'example_app_widgets.dart';

class ExampleRecentActivityPage extends StatelessWidget {
  const ExampleRecentActivityPage({super.key, required this.controller});

  static const String routeName = '/activity';

  final ExampleAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ExamplePageScaffold(
          title: 'Recent Activity',
          subtitle:
              'Every demo action adds a short breadcrumb here so the example reads like a live SDK console.',
          child: ExampleRecentActivityCard(entries: controller.recentActivity),
        );
      },
    );
  }
}
