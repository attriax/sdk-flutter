import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

import 'example_app_formatters.dart';
import 'example_app_widgets.dart';

class ExampleDeepLinkResultPage extends StatefulWidget {
  const ExampleDeepLinkResultPage({
    super.key,
    required this.sdk,
    required this.rawEvent,
  });

  static const String routeName = '/deeplinks/result';

  final Attriax sdk;
  final AttriaxRawDeepLinkEvent rawEvent;

  @override
  State<ExampleDeepLinkResultPage> createState() =>
      _ExampleDeepLinkResultPageState();
}

class _ExampleDeepLinkResultPageState extends State<ExampleDeepLinkResultPage> {
  late final Future<AttriaxDeepLinkEvent> _resolutionFuture = widget
      .sdk
      .deepLinks
      .waitResolution(widget.rawEvent);

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: 'Deep Link Result',
      subtitle:
          'This route opens from the raw deep-link stream first, then waits for the resolved deep-link event.',
      child: FutureBuilder<AttriaxDeepLinkEvent>(
        future: _resolutionFuture,
        builder: (context, snapshot) {
          final resolution = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExampleSectionCard(
                title: snapshot.connectionState == ConnectionState.done
                    ? (resolution?.found == true
                          ? 'Deep link matched successfully'
                          : 'Deep link reached the app')
                    : 'Resolving deep link...',
                subtitle: snapshot.hasError
                    ? formatExampleError(snapshot.error!)
                    : widget.rawEvent.uri.toString(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'Raw URI',
                      value: widget.rawEvent.uri.toString(),
                    ),
                    ExampleKeyValueRow(
                      label: 'Received at',
                      value: formatExampleTimestamp(widget.rawEvent.receivedAt),
                    ),
                    ExampleKeyValueRow(
                      label: 'Initial link',
                      value: widget.rawEvent.isInitial ? 'Yes' : 'No',
                    ),
                    if (snapshot.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
              if (resolution != null) ...<Widget>[
                const SizedBox(height: 16),
                ExampleSectionCard(
                  title: 'Resolution data',
                  subtitle:
                      'Use deepLinks.waitResolution(rawEvent) when you need the backend-verified deep-link result.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ExampleKeyValueRow(
                        label: 'Trigger',
                        value: resolution.trigger.name,
                      ),
                      ExampleKeyValueRow(
                        label: 'Attriax subdomain',
                        value: resolution.isAttriaxSubDomain ? 'Yes' : 'No',
                      ),
                      ExampleKeyValueRow(
                        label: 'Found',
                        value: resolution.found ? 'Yes' : 'No',
                      ),
                      ExampleKeyValueRow(
                        label: 'Canonical URI',
                        value: resolution.uri.toString(),
                      ),
                      ExampleKeyValueRow(
                        label: 'Clicked at',
                        value: formatExampleTimestamp(resolution.clickedAt),
                      ),
                      ExampleKeyValueRow(
                        label: 'Consumed at',
                        value: formatExampleTimestamp(resolution.consumedAt),
                      ),
                      const SizedBox(height: 12),
                      ExampleJsonCard(
                        title: 'Payload',
                        value: <String, Object?>{
                          'data': resolution.data,
                          'utm': resolution.utm?.toJson(),
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
