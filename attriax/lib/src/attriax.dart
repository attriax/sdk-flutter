import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
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

/// Canonical ad lifecycle events tracked by the Attriax SDKs.
enum AttriaxAdEventType {
  request('ad_request'),
  load('ad_load'),
  loadFailed('ad_load_failed'),
  show('ad_show'),
  showFailed('ad_show_failed'),
  impression('ad_impression'),
  click('ad_click'),
  dismiss('ad_dismiss'),
  reward('ad_reward');

  const AttriaxAdEventType(this.eventName);

  final String eventName;
}

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

  /// Startup and deep-link referrer lookups exposed through a focused facade.
  late final AttriaxReferrer referrer = AttriaxReferrer._(_runtime);

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

  /// Requests Apple App Tracking Transparency authorization when available.
  ///
  /// On non-Apple platforms this resolves to
  /// [AttriaxTrackingAuthorizationStatus.notSupported]. This always forwards
  /// the real platform ATT request when one is available, even when
  /// [AttriaxConfig.collectAdvertisingId] is false, and refreshes the SDK's
  /// cached ATT status with the result.
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) => _runtime.requestTrackingAuthorization(timeout: timeout);

  /// Reads the current Apple App Tracking Transparency status when available.
  ///
  /// On non-Apple platforms this resolves to
  /// [AttriaxTrackingAuthorizationStatus.notSupported]. This queries the
  /// platform directly and refreshes the SDK's cached ATT status.
  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus() =>
      _runtime.getTrackingAuthorizationStatus();

  /// Initializes the SDK runtime.
  ///
  /// This restores persisted flags, generates or loads the SDK device ID,
  /// captures the immediate context snapshot, and starts listeners.
  ///
  /// App-open tracking is always scheduled automatically in the background.
  /// Set [enabled] or [eventsEnabled] to override the persisted values for the
  /// current startup.
  Future<void> init({bool? enabled, bool? eventsEnabled}) =>
      _runtime.init(enabled: enabled, eventsEnabled: eventsEnabled);

  /// Clears SDK-owned persisted state and returns this instance to pre-init state.
  ///
  /// After calling [reset], call [init] again before using the instance.
  Future<void> reset() => _runtime.reset();

  /// Queues a custom analytics event for delivery to the Attriax backend.
  ///
  /// [eventData] accepts regular JSON-compatible Dart values represented as a
  /// `Map<String, Object?>` with nested maps, lists, strings, numbers, booleans,
  /// or `null`. Regular events flush immediately during first launch by default
  /// and use [AttriaxConfig.eventFlushInterval] on later launches unless
  /// [flushImmediately] is set to `true` or another immediate request drains the
  /// queue sooner.
  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) => _runtime.recordEvent(
    eventName,
    eventData: eventData,
    flushImmediately: flushImmediately,
  );

  /// Queues a standardized purchase revenue event for delivery to Attriax.
  ///
  /// Use negative [revenue] values to report refunds or downward adjustments.
  /// Any [metadata] fields are merged into the outgoing event payload before
  /// the typed purchase fields are applied.
  ///
  /// [currency] should be an ISO 4217 code such as `USD` or `EUR`.
  /// Set [revenueInMicros] to `true` only when [revenue] is already expressed
  /// in micros instead of whole currency units.
  /// [purchaseType] is an optional stable subtype for your own reporting,
  /// such as `one_time`, `subscription_initial`, or
  /// `subscription_renewal`; prefer normalized machine-readable values over
  /// localized labels.
  /// [transactionId] should be the unique store order or transaction id used
  /// for idempotency. [originalTransactionId] should point at the root purchase
  /// when renewals or restorations share subscription history.
  /// [validationProvider] and [validationEnvironment] describe how the receipt
  /// payload should be interpreted, for example `google_play` with
  /// `production` or `app_store` with `sandbox`.
  /// [purchaseToken], [receiptData], [signedPayload], and [receiptSignature]
  /// should contain the raw platform payloads you want Attriax to hash and
  /// associate with server-side validation.
  /// [store] and [packageName] help disambiguate which app-store record or app
  /// build produced the purchase, especially in multi-app or white-label setups.
  /// [validationId] links this event to an already-created validation record
  /// when validation happened before the revenue event was sent.
  /// [test] marks sandbox or QA purchases. [voided] marks store data that was
  /// already voided when you are backfilling or replaying events.
  Future<void> recordPurchase({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    String? validationProvider,
    String? validationEnvironment,
    String? purchaseToken,
    String? receiptData,
    String? signedPayload,
    String? receiptSignature,
    bool? isRenewal,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? validationId,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) {
    final normalizedRevenue = revenue.toDouble();
    if (!normalizedRevenue.isFinite) {
      throw ArgumentError.value(revenue, 'revenue', 'revenue must be finite.');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'quantity must be positive.',
      );
    }

    final normalizedRevenueCurrency = _normalizeRevenueCurrency(
      normalizedRevenue,
      currency,
    );

    return _runtime.recordEvent(
      'purchase',
      eventData: <String, Object?>{
        ...?metadata,
        'revenue': normalizedRevenueCurrency.revenue,
        'currency': normalizedRevenueCurrency.currency,
        if (revenueInMicros) 'revenueInMicros': true,
        'purchaseType': ?_trimOrNull(purchaseType),
        'productId': ?_trimOrNull(productId),
        'transactionId': ?_trimOrNull(transactionId),
        'originalTransactionId': ?_trimOrNull(originalTransactionId),
        'validationProvider': ?_trimOrNull(validationProvider),
        'validationEnvironment': ?_trimOrNull(validationEnvironment),
        'purchaseToken': ?_trimOrNull(purchaseToken),
        'receiptData': ?_trimOrNull(receiptData),
        'signedPayload': ?_trimOrNull(signedPayload),
        'receiptSignature': ?_trimOrNull(receiptSignature),
        'isRenewal': ?isRenewal,
        if (quantity != 1) 'quantity': quantity,
        'store': ?_trimOrNull(store),
        'packageName': ?_trimOrNull(packageName),
        'voided': ?voided,
        'test': ?test,
        'validationId': ?_trimOrNull(validationId),
      },
      flushImmediately: flushImmediately,
    );
  }

  /// Queues a standardized refund revenue event for delivery to Attriax.
  ///
  /// The outgoing payload always uses a negative revenue amount and the
  /// `refund` event name so callers do not need to negate values manually.
  ///
  /// Use [transactionId] for the refund transaction itself and
  /// [originalTransactionId] for the original order or subscription root.
  /// [reason] accepts an optional machine-readable refund reason such as
  /// `chargeback` or `revoked`.
  Future<void> recordRefund({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? reason,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) {
    final normalizedRevenue = revenue.toDouble();
    if (!normalizedRevenue.isFinite) {
      throw ArgumentError.value(revenue, 'revenue', 'revenue must be finite.');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'quantity must be positive.',
      );
    }

    final normalizedRevenueCurrency = _normalizeRevenueCurrency(
      normalizedRevenue,
      currency,
    );
    final refundRevenue = normalizedRevenueCurrency.revenue == 0
        ? 0
        : -normalizedRevenueCurrency.revenue.abs();

    return _runtime.recordEvent(
      'refund',
      eventData: <String, Object?>{
        ...?metadata,
        'revenue': refundRevenue,
        'currency': normalizedRevenueCurrency.currency,
        'revenueType': 'refund',
        if (revenueInMicros) 'revenueInMicros': true,
        'purchaseType': ?_trimOrNull(purchaseType),
        'productId': ?_trimOrNull(productId),
        'transactionId': ?_trimOrNull(transactionId),
        'originalTransactionId': ?_trimOrNull(originalTransactionId),
        if (quantity != 1) 'quantity': quantity,
        'store': ?_trimOrNull(store),
        'packageName': ?_trimOrNull(packageName),
        'voided': ?voided,
        'test': ?test,
        'reason': ?_trimOrNull(reason),
      },
      flushImmediately: flushImmediately,
    );
  }

  /// Validates a purchase receipt immediately and returns the public result.
  ///
  /// Use this during a purchase flow when the app needs an immediate receipt
  /// verification response. The current SDK device id is attached
  /// automatically.
  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    String? provider,
    String? environment,
    String? transactionId,
    String? originalTransactionId,
    String? productId,
    String? store,
    String? packageName,
    String? purchaseToken,
    String? receiptData,
    String? signedPayload,
    String? receiptSignature,
    bool? test,
  }) => _runtime.validateReceipt(
    provider: provider,
    environment: environment,
    transactionId: transactionId,
    originalTransactionId: originalTransactionId,
    productId: productId,
    store: store,
    packageName: packageName,
    purchaseToken: purchaseToken,
    receiptData: receiptData,
    signedPayload: signedPayload,
    receiptSignature: receiptSignature,
    test: test,
  );

  /// Registers the current Firebase Cloud Messaging token for uninstall tracking.
  ///
  /// Call this after your app receives an FCM token and again whenever Firebase
  /// rotates that token. Pass `null` or an empty string to clear the currently
  /// registered FCM uninstall token for this device. Attriax currently supports
  /// this flow on Android and iOS. On Apple platforms, Firebase must already be
  /// configured to map the APNs device token to the FCM registration token.
  Future<void> registerFirebaseMessagingToken(
    String? token, {
    Map<String, Object?>? metadata,
  }) =>
      _runtime.registerFirebaseMessagingToken(token: token, metadata: metadata);

  /// Registers the current Apple Push Notification service token for uninstall
  /// tracking.
  ///
  /// Call this after your app receives an APNs device token and again whenever
  /// Apple rotates that token. Pass `null` or an empty string to clear the
  /// currently registered APNs uninstall token for this device. Attriax
  /// currently supports this flow on Apple platforms only.
  Future<void> registerApplePushToken(
    String? token, {
    Map<String, Object?>? metadata,
  }) => _runtime.registerApplePushToken(token: token, metadata: metadata);

  /// Queues a standardized ad revenue event for delivery to Attriax.
  ///
  /// Any [metadata] fields are merged into the outgoing event payload before
  /// the typed ad monetization fields are applied.
  /// [currency] should be an ISO 4217 code such as `USD`.
  /// Set [revenueInMicros] to `true` only when [revenue] is already expressed
  /// in micros.
  /// [adNetwork] should identify the network or mediation source, for example
  /// `admob`, `applovin_max`, or `unity_ads`.
  /// [adFormat] should describe the served format such as `banner`,
  /// `interstitial`, `rewarded`, or `native`.
  /// [adType] is an optional app-defined subtype like `impression`,
  /// `paid_event`, or `rewarded_complete`.
  /// [adPlacement] should be your in-app placement or slot identifier so the
  /// dashboard can separate monetization by surface.
  /// [test] marks monetization callbacks that came from sandbox or QA traffic.
  Future<void> recordAdRevenue({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? adNetwork,
    String? adFormat,
    String? adType,
    String? adPlacement,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) {
    final normalizedRevenue = revenue.toDouble();
    if (!normalizedRevenue.isFinite) {
      throw ArgumentError.value(revenue, 'revenue', 'revenue must be finite.');
    }

    final normalizedRevenueCurrency = _normalizeRevenueCurrency(
      normalizedRevenue,
      currency,
    );

    return _runtime.recordEvent(
      'ad_revenue',
      eventData: <String, Object?>{
        ...?metadata,
        'revenue': normalizedRevenueCurrency.revenue,
        'currency': normalizedRevenueCurrency.currency,
        if (revenueInMicros) 'revenueInMicros': true,
        'adNetwork': ?_trimOrNull(adNetwork),
        'adFormat': ?_trimOrNull(adFormat),
        'adType': ?_trimOrNull(adType),
        'adPlacement': ?_trimOrNull(adPlacement),
        'test': ?test,
      },
      flushImmediately: flushImmediately,
    );
  }

  /// Queues a canonical ad lifecycle event for delivery to Attriax.
  ///
  /// Use this for ad callbacks such as load, show, click, dismiss, reward,
  /// and failure paths so Attriax can group ad delivery consistently.
  Future<void> recordAdEvent(
    AttriaxAdEventType type, {
    String? adNetwork,
    String? mediationNetwork,
    String? adUnitId,
    String? adPlacement,
    String? adFormat,
    String? adType,
    String? failureReason,
    num? loadLatencyMs,
    String? rewardType,
    num? rewardAmount,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) {
    final normalizedLoadLatencyMs = loadLatencyMs?.toDouble();
    if (normalizedLoadLatencyMs != null && !normalizedLoadLatencyMs.isFinite) {
      throw ArgumentError.value(
        loadLatencyMs,
        'loadLatencyMs',
        'loadLatencyMs must be finite.',
      );
    }

    final normalizedRewardAmount = rewardAmount?.toDouble();
    if (normalizedRewardAmount != null && !normalizedRewardAmount.isFinite) {
      throw ArgumentError.value(
        rewardAmount,
        'rewardAmount',
        'rewardAmount must be finite.',
      );
    }

    return _runtime.recordEvent(
      type.eventName,
      eventData: <String, Object?>{
        ...?metadata,
        'adNetwork': ?_trimOrNull(adNetwork),
        'mediationNetwork': ?_trimOrNull(mediationNetwork),
        'adUnitId': ?_trimOrNull(adUnitId),
        'adPlacement': ?_trimOrNull(adPlacement),
        'adFormat': ?_trimOrNull(adFormat),
        'adType': ?_trimOrNull(adType),
        'failureReason': ?_trimOrNull(failureReason),
        'rewardType': ?_trimOrNull(rewardType),
        'loadLatencyMs': ?normalizedLoadLatencyMs,
        'rewardAmount': ?normalizedRewardAmount,
        'test': ?test,
      },
      flushImmediately: flushImmediately,
    );
  }

  /// Queues a first-class page view event for screen analytics and funnels.
  ///
  /// This is a convenience wrapper over [recordEvent] that standardizes the
  /// payload under the `page_view` event name so the dashboard can aggregate
  /// top pages and conversion funnels consistently. By default page views flush
  /// immediately during first launch and use the configured event batching
  /// interval on later launches unless [flushImmediately] is set.
  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) => _runtime.recordPageView(
    pageName,
    pageClass: pageClass,
    pageTitle: pageTitle,
    previousPageName: previousPageName,
    parameters: parameters,
    source: source,
    flushImmediately: flushImmediately,
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
  /// Returns the completed backend deep-link event. When Attriax does not
  /// recognize the link, the returned event still completes with `found == false`.
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
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

  _AttriaxNormalizedRevenue _normalizeRevenueCurrency(
    double revenue,
    String currency,
  ) {
    final normalizedCurrency = _trimOrNull(currency)?.toUpperCase();
    if (normalizedCurrency != null &&
        RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCurrency)) {
      return _AttriaxNormalizedRevenue(
        revenue: revenue,
        currency: normalizedCurrency,
      );
    }

    debugPrint(
      '[Attriax][WARNING] Invalid revenue currency "$currency"; defaulting revenue to 0 USD.',
    );
    return const _AttriaxNormalizedRevenue(revenue: 0, currency: 'USD');
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class _AttriaxNormalizedRevenue {
  const _AttriaxNormalizedRevenue({
    required this.revenue,
    required this.currency,
  });

  final double revenue;
  final String currency;
}

/// Referrer lookups exposed by [Attriax].
///
/// These methods cover startup attribution snapshots and runtime deep-link
/// referrers. All lookups resolve to `null` immediately until [Attriax.init]
/// completes and while the SDK is disabled.
class AttriaxReferrer {
  AttriaxReferrer._(this._runtime);

  final AttriaxRuntime _runtime;

  /// Original install referrer persisted for this installation.
  ///
  /// This resolves from local storage on later launches, or after the first
  /// successful app-open request on a fresh install or reinstall.
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getOriginalInstallReferrer(timeout: timeout, safe: safe);

  /// Reinstall referrer persisted for the current installation, when one exists.
  ///
  /// This resolves after the first successful app-open request that classifies
  /// the launch as a reinstall, or from cached storage on later launches.
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getReinstallReferrer(timeout: timeout, safe: safe);

  /// Deep-link referrer that opened the current session.
  ///
  /// This waits for the startup deep-link flow to settle. It resolves to a
  /// cold-start or deferred deep-link referrer, or `null` when the current
  /// session started without one.
  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getSessionReferrer(timeout: timeout, safe: safe);

  /// Most recent deep-link referrer observed in the current session.
  ///
  /// If no deep link has been received yet, this waits for the next handled
  /// deep-link event.
  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _runtime.getLatestDeepLinkReferrer(timeout: timeout, safe: safe);
}

/// Deep-link state and subscriptions exposed by [Attriax].
///
/// This facade covers both regular incoming links and deferred deep links that
/// resolve later from app-open tracking.
class AttriaxDeepLinks {
  AttriaxDeepLinks._(this._runtime);

  final AttriaxRuntime _runtime;

  /// Launch raw deep-link event captured during startup, when one was present.
  AttriaxRawDeepLinkEvent? get rawInitialDeepLink =>
      _runtime.rawInitialDeepLink;

  /// Launch deep-link event captured during startup, when one was present.
  ///
  /// This stays `null` until the initial-link probe completes. Use
  /// [initialDeepLinkResolved] to distinguish "not resolved yet" from "resolved
  /// and no initial deep link was found".
  AttriaxDeepLinkEvent? get initialDeepLink => _runtime.initialDeepLink;

  /// Whether the initial deep-link probe has completed for this app session.
  bool get initialDeepLinkResolved => _runtime.isInitialDeepLinkResolved;

  /// Waits for the initial deep-link probe to finish if it is still pending.
  ///
  /// This resolves to the launch deep-link event, or `null` when no initial
  /// deep link was present.
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() =>
      _runtime.waitForInitialDeepLink();

  /// Waits for the resolved deep-link event corresponding to [rawEvent].
  Future<AttriaxDeepLinkEvent> waitResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) => _runtime.waitForDeepLinkResolution(rawEvent);

  /// Broadcast stream of raw deep-link inputs from native platform capture.
  Stream<AttriaxRawDeepLinkEvent> get rawStream => _runtime.rawDeepLinks;

  /// Broadcast stream of handled deep-link events.
  ///
  /// Automatic incoming links emit here after Attriax resolves them.
  /// Deferred app-open matches are also emitted here.
  Stream<AttriaxDeepLinkEvent> get stream => _runtime.deepLinks;

  /// Most recent handled deep-link event seen by the SDK.
  AttriaxDeepLinkEvent? get latestDeepLink => _runtime.latestDeepLink;
}
