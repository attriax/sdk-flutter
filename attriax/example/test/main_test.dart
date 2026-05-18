import 'dart:async';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:attriax_flutter_example/example_platform_bridge.dart';
import 'package:attriax_flutter_example/example_push_tokens.dart';
import 'package:attriax_flutter_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAttriax sdk;
  late FakePushTokenService pushTokens;
  late FakePlatformBridge platformBridge;

  setUp(() {
    sdk = FakeAttriax();
    pushTokens = FakePushTokenService(
      ExamplePushTokenSnapshot(
        phase: ExamplePushTokenPhase.ready,
        summary: 'FCM token synced with Attriax.',
        permissionStatus: 'Authorized',
        setupHint: 'Firebase is configured for tests.',
        fcmToken: 'fcm_token_12345',
        lastUpdatedAt: DateTime.utc(2026, 5, 14, 9),
        firebaseConfigured: true,
        listeningForRefresh: true,
      ),
    );
    platformBridge = FakePlatformBridge(
      const ExampleAppLinkDomainStatus(
        host: 'example-test.attriax.com',
        state: ExampleAppLinkDomainState.verified,
        details: 'Android verified the host for this app.',
        linkHandlingAllowed: true,
        canOpenSettings: true,
      ),
    );
  });

  Future<void> pumpExampleApp(
    WidgetTester tester, {
    String? bootstrapError,
  }) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await sdk.dispose();
      await pushTokens.dispose();
    });

    await tester.pumpWidget(
      AttriaxPackageExampleApp(
        sdk: sdk,
        bootstrapError: bootstrapError,
        pushTokenService: pushTokens,
        platformBridge: platformBridge,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> pumpRouteTransition(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> tapVisibleText(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(finder, warnIfMissed: false);
  }

  Future<void> tapNavigationTile(WidgetTester tester, String label) async {
    await tapVisibleText(tester, label);
    await pumpRouteTransition(tester);
  }

  testWidgets('shows the rewritten home surface with status and page links', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.text('Current SDK state'), findsOneWidget);
    expect(find.text('Deep links'), findsOneWidget);
    expect(find.text('Token registration'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Controls'), findsOneWidget);
    expect(find.text('Mini games'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.textContaining('FCM token synced with Attriax.'), findsWidgets);
  });

  testWidgets('shows the bootstrap error page and skips startup refreshes', (
    tester,
  ) async {
    await pumpExampleApp(
      tester,
      bootstrapError: 'Attriax init failed: network unavailable',
    );

    expect(find.text('Startup blocked'), findsOneWidget);
    expect(
      find.text('Attriax init failed: network unavailable'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Edit lib/example_app_configuration.dart to change the app token',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Current token:'), findsOneWidget);
    expect(find.text('Current SDK state'), findsNothing);
    expect(pushTokens.refreshCalls, 0);
  });

  testWidgets('deep link events navigate to the result page', (tester) async {
    await pumpExampleApp(tester);

    final rawEvent = AttriaxRawDeepLinkEvent(
      uri: Uri.parse(
        'https://example-test.attriax.com/example/deep-link-success',
      ),
      receivedAt: DateTime.utc(2026, 5, 14, 10),
      isInitial: false,
    );
    final resolution = AttriaxDeepLinkEvent(
      uri: Uri.parse(
        'https://example-test.attriax.com/example/deep-link-success',
      ),
      clickedAt: DateTime.utc(2026, 5, 14, 10),
      consumedAt: DateTime.utc(2026, 5, 14, 10, 0, 1),
      found: true,
      trigger: AttriaxDeepLinkTrigger.foreground,
      isAttriaxSubDomain: true,
      rawEvent: rawEvent,
      data: const <String, String>{'campaign': 'spring-launch'},
    );

    sdk.emitDeepLink(rawEvent: rawEvent, resolvedEvent: resolution);

    await pumpRouteTransition(tester);
    await tester.pump();

    expect(find.text('Deep Link Result'), findsWidgets);
    expect(find.text('Deep link matched successfully'), findsOneWidget);
    expect(find.textContaining('spring-launch'), findsWidgets);
  });

  testWidgets(
    'token page refreshes live token status without manual send fields',
    (tester) async {
      await pumpExampleApp(tester);

      await tapNavigationTile(tester, 'Token registration');

      expect(find.text('Current token state'), findsOneWidget);
      expect(find.text('Request permission and sync'), findsOneWidget);
      expect(find.text('Refresh status'), findsOneWidget);
      expect(find.text('Send Firebase token'), findsNothing);
      expect(find.text('Send APNs token'), findsNothing);

      await tapVisibleText(tester, 'Request permission and sync');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(pushTokens.refreshCalls, 2);
      expect(pushTokens.lastRequestPermission, isTrue);
    },
  );

  testWidgets('events page buttons call standardized helpers', (tester) async {
    await pumpExampleApp(tester);

    await tapNavigationTile(tester, 'Events');

    await tester.enterText(
      find.byKey(const ValueKey<String>('purchase_revenue_field')),
      '12.49',
    );
    await tapVisibleText(tester, 'recordPurchase');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.textContaining('open the Attriax dashboard now'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('ad_revenue_micros_field')),
      '4200',
    );
    await tapVisibleText(tester, 'ad_revenue');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tapVisibleText(tester, 'validateReceipt');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(sdk.recordedPurchases, hasLength(1));
    expect(sdk.recordedAdRevenue, hasLength(1));
    expect(sdk.recordedPurchases.single['revenue'], 12.49);
    expect(sdk.recordedAdRevenue.single['revenue'], 4200);
    expect(find.textContaining('Fake Unity-style validation'), findsOneWidget);
  });

  testWidgets('deep links page uses the typed prefix for new links', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tapNavigationTile(tester, 'Deep links');

    await tester.enterText(
      find.byKey(const ValueKey<String>('dynamic_link_prefix_field')),
      'campaigns/spring',
    );
    await tapVisibleText(tester, 'Create tracked link');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('campaigns/spring'), findsWidgets);
  });

  testWidgets('recent activity opens on its own page', (tester) async {
    await pumpExampleApp(tester);

    await tapNavigationTile(tester, 'Recent activity');

    expect(find.text('Recent Activity'), findsWidgets);
    expect(find.text('Recent activity'), findsWidgets);
  });

  testWidgets('controls page crash button uses the platform bridge', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tapNavigationTile(tester, 'Controls');
    await tapVisibleText(tester, 'Trigger native crash');
    await tester.pump();

    expect(platformBridge.didTriggerNativeCrash, isTrue);
  });

  testWidgets('mini games open dedicated full-screen routes on phone layouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 851));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await pumpExampleApp(tester);

    await tapNavigationTile(tester, 'Mini games');
    await tester.enterText(
      find.byKey(const ValueKey<String>('game_player_name_field')),
      'Taylor',
    );
    await tester.pump();
    await tapVisibleText(tester, 'Pulse Sprint');
    await pumpRouteTransition(tester);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pulse Sprint'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

class FakeAttriax extends Fake implements Attriax {
  final StreamController<AttriaxRawDeepLinkEvent> _rawDeepLinksController =
      StreamController<AttriaxRawDeepLinkEvent>.broadcast();
  final StreamController<AttriaxDeepLinkEvent> _deepLinksController =
      StreamController<AttriaxDeepLinkEvent>.broadcast();
  final StreamController<AttriaxSynchronizationState>
  _synchronizationController =
      StreamController<AttriaxSynchronizationState>.broadcast();

  bool _enabled = true;
  bool _eventsEnabled = true;

  final List<Map<String, Object?>> recordedEvents = <Map<String, Object?>>[];
  final List<Map<String, Object?>> recordedPurchases = <Map<String, Object?>>[];
  final List<Map<String, Object?>> recordedAdRevenue = <Map<String, Object?>>[];

  AttriaxInstallReferrerDetails? originalInstallReferrerResult =
      const AttriaxInstallReferrerDetails(
        attributionType: AttributionType.referrer,
        precision: 1,
        campaign: 'spring-launch',
        source: 'attriax',
      );
  AttriaxInstallReferrerDetails? reinstallReferrerResult;
  AttriaxRawDeepLinkEvent? rawInitialDeepLinkResult;
  AttriaxDeepLinkEvent? initialDeepLinkResult;
  AttriaxDeepLinkEvent? latestDeepLinkResult;
  final Map<AttriaxRawDeepLinkEvent, Future<AttriaxDeepLinkEvent>>
  _resolutionByRaw = <AttriaxRawDeepLinkEvent, Future<AttriaxDeepLinkEvent>>{};

  @override
  late final AttriaxDeepLinks deepLinks = _FakeAttriaxDeepLinks(this);

  @override
  late final AttriaxSynchronization synchronization =
      _FakeAttriaxSynchronization(this);

  @override
  late final AttriaxReferrer referrer = _FakeAttriaxReferrer(this);

  @override
  bool get isInitialized => true;

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool value) {
    _enabled = value;
  }

  @override
  bool get eventsEnabled => _eventsEnabled;

  @override
  set eventsEnabled(bool value) {
    _eventsEnabled = value;
  }

  @override
  bool get isFirstLaunch => true;

  @override
  String? get deviceId => 'device_example_123';

  @override
  AttriaxSdkSnapshot? get sdkSnapshot =>
      const AttriaxSdkSnapshot(apiVersion: 'v1', packageVersion: '0.1.0');

  @override
  Future<void> init({bool? enabled, bool? eventsEnabled}) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> dispose() async {
    if (!_rawDeepLinksController.isClosed) {
      await _rawDeepLinksController.close();
    }
    if (!_deepLinksController.isClosed) {
      await _deepLinksController.close();
    }
    if (!_synchronizationController.isClosed) {
      await _synchronizationController.close();
    }
  }

  @override
  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) async {
    recordedEvents.add(<String, Object?>{
      'eventName': eventName,
      'eventData': eventData,
      'flushImmediately': flushImmediately,
    });
  }

  @override
  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) async {
    recordedEvents.add(<String, Object?>{
      'eventName': 'page_view',
      'pageName': pageName,
      'pageClass': pageClass,
      'pageTitle': pageTitle,
      'previousPageName': previousPageName,
      'parameters': parameters,
      'source': source,
    });
  }

  @override
  Future<void> recordAdEvent(
    AttriaxAdEventType type, {
    String? adNetwork,
    String? mediationNetwork,
    String? adUnitId,
    String? adPlacement,
    String? adFormat,
    String? adType,
    String? failureReason,
    num? loadLatencyMs,
    String? rewardType,
    num? rewardAmount,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) async {
    recordedEvents.add(<String, Object?>{
      'eventName': type.eventName,
      'adPlacement': adPlacement,
    });
  }

  @override
  Future<void> recordAdRevenue({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? adNetwork,
    String? adFormat,
    String? adType,
    String? adPlacement,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) async {
    recordedAdRevenue.add(<String, Object?>{
      'revenue': revenue,
      'currency': currency,
      'adPlacement': adPlacement,
    });
  }

  @override
  Future<void> recordPurchase({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    String? validationProvider,
    String? validationEnvironment,
    String? purchaseToken,
    String? receiptData,
    String? signedPayload,
    String? receiptSignature,
    bool? isRenewal,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? validationId,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) async {
    recordedPurchases.add(<String, Object?>{
      'revenue': revenue,
      'currency': currency,
      'productId': productId,
    });
  }

  @override
  Future<void> recordRefund({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? reason,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) async {}

  @override
  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    String? provider,
    String? environment,
    String? transactionId,
    String? originalTransactionId,
    String? productId,
    String? store,
    String? packageName,
    String? purchaseToken,
    String? receiptData,
    String? signedPayload,
    String? receiptSignature,
    bool? test,
  }) async {
    return const AttriaxRevenueReceiptValidationResult(
      validationId: 'validation_demo',
      status: AttriaxRevenueReceiptValidationStatus.pending,
      publicReceipt: <String, Object?>{},
    );
  }

  @override
  Future<void> registerFirebaseMessagingToken(
    String? token, {
    Map<String, Object?>? metadata,
  }) async {}

  @override
  Future<void> registerApplePushToken(
    String? token, {
    Map<String, Object?>? metadata,
  }) async {}

  @override
  Future<void> setUser(String? userId, {String? userName}) async {}

  @override
  Future<void> setUserProperty(String name, Object? value) async {}

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {}

  @override
  Future<void> clearUserProperties({List<String>? propertyNames}) async {}

  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkRedirects? redirects,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    Map<String, Object?>? data,
  }) async {
    final normalizedPrefix = prefix?.trim();
    final prefixPath = normalizedPrefix == null || normalizedPrefix.isEmpty
        ? ''
        : '${normalizedPrefix.replaceAll(RegExp(r'^/+|/+$'), '')}/';
    return AttriaxCreateDynamicLinkResult(
      link: AttriaxDynamicLinkRecord(
        id: 'link_demo_1',
        path: '${prefixPath}example/deep-link-success',
        shortUrl:
            'https://example-test.attriax.com/${prefixPath}example/deep-link-success',
        group: group,
        data: data,
        createdAt: DateTime.utc(2026, 5, 14, 10),
      ),
    );
  }

  @override
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    return AttriaxDeepLinkEvent(
      uri:
          uri ??
          Uri.parse('https://example-test.attriax.com/${linkPath ?? ''}'),
      clickedAt: DateTime.utc(2026, 5, 14, 10),
      consumedAt: DateTime.utc(2026, 5, 14, 10, 0, 1),
      found: true,
      trigger: AttriaxDeepLinkTrigger.foreground,
      isAttriaxSubDomain: true,
      data: const <String, String>{'source': 'manual'},
    );
  }

  void emitDeepLink({
    required AttriaxRawDeepLinkEvent rawEvent,
    required AttriaxDeepLinkEvent resolvedEvent,
  }) {
    rawInitialDeepLinkResult ??= rawEvent.isInitial ? rawEvent : null;
    initialDeepLinkResult ??= rawEvent.isInitial ? resolvedEvent : null;
    latestDeepLinkResult = resolvedEvent;
    _resolutionByRaw[rawEvent] = Future<AttriaxDeepLinkEvent>.value(
      resolvedEvent,
    );
    _rawDeepLinksController.add(rawEvent);
    _deepLinksController.add(resolvedEvent);
  }
}

