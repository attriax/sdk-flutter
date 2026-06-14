import 'package:flutter/widgets.dart';

import 'attriax.dart';

typedef AttriaxRouteNameResolver = String? Function(Route<dynamic>? route);
typedef AttriaxPageMetadataBuilder =
    Map<String, Object?>? Function(Route<dynamic>? route);

/// Navigator observer that turns page transitions into `page_view` events.
class AttriaxNavigationObserver extends NavigatorObserver {
  AttriaxNavigationObserver({
    required Attriax attriax,
    AttriaxRouteNameResolver? routeNameResolver,
    AttriaxPageMetadataBuilder? metadataBuilder,
    this.source = 'navigator_observer',
  }) : _attriax = attriax,
       _routeNameResolver = routeNameResolver,
       _metadataBuilder = metadataBuilder;

  final Attriax _attriax;
  final AttriaxRouteNameResolver? _routeNameResolver;
  final AttriaxPageMetadataBuilder? _metadataBuilder;
  final String source;

  String? _lastTrackedPageName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackVisibleRoute(route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackVisibleRoute(previousRoute, route);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _trackVisibleRoute(newRoute, oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  String? resolveRouteName(Route<dynamic>? route) {
    final resolved = _routeNameResolver?.call(route)?.trim();
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }

    final settingsName = route?.settings.name?.trim();
    if (settingsName != null && settingsName.isNotEmpty) {
      return settingsName;
    }

    return null;
  }

  void _trackVisibleRoute(
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    if (route is! PageRoute<dynamic>) {
      return;
    }

    final currentPageName = resolveRouteName(route);
    if (currentPageName == null || currentPageName == _lastTrackedPageName) {
      return;
    }

    _lastTrackedPageName = currentPageName;

    try {
      _attriax.tracking.recordPageView(
        currentPageName,
        pageClass: route.runtimeType.toString(),
        previousPageName: resolveRouteName(previousRoute),
        parameters: _metadataBuilder?.call(route),
        source: source,
      );
    } catch (_) {}
  }
}
