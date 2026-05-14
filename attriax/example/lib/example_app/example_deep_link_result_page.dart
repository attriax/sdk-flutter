import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

import 'example_app_formatters.dart';
import 'example_app_widgets.dart';

class ExampleDeepLinkResultPage extends StatefulWidget {
  const ExampleDeepLinkResultPage({super.key, required this.event});

  static const String routeName = '/deeplinks/result';

  final AttriaxDeepLinkEvent event;

  @override
  State<ExampleDeepLinkResultPage> createState() =>
      _ExampleDeepLinkResultPageState();
}

class _ExampleDeepLinkResultPageState extends State<ExampleDeepLinkResultPage> {
  late final Future<AttriaxDeepLinkResolution> _resolutionFuture = widget.event
      .resolve();

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: 'Deep Link Result',
      subtitle:
          'This is the route the example opens when a deep link reaches the app. The event arrives first, then the resolution settles.',
      child: FutureBuilder<AttriaxDeepLinkResolution>(
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
                    : widget.event.uri.toString(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'Trigger',
                      value: widget.event.trigger.name,
                    ),
                    ExampleKeyValueRow(
                      label: 'Received at',
                      value: formatExampleTimestamp(widget.event.receivedAt),
                    ),
                    ExampleKeyValueRow(
                      label: 'Attriax host',
                      value: widget.event.isAttriaxDomain ? 'Yes' : 'No',
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
                      'Use event.resolve() when you need the backend-verified deep-link result.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
