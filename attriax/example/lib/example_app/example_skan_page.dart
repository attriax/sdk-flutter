import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

import 'example_app_controller.dart';
import 'example_app_formatters.dart';
import 'example_app_widgets.dart';

class ExampleSkanPage extends StatefulWidget {
  const ExampleSkanPage({super.key, required this.controller});

  static const String routeName = '/skan';

  final ExampleAppController controller;

  @override
  State<ExampleSkanPage> createState() => _ExampleSkanPageState();
}

class _ExampleSkanPageState extends State<ExampleSkanPage> {
  late final TextEditingController _fineValueController = TextEditingController(
    text: (widget.controller.skanState?.fineValue ?? 0).toString(),
  );
  AttriaxSkanCoarseValue? _selectedCoarseValue;
  bool _lockWindow = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentStateIntoForm();
  }

  @override
  void dispose() {
    _fineValueController.dispose();
    super.dispose();
  }

  void _loadCurrentStateIntoForm() {
    final state = widget.controller.skanState;
    _fineValueController.text = (state?.fineValue ?? 0).toString();
    _selectedCoarseValue = state?.coarseValue;
    _lockWindow = state?.lockWindow ?? false;
  }

  Future<void> _refreshState() async {
    await widget.controller.refreshSkanState();
    if (!mounted) {
      return;
    }

    setState(_loadCurrentStateIntoForm);
  }

  Future<void> _applyUpdate() async {
    final fineValue = int.tryParse(_fineValueController.text.trim());
    if (fineValue == null || fineValue < 0 || fineValue > 63) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a fine conversion value between 0 and 63.'),
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await widget.controller.updateSkanConversionValue(
        fineValue: fineValue,
        coarseValue: _selectedCoarseValue,
        lockWindow: _lockWindow,
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (!widget.controller.skanTestingAvailable) {
          return const ExamplePageScaffold(
            title: 'SKAdNetwork Testing',
            subtitle:
                'The public example exposes manual SKAN controls on iOS only.',
            child: ExampleSectionCard(
              title: 'Unavailable here',
              subtitle:
                  'Open this page on an iPhone build of the example app to read local state and send manual conversion value updates.',
              child: Text(
                'This route stays in the example so shared code keeps compiling, but the controls are hidden outside iOS.',
              ),
            ),
          );
        }

        final skanState = widget.controller.skanState;
        final lastResult = widget.controller.lastSkanUpdateResult;
        final schema = skanState?.schema;

        return ExamplePageScaffold(
          title: 'SKAdNetwork Testing',
          subtitle:
              'Use this iPhone-only page to inspect local SKAN state, try any fine value from 0 to 63, optionally set a coarse value, and lock the current window.',
          actions: <Widget>[
            FilledButton.tonalIcon(
              onPressed: _isUpdating ? null : _refreshState,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExampleSectionCard(
                title: 'Current SKAN state',
                subtitle:
                    'These values come from the SDK\'s locally persisted iOS SKAdNetwork snapshot.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        ExampleMetricChip(
                          label: 'Enabled',
                          value: skanState == null
                              ? 'Unknown'
                              : (skanState.enabled ? 'Yes' : 'No'),
                        ),
                        ExampleMetricChip(
                          label: 'Fine value',
                          value: skanState?.fineValue?.toString() ?? 'Not set',
                        ),
                        ExampleMetricChip(
                          label: 'Coarse value',
                          value: skanState?.coarseValue?.name ?? 'Not set',
                        ),
                        ExampleMetricChip(
                          label: 'Window locked',
                          value: skanState?.lockWindow == true ? 'Yes' : 'No',
                        ),
                        ExampleMetricChip(
                          label: 'First launch value',
                          value: skanState == null
                              ? 'Unknown'
                              : (skanState.firstLaunchValueRegistered
                                    ? 'Registered'
                                    : 'Pending'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ExampleKeyValueRow(
                      label: 'Schema version',
                      value: skanState?.schemaVersion?.toString() ?? 'Unknown',
                    ),
                    ExampleKeyValueRow(
                      label: 'Last updated',
                      value: skanState?.lastUpdatedAt == null
                          ? 'Not available'
                          : formatExampleTimestamp(skanState!.lastUpdatedAt!),
                    ),
                    ExampleKeyValueRow(
                      label: 'Retention days',
                      value:
                          skanState == null ||
                              skanState.completedRetentionDays.isEmpty
                          ? 'None'
                          : skanState.completedRetentionDays.join(', '),
                    ),
                    ExampleKeyValueRow(
                      label: 'Purchase count',
                      value: skanState?.purchaseCount.toString() ?? '0',
                    ),
                    ExampleKeyValueRow(
                      label: 'Ad show count',
                      value: skanState?.adShowCount.toString() ?? '0',
                    ),
                    ExampleKeyValueRow(
                      label: 'Window 1 groups',
                      value: schema?.window1.groups.length.toString() ?? '0',
                    ),
                    ExampleKeyValueRow(
                      label: 'Window 2 events',
                      value: schema?.window2.events.length.toString() ?? '0',
                    ),
                    ExampleKeyValueRow(
                      label: 'Window 3 events',
                      value: schema?.window3.events.length.toString() ?? '0',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Manual conversion update',
                subtitle:
                    'Apple accepts only monotonic changes, so lower values can come back as already at or above value. Developer and Development postbacks still depend on the iPhone settings you configured.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      key: const ValueKey<String>('skan_fine_value_field'),
                      controller: _fineValueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fine conversion value (0-63)',
                        hintText: '0',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        ExampleActionButton(
                          label: 'Preset 0',
                          onPressed: () {
                            setState(() {
                              _fineValueController.text = '0';
                            });
                          },
                        ),
                        ExampleActionButton(
                          label: 'Preset 10',
                          onPressed: () {
                            setState(() {
                              _fineValueController.text = '10';
                            });
                          },
                        ),
                        ExampleActionButton(
                          label: 'Preset 31',
                          onPressed: () {
                            setState(() {
                              _fineValueController.text = '31';
                            });
                          },
                        ),
                        ExampleActionButton(
                          label: 'Preset 63',
                          onPressed: () {
                            setState(() {
                              _fineValueController.text = '63';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AttriaxSkanCoarseValue?>(
                      key: ValueKey<String>(
                        'skan_coarse_${_selectedCoarseValue?.name ?? 'none'}',
                      ),
                      initialValue: _selectedCoarseValue,
                      decoration: const InputDecoration(
                        labelText: 'Coarse value',
                        border: OutlineInputBorder(),
                      ),
                      items: const <DropdownMenuItem<AttriaxSkanCoarseValue?>>[
                        DropdownMenuItem<AttriaxSkanCoarseValue?>(
                          value: null,
                          child: Text('None'),
                        ),
                        DropdownMenuItem<AttriaxSkanCoarseValue?>(
                          value: AttriaxSkanCoarseValue.low,
                          child: Text('Low'),
                        ),
                        DropdownMenuItem<AttriaxSkanCoarseValue?>(
                          value: AttriaxSkanCoarseValue.medium,
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem<AttriaxSkanCoarseValue?>(
                          value: AttriaxSkanCoarseValue.high,
                          child: Text('High'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCoarseValue = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _lockWindow,
                      title: const Text('Lock SKAN window'),
                      subtitle: const Text(
                        'Send lockWindow=true together with this manual update.',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _lockWindow = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        FilledButton(
                          onPressed: _isUpdating ? null : _applyUpdate,
                          child: Text(
                            _isUpdating ? 'Updating...' : 'Apply SKAN value',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _isUpdating
                              ? null
                              : () {
                                  setState(_loadCurrentStateIntoForm);
                                },
                          child: const Text('Load current state'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Last update result',
                subtitle:
                    'The SDK mirrors the last native update result here so you can compare the requested values with the persisted state after Apple responds.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExampleKeyValueRow(
                      label: 'Status',
                      value: lastResult == null
                          ? 'Not available'
                          : describeExampleSkanUpdateStatus(lastResult.status),
                    ),
                    ExampleKeyValueRow(
                      label: 'Message',
                      value: lastResult?.message ?? 'Not available',
                    ),
                    ExampleKeyValueRow(
                      label: 'Requested fine',
                      value: lastResult?.fineValue?.toString() ?? 'Unknown',
                    ),
                    ExampleKeyValueRow(
                      label: 'Requested coarse',
                      value: lastResult?.coarseValue?.name ?? 'None',
                    ),
                    ExampleKeyValueRow(
                      label: 'Requested lock',
                      value: lastResult?.lockWindow == true ? 'Yes' : 'No',
                    ),
                    const SizedBox(height: 12),
                    ExampleJsonCard(
                      title: 'Persisted SKAN state JSON',
                      value: skanState?.toJson(),
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
