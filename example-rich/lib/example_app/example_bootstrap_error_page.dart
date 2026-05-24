import 'package:flutter/material.dart';

import '../example_app_configuration.dart';
import 'example_app_widgets.dart';

class ExampleBootstrapErrorPage extends StatelessWidget {
  const ExampleBootstrapErrorPage({super.key, required this.errorText});

  final String errorText;

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: 'Attriax Flutter Example',
      subtitle: 'The example now expects its app token to live in code.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExampleSectionCard(
            title: 'Startup blocked',
            subtitle: errorText,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(exampleConfigurationHelpText()),
                const SizedBox(height: 12),
                SelectableText(
                  'Current token: ${maskExampleSecret(exampleAppToken)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