class _FakeAttriaxDeepLinks implements AttriaxDeepLinks {
  _FakeAttriaxDeepLinks(this._sdk);

  final FakeAttriax _sdk;

  @override
  AttriaxRawDeepLinkEvent? get rawInitialDeepLink =>
      _sdk.rawInitialDeepLinkResult;

  @override
  AttriaxDeepLinkEvent? get initialDeepLink => _sdk.initialDeepLinkResult;

  @override
  bool get initialDeepLinkResolved => true;

  @override
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() async =>
      _sdk.initialDeepLinkResult;

  @override
  Future<AttriaxDeepLinkEvent> waitResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) async => _sdk._resolutionByRaw[rawEvent]!;

  @override
  Stream<AttriaxRawDeepLinkEvent> get rawStream =>
      _sdk._rawDeepLinksController.stream;

  @override
  Stream<AttriaxDeepLinkEvent> get stream => _sdk._deepLinksController.stream;

  @override
  AttriaxDeepLinkEvent? get latestDeepLink => _sdk.latestDeepLinkResult;
}

class _FakeAttriaxSynchronization extends Fake
    implements AttriaxSynchronization {
  _FakeAttriaxSynchronization(this._sdk);

  final FakeAttriax _sdk;

  @override
  AttriaxSynchronizationState get state =>
      AttriaxSynchronizationState.synchronized;

  @override
  bool get isSynchronized => true;

  @override
  Stream<AttriaxSynchronizationState> get states =>
      _sdk._synchronizationController.stream;
}

