import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:attriax_flutter_windows/attriax_flutter_windows.dart';
import 'package:flutter/material.dart';

/// Points the example at the local dev API stack. The KMP core C-ABI engine
/// receives this config (serialized to JSON) through `attriax_create`.
const AttriaxConfig _config = AttriaxConfig(
  projectToken: 'ax_4961d1f22e274281919b1b021ec2eb48',
  apiBaseUrl: 'http://localhost:33000',
  appVersion: '1.0.0',
  appBuildNumber: '1',
  appPackageName: 'com.attriax.example.windows',
  enableDebugLogs: true,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AttriaxWindows _platform = AttriaxWindows();

  String _status = 'Initializing...';
  String _deviceId = '(pending)';
  String _sync = '(pending)';
  int _events = 0;
  StreamSubscription<AttriaxSynchronizationState>? _syncSub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // Loads attriax_core.dll, builds the engine from _config, wires the event
      // callback, and drives the engine's `init` (→ POST /api/sdk/v1/open).
      await _platform.initialize(_config);

      _syncSub = _platform.synchronizationStates.listen((state) {
        if (mounted) {
          setState(() => _sync = state.name);
        }
      });

      // → POST /api/sdk/v1/events  (session open also fires /sessions).
      await _platform.recordEvent(
        'windows_example_open',
        eventData: <String, Object?>{'source': 'ffi_example'},
        flushImmediately: true,
      );
      await _platform.recordPageView('home');
      _events += 2;

      final deviceId = await _platform.getDeviceId();
      final sync = await _platform.getSynchronizationState();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = 'Initialized';
        _deviceId = deviceId ?? '(none)';
        _sync = sync.name;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _status = 'Init failed: $error');
      }
    }
  }

  Future<void> _sendEvent() async {
    await _platform.recordEvent(
      'windows_button_tap',
      eventData: <String, Object?>{'count': _events + 1},
      flushImmediately: true,
    );
    if (mounted) {
      setState(() => _events += 1);
    }
  }

  @override
  void dispose() {
    unawaited(_syncSub?.cancel());
    unawaited(_platform.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Attriax Windows Example')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Status: $_status'),
              Text('Device id: $_deviceId'),
              Text('Synchronization: $_sync'),
              Text('Events sent: $_events'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendEvent,
                child: const Text('Send test event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
