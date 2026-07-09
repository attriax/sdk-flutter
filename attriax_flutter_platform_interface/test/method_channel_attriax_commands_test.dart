import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('attriax');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger
      ..setMockMethodCallHandler(channel, null)
      ..setMockStreamHandler(
        const EventChannel(attriaxSynchronizationEventChannelName),
        null,
      )
      ..setMockStreamHandler(
        const EventChannel(attriaxDeepLinkEventChannelName),
        null,
      );
  });

  MethodCall? capturedCall;
  void handle(Future<Object?> Function(MethodCall call) responder) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      capturedCall = call;
      return responder(call);
    });
  }

  test('initialize serializes the config over the channel', () async {
    handle((_) async => null);

    await MethodChannelAttriax().initialize(
      const AttriaxConfig(projectToken: 'ax_test', gdprEnabled: true),
    );

    expect(capturedCall!.method, 'initialize');
    final config = (capturedCall!.arguments
        as Map)['config'] as Map<Object?, Object?>;
    expect(config['projectToken'], 'ax_test');
    expect(config['gdprEnabled'], true);
    expect(config['requestTimeoutMs'], isA<int>());
  });

  test('recordEvent forwards name, data, and flush flag', () async {
    handle((_) async => null);

    await MethodChannelAttriax().recordEvent(
      'checkout',
      eventData: <String, Object?>{'value': 10},
      flushImmediately: true,
    );

    expect(capturedCall!.method, 'recordEvent');
    expect(capturedCall!.arguments, <String, Object?>{
      'name': 'checkout',
      'eventData': <String, Object?>{'value': 10},
      'flushImmediately': true,
    });
  });

  test('recordPurchase forwards revenue and currency', () async {
    handle((_) async => null);

    await MethodChannelAttriax().recordPurchase(
      revenue: 4.99,
      currency: 'EUR',
      productId: 'pro_monthly',
    );

    expect(capturedCall!.method, 'recordPurchase');
    final args = capturedCall!.arguments as Map;
    expect(args['revenue'], 4.99);
    expect(args['currency'], 'EUR');
    expect(args['productId'], 'pro_monthly');
    expect(args['flushImmediately'], true);
  });

  test('recordNotification forwards wire type and source', () async {
    handle((_) async => null);

    await MethodChannelAttriax().recordNotification(
      type: 'opened',
      notificationId: 'n-1',
      source: 'fcm',
    );

    expect(capturedCall!.method, 'recordNotification');
    final args = capturedCall!.arguments as Map;
    expect(args['type'], 'opened');
    expect(args['notificationId'], 'n-1');
    expect(args['source'], 'fcm');
  });

  test('registerPushToken maps the provider to its wire slug', () async {
    handle((_) async => null);

    await MethodChannelAttriax().registerPushToken(
      provider: AttriaxPushTokenProvider.apns,
      token: 'apns-token',
    );

    expect(capturedCall!.method, 'registerPushToken');
    final args = capturedCall!.arguments as Map;
    expect(args['provider'], 'apns');
    expect(args['token'], 'apns-token');
  });

  test('setGdprConsent forwards category values', () async {
    handle((_) async => null);

    await MethodChannelAttriax().setGdprConsent(
      analytics: true,
      attribution: false,
      adEvents: true,
    );

    expect(capturedCall!.method, 'setGdprConsent');
    expect(capturedCall!.arguments, <String, Object?>{
      'analytics': true,
      'attribution': false,
      'adEvents': true,
    });
  });

  test('setAnonymousTracking forwards the enabled flag', () async {
    handle((_) async => null);

    await MethodChannelAttriax().setAnonymousTracking(enabled: false);

    expect(capturedCall!.method, 'setAnonymousTracking');
    expect(capturedCall!.arguments, <String, Object?>{'enabled': false});
  });

  test('validateReceipt parses the returned result', () async {
    handle(
      (_) async => <String, Object?>{
        'validationId': 'val-1',
        'status': 'verified',
        'provider': 'app_store',
        'publicReceipt': <String, Object?>{'productId': 'pro'},
      },
    );

    final result = await MethodChannelAttriax().validateReceipt(
      receipt: 'base64-receipt',
    );

    expect(capturedCall!.method, 'validateReceipt');
    expect((capturedCall!.arguments as Map)['receipt'], 'base64-receipt');
    expect(result.validationId, 'val-1');
    expect(result.status, AttriaxRevenueReceiptValidationStatus.verified);
    expect(result.provider, 'app_store');
  });

  test('recordDeepLink parses the resolved event', () async {
    handle(
      (_) async => <String, Object?>{
        'uri': 'https://demo.attriax.com/promo',
        'clickedAt': '2026-05-04T10:00:00.000Z',
        'consumedAt': '2026-05-04T10:00:01.000Z',
        'found': true,
        'trigger': 'foreground',
        'isAttriaxSubDomain': true,
      },
    );

    final event = await MethodChannelAttriax().recordDeepLink(
      uri: Uri.parse('https://demo.attriax.com/promo'),
    );

    expect(capturedCall!.method, 'recordDeepLink');
    expect(event, isNotNull);
    expect(event!.found, isTrue);
    expect(event.trigger, AttriaxDeepLinkTrigger.foreground);
  });

  test('getDeviceId returns the resolved identifier', () async {
    handle((_) async => 'device-abc');

    final deviceId = await MethodChannelAttriax().getDeviceId();

    expect(capturedCall!.method, 'getDeviceId');
    expect(deviceId, 'device-abc');
  });

  test('getSynchronizationState parses the wire value', () async {
    handle((_) async => 'synchronized');

    final state = await MethodChannelAttriax().getSynchronizationState();

    expect(capturedCall!.method, 'getSynchronizationState');
    expect(state, AttriaxSynchronizationState.synchronized);
  });

  test('getSkanState returns null when the engine has none', () async {
    handle((_) async => null);

    expect(await MethodChannelAttriax().getSkanState(), isNull);
  });

  test('fire-and-forget commands swallow a missing plugin', () async {
    // No handler registered → MissingPluginException is caught internally.
    await expectLater(MethodChannelAttriax().recordEvent('tap'), completes);
    await expectLater(MethodChannelAttriax().flush(), completes);
  });

  test('synchronizationStates surfaces engine transitions', () async {
    messenger.setMockStreamHandler(
      const EventChannel(attriaxSynchronizationEventChannelName),
      MockStreamHandler.inline(
        onListen: (arguments, sink) {
          sink
            ..success('synchronizing')
            ..success('synchronized')
            ..endOfStream();
        },
      ),
    );

    final states = await MethodChannelAttriax().synchronizationStates.toList();

    expect(states, <AttriaxSynchronizationState>[
      AttriaxSynchronizationState.synchronizing,
      AttriaxSynchronizationState.synchronized,
    ]);
  });

  test('deepLinkEvents decodes resolved events from the channel', () async {
    messenger.setMockStreamHandler(
      const EventChannel(attriaxDeepLinkEventChannelName),
      MockStreamHandler.inline(
        onListen: (arguments, sink) {
          sink
            ..success(<String, Object?>{
              'uri': 'https://demo.attriax.com/a',
              'clickedAt': '2026-05-04T10:00:00.000Z',
              'consumedAt': '2026-05-04T10:00:01.000Z',
              'found': true,
              'trigger': 'coldStart',
              'isAttriaxSubDomain': true,
            })
            ..endOfStream();
        },
      ),
    );

    final events = await MethodChannelAttriax().deepLinkEvents.toList();

    expect(events, hasLength(1));
    expect(events.single.trigger, AttriaxDeepLinkTrigger.coldStart);
    expect(events.single.uri.path, '/a');
  });
}
