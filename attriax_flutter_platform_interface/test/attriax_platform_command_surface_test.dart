import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake platform that overrides nothing, so it exercises the abstract
/// [AttriaxPlatform] default implementations.
class _BareFakeAttriax extends AttriaxPlatform {}

/// A fake platform that records the engine commands the facade will forward.
class _RecordingFakeAttriax extends AttriaxPlatform {
  final List<String> calls = <String>[];
  AttriaxConfig? initializedWith;
  String? lastEventName;
  Map<String, Object?>? lastEventData;
  bool? lastFlushImmediately;

  final _syncController =
      StreamController<AttriaxSynchronizationState>.broadcast();

  @override
  Future<void> initialize(AttriaxConfig config) async {
    calls.add('initialize');
    initializedWith = config;
  }

  @override
  Future<void> recordEvent(
    String name, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) async {
    calls.add('recordEvent');
    lastEventName = name;
    lastEventData = eventData;
    lastFlushImmediately = flushImmediately;
  }

  @override
  Future<String?> getDeviceId() async => 'device-123';

  @override
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _syncController.stream;

  void emitSyncState(AttriaxSynchronizationState state) =>
      _syncController.add(state);

  Future<void> close() => _syncController.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxPlatform default implementations', () {
    final platform = _BareFakeAttriax();

    test('engine commands throw UnimplementedError by default', () {
      expect(
        () => platform.initialize(
          const AttriaxConfig(projectToken: 'ax_token'),
        ),
        throwsUnimplementedError,
      );
      expect(() => platform.recordEvent('tap'), throwsUnimplementedError);
      expect(
        () => platform.recordPurchase(revenue: 9.99),
        throwsUnimplementedError,
      );
      expect(
        () => platform.setGdprConsent(
          analytics: true,
          attribution: true,
          adEvents: true,
        ),
        throwsUnimplementedError,
      );
      expect(platform.flush, throwsUnimplementedError);
      expect(platform.reset, throwsUnimplementedError);
      expect(platform.dispose, throwsUnimplementedError);
      expect(platform.getDeviceId, throwsUnimplementedError);
      expect(platform.getSynchronizationState, throwsUnimplementedError);
    });

    test('event streams default to an empty stream', () async {
      expect(await platform.synchronizationStates.isEmpty, isTrue);
      expect(await platform.deepLinkEvents.isEmpty, isTrue);
      expect(await platform.rawDeepLinkEvents.isEmpty, isTrue);
      expect(await platform.initialDeepLinkResolutions.isEmpty, isTrue);
    });

    test('retained legacy signal methods keep their benign defaults', () async {
      final context = await platform.collectInstallReferrer();
      expect(context.installReferrer, isNull);
      expect(await platform.readAttributionClipboard(), isNull);
      expect(await platform.consumePendingCrashReport(), isNull);
      expect(
        await platform.getTrackingAuthorizationStatus(),
        AttriaxTrackingAuthorizationStatus.notSupported,
      );
    });
  });

  group('AttriaxPlatform.instance', () {
    test('a verified fake can be installed and drives commands', () async {
      final fake = _RecordingFakeAttriax();
      addTearDown(fake.close);

      AttriaxPlatform.instance = fake;
      expect(AttriaxPlatform.instance, same(fake));

      await AttriaxPlatform.instance.initialize(
        const AttriaxConfig(projectToken: 'ax_instance'),
      );
      await AttriaxPlatform.instance.recordEvent(
        'checkout',
        eventData: <String, Object?>{'value': 12},
        flushImmediately: true,
      );

      expect(fake.calls, <String>['initialize', 'recordEvent']);
      expect(fake.initializedWith?.projectToken, 'ax_instance');
      expect(fake.lastEventName, 'checkout');
      expect(fake.lastEventData, <String, Object?>{'value': 12});
      expect(fake.lastFlushImmediately, isTrue);
      expect(await AttriaxPlatform.instance.getDeviceId(), 'device-123');
    });

    test('a fake stream surfaces engine events to a listener', () async {
      final fake = _RecordingFakeAttriax();
      addTearDown(fake.close);

      final received = <AttriaxSynchronizationState>[];
      final subscription = fake.synchronizationStates.listen(received.add);
      addTearDown(subscription.cancel);

      fake
        ..emitSyncState(AttriaxSynchronizationState.synchronizing)
        ..emitSyncState(AttriaxSynchronizationState.synchronized);
      await Future<void>.delayed(Duration.zero);

      expect(received, <AttriaxSynchronizationState>[
        AttriaxSynchronizationState.synchronizing,
        AttriaxSynchronizationState.synchronized,
      ]);
    });
  });
}
