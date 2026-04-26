import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'attriax_deep_link_source.dart';
import 'internal/attriax_context_collector.dart';
import 'internal/attriax_deep_link_listener.dart';
import 'internal/attriax_logger.dart';
import 'internal/attriax_runtime.dart';
import 'attriax_synchronization.dart';

/// The public entry point for the Attriax mobile attribution SDK.
///
/// Create one application-level instance and initialize it during startup.
/// Awaiting [init] is the recommended path because it guarantees the SDK has
/// collected context, restored persisted state, and started its listeners
/// before your app continues. If your startup path must stay non-blocking, you
/// can still call `unawaited(attriax.init())` intentionally.
///
/// ```dart
/// final attriax = Attriax(
///   config: const AttriaxConfig(
///     appToken: 'ax_your_app_token',
///     apiBaseUrl: 'https://api.attriax.com',
///   ),
/// );
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await attriax.init();
///   runApp(const MyApp());
/// }
/// ```
class Attriax {
  /// Creates the production SDK instance.
  ///
  /// Construct this once at application level and reuse it for the whole app
  /// lifecycle. The logger defaults to verbose output in debug builds and to
  /// warning or error output in non-debug builds unless [AttriaxConfig.enableDebugLogs]
  /// overrides that behavior.
  Attriax({required AttriaxConfig config})
    : _runtime = AttriaxRuntime(
        config: config,
        deepLinkListener: AttriaxDeepLinkListener(
          deepLinkSource: createDefaultAttriaxDeepLinkSource(),
        ),
        contextCollector: AttriaxContextCollector(config: config),
        connectivity: Connectivity(),
        client: http.Client(),
        logger: AttriaxLogger(
          enableDebugLogs: config.enableDebugLogs ?? kDebugMode,
        ),
      );

  /// Creates a test-friendly SDK instance with injected dependencies.
  ///
  /// Use this constructor in widget, integration, or package tests when you
  /// need full control over HTTP, deep-link, connectivity, or preference state.
  @visibleForTesting
  Attriax.test({
    required AttriaxConfig config,
    required http.Client client,
    required AttriaxDeepLinkSource deepLinkSource,
    required Connectivity connectivity,
    required AttriaxContextCollector contextCollector,
    SharedPreferences? prefs,
    bool? enableDebugLogs,
  }) : _runtime = AttriaxRuntime(
         config: config,
         deepLinkListener: AttriaxDeepLinkListener(
           deepLinkSource: deepLinkSource,
         ),
         contextCollector: contextCollector,
         connectivity: connectivity,
         client: client,
         logger: AttriaxLogger(
           enableDebugLogs:
               enableDebugLogs ?? config.enableDebugLogs ?? kDebugMode,
         ),
         prefsOverride: prefs,
       );

  final AttriaxRuntime _runtime;

  /// Synchronization state and events exposed through a focused facade.
  late final AttriaxSynchronization synchronization = AttriaxSynchronization(
    _runtime,
  );

  /// Immutable SDK configuration supplied at construction time.
  AttriaxConfig get config => _runtime.config;

  /// Whether [init] has completed successfully.
  ///
  /// Until this becomes `true`, tracking and identification calls throw because
  /// the SDK has not finished restoring persisted state or collecting context.
  bool get isInitialized => _runtime.isInitialized;

  /// Whether the SDK is globally enabled.
  ///
  /// When disabled, no new requests are queued and deep-link listeners are
  /// stopped until this property is set back to `true`.
  bool get enabled => _runtime.isEnabled;

  /// Updates whether the SDK is globally enabled.
  ///
  /// The runtime state flips immediately and persistence/listener updates are
  /// applied asynchronously in the background.
  set enabled(bool value) => _runtime.setEnabled(enabled: value);

  /// Whether custom event tracking is currently enabled.
  ///
  /// This setting only affects calls to [trackEvent]. App-open tracking and
  /// identification continue to work while the SDK itself is enabled.
  bool get eventsEnabled => _runtime.areEventsEnabled;

  /// Updates whether custom event tracking is enabled.
  ///
  /// The runtime state flips immediately and persistence is applied
  /// asynchronously in the background.
  set eventsEnabled(bool value) => _runtime.setEventsEnabled(enabled: value);

  /// Whether the current installation run is the first launch observed by the SDK.
  ///
  /// This value is restored during [init] and stays stable for the current app
  /// session.
  bool get isFirstLaunch => _runtime.isFirstLaunch;

  /// Stable per-installation device identifier generated by the SDK.
  ///
  /// The value is available after [init] restores or creates it.
  String? get deviceId => _runtime.deviceId;

