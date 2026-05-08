import 'dart:async';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:attriax_flutter_example/example_app_configuration.dart';
import 'package:attriax_flutter_example/example_attriax_sdk.dart';
import 'package:attriax_flutter_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const configuredExampleAppToken = 'ax_live_demo_token';

void main() {
  late FakeExampleAttriaxSdk sdk;

  test('detects whether the example app token is configured', () {
    expect(isExampleAppConfigured(appToken: 'ax_your_app_token'), isFalse);
    expect(isExampleAppConfigured(appToken: configuredExampleAppToken), isTrue);

    expect(
      () => ensureExampleAppConfigured(appToken: 'ax_your_app_token'),
      throwsA(isA<StateError>()),
    );
    expect(
      () => ensureExampleAppConfigured(appToken: configuredExampleAppToken),
      returnsNormally,
    );
  });

  setUp(() {
    sdk = FakeExampleAttriaxSdk();
  });

  tearDown(() async {
    await sdk.dispose();
  });

  testWidgets('shows the setup screen when no SDK is configured', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const AttriaxPackageExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Attriax Example Setup'), findsOneWidget);
    expect(find.text('Save configuration and initialize'), findsOneWidget);
  });

  testWidgets('shows inline validation for an invalid API base URL', (
    tester,
  ) async {
    var applyCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ExampleSetupPage(
          onApplyConfiguration: (_) async {
            applyCalls += 1;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'ax_live_demo_token');
    await tester.enterText(
      find.byType(TextField).at(1),
      'http://api.attriax.com',
    );
    await tester.tap(find.text('Save configuration and initialize'));
    await tester.pumpAndSettle();

    expect(
      find.text('API base URL must use HTTPS unless it targets localhost.'),
      findsOneWidget,
    );
    expect(applyCalls, 0);
  });

  testWidgets(
    'shows install-referrer state after loading startup attribution',
    (tester) async {
      sdk.installReferrerResult = const AttriaxInstallReferrerDetails(
        attributionType: AttributionType.referrer,
        precision: 1,
        campaign: 'spring-launch',
      );

      await tester.pumpWidget(
        AttriaxPackageExampleApp(
          sdk: sdk,
          initialConfiguration: const ExampleAppConfiguration(
            appToken: configuredExampleAppToken,
          ),
        ),
      );
      await tester.ensureVisible(find.text('Load startup attribution result'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Load startup attribution result'));
      await tester.pumpAndSettle();

      expect(find.text('Startup attribution loaded.'), findsOneWidget);
      expect(
        find.text('Install referrer campaign: spring-launch'),
        findsOneWidget,
      );
    },
  );

  testWidgets('navigates to the promo route when a deep link match arrives', (
    tester,
  ) async {
    await tester.pumpWidget(
      AttriaxPackageExampleApp(
        sdk: sdk,
        initialConfiguration: const ExampleAppConfiguration(
          appToken: configuredExampleAppToken,
        ),
      ),
    );

    final rawEvent = AttriaxRawDeepLinkEvent(
      uri: Uri.parse('https://links.attriax.com/promo/spring-launch'),
      linkPath: 'promo/spring-launch',
      isFirstLaunch: true,
      isInitialLink: true,
      occurredAt: DateTime.utc(2026, 4, 27, 8),
    );
    final resolution = AttriaxDeepLinkResolution(
      deepLink: const AttriaxDeepLink(
        path: 'promo/spring-launch',
        data: <String, Object?>{'campaign': 'spring-launch'},
      ),
      rawEvent: rawEvent,
      isFirstLaunch: true,
      isDeferred: false,
      occurredAt: DateTime.utc(2026, 4, 27, 8, 0, 1),
    );

    sdk.emitDeepLink(
      AttriaxDeepLinkEvent(
        rawEvent: rawEvent,
        resultFuture: Future<AttriaxDeepLinkResult>.value(
          AttriaxDeepLinkResult(rawEvent: rawEvent, resolution: resolution),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Promo Screen'), findsWidgets);
    expect(find.text('Matched path: promo/spring-launch'), findsOneWidget);
    expect(find.text('Navigation source: matched_conversion'), findsOneWidget);
    expect(find.text('campaign: spring-launch'), findsOneWidget);
  });

  testWidgets('shows the setup form with a placeholder initial token', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AttriaxPackageExampleApp(
        initialConfiguration: ExampleAppConfiguration(
          appToken: 'ax_your_app_token',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Attriax Example Setup'), findsOneWidget);
    expect(find.text('Save configuration and initialize'), findsOneWidget);
    expect(find.text('ax_your_app_token'), findsOneWidget);
  });
}

class FakeExampleAttriaxSdk implements ExampleAttriaxSdk {
  final StreamController<AttriaxDeepLinkEvent> _deepLinksController =
      StreamController<AttriaxDeepLinkEvent>.broadcast();
  final StreamController<AttriaxSynchronizationState>
  _synchronizationController =
      StreamController<AttriaxSynchronizationState>.broadcast();

  bool _enabled = true;
  bool _eventsEnabled = true;
  final AttriaxSynchronizationState _synchronizationState =
      AttriaxSynchronizationState.synchronized;

  AttriaxInstallReferrerDetails? installReferrerResult;
  AttriaxDeepLinkResult? initialDeepLinkResult;
  @override
  late final AttriaxDeepLinks deepLinks = _FakeAttriaxDeepLinks(this);

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
  AttriaxSynchronizationState get synchronizationState => _synchronizationState;

  @override
  bool get isSynchronized =>
      _synchronizationState == AttriaxSynchronizationState.synchronized;

  @override
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _synchronizationController.stream;

  @override
  Future<AttriaxInstallReferrerDetails?> get installReferrer async =>
      installReferrerResult;

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await _deepLinksController.close();
    await _synchronizationController.close();
  }

  @override
  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
  }) async {}

  @override
  Future<void> setUser(String? userId, {String? userName}) async {}

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
  }) async => const AttriaxCreateDynamicLinkResult(
    link: AttriaxDynamicLinkRecord(
      id: 'link_123',
      path: 'promo/example',
      shortUrl: 'https://ax.example/link_123',
    ),
  );

  @override
  Future<AttriaxDeepLinkResolution?> recordDeepLink({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async => null;

  @override
  List<NavigatorObserver> buildNavigatorObservers() =>
      const <NavigatorObserver>[];

  void emitDeepLink(AttriaxDeepLinkEvent event) {
    _deepLinksController.add(event);
  }
}

class _FakeAttriaxDeepLinks implements AttriaxDeepLinks {
  _FakeAttriaxDeepLinks(this._sdk);

  final FakeExampleAttriaxSdk _sdk;

  @override
  AttriaxDeepLinkResult? get initialDeepLink => _sdk.initialDeepLinkResult;

  @override
  bool get initialDeepLinkResolved => true;

  @override
  AttriaxDeepLinkResult? get latestDeepLink => null;

  @override
  Stream<AttriaxDeepLinkEvent> get stream => _sdk._deepLinksController.stream;

  @override
  Future<AttriaxDeepLinkResult?> waitForInitialDeepLink() =>
      Future<AttriaxDeepLinkResult?>.value(_sdk.initialDeepLinkResult);
}