class _FakeAttriaxReferrer extends Fake implements AttriaxReferrer {
  _FakeAttriaxReferrer(this._sdk);

  final FakeAttriax _sdk;

  @override
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) async => _sdk.originalInstallReferrerResult;

  @override
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) async => _sdk.reinstallReferrerResult;
}

class FakePushTokenService implements ExamplePushTokenService {
  FakePushTokenService(this._snapshot);

  final ExamplePushTokenSnapshot _snapshot;
  final StreamController<ExamplePushTokenSnapshot> _controller =
      StreamController<ExamplePushTokenSnapshot>.broadcast();

  int refreshCalls = 0;
  bool lastRequestPermission = false;

  @override
  ExamplePushTokenSnapshot get snapshot => _snapshot;

  @override
  Stream<ExamplePushTokenSnapshot> get snapshots => _controller.stream;

  @override
  Future<void> refresh({bool requestPermission = false}) async {
    refreshCalls += 1;
    lastRequestPermission = requestPermission;
    _controller.add(_snapshot);
  }

  @override
  Future<void> dispose() async {
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}

class FakePlatformBridge implements ExamplePlatformBridge {
  FakePlatformBridge(this.status);

  ExampleAppLinkDomainStatus status;
  bool didOpenSettings = false;
  bool didTriggerNativeCrash = false;

  @override
  Future<ExampleAppLinkDomainStatus> getAppLinkStatus({
    required String host,
  }) async => status;

  @override
  Future<bool> openAppLinkSettings() async {
    didOpenSettings = true;
    return true;
  }

  @override
  Future<bool> triggerNativeCrash() async {
    didTriggerNativeCrash = true;
    return true;
  }
}
