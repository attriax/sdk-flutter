import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'AttriaxConfig defaults to 60-second batching and session heartbeats',
    () {
      const config = AttriaxConfig(appToken: 'ax_test_token');

      expect(config.eventFlushInterval, const Duration(seconds: 60));
      expect(config.sessionHeartbeatInterval, const Duration(seconds: 60));
      expect(
        config.firstLaunchSessionHeartbeatInterval,
        const Duration(seconds: 5),
      );
      expect(config.skan, isNull);
    },
  );

  test('AttriaxConfig keeps the optional SKAN configuration', () {
    const config = AttriaxConfig(
      appToken: 'ax_test_token',
      skan: AttriaxSkanConfig(
        enabled: true,
        mode: AttriaxSkanMode.manual,
        template: AttriaxSkanTemplate.subscription,
        lockWindowEnabled: true,
        registerFirstLaunchValue: false,
      ),
    );

    expect(config.skan, isNotNull);
    expect(config.skan?.mode, AttriaxSkanMode.manual);
    expect(config.skan?.template, AttriaxSkanTemplate.subscription);
    expect(config.skan?.lockWindowEnabled, isTrue);
    expect(config.skan?.registerFirstLaunchValue, isFalse);
  });
}
