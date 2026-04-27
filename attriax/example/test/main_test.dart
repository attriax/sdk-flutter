import 'dart:async';

import 'package:attriax/attriax.dart';
import 'package:attriax_example/example_attriax_sdk.dart';
import 'package:attriax_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeExampleAttriaxSdk sdk;

  setUp(() {
    sdk = FakeExampleAttriaxSdk();
  });

  tearDown(() async {
    await sdk.dispose();
  });

  testWidgets('shows the app-open result after waiting for tracking', (
    tester,
  ) async {
    sdk.appOpenResult = const AttriaxAppOpenResult(
      userId: 'user_123',
      isNewUser: true,
      isFirstLaunch: true,
      attributionType: AttributionType.organic,
    );

    await tester.pumpWidget(AttriaxPackageExampleApp(sdk: sdk));
    await tester.ensureVisible(find.text('Wait for app open tracking result'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wait for app open tracking result'));
    await tester.pumpAndSettle();

    expect(find.text('App open tracked: organic'), findsOneWidget);
    expect(find.text('Attribution type: organic'), findsOneWidget);
    expect(find.text('New user: true'), findsOneWidget);
  });

  testWidgets('navigates to the promo route when a deep link match arrives', (
    tester,
  ) async {
    await tester.pumpWidget(AttriaxPackageExampleApp(sdk: sdk));

    final rawEvent = AttriaxRawDeepLinkEvent(
      uri: Uri.parse('https://links.attriax.com/promo/spring-launch'),
      linkPath: 'promo/spring-launch',
      isFirstLaunch: true,
      isInitialLink: true,
      occurredAt: DateTime.utc(2026, 4, 27, 8),
    );
    final conversion = AttriaxDeepLinkConversionEvent(
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
          AttriaxDeepLinkResult(rawEvent: rawEvent, conversion: conversion),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Promo Screen'), findsWidgets);
    expect(find.text('Matched path: promo/spring-launch'), findsOneWidget);
    expect(find.text('Navigation source: matched_conversion'), findsOneWidget);
    expect(find.text('campaign: spring-launch'), findsOneWidget);
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

  AttriaxAppOpenResult? appOpenResult;

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
  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinksController.stream;

  @override
  Future<void> init() async {}

  @override
  Future<AttriaxAppOpenResult?> waitForAppOpenTracking() async => appOpenResult;

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    String? linkId,
  }) async {}

  @override
  Future<void> identify(
    String externalUserId, {
    String? externalUserName,
  }) async {}

  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    bool? iosRedirect,
    bool? androidRedirect,
    String? previewTitle,
    String? previewDescription,
    String? previewImagePath,
    Map<String, Object?>? data,
  }) async => const AttriaxCreateDynamicLinkResult(
    link: AttriaxDynamicLinkRecord(
      id: 'link_123',
      path: 'promo/example',
      shortUrl: 'https://ax.example/link_123',
    ),
  );

  @override
  Future<AttriaxDeepLinkConversionEvent?> recordDeepLinkConversion({
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

  Future<void> dispose() async {
    await _deepLinksController.close();
    await _synchronizationController.close();
  }
}
