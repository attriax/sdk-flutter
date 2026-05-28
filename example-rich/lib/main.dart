import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

import 'example_app/example_app_formatters.dart';
import 'example_app/example_app_shell.dart';
import 'example_app_configuration.dart';

export 'example_app/example_app_shell.dart' show AttriaxPackageExampleApp;

final Attriax _exampleSdk = Attriax(
  config: AttriaxConfig(
    projectToken: exampleProjectToken,
    gdprEnabled: true,
    gdprAutoDetect: true,
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(_ExampleBootstrapApp(sdk: _exampleSdk));
}

class _ExampleBootstrapApp extends StatefulWidget {
  const _ExampleBootstrapApp({required this.sdk});

  final Attriax sdk;

  @override
  State<_ExampleBootstrapApp> createState() => _ExampleBootstrapAppState();
}

class _ExampleBootstrapAppState extends State<_ExampleBootstrapApp> {
  bool _isReady = false;
  String? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    String? bootstrapError;
    if (!isExampleProjectConfigured) {
      bootstrapError =
          'Set a real Attriax project token in lib/example_app_configuration.dart before running this example.';
    } else {
      try {
        await widget.sdk.init();
      } catch (error) {
        bootstrapError = 'Attriax init failed: ${formatExampleError(error)}';
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _bootstrapError = bootstrapError;
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D6E5E),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F8F7),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFFF4F8F7), Color(0xFFE8F2EF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  SizedBox(height: 16),
                  Text('Starting Attriax example...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AttriaxPackageExampleApp(
      sdk: widget.sdk,
      ownsSdk: true,
      bootstrapError: _bootstrapError,
    );
  }
}
