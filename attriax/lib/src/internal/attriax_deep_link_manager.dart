import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

import 'attriax_api_models.dart';
import 'attriax_context_manager.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_deep_link_resolver.dart';
import 'attriax_event_hub.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';
import 'attriax_request_manager.dart';

/// Owns deep-link listener lifecycle, stream state, and manual/deferred link
/// emission for the runtime.
class AttriaxDeepLinkManager {
  AttriaxDeepLinkManager({
    required AttriaxConfig config,
    required AttriaxContextManager contextManager,
    required AttriaxDeepLinkListener listener,
    required AttriaxEventHub eventHub,
    required AttriaxPreferencesStore preferencesStore,
    String? Function()? currentSessionIdProvider,
    required AttriaxRequestManager requestManager,
    required AttriaxLogger logger,
    AttriaxDeepLinkResolver resolver = const AttriaxDeepLinkResolver(),
    AttriaxClock? clock,
  }) : _config = config,
       _contextManager = contextManager,
       _listener = listener,
       _eventHub = eventHub,
       _preferencesStore = preferencesStore,
       _currentSessionIdProvider = currentSessionIdProvider ?? _noSessionId,
       _requestManager = requestManager,
       _logger = logger,
       _resolver = resolver,
       _clock = clock ?? const AttriaxSystemClock();

  final AttriaxConfig _config;
  final AttriaxContextManager _contextManager;
  final AttriaxDeepLinkListener _listener;
  final AttriaxEventHub _eventHub;
  final AttriaxPreferencesStore _preferencesStore;
  final String? Function() _currentSessionIdProvider;
  final AttriaxRequestManager _requestManager;
  final AttriaxLogger _logger;
  final AttriaxDeepLinkResolver _resolver;
  final AttriaxClock _clock;

  Stream<AttriaxDeepLinkEvent> get stream => _eventHub.deepLinks;
  AttriaxDeepLinkEvent? get initialDeepLink => _eventHub.initialDeepLinkValue;
  bool get isInitialDeepLinkResolved => _eventHub.isInitialDeepLinkResolved;
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() =>
      _eventHub.initialDeepLink;
  AttriaxDeepLinkEvent? get latestDeepLink => _eventHub.latestDeepLink;

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
    final clickedAt = _clock.now();
    final completer = Completer<AttriaxDeepLinkResolution>();

