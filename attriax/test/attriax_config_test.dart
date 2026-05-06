import 'package:attriax_platform_interface/attriax_platform_interface.dart';
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
    },
  );
}
