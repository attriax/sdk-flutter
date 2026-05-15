import 'dart:async';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/material.dart';

import '../example_platform_bridge.dart';
import '../example_push_tokens.dart';
import 'example_app_controller.dart';
import 'example_bootstrap_error_page.dart';
import 'example_controls_page.dart';
import 'example_deep_link_result_page.dart';
import 'example_deep_links_page.dart';
import 'example_events_page.dart';
import 'example_game_page.dart';
import 'example_home_page.dart';
import 'example_push_tokens_page.dart';
import 'example_recent_activity_page.dart';

final GlobalKey<NavigatorState> _exampleNavigatorKey =
    GlobalKey<NavigatorState>();

class AttriaxPackageExampleApp extends StatefulWidget {
  const AttriaxPackageExampleApp({
    super.key,
    required this.sdk,
    this.ownsSdk = false,
    this.bootstrapError,
    this.pushTokenService,
    this.platformBridge,
  });

  final Attriax sdk;
  final bool ownsSdk;
  final String? bootstrapError;
  final ExamplePushTokenService? pushTokenService;
  final ExamplePlatformBridge? platformBridge;

  @override
  State<AttriaxPackageExampleApp> createState() =>
      _AttriaxPackageExampleAppState();
}

class _AttriaxPackageExampleAppState extends State<AttriaxPackageExampleApp> {
  late final ExampleAppController _controller = ExampleAppController(
    sdk: widget.sdk,
    pushTokenService: widget.pushTokenService,
    platformBridge: widget.platformBridge,
  );

  @override
  void initState() {
    super.initState();
    _controller.onDeepLinkNavigation = _openDeepLinkResult;
    if (widget.bootstrapError == null) {
      unawaited(_controller.start());
    }
  }

  @override
  void dispose() {
    unawaited(_controller.disposeController());
    if (widget.ownsSdk) {
      unawaited(widget.sdk.dispose());
    }
    super.dispose();
  }

  void _openDeepLinkResult(AttriaxRawDeepLinkEvent event) {
    _exampleNavigatorKey.currentState?.pushNamed(
      ExampleDeepLinkResultPage.routeName,
      arguments: event,
    );
  }

  Route<void> _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case ExampleDeepLinksPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExampleDeepLinksPage(controller: _controller),
          settings: settings,
        );
      case ExamplePushTokensPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExamplePushTokensPage(controller: _controller),
          settings: settings,
        );
      case ExampleEventsPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExampleEventsPage(controller: _controller),
          settings: settings,
        );
      case ExampleControlsPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExampleControlsPage(controller: _controller),
          settings: settings,
        );
      case ExampleGamePage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExampleGamePage(controller: _controller),
          settings: settings,
        );
      case ExamplePulseSprintPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExamplePulseSprintPage(controller: _controller),
          settings: settings,
        );
      case ExampleBeatBridgePage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExampleBeatBridgePage(controller: _controller),
          settings: settings,
        );
      case ExampleLaneDashPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExampleLaneDashPage(controller: _controller),
          settings: settings,
        );
      case ExampleRecentActivityPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ExampleRecentActivityPage(controller: _controller),
          settings: settings,
        );
      case ExampleDeepLinkResultPage.routeName:
        final event = settings.arguments as AttriaxRawDeepLinkEvent;
        return MaterialPageRoute<void>(
          builder: (_) =>
              ExampleDeepLinkResultPage(sdk: widget.sdk, rawEvent: event),
          settings: settings,
        );
      case '/':
      default:
        return MaterialPageRoute<void>(
          builder: (_) => ExampleHomePage(controller: _controller),
          settings: settings,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attriax Flutter Example',
      navigatorKey: _exampleNavigatorKey,
      navigatorObservers: <NavigatorObserver>[
        AttriaxNavigationObserver(attriax: widget.sdk),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6E5E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F8F7),
        useMaterial3: true,
      ),
      onGenerateRoute: _buildRoute,
      home: widget.bootstrapError == null
          ? ExampleHomePage(controller: _controller)
          : ExampleBootstrapErrorPage(errorText: widget.bootstrapError!),
    );
  }
}
