import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

import '../example_app_configuration.dart';
import 'example_app_controller.dart';
import 'example_app_formatters.dart';
import 'example_app_widgets.dart';

class ExampleDeepLinksPage extends StatefulWidget {
  const ExampleDeepLinksPage({super.key, required this.controller});

  static const String routeName = '/deeplinks';

  final ExampleAppController controller;

  @override
  State<ExampleDeepLinksPage> createState() => _ExampleDeepLinksPageState();
}

class _ExampleDeepLinksPageState extends State<ExampleDeepLinksPage> {
  late final TextEditingController _manualController = TextEditingController(
    text: buildExampleFallbackDeepLink().toString(),
  );
  late final TextEditingController _prefixController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final currentLink = widget.controller.currentDeepLink;

        return ExamplePageScaffold(
          title: 'Deep Links',
          subtitle:
              'Track startup state, inspect the latest incoming link, and build a demo link for external testing.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExampleSectionCard(
                title: 'Current state',
                subtitle:
                    'This is the deep-link state the SDK currently exposes through attriax.deepLinks and attriax.referrer.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'Initial probe',
                      value: widget.controller.initialDeepLinkResolved
                          ? 'Resolved'
                          : 'Still waiting',
                    ),
                    ExampleKeyValueRow(
                      label: 'Initial raw deep link',
                      value: widget.controller.rawInitialDeepLink == null
                          ? 'None'
                          : widget.controller.rawInitialDeepLink!.uri
                                .toString(),
                    ),
                    ExampleKeyValueRow(
                      label: 'Latest raw deep link',
                      value: widget.controller.latestRawDeepLink == null
                          ? 'None'
                          : widget.controller.latestRawDeepLink!.uri.toString(),
                    ),
                    ExampleKeyValueRow(
                      label: 'Initial resolved deep link',
                      value: widget.controller.initialDeepLink == null
                          ? 'None'
                          : widget.controller.initialDeepLink!.uri.toString(),
                    ),
                    ExampleKeyValueRow(
                      label: 'Latest resolved deep link',
                      value: widget.controller.latestDeepLink == null
                          ? 'None'
                          : widget.controller.latestDeepLink!.uri.toString(),
                    ),
                    ExampleKeyValueRow(
                      label: 'Latest resolution',
                      value: describeExampleResolution(
                        widget.controller.latestResolution,
                      ),
                    ),
                    const ExampleKeyValueRow(
                      label: 'Configured host',
                      value: exampleDeepLinkHost,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Create a demo link',
                subtitle:
                    'Use attriax.createDynamicLink() for a real tracked link. The fallback URL still helps validate host-side app-link routing.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      key: const ValueKey<String>('dynamic_link_prefix_field'),
                      controller: _prefixController,
                      decoration: const InputDecoration(
                        labelText: 'Prefix (optional)',
                        hintText: 'campaigns/flutter-demo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(currentLink),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: () =>
                              widget.controller.createDemoDynamicLink(
                                prefix: _prefixController.text,
                              ),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Create tracked link'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: widget.controller.copyLatestLink,
                          icon: const Icon(Icons.copy_all_outlined),
                          label: const Text('Copy link'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _shareCurrentLink(context),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share link'),
                        ),
                      ],
                    ),
                    if (widget.controller.latestCreatedLink !=
                        null) ...<Widget>[
                      const SizedBox(height: 12),
                      ExampleKeyValueRow(
                        label: 'Requested prefix',
                        value: _prefixController.text.trim().isEmpty
                            ? 'Default'
                            : _prefixController.text.trim(),
                      ),
                      ExampleKeyValueRow(
                        label: 'Short URL host',
                        value: Uri.parse(
                          widget.controller.latestCreatedLink!.link.shortUrl,
                        ).host,
                      ),
                      ExampleKeyValueRow(
                        label: 'Group',
                        value:
                            widget.controller.latestCreatedLink!.link.group ??
                            'None',
                      ),
                      ExampleKeyValueRow(
                        label: 'Path',
                        value: widget.controller.latestCreatedLink!.link.path,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Android app-link status',
                subtitle:
                    'The example host checks whether $exampleDeepLinkHost is verified for this Android build and can jump into system settings when it is not.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'State',
                      value: describeExampleDomainState(
                        widget.controller.appLinkStatus.state,
                      ),
                    ),
                    ExampleKeyValueRow(
                      label: 'Link handling allowed',
                      value: widget.controller.appLinkStatus.linkHandlingAllowed
                          ? 'Yes'
                          : 'No',
                    ),
                    ExampleKeyValueRow(
                      label: 'Details',
                      value: widget.controller.appLinkStatus.details,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        FilledButton.tonalIcon(
                          onPressed: widget.controller.refreshDomainStatus,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh status'),
                        ),
                        if (widget.controller.appLinkStatus.canOpenSettings)
                          FilledButton.icon(
                            onPressed: widget.controller.openAppLinkSettings,
                            icon: const Icon(Icons.settings_applications),
                            label: Text(
                              widget.controller.appLinkStatus.isVerified
                                  ? 'Open settings'
                                  : 'Verify in settings',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Manual recording helper',
                subtitle:
                    'Useful on desktop, web, or when you want to test recordDeepLink(...) directly without leaving the app.',
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _manualController,
                      decoration: const InputDecoration(
                        labelText: 'Full URL or Attriax path',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonalIcon(
                        onPressed: () => widget.controller.recordManualDeepLink(
                          _manualController.text,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Record deep link'),
                      ),
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

  Future<void> _shareCurrentLink(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;

    await SharePlus.instance.share(
      ShareParams(
        title: 'Attriax Flutter Example',
        subject: 'Attriax deep-link demo',
        text: widget.controller.currentDeepLink,
        uri: Uri.tryParse(widget.controller.currentDeepLink),
        sharePositionOrigin: origin,
      ),
    );
    await widget.controller.noteSharedLink();
  }
}
