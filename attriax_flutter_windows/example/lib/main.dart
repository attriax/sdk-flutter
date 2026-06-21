import 'package:attriax_flutter_windows/attriax_flutter_windows.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _nativeContextSource = 'Loading...';
  String _installReferrerStatus = 'Loading...';
  final AttriaxWindows _platform = AttriaxWindows();

  @override
  void initState() {
    super.initState();
    _loadPlatformState();
  }

  Future<void> _loadPlatformState() async {
    final nativeContext = await _platform.collectNativeContext();
    final installReferrer = await _platform.collectInstallReferrer();

    if (!mounted) {
      return;
    }

    setState(() {
      _nativeContextSource = '${nativeContext.metadata['source'] ?? 'unknown'}';
      _installReferrerStatus =
          '${installReferrer.metadata['installReferrerStatus'] ?? 'unknown'}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Attriax Windows Example')),
        body: Center(
          child: Text(
            'Native context source: $_nativeContextSource\n'
            'Install referrer status: $_installReferrerStatus\n',
          ),
        ),
      ),
    );
  }
}
