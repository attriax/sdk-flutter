import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_api_models.dart';
import 'attriax_consent_manager.dart';
import 'attriax_context_manager.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_deep_link_resolver.dart';
import 'attriax_event_hub.dart';
import 'attriax_generated_transport.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';
import 'attriax_request_manager.dart';
import 'deep_links/attriax_deep_link_browser_handler.dart';

/// Default upper bound for how long [AttriaxDeepLinkManager.recordManualConversion]
/// waits for a resolution before failing with a [TimeoutException].
const Duration _defaultManualConversionTimeout = Duration(seconds: 30);

/// Owns deep-link listener lifecycle, stream state, and manual/deferred link
/// emission for the runtime.
class AttriaxDeepLinkManager {
  AttriaxDeepLinkManager({
    required AttriaxConfig config,
    required AttriaxContextManager contextManager,
    required AttriaxDeepLinkListener listener,
    required AttriaxEventHub eventHub,
    required AttriaxDeepLinkStateStore preferencesStore,
    required AttriaxRequestManager requestManager,
    required AttriaxLogger logger,
    Future<AttriaxTransportSuccess> Function(
      AttriaxResolveDeepLinkRequest request,
    )?
    directSend,
    AttriaxTrackingDecision Function()? trackingDecision,
    String? Function()? currentSessionIdProvider,
    AttriaxDeepLinkResolver resolver = const AttriaxDeepLinkResolver(),
    AttriaxPlatform? platform,
    AttriaxClock? clock,
    Duration manualConversionTimeout = _defaultManualConversionTimeout,
  }) : _config = config,
       _manualConversionTimeout = manualConversionTimeout,
       _contextManager = contextManager,
       _listener = listener,
       _eventHub = eventHub,
       _preferencesStore = preferencesStore,
       _currentSessionIdProvider = currentSessionIdProvider ?? _noSessionId,
       _requestManager = requestManager,
       _directSend = directSend ?? _unsupportedDirectSend,
       _trackingDecision = trackingDecision ?? _identifiedTrackingDecision,
       _logger = logger,
       _resolver = resolver,
       _platform = platform ?? AttriaxPlatform.instance,
       _clock = clock ?? const AttriaxSystemClock() {
    _browserHandler = AttriaxDeepLinkBrowserHandler(
      config: _config,
      platform: _platform,
      logger: _logger,
    );
  }

  final AttriaxConfig _config;
  final AttriaxContextManager _contextManager;
  final AttriaxDeepLinkListener _listener;
  final AttriaxEventHub _eventHub;
  final AttriaxDeepLinkStateStore _preferencesStore;
  final String? Function() _currentSessionIdProvider;
  final AttriaxRequestManager _requestManager;
  final Future<AttriaxTransportSuccess> Function(
    AttriaxResolveDeepLinkRequest request,
  )
  _directSend;
  final AttriaxTrackingDecision Function() _trackingDecision;
  final AttriaxLogger _logger;
  final AttriaxDeepLinkResolver _resolver;
  final AttriaxPlatform _platform;
  final AttriaxClock _clock;
  final Duration _manualConversionTimeout;
  late final AttriaxDeepLinkBrowserHandler _browserHandler;