    await _requestManager.enqueue(
      attriaxBuildResolveDeepLinkRequest(
        appToken: _config.appToken,
        deviceId: _contextManager.requiredDeviceId,
        deviceIdSource: _contextManager.requireDeviceIdSource(),
        platform: _contextManager.requiredSnapshot.platform,
        source: source,
        isFirstLaunch: _contextManager.isFirstLaunch,
        rawUrl: effectiveUri.toString(),
        linkPath: normalizedLinkPath,
        metadata: metadata,
      ),
      onSuccess: (response) {
        if (response is! AttriaxResolveDeepLinkApiResponse) {
          _logger.error('Unexpected response type for deep-link resolution.');
          if (!completer.isCompleted) {
            completer.completeError(
              StateError('Unexpected response type for deep-link resolution.'),
            );
          }
          return;
        }

        final resolution = _resolver.buildResolution(
          response.result,
          clickedAt: clickedAt,
        );
        if (!completer.isCompleted) {
          completer.complete(resolution);
        }
      },
      onError: (error, stackTrace) {
        _logger.error(
          'Manual deep-link resolution failed.',
          error: error,
          stackTrace: stackTrace,
        );
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    return completer.future;
  }

  Future<void> handleDeferredAppOpen(
    AttriaxAppOpenResult? result, {
    String? originSessionId,
  }) async {
    if (result == null ||
        result.installState == AttriaxInstallState.appDataClear) {
      return;
    }

    final deepLink = result.deepLink;
    if (deepLink == null) {
      return;
    }

    if (!_isCurrentSession(originSessionId)) {
      _logger.verbose(
        'Suppressing deferred deep-link event because its originating session is no longer current.',
      );
      return;
    }

    final alreadyHandled = await _preferencesStore
        .readDeferredAppOpenDeepLinkHandled();
    if (alreadyHandled) {
      return;
    }

    _eventHub.emitResolvedDeepLink(
      uri: _resolver.buildDeferredUri(result),
      receivedAt: result.acceptedAt ?? _clock.now(),
      trigger: AttriaxDeepLinkTrigger.deferred,
      resolution: _resolver.buildDeferredResolution(
        result,
        fallbackTime: _clock.now(),
      ),
      isAttriaxDomain: true,
    );

    await _preferencesStore.setDeferredAppOpenDeepLinkHandled(value: true);
  }

  Future<void> _handleIncomingLink(
    Uri uri, {
    required bool isInitialLink,
  }) async {
    final receivedAt = _clock.now();
    final originSessionId = _currentSessionIdProvider();
    final event = _eventHub.stagePendingDeepLink(
      uri: uri,
      receivedAt: receivedAt,
      trigger: isInitialLink
          ? AttriaxDeepLinkTrigger.coldStart
          : AttriaxDeepLinkTrigger.foreground,
      isInitialLink: isInitialLink,
      isAttriaxDomain: _resolver.isAttriaxDomain(uri),
    );
    _logger.verbose(
      'Received deep link ${_resolver.extractLinkPathFromUri(uri) ?? uri.toString()}.',
    );

    try {
      await _requestManager.enqueue(
        attriaxBuildResolveDeepLinkRequest(
          appToken: _config.appToken,
          deviceId: _contextManager.requiredDeviceId,
          deviceIdSource: _contextManager.requireDeviceIdSource(),
          platform: _contextManager.requiredSnapshot.platform,
          source: 'attriax_sdk',
          isFirstLaunch: _contextManager.isFirstLaunch,
          rawUrl: uri.toString(),
          linkPath: _resolver.extractLinkPathFromUri(uri),
          metadata: <String, Object?>{
            'isInitialLink': isInitialLink,
            'queryParameters': uri.queryParametersAll,
          },
        ),
        onSuccess: (response) {
          if (!_isCurrentSession(originSessionId)) {
            _logger.verbose(
              'Suppressing deep-link event because its originating session is no longer current.',
            );
            _eventHub.dropPendingDeepLink(event: event);
            return;
          }

          if (response is! AttriaxResolveDeepLinkApiResponse) {
            _logger.error('Unexpected response type for deep-link resolution.');
            _eventHub.failPendingDeepLink(
              event: event,
              error: StateError(
                'Unexpected response type for deep-link resolution.',
              ),
            );
            _eventHub.publishPendingDeepLink(
              event: event,
              isInitialLink: isInitialLink,
            );
            return;
          }

          final resolution = _resolver.buildResolution(
            response.result,
            clickedAt: receivedAt,
          );
          _eventHub.resolvePendingDeepLink(
            event: event,
            resolution: resolution,
          );
          _eventHub.publishPendingDeepLink(
            event: event,
            isInitialLink: isInitialLink,
          );
        },
        onError: (error, stackTrace) {
          if (!_isCurrentSession(originSessionId)) {
            _logger.verbose(
              'Suppressing deep-link error event because its originating session is no longer current.',
            );
            _eventHub.dropPendingDeepLink(event: event);
            return;
          }

          _logger.error(
            'Deep-link resolution request failed.',
            error: error,
            stackTrace: stackTrace,
          );
          _eventHub.failPendingDeepLink(
            event: event,
            error: error,
            stackTrace: stackTrace,
          );
          _eventHub.publishPendingDeepLink(
            event: event,
            isInitialLink: isInitialLink,
          );
        },
      );
    } catch (error, stackTrace) {
      if (!_isCurrentSession(originSessionId)) {
        _logger.verbose(
          'Suppressing deep-link enqueue error because its originating session is no longer current.',
        );
        _eventHub.dropPendingDeepLink(event: event);
        return;
      }

      _logger.error(
        'Deep-link resolution request could not be queued.',
        error: error,
        stackTrace: stackTrace,
      );
      _eventHub.failPendingDeepLink(
        event: event,
        error: error,
        stackTrace: stackTrace,
      );
      _eventHub.publishPendingDeepLink(
        event: event,
        isInitialLink: isInitialLink,
      );
    }
  }

  bool _isCurrentSession(String? originSessionId) {
    final currentSessionId = _currentSessionIdProvider();
    if (originSessionId == null || currentSessionId == null) {
      return true;
    }

    return originSessionId == currentSessionId;
  }
}

String? _noSessionId() => null;
