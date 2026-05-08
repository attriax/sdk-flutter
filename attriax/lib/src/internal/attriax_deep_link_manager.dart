import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

import 'attriax_api_models.dart';
import 'attriax_context_manager.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_deep_link_resolver.dart';
import 'attriax_event_hub.dart';
import 'attriax_logger.dart';
import 'attriax_request_manager.dart';

/// Owns deep-link listener lifecycle, stream state, and manual/deferred link
/// emission for the runtime.
class AttriaxDeepLinkManager {
  AttriaxDeepLinkManager({
    required AttriaxConfig config,
    required AttriaxContextManager contextManager,
    required AttriaxDeepLinkListener listener,
    required AttriaxEventHub eventHub,
    required AttriaxRequestManager requestManager,
    required AttriaxLogger logger,
    AttriaxDeepLinkResolver resolver = const AttriaxDeepLinkResolver(),
    AttriaxClock? clock,
  }) : _config = config,
       _contextManager = contextManager,
       _listener = listener,
       _eventHub = eventHub,
       _requestManager = requestManager,
       _logger = logger,
       _resolver = resolver,
       _clock = clock ?? const AttriaxSystemClock();

  final AttriaxConfig _config;
  final AttriaxContextManager _contextManager;
  final AttriaxDeepLinkListener _listener;
  final AttriaxEventHub _eventHub;
  final AttriaxRequestManager _requestManager;
  final AttriaxLogger _logger;
  final AttriaxDeepLinkResolver _resolver;
  final AttriaxClock _clock;

  Stream<AttriaxDeepLinkEvent> get stream => _eventHub.deepLinks;
  AttriaxDeepLinkResult? get initialDeepLink => _eventHub.initialDeepLinkValue;
  bool get isInitialDeepLinkResolved => _eventHub.isInitialDeepLinkResolved;
  Future<AttriaxDeepLinkResult?> waitForInitialDeepLink() =>
      _eventHub.initialDeepLink;
  AttriaxDeepLinkResult? get latestDeepLink => _eventHub.latestDeepLink;

  Future<void> start() => _listener.start(
    _handleIncomingLink,
    onInitialLinkProbeCompleted: _eventHub.completeInitialDeepLinkIfAbsent,
  );

  Future<void> stop() => _listener.stop();

  void completeInitialLinkIfAbsent() =>
      _eventHub.completeInitialDeepLinkIfAbsent();

  Future<AttriaxDeepLinkResolution?> recordManualConversion({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    if (uri == null && (linkPath == null || linkPath.trim().isEmpty)) {
      throw ArgumentError('Either uri or linkPath must be provided.');
    }

    final normalizedLinkPath = _resolver.normalizeLinkPath(linkPath);
    final effectiveUri =
        uri ??
        Uri(path: normalizedLinkPath == null ? '/' : '/$normalizedLinkPath');
    final rawEvent = AttriaxRawDeepLinkEvent(
      uri: effectiveUri,
      linkPath:
          _resolver.extractLinkPathFromUri(effectiveUri) ?? normalizedLinkPath,
      isFirstLaunch: _contextManager.isFirstLaunch,
      isInitialLink: false,
      occurredAt: _clock.now(),
    );
    final completer = Completer<AttriaxDeepLinkResolution?>();

    await _requestManager.enqueue(
      attriaxBuildResolveDeepLinkRequest(
        appToken: _config.appToken,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _contextManager.requireDeviceIdSource(),
        platform: _contextManager.requiredSnapshot.platform,
        source: source,
        isFirstLaunch: _contextManager.isFirstLaunch,
        rawUrl: uri?.toString(),
        linkPath: normalizedLinkPath,
        metadata: metadata,
      ),
      onSuccess: (response) {
        if (response is! AttriaxResolveDeepLinkApiResponse) {
          _logger.error('Unexpected response type for deep-link resolution.');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          return;
        }

        final event = _resolver.buildResolution(
          response.result,
          rawEvent: rawEvent,
          isDeferred: false,
        );
        if (!completer.isCompleted) {
          completer.complete(event);
        }
      },
      onError: (error, stackTrace) {
        _logger.error(
          'Manual deep-link resolution failed.',
          error: error,
          stackTrace: stackTrace,
        );
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );

    return completer.future;
  }

  void handleDeferredAppOpen(AttriaxAppOpenResult? result) {
    final deepLink = result?.deepLink;
    if (deepLink == null) {
      return;
    }

    _eventHub.emitResolvedDeepLink(
      resolution: AttriaxDeepLinkResolution(
        deepLink: deepLink,
        isFirstLaunch: result!.isFirstLaunch,
        isDeferred: true,
        occurredAt: result.acceptedAt ?? _clock.now(),
      ),
    );
  }

  Future<void> _handleIncomingLink(
    Uri uri, {
    required bool isInitialLink,
  }) async {
    final rawEvent = AttriaxRawDeepLinkEvent(
      uri: uri,
      linkPath: _resolver.extractLinkPathFromUri(uri),
      isFirstLaunch: _contextManager.isFirstLaunch,
      isInitialLink: isInitialLink,
      occurredAt: _clock.now(),
    );

    _eventHub.emitPendingDeepLink(rawEvent);
    _logger.verbose(
      'Received deep link ${rawEvent.linkPath ?? rawEvent.uri.toString()}.',
    );

    await _requestManager.enqueue(
      attriaxBuildResolveDeepLinkRequest(
        appToken: _config.appToken,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _contextManager.requireDeviceIdSource(),
        platform: _contextManager.requiredSnapshot.platform,
        source: 'attriax_sdk',
        isFirstLaunch: _contextManager.isFirstLaunch,
        rawUrl: uri.toString(),
        metadata: <String, Object?>{
          'isInitialLink': isInitialLink,
          'queryParameters': uri.queryParametersAll,
        },
      ),
      onSuccess: (response) {
        if (response is! AttriaxResolveDeepLinkApiResponse) {
          _logger.error('Unexpected response type for deep-link resolution.');
          return;
        }

        final resolution = _resolver.buildResolution(
          response.result,
          rawEvent: rawEvent,
          isDeferred: false,
        );
        if (resolution != null) {
          _eventHub.resolvePendingDeepLink(
            rawEvent: rawEvent,
            resolution: resolution,
          );
          return;
        }

        _eventHub.failPendingDeepLink(
          rawEvent: rawEvent,
          failure: _resolver.buildFailure(response.result, rawEvent: rawEvent),
        );
      },
      onError: (error, stackTrace) {
        _logger.error(
          'Deep-link resolution request failed.',
          error: error,
          stackTrace: stackTrace,
        );
        _eventHub.failPendingDeepLink(
          rawEvent: rawEvent,
          failure: AttriaxDeepLinkResolutionFailure(
            reason: error.toString(),
            rawEvent: rawEvent,
            isFirstLaunch: rawEvent.isFirstLaunch,
            occurredAt: _clock.now(),
          ),
        );
      },
    );
  }
}
