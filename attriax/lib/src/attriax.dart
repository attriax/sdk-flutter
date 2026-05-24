import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'attriax_ad_event_type.dart';
import 'attriax_analytics_keys.dart';
import 'attriax_consent.dart';
import 'attriax_deep_link_source.dart';
import 'internal/attriax_context_collector.dart';
import 'internal/attriax_deep_link_listener.dart';
import 'internal/attriax_logger.dart';
import 'internal/attriax_runtime.dart';
import 'attriax_synchronization.dart';

part 'attriax_deep_links.dart';
part 'attriax_referrer.dart';
part 'attriax_skan.dart';
part 'attriax_tracking.dart';

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

  /// Regulation-scoped consent helpers exposed through a focused facade.
  late final AttriaxConsent consent = AttriaxConsent(_runtime);

  /// Tracking, revenue, and user-association helpers exposed through a facade.
  late final AttriaxTracking tracking = AttriaxTracking._(_runtime);

  /// Startup and deep-link referrer lookups exposed through a focused facade.
  late final AttriaxReferrer referrer = AttriaxReferrer._(_runtime);

  /// Deep-link state and stream access for immediate, initial, and deferred links.
  ///
  /// Deferred deep links resolved from the app-open flow are surfaced through
  /// this facade alongside regular incoming links.
  late final AttriaxDeepLinks deepLinks = AttriaxDeepLinks._(_runtime);

  /// SKAdNetwork state and update helpers exposed through a focused facade.
  late final AttriaxSkan skan = AttriaxSkan._(_runtime);

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

  /// Initializes the SDK runtime.
  ///
  /// This restores persisted flags, generates or loads the SDK device ID,
  /// captures the immediate context snapshot, and starts listeners.
  ///
  /// App-open tracking is always scheduled automatically in the background.
  /// Set [enabled] before [init] when you need to override the persisted SDK
  /// enabled state for the current startup. Use `tracking.enabled` before or
  /// after [init] to control event-style tracking independently.
  Future<void> init({bool? enabled}) => _runtime.init(enabled: enabled);

  /// Clears SDK-owned persisted state and returns this instance to pre-init state.
  ///
  /// After calling [reset], call [init] again before using the instance.
  Future<void> reset() => _runtime.reset();

  /// Validates a purchase receipt immediately and returns the public result.
  ///
  /// Use this during a purchase flow when the app needs an immediate receipt
  /// verification response. This remains available even when tracking has been
  /// disabled or GDPR consent is still unresolved, because receipt validation
  /// is treated as a direct functional request rather than event tracking.
  /// The current SDK device id is attached automatically.
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

  /// Releases listeners, closes streams, and disposes runtime resources.
  Future<void> dispose() => _runtime.dispose();
}
