import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:attriax_flutter_linux/attriax_flutter_linux.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests exercise the wrapper contract that does NOT require the native
/// `libattriax_core.so` (which is bundled next to the built executable, not
/// available under `flutter test`): before `initialize` every command must
/// degrade to the same benign default the other bindings return rather than
/// throwing into app code.
void main() {
  late AttriaxLinux platform;

  setUp(() {
    platform = AttriaxLinux();
  });

  test('collectNativeContext returns an empty benign context', () async {
    final context = await platform.collectNativeContext();
    expect(context.metadata, isEmpty);
  });

  test('fire-and-forget commands are no-ops before initialize', () async {
    // Must complete without throwing even though there is no engine handle.
    await platform.recordEvent('before_init');
    await platform.setGdprConsentNotRequired();
    await platform.setEventTrackingEnabled(enabled: false);
  });

  test('reads fall back to benign defaults before initialize', () async {
    expect(await platform.getDeviceId(), isNull);
    expect(await platform.getIsInitialized(), isFalse);
    expect(await platform.getEventTrackingEnabled(), isTrue);
    expect(
      await platform.getSynchronizationState(),
      AttriaxSynchronizationState.initializing,
    );
    expect(await platform.getLatestDeepLink(), isNull);
  });

  test('createDynamicLink surfaces its unsupported state', () async {
    expect(
      () => platform.createDynamicLink(destinationUrl: 'https://x.test'),
      throwsA(isA<StateError>()),
    );
  });
}
