import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

import 'example_app_controller.dart';
import 'example_app_widgets.dart';

const List<String> _examplePurchaseCurrencies = <String>[
  'USD',
  'EUR',
  'GBP',
  'JPY',
];

class ExampleEventsPage extends StatefulWidget {
  const ExampleEventsPage({super.key, required this.controller});

  static const String routeName = '/events';

  final ExampleAppController controller;

  @override
  State<ExampleEventsPage> createState() => _ExampleEventsPageState();
}

class _ExampleEventsPageState extends State<ExampleEventsPage> {
  late final TextEditingController _purchaseRevenueController =
      TextEditingController(text: '9.99');
  late final TextEditingController _adRevenueMicrosController =
      TextEditingController(text: '4200');
  String _selectedCurrency = _examplePurchaseCurrencies.first;

  @override
  void dispose() {
    _purchaseRevenueController.dispose();
    _adRevenueMicrosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return ExamplePageScaffold(
          title: 'Events',
          subtitle:
              'Use the standardized tracking helpers when they fit, and fall back to tracking.recordEvent() for app-specific analytics.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExampleSectionCard(
                title: 'Custom events',
                subtitle:
                    'These buttons call attriax.tracking.recordEvent(...) with payloads your app would normally send from real UX moments.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    ExampleActionButton(
                      label: 'signup_completed',
                      onPressed: () => _runScheduledEventAction(
                        () => widget.controller.sendCustomEvent(
                          name: 'signup_completed',
                          data: const <String, Object?>{
                            'method': 'email',
                            'plan': 'starter',
                          },
                        ),
                      ),
                    ),
                    ExampleActionButton(
                      label: 'invite_shared',
                      onPressed: () => _runScheduledEventAction(
                        () => widget.controller.sendCustomEvent(
                          name: 'invite_shared',
                          data: const <String, Object?>{
                            'channel': 'telegram',
                            'contactsSelected': 3,
                          },
                        ),
                      ),
                    ),
                    ExampleActionButton(
                      label: 'search_performed',
                      onPressed: () => _runScheduledEventAction(
                        () => widget.controller.sendCustomEvent(
                          name: 'search_performed',
                          data: const <String, Object?>{
                            'query': 'wireless earbuds',
                            'resultCount': 14,
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Page views',
                subtitle:
                    'recordPageView() keeps screen analytics normalized under the page_view event.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    ExampleActionButton(
                      label: 'Home view',
                      onPressed: () => _runScheduledEventAction(
                        () => widget.controller.sendPageView(
                          pageName: 'Home',
                          pageClass: 'HomeScreen',
                          pageTitle: 'Attriax Example Home',
                          previousPageName: 'Launch',
                          parameters: const <String, Object?>{
                            'tab': 'overview',
                          },
                        ),
                      ),
                    ),
                    ExampleActionButton(
                      label: 'Checkout step 2',
                      onPressed: () => _runScheduledEventAction(
                        () => widget.controller.sendPageView(
                          pageName: 'Checkout',
                          pageClass: 'CheckoutScreen',
                          pageTitle: 'Checkout',
                          previousPageName: 'Cart',
                          parameters: const <String, Object?>{'step': 2},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Ad events and ad revenue',
                subtitle:
                    'These helpers standardize ad delivery, failure, engagement, and tiny paid-event revenue samples in USD micros.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        ExampleActionButton(
                          label: 'ad_request',
                          onPressed: () => _runScheduledEventAction(
                            () => widget.controller.sendAdLifecycle(
                              AttriaxAdEventType.request,
                            ),
                          ),
                        ),
                        ExampleActionButton(
                          label: 'ad_load',
                          onPressed: () => _runScheduledEventAction(
                            () => widget.controller.sendAdLifecycle(
                              AttriaxAdEventType.load,
                            ),
                          ),
                        ),
                        ExampleActionButton(
                          label: 'ad_impression',
                          onPressed: () => _runScheduledEventAction(
                            () => widget.controller.sendAdLifecycle(
                              AttriaxAdEventType.impression,
                            ),
                          ),
                        ),
                        ExampleActionButton(
                          label: 'ad_reward',
                          onPressed: () => _runScheduledEventAction(
                            () => widget.controller.sendAdLifecycle(
                              AttriaxAdEventType.reward,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 260,
                          child: TextField(
                            key: const ValueKey<String>(
                              'ad_revenue_micros_field',
                            ),
                            controller: _adRevenueMicrosController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Revenue (micros, USD only)',
                              hintText: '4200',
                              helperText: '4200 micros = USD 0.0042',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () async {
                            final revenueMicros = _parsePositiveInt(
                              _adRevenueMicrosController.text,
                            );
                            if (revenueMicros == null) {
                              _showInputError(
                                context,
                                'Enter a positive ad revenue micros value.',
                              );
                              return;
                            }
                            await _runScheduledEventAction(
                              () => widget.controller.sendAdRevenueExample(
                                revenueMicros: revenueMicros,
                              ),
                            );
                          },
                          child: const Text('ad_revenue'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Purchases, refunds, and validation',
                subtitle:
                    'Set the real revenue and currency for the purchase/refund examples. Receipt validation stays fake here so the public example does not depend on store receipts.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 200,
                          child: TextField(
                            key: const ValueKey<String>(
                              'purchase_revenue_field',
                            ),
                            controller: _purchaseRevenueController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Revenue',
                              hintText: '9.99',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: DropdownButtonFormField<String>(
                            key: const ValueKey<String>(
                              'purchase_currency_field',
                            ),
                            initialValue: _selectedCurrency,
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                              border: OutlineInputBorder(),
                            ),
                            items: _examplePurchaseCurrencies
                                .map(
                                  (currency) => DropdownMenuItem<String>(
                                    value: currency,
                                    child: Text(currency),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedCurrency = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        ExampleActionButton(
                          label: 'recordPurchase',
                          onPressed: () async {
                            final revenue = _parsePositiveNumber(
                              _purchaseRevenueController.text,
                            );
                            if (revenue == null) {
                              _showInputError(
                                context,
                                'Enter a positive purchase revenue.',
                              );
                              return;
                            }
                            await _runScheduledEventAction(
                              () => widget.controller.sendPurchaseExample(
                                revenue: revenue,
                                currency: _selectedCurrency,
                              ),
                            );
                          },
                        ),
                        ExampleActionButton(
                          label: 'recordRefund',
                          onPressed: () async {
                            final revenue = _parsePositiveNumber(
                              _purchaseRevenueController.text,
                            );
                            if (revenue == null) {
                              _showInputError(
                                context,
                                'Enter a positive refund revenue.',
                              );
                              return;
                            }
                            await _runScheduledEventAction(
                              () => widget.controller.sendRefundExample(
                                revenue: revenue,
                                currency: _selectedCurrency,
                              ),
                            );
                          },
                        ),
                        ExampleActionButton(
                          label: 'validateReceipt',
                          onPressed: () async {
                            final revenue = _parsePositiveNumber(
                              _purchaseRevenueController.text,
                            );
                            if (revenue == null) {
                              _showInputError(
                                context,
                                'Enter a positive purchase revenue first.',
                              );
                              return;
                            }
                            await widget.controller.validateDemoReceipt(
                              revenue: revenue,
                              currency: _selectedCurrency,
                            );
                          },
                        ),
                      ],
                    ),
                    if (widget.controller.latestValidationSummary !=
                        null) ...<Widget>[
                      const SizedBox(height: 12),
                      SelectableText(
                        widget.controller.latestValidationSummary!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  num? _parsePositiveNumber(String value) {
    final parsed = num.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  int? _parsePositiveInt(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  void _showInputError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runScheduledEventAction(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    FocusManager.instance.primaryFocus?.unfocus();
    await action();
    if (!mounted) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Event scheduled. You can open the Attriax dashboard now; it should appear within 1-60 seconds.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
