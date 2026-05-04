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
/// Awaiting [init] restores persisted state, captures the immediate runtime
/// context, and starts listeners. Network-backed work such as app-open
/// tracking and install-referrer enrichment continues asynchronously after
/// [init] completes.
///
/// ```dart
/// final attriax = Attriax(
///   config: const AttriaxConfig(
///     appToken: 'ax_your_app_token',
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
    : this._withLogger(
        config: config,
        logger: AttriaxLogger(
          enableDebugLogs: config.enableDebugLogs ?? kDebugMode,
        ),
      );

  Attriax._withLogger({
    required AttriaxConfig config,
    required AttriaxLogger logger,
  }) : _runtime = AttriaxRuntime(
         config: config,
         deepLinkListener: AttriaxDeepLinkListener(
           deepLinkSource: createDefaultAttriaxDeepLinkSource(),
         ),
         contextCollector: AttriaxContextCollector(
           config: config,
           logger: logger,
         ),
         connectivity: Connectivity(),
         client: http.Client(),
         logger: logger,
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

  /// Deep-link state and stream access for immediate, initial, and deferred links.
  ///
  /// Deferred deep links resolved from the app-open flow are surfaced through
  /// this facade alongside regular incoming links.
  late final AttriaxDeepLinks deepLinks = AttriaxDeepLinks._(_runtime);

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
  /// This setting only affects calls to [recordEvent]. App-open tracking and
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

  /// Stable Attriax device identifier restored or generated during [init].
  ///
  /// This becomes available after [init] completes and remains stable across
  /// launches until the SDK storage is cleared.
  String? get deviceId => _runtime.deviceId;

  /// SDK version and metadata snapshot captured during initialization.
  ///
  /// This becomes available after [init] captures the initial runtime state.
  AttriaxSdkSnapshot? get sdkSnapshot => _runtime.sdkSnapshot;

  /// Latest structured install-referrer details known for this installation.
  ///
  /// If a cached API result exists, this future resolves from local
  /// preferences. Otherwise it resolves after the first app-open request
  /// returns an install-referrer payload, or `null` when no such payload is
  /// available. If [init] runs with `enabled: false`, the platform install
  /// referrer is not checked and this future resolves to `null`; setting
  /// [enabled] back to `true` later starts the app-open/referrer request once
  /// for the current session and exposes that new result through this getter.
  Future<AttriaxInstallReferrerDetails?> get installReferrer =>
      _runtime.installReferrer;

  /// Initializes the SDK runtime.
  ///
  /// This restores persisted flags, generates or loads the SDK device ID,
  /// captures the immediate context snapshot, starts deep-link listeners, and
  /// optionally schedules the initial app-open request.
  ///
  /// Set [enabled] or [eventsEnabled] to override the persisted values for the
  /// current startup. Set [trackAppOpen] to `false` only when you explicitly
  /// want to skip automatic app-open tracking; doing so also prevents deferred
  /// deep-link delivery from the app-open response and causes [installReferrer]
  /// to resolve to `null` for that startup.
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
  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
  }) => _runtime.recordEvent(eventName, eventData: eventData);

  /// Queues a first-class page view event for screen analytics and funnels.
  ///
  /// This is a convenience wrapper over [recordEvent] that standardizes the
  /// payload under the `page_view` event name so the dashboard can aggregate
  /// top pages and conversion funnels consistently.
  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
  }) => _runtime.recordPageView(
    pageName,
    pageClass: pageClass,
    pageTitle: pageTitle,
    previousPageName: previousPageName,
    parameters: parameters,
    source: source,
  );

  /// Queues a handled error or crash report for delivery to the Attriax backend.
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  }) => _runtime.recordError(
    error,
    stackTrace,
    fatal: fatal,
    source: source,
    reason: reason,
    metadata: metadata,
  );

  /// Associates the current installation with an external application user.
  ///
  /// Call this after your app signs a user in or when you need to attach Attriax
  /// attribution data to an existing account identifier in your backend. Pass
  /// `null` to clear the currently associated external user id.
  Future<void> setUser(String? userId, {String? userName}) =>
      _runtime.setUser(userId, userName: userName);

  /// Sets or clears a single user property attached to future tracked events.
  Future<void> setUserProperty(String name, Object? value) =>
      _runtime.setUserProperty(name, value);

  /// Sets multiple user properties attached to future tracked events.
  Future<void> setUserProperties(Map<String, Object?> properties) =>
      _runtime.setUserProperties(properties);

  /// Clears selected user properties or every stored user property when omitted.
  Future<void> clearUserProperties({List<String>? propertyNames}) =>
      _runtime.clearUserProperties(propertyNames: propertyNames);

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
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    Map<String, Object?>? data,
  }) => _runtime.createDynamicLink(
    name: name,
    destinationUrl: destinationUrl,
    group: group,
    prefix: prefix,
    socialPreview: socialPreview,
    utms: utms,
    redirects: redirects,
    data: data,
  );

  /// Records a deep link manually without emitting it through the deep-link stream.
  ///
  /// Provide either [uri] or [linkPath]. [metadata] accepts regular
  /// JSON-compatible Dart values and is sent with the resolution request.
  /// Returns the successful resolution when the backend matches a deep link,
  /// otherwise returns `null`.
  Future<AttriaxDeepLinkResolution?> recordDeepLink({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) => _runtime.recordDeepLink(
    uri: uri,
    linkPath: linkPath,
    metadata: metadata,
    source: source,
  );

  /// Releases listeners, closes streams, and disposes runtime resources.
  Future<void> dispose() => _runtime.dispose();
}

/// Deep-link state and subscriptions exposed by [Attriax].
///
/// This facade covers both regular incoming links and deferred deep links that
/// resolve later from app-open tracking.
class AttriaxDeepLinks {
  AttriaxDeepLinks._(this._runtime);

  final AttriaxRuntime _runtime;

  /// Latest resolved result for the launch deep link that opened this session.
  ///
  /// This stays `null` until the initial-link probe completes. Use
  /// [initialDeepLinkResolved] to distinguish "not resolved yet" from "resolved
  /// and no initial deep link was found".
  AttriaxDeepLinkResult? get initialDeepLink => _runtime.initialDeepLink;

  /// Whether the initial deep-link probe has completed for this app session.
  bool get initialDeepLinkResolved => _runtime.isInitialDeepLinkResolved;

  /// Waits for the initial deep-link probe to finish if it is still pending.
  ///
  /// This resolves to the matched or failed backend result for the launch deep
  /// link, or `null` when no initial deep link was present.
  Future<AttriaxDeepLinkResult?> waitForInitialDeepLink() =>
      _runtime.waitForInitialDeepLink();

  /// Broadcast stream of handled deep-link events.
  ///
  /// Automatic incoming links emit immediately with raw link data, and callers
  /// can await [AttriaxDeepLinkEvent.resolve] when they also need the
  /// server-side resolution outcome. Deferred app-open matches are emitted here
  /// as already-resolved deep-link events.
  Stream<AttriaxDeepLinkEvent> get stream => _runtime.deepLinks;

  /// Most recent handled deep-link result seen by the SDK.
  ///
  /// This includes matched, failed, and deferred deep-link outcomes once they
  /// have completed.
  AttriaxDeepLinkResult? get latestDeepLink => _runtime.latestDeepLink;
}