  /// Latest collected device, app, platform, and SDK context snapshot.
  ///
  /// This is primarily useful for diagnostics, QA validation, and debugging
  /// integration state after [init] completes.
  AttriaxContextSnapshot? get contextSnapshot => _runtime.contextSnapshot;

  /// Most recent successful app-open tracking response.
  ///
  /// This stays `null` until the initial app-open request succeeds.
  AttriaxAppOpenResult? get lastAppOpenResult => _runtime.lastAppOpenResult;

  /// Broadcast deep-link stream with no buffering.
  ///
  /// Automatic incoming links emit immediately with raw link data, and callers
  /// can await [AttriaxDeepLinkEvent.waitForConversionResult] when they also
  /// need the server-side resolution outcome. Deferred app-open matches are
  /// emitted as already-resolved deep-link events.
  Stream<AttriaxDeepLinkEvent> get deepLinks => _runtime.deepLinks;

  /// Initializes the SDK runtime.
  ///
  /// This restores persisted flags, generates or loads the SDK device ID,
  /// collects the current context snapshot, starts deep-link listeners, and
  /// optionally queues the initial app-open request.
  ///
  /// Set [enabled] or [eventsEnabled] to override the persisted values for the
  /// current startup. Set [trackAppOpen] to `false` only when you explicitly
  /// want to skip automatic app-open tracking.
  Future<void> init({
    bool? enabled,
    bool? eventsEnabled,
    bool trackAppOpen = true,
  }) => _runtime.init(
    enabled: enabled,
    eventsEnabled: eventsEnabled,
    trackAppOpen: trackAppOpen,
  );

  /// Queues a custom analytics event for delivery to the Attriax backend.
  ///
  /// [eventData] accepts regular JSON-compatible Dart values represented as a
  /// `Map<String, Object?>` with nested maps, lists, strings, numbers, booleans,
  /// or `null`. The request is queued locally and flushed immediately when the
  /// device is online.
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    String? linkId,
  }) => _runtime.trackEvent(eventName, eventData: eventData, linkId: linkId);

  /// Queues a first-class page view event for screen analytics and funnels.
  ///
  /// This is a convenience wrapper over [trackEvent] that standardizes the
  /// payload under the `page_view` event name so the dashboard can aggregate
  /// top pages and conversion funnels consistently.
  Future<void> trackPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
  }) => _runtime.trackPageView(
    pageName,
    pageClass: pageClass,
    pageTitle: pageTitle,
    previousPageName: previousPageName,
    parameters: parameters,
    source: source,
  );

  /// Associates the current installation with an external application user.
  ///
  /// Call this after your app signs a user in or when you need to attach Attriax
  /// attribution data to an existing account identifier in your backend.
  Future<void> identify(String externalUserId, {String? externalUserName}) =>
      _runtime.identify(externalUserId, externalUserName: externalUserName);

  /// Creates a short dynamic link that can carry optional routing data.
  ///
  /// Attriax generates the final short code server-side, applies app-level
  /// defaults for omitted destination and Open Graph fields, and returns the
  /// shareable short URL together with the persisted link metadata.
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    bool? iosRedirect,
    bool? androidRedirect,
    String? previewTitle,
    String? previewDescription,
    String? previewImagePath,
    Map<String, Object?>? data,
  }) => _runtime.createDynamicLink(
    name: name,
    destinationUrl: destinationUrl,
    group: group,
    prefix: prefix,
    iosRedirect: iosRedirect,
    androidRedirect: androidRedirect,
    previewTitle: previewTitle,
    previewDescription: previewDescription,
    previewImagePath: previewImagePath,
    data: data,
  );

  /// Resolves a deep link manually and emits the same conversion signals as automatic handling.
  ///
  /// Provide either [uri] or [linkPath]. [metadata] accepts regular
  /// JSON-compatible Dart values and is sent with the resolution request.
  /// Returns the successful conversion event when the backend matches a deep
  /// link, otherwise returns `null` and emits a conversion failure signal.
  Future<AttriaxDeepLinkConversionEvent?> recordDeepLinkConversion({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) => _runtime.recordDeepLinkConversion(
    uri: uri,
    linkPath: linkPath,
    metadata: metadata,
    source: source,
  );

  /// Waits for the first app-open tracking request to finish.
  ///
  /// Returns the successful app-open response when available, `null` when no
  /// app-open request was scheduled, or propagates the request failure.
  Future<AttriaxAppOpenResult?> waitForAppOpenTracking() =>
      _runtime.waitForAppOpenTracking();

  /// Releases listeners, closes streams, and disposes runtime resources.
  Future<void> dispose() => _runtime.dispose();
}
