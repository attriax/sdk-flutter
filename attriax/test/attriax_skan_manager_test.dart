import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_context_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_request_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_runtime_settings_state.dart';
import 'package:attriax_flutter/src/internal/attriax_session_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_skan_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_tracking_manager.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxSkanManager', () {
    late SharedPreferences prefs;
    late AttriaxPreferencesStore store;
    late _FakeSkanPlatform platform;
    late _FixedClock clock;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      store = AttriaxPreferencesStore(prefsOverride: prefs);
      platform = _FakeSkanPlatform();
      clock = _FixedClock(DateTime.utc(2026, 5, 15, 13));
    });

    test('registers the first-launch value on iOS', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      await manager.init(isFirstLaunch: true);

      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 0);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.low);
      expect(manager.state?.fineValue, 0);
      expect(manager.state?.firstLaunchValueRegistered, isTrue);
      expect((await store.readSkanState())?.fineValue, 0);
    });

    test('ignores SKAN state and events on non-iOS platforms', () async {
      await store.setSkanState(
        state: const AttriaxSkanState(enabled: true, fineValue: 7),
      );

      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.android,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      await manager.init(isFirstLaunch: true);
      await manager.applyAppOpenResult(
        AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: false,
          isFirstLaunch: false,
          acceptedAt: clock.now(),
          skan: _runtimeConfiguration(version: 1),
        ),
      );

      final result = await manager.handleTrackedEvent('purchase');

      expect(result, isNull);
      expect(platform.calls, isEmpty);
      expect(manager.state, isNull);
      expect(await store.readSkanState(), isNull);
    });

    test('encodes window 1 event ranks into fine-value bit ranges', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      await manager.init(isFirstLaunch: false);
      await manager.applyAppOpenResult(
        AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: false,
          isFirstLaunch: false,
          acceptedAt: clock.now(),
          skan: _runtimeConfiguration(
            version: 3,
            window1: const AttriaxSkanWindow1(
              groups: <AttriaxSkanWindow1Group>[
                AttriaxSkanWindow1Group(
                  id: 'group_revenue',
                  startBit: 4,
                  bitCount: 2,
                  events: <AttriaxSkanEvent>[
                    AttriaxSkanEvent(
                      id: 'event_add_to_cart',
                      eventName: 'add_to_cart',
                    ),
                    AttriaxSkanEvent(
                      id: 'event_purchase',
                      eventName: 'purchase',
                    ),
                    AttriaxSkanEvent(
                      id: 'event_subscription_started',
                      eventName: 'subscription_started',
                      coarseValue: AttriaxSkanCoarseValue.high,
                      lockWindow: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      final requestManager = _FakeRequestManager();
      final trackingManager = AttriaxTrackingManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: clock,
        contextManager: const _FakeTrackingContext(),
        settingsState: const _FakeSettingsState(),
        requestManager: requestManager,
        sessionManager: _FakeSessionManager(),
        skanManager: manager,
      );

      await trackingManager.recordEvent('subscription_started');

      expect(requestManager.enqueuedRequests, hasLength(1));
      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 48);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.high);
      expect(platform.calls.single.lockWindow, isTrue);
      expect(manager.state?.schemaVersion, 3);
      expect(manager.state?.schema?.window1.groups.single.startBit, 4);
      expect(manager.state?.fineValue, 48);
    });

    test('applies coarse-only updates in window 2', () async {
      clock = _FixedClock(DateTime.utc(2026, 5, 19, 13));
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      await manager.init(isFirstLaunch: false);
      await manager.applyAppOpenResult(
        AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: false,
          isFirstLaunch: false,
          acceptedAt: DateTime.utc(2026, 5, 15, 13),
          skan: _runtimeConfiguration(
            version: 4,
            window2: const AttriaxSkanCoarseWindow(
              events: <AttriaxSkanCoarseWindowEvent>[
                AttriaxSkanCoarseWindowEvent(
                  id: 'event_purchase_window_2',
                  eventName: 'purchase',
                  coarseValue: AttriaxSkanCoarseValue.medium,
                  conditions: <AttriaxSkanCondition>[
                    AttriaxSkanCondition(
                      id: 'condition_plan',
                      paramKey: 'plan',
                      value: 'pro',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await manager.handleTrackedEvent(
        'purchase',
        eventData: const <String, Object?>{'plan': 'pro'},
      );

      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 0);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.medium);
      expect(manager.state?.fineValue, 0);
      expect(manager.state?.coarseValue, AttriaxSkanCoarseValue.medium);
    });

    test('tracks purchase count and cumulative USD revenue locally', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      await manager.init(isFirstLaunch: false);
      await manager.applyAppOpenResult(
        AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: false,
          isFirstLaunch: false,
          acceptedAt: clock.now(),
          skan: _runtimeConfiguration(
            version: 7,
            window1: const AttriaxSkanWindow1(
              groups: <AttriaxSkanWindow1Group>[
                AttriaxSkanWindow1Group(
                  id: 'group_purchase',
                  startBit: 0,
                  bitCount: 2,
                  events: <AttriaxSkanEvent>[
                    AttriaxSkanEvent(
                      id: 'event_second_purchase',
                      eventName: 'purchase',
                      coarseValue: AttriaxSkanCoarseValue.medium,
                      conditions: <AttriaxSkanCondition>[
                        AttriaxSkanCondition(
                          id: 'condition_count',
                          paramKey: 'count',
                          operator: AttriaxSkanRuleOperator.gte,
                          value: 2,
                        ),
                      ],
                    ),
                    AttriaxSkanEvent(
                      id: 'event_revenue',
                      eventName: 'purchase',
                      coarseValue: AttriaxSkanCoarseValue.high,
                      lockWindow: true,
                      conditions: <AttriaxSkanCondition>[
                        AttriaxSkanCondition(
                          id: 'condition_revenue',
                          paramKey: 'revenue',
                          operator: AttriaxSkanRuleOperator.gte,
                          value: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await manager.handleTrackedEvent(
        'purchase',
        eventData: const <String, Object?>{'revenue': 2.5},
      );
      await manager.handleTrackedEvent(
        'purchase',
        eventData: const <String, Object?>{'revenue': 3.0},
      );

      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 2);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.high);
      expect(platform.calls.single.lockWindow, isTrue);
      expect(manager.state?.purchaseRevenueUsdMicros, 5500000);
      expect(manager.state?.purchaseCount, 2);
    });

    test('converts non-USD purchase revenue before local matching', () async {
      int? convertedAmountMicros;
      String? convertedCurrency;
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
        usdRevenueConverter:
            ({
              required amountMicros,
              required currency,
              required clientOccurredAt,
            }) async {
              convertedAmountMicros = amountMicros;
              convertedCurrency = currency;
              return 1200000;
            },
      );
      await manager.init(isFirstLaunch: false);
      await manager.applyAppOpenResult(
        AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: false,
          isFirstLaunch: false,
          acceptedAt: clock.now(),
          skan: _runtimeConfiguration(
            version: 8,
            window1: const AttriaxSkanWindow1(
              groups: <AttriaxSkanWindow1Group>[
                AttriaxSkanWindow1Group(
                  id: 'group_purchase',
                  startBit: 0,
                  bitCount: 1,
                  events: <AttriaxSkanEvent>[
                    AttriaxSkanEvent(
                      id: 'event_revenue',
                      eventName: 'purchase',
                      coarseValue: AttriaxSkanCoarseValue.medium,
                      conditions: <AttriaxSkanCondition>[
                        AttriaxSkanCondition(
                          id: 'condition_revenue',
                          paramKey: 'revenue',
                          operator: AttriaxSkanRuleOperator.gte,
                          value: 1.2,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await manager.handleTrackedEvent(
        'purchase',
        eventData: const <String, Object?>{'revenue': 0.99, 'currency': 'eur'},
      );

      expect(convertedAmountMicros, 990000);
      expect(convertedCurrency, 'EUR');
      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 1);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.medium);
      expect(manager.state?.purchaseRevenueUsdMicros, 1200000);
      expect(manager.state?.purchaseCount, 1);
    });

    test('tracks purchase count without inventing revenue', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      await manager.init(isFirstLaunch: false);
      await manager.applyAppOpenResult(
        AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: false,
          isFirstLaunch: false,
          acceptedAt: clock.now(),
          skan: _runtimeConfiguration(
            version: 10,
            window1: const AttriaxSkanWindow1(
              groups: <AttriaxSkanWindow1Group>[
                AttriaxSkanWindow1Group(
                  id: 'group_purchase_count',
                  startBit: 0,
                  bitCount: 1,
                  events: <AttriaxSkanEvent>[
                    AttriaxSkanEvent(
                      id: 'event_second_purchase',
                      eventName: 'purchase',
                      coarseValue: AttriaxSkanCoarseValue.medium,
                      conditions: <AttriaxSkanCondition>[
                        AttriaxSkanCondition(
                          id: 'condition_count',
                          paramKey: 'count',
                          operator: AttriaxSkanRuleOperator.gte,
                          value: 2,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await manager.handleTrackedEvent('purchase');
      await manager.handleTrackedEvent('purchase');

      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 1);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.medium);
      expect(manager.state?.purchaseCount, 2);
      expect(manager.state?.purchaseRevenueUsdMicros, 0);
    });

    test('tracks ad show count locally', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      await manager.init(isFirstLaunch: false);
      await manager.applyAppOpenResult(
        AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: false,
          isFirstLaunch: false,
          acceptedAt: clock.now(),
          skan: _runtimeConfiguration(
            version: 9,
            window1: const AttriaxSkanWindow1(
              groups: <AttriaxSkanWindow1Group>[
                AttriaxSkanWindow1Group(
                  id: 'group_ads',
                  startBit: 0,
                  bitCount: 1,
                  events: <AttriaxSkanEvent>[
                    AttriaxSkanEvent(
                      id: 'event_ads',
                      eventName: 'ad_show',
                      coarseValue: AttriaxSkanCoarseValue.medium,
                      conditions: <AttriaxSkanCondition>[
                        AttriaxSkanCondition(
                          id: 'condition_shown',
                          paramKey: 'shown',
                          operator: AttriaxSkanRuleOperator.gte,
                          value: 2,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await manager.handleTrackedEvent('ad_show');
      await manager.handleTrackedEvent('ad_show');

      expect(platform.calls, hasLength(1));
      expect(platform.calls.single.fineValue, 1);
      expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.medium);
      expect(manager.state?.adShowCount, 2);
    });

    test(
      'evaluates retention milestones from configured retention events',
      () async {
        clock = _FixedClock(DateTime.utc(2026, 5, 22, 9));
        final manager = AttriaxSkanManager(
          config: const AttriaxConfig(
            appToken: 'ax_test_token',
            skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
          ),
          preferencesStore: store,
          platform: platform,
          platformType: AttriaxPlatformType.ios,
          clock: clock,
          logger: AttriaxLogger(enableDebugLogs: false),
        );
        await manager.init(isFirstLaunch: false);

        await manager.applyAppOpenResult(
          AttriaxAppOpenResult(
            userId: 'user_1',
            isNewUser: false,
            isFirstLaunch: false,
            acceptedAt: DateTime.utc(2026, 5, 15, 9),
            skan: _runtimeConfiguration(
              version: 5,
              window2: const AttriaxSkanCoarseWindow(
                events: <AttriaxSkanCoarseWindowEvent>[
                  AttriaxSkanCoarseWindowEvent(
                    id: 'retention_day_7',
                    eventName: '_attriax_retention',
                    coarseValue: AttriaxSkanCoarseValue.high,
                    conditions: <AttriaxSkanCondition>[
                      AttriaxSkanCondition(
                        id: 'condition_day',
                        paramKey: 'day',
                        value: 7,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(platform.calls, hasLength(1));
        expect(platform.calls.single.fineValue, 0);
        expect(platform.calls.single.coarseValue, AttriaxSkanCoarseValue.high);
        expect(manager.state?.completedRetentionDays, const <int>[7]);
      },
    );

    test('does not update SKAN when event tracking is disabled', () async {
      final manager = AttriaxSkanManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        preferencesStore: store,
        platform: platform,
        platformType: AttriaxPlatformType.ios,
        clock: clock,
        logger: AttriaxLogger(enableDebugLogs: false),
      );
      await manager.init(isFirstLaunch: false);
      await manager.applyAppOpenResult(
        AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: false,
          isFirstLaunch: false,
          acceptedAt: clock.now(),
          skan: _runtimeConfiguration(
            version: 6,
            window1: const AttriaxSkanWindow1(
              groups: <AttriaxSkanWindow1Group>[
                AttriaxSkanWindow1Group(
                  id: 'group_purchase',
                  startBit: 0,
                  bitCount: 2,
                  events: <AttriaxSkanEvent>[
                    AttriaxSkanEvent(
                      id: 'event_purchase',
                      eventName: 'purchase',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      final requestManager = _FakeRequestManager();
      final trackingManager = AttriaxTrackingManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          skan: AttriaxSkanConfig(registerFirstLaunchValue: false),
        ),
        logger: AttriaxLogger(enableDebugLogs: false),
        clock: clock,
        contextManager: const _FakeTrackingContext(),
        settingsState: const _FakeSettingsState(areEventsEnabled: false),
        requestManager: requestManager,
        sessionManager: _FakeSessionManager(),
        skanManager: manager,
      );

      await trackingManager.recordEvent('purchase');

      expect(requestManager.enqueuedRequests, isEmpty);
      expect(platform.calls, isEmpty);
      expect(manager.state?.fineValue, isNull);
    });
  });
}

AttriaxSkanRuntimeConfiguration _runtimeConfiguration({
  required int version,
  AttriaxSkanWindow1 window1 = const AttriaxSkanWindow1(),
  AttriaxSkanCoarseWindow window2 = const AttriaxSkanCoarseWindow(),
  AttriaxSkanCoarseWindow window3 = const AttriaxSkanCoarseWindow(),
}) => AttriaxSkanRuntimeConfiguration(
  enabled: true,
  schema: AttriaxSkanSchema(
    version: version,
    window1: window1,
    window2: window2,
    window3: window3,
  ),
);

class _FakeSkanPlatform extends AttriaxPlatform {
  final List<_SkanCall> calls = <_SkanCall>[];

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  @override
  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    calls.add(
      _SkanCall(
        fineValue: fineValue,
        coarseValue: coarseValue,
        lockWindow: lockWindow,
      ),
    );

    return AttriaxSkanUpdateResult(
      status: AttriaxSkanUpdateStatus.updated,
      fineValue: fineValue,
      coarseValue: coarseValue,
      lockWindow: lockWindow,
    );
  }
}

class _SkanCall {
  const _SkanCall({
    required this.fineValue,
    required this.lockWindow,
    this.coarseValue,
  });

  final int fineValue;
  final AttriaxSkanCoarseValue? coarseValue;
  final bool lockWindow;
}

class _FixedClock implements AttriaxClock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

class _FakeTrackingContext implements AttriaxTrackingContext {
  const _FakeTrackingContext();

  @override
  String get requiredDeviceId => 'sdk_device';

  @override
  AttriaxContextSnapshot get requiredSnapshot => const AttriaxContextSnapshot(
    platform: AttriaxPlatformType.ios,
    deviceId: 'sdk_device',
    isFirstLaunch: false,
    sdk: AttriaxSdkSnapshot(
      apiVersion: attriaxSdkApiVersion,
      packageVersion: attriaxSdkPackageVersion,
    ),
    app: AttriaxAppSnapshot(
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'com.attriax.test',
    ),
    device: AttriaxDeviceSnapshot(model: 'Test iPhone', osVersion: '17.5'),
  );

  @override
  String requireDeviceIdSource() => 'test';
}

class _FakeSettingsState implements AttriaxRuntimeSettingsView {
  const _FakeSettingsState({this.areEventsEnabled = true});

  @override
  bool get isEnabled => true;

  @override
  final bool areEventsEnabled;
}

class _FakeRequestManager extends AttriaxRequestManager {
  final List<AttriaxApiRequest> enqueuedRequests = <AttriaxApiRequest>[];

  @override
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool flushImmediately = true,
  }) async {
    enqueuedRequests.add(request);
  }
}

class _FakeSessionManager implements AttriaxTrackedSessionPreparer {
  @override
  Future<AttriaxSessionSnapshot?> prepareTrackedSessionAt(
    DateTime occurredAt,
  ) async => AttriaxSessionSnapshot(
    id: 'session_1',
    deviceId: 'sdk_device',
    platform: AttriaxPlatformType.ios,
    isFirstLaunch: false,
    startedAt: occurredAt.subtract(const Duration(seconds: 1)),
    lastActivityAt: occurredAt,
    heartbeatInterval: const Duration(seconds: 60),
  );
}