  Stream<AttriaxRawDeepLinkEvent> get rawStream => _eventHub.rawDeepLinks;
  AttriaxRawDeepLinkEvent? get rawInitialDeepLink =>
      _eventHub.rawInitialDeepLinkValue;
  Stream<AttriaxDeepLinkEvent> get stream => _eventHub.deepLinks;
  AttriaxDeepLinkEvent? get initialDeepLink => _eventHub.initialDeepLinkValue;
  bool get isInitialDeepLinkResolved => _eventHub.isInitialDeepLinkResolved;
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() =>
      _eventHub.initialDeepLink;
  AttriaxDeepLinkEvent? get latestDeepLink => _eventHub.latestDeepLink;
  Future<AttriaxDeepLinkEvent> waitResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) => _eventHub.waitForResolution(rawEvent);

  Future<void> start() => _listener.start(
    _handleIncomingLink,
    onInitialLinkProbeCompleted: _eventHub.completeInitialDeepLinkIfAbsent,
  );

  Future<void> stop() => _listener.stop();

  void completeInitialLinkIfAbsent() =>
      _eventHub.completeInitialDeepLinkIfAbsent();

  Future<AttriaxDeepLinkEvent?> recordManualConversion({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    final normalizedLinkPath = _resolver.extractLinkPathFromUri(uri);
    final clickedAt = _clock.now();
    final completer = Completer<AttriaxDeepLinkEvent>();

    await _dispatchResolveRequest(
      _buildResolveRequest(
        source: source,
        rawUrl: uri.toString(),
        linkPath: normalizedLinkPath,
        metadata: metadata,
      ),
      onSuccess: (response) {
        unawaited(
          _completeManualConversionSuccess(
            response: response,
            clickedAt: clickedAt,
            fallbackUri: uri,
            completer: completer,
          ),
        );
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

    // Bound the wait so an awaited manual resolution cannot hang forever when
    // the resolve request stays unsent (e.g. offline for a long time). The
    // underlying request still follows the normal queue/retry policy; only the
    // public future returned to the caller is time-bounded.
    return completer.future.timeout(
      _manualConversionTimeout,
      onTimeout: () {
        _logger.warning(
          'Manual deep-link resolution timed out before completing.',
        );
        throw TimeoutException(
          'Manual deep-link resolution did not complete in time.',
          _manualConversionTimeout,
        );
      },
    );
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
      event: _resolver.buildDeferredResolution(
        result,
        fallbackTime: _clock.now(),
      ),
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
      isInitialLink: isInitialLink,
    );
    _eventHub.publishPendingDeepLink(
      event: event,
      isInitialLink: isInitialLink,
    );
    _logger.verbose(
      'Received deep link ${_resolver.extractLinkPathFromUri(uri) ?? uri.toString()}.',
    );

    try {
      await _dispatchResolveRequest(
        _buildResolveRequest(
          source: 'attriax_sdk',
          rawUrl: uri.toString(),
          linkPath: _resolver.extractLinkPathFromUri(uri),
          metadata: <String, Object?>{
            'isInitialLink': isInitialLink,
            'queryParameters': uri.queryParametersAll,
          },
        ),
        onSuccess: (response) {
          unawaited(
            _handleIncomingLinkSuccess(
              response: response,
              event: event,
              isInitialLink: isInitialLink,
              originSessionId: originSessionId,
              receivedAt: receivedAt,
            ),
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
    }
  }

  AttriaxResolveDeepLinkRequest _buildResolveRequest({
    required String source,
    String? rawUrl,
    String? linkPath,
    Map<String, Object?>? metadata,
  }) {
    final decision = _trackingDecision();
    return attriaxBuildResolveDeepLinkRequest(
      projectToken: _config.projectToken,
      deviceId: decision.attachDeviceIdentity
          ? _contextManager.requiredDeviceId
          : null,
      deviceIdSource: decision.attachDeviceIdentity
          ? _contextManager.requireDeviceIdSource()
          : null,
      platform: _contextManager.requiredSnapshot.platform,
      source: source,
      isFirstLaunch: _contextManager.isFirstLaunch,
      rawUrl: rawUrl,
      linkPath: linkPath,
      metadata: metadata,
    );
  }

  Future<void> _dispatchResolveRequest(
    AttriaxResolveDeepLinkRequest request, {
    required void Function(AttriaxApiResponse response) onSuccess,
    required void Function(Object error, StackTrace? stackTrace) onError,
  }) async {
    final decision = _trackingDecision();
    final shouldSendDirectly =
        decision.sendNetworkDirectly && !decision.attachDeviceIdentity;
    if (!shouldSendDirectly) {
      await _requestManager.enqueue(
        request,
        onSuccess: onSuccess,
        onError: onError,
      );
      return;
    }

    try {
      final delivery = await _directSend(request);
      onSuccess(delivery.response);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  bool _isCurrentSession(String? originSessionId) {
    // A link captured before any session existed (cold start) has no origin
    // session, so it should attach to whatever session is current.
    if (originSessionId == null) {
      return true;
    }

    // The link belongs to a known origin session. If the current session has
    // ended (null) or has been replaced by a different one, the link is stale
    // and must not leak into it.
    return originSessionId == _currentSessionIdProvider();
  }

  Future<void> _completeManualConversionSuccess({
    required AttriaxApiResponse response,
    required DateTime clickedAt,
    required Uri fallbackUri,
    required Completer<AttriaxDeepLinkEvent> completer,
  }) async {
    if (response is! AttriaxResolveDeepLinkApiResponse) {
      _logger.error('Unexpected response type for deep-link resolution.');
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Unexpected response type for deep-link resolution.'),
        );
      }
      return;
    }

    try {
      final resolution = await _buildResolutionWithBrowserHandling(
        response.result,
        clickedAt: clickedAt,
        trigger: AttriaxDeepLinkTrigger.foreground,
        isAttriaxSubDomain: _resolver.isAttriaxDomain(fallbackUri),
        fallbackUri: fallbackUri,
      );
      if (!completer.isCompleted) {
        completer.complete(resolution);
      }
    } catch (error, stackTrace) {
      _logger.error(
        'Manual deep-link browser handling failed.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    }
  }

  Future<void> _handleIncomingLinkSuccess({
    required AttriaxApiResponse response,
    required AttriaxRawDeepLinkEvent event,
    required bool isInitialLink,
    required String? originSessionId,
    required DateTime receivedAt,
  }) async {
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
        error: StateError('Unexpected response type for deep-link resolution.'),
      );
      return;
    }

    try {
      final resolution = await _buildResolutionWithBrowserHandling(
        response.result,
        clickedAt: receivedAt,
        trigger: isInitialLink
            ? AttriaxDeepLinkTrigger.coldStart
            : AttriaxDeepLinkTrigger.foreground,
        isAttriaxSubDomain: _resolver.isAttriaxDomain(event.uri),
        fallbackUri: event.uri,
        rawEvent: event,
      );
      _eventHub
        ..resolvePendingDeepLink(event: event, resolution: resolution)
        ..emitResolvedDeepLink(event: resolution);
    } catch (error, stackTrace) {
      _logger.error(
        'Deep-link browser handling failed.',
        error: error,
        stackTrace: stackTrace,
      );
      _eventHub.failPendingDeepLink(
        event: event,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<AttriaxDeepLinkEvent> _buildResolutionWithBrowserHandling(
    AttriaxDeepLinkResolutionResult result, {
    required DateTime clickedAt,
    required AttriaxDeepLinkTrigger trigger,
    required bool isAttriaxSubDomain,
    Uri? fallbackUri,
    AttriaxRawDeepLinkEvent? rawEvent,
  }) async {
    final handledBySdk = await _browserHandler.handle(result.browserAction);
    return _resolver.buildResolution(
      result,
      clickedAt: clickedAt,
      trigger: trigger,
      isAttriaxSubDomain: isAttriaxSubDomain,
      fallbackUri: fallbackUri,
      rawEvent: rawEvent,
      handledBySdk: handledBySdk,
    );
  }
}

String? _noSessionId() => null;
AttriaxTrackingDecision _identifiedTrackingDecision() =>
    const AttriaxTrackingDecision(
      capture: true,
      identityMode: AttriaxTrackingIdentityMode.identified,
      deferNetwork: false,
    );
Future<AttriaxTransportSuccess> _unsupportedDirectSend(
  AttriaxResolveDeepLinkRequest request,
) => Future<AttriaxTransportSuccess>.error(
  StateError('Direct deep-link resolution is not configured.'),
);
