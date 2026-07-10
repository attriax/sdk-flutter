import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:flutter/foundation.dart';

import 'attriax_ad_event_type.dart';
import 'attriax_analytics_keys.dart';
import 'attriax_consent.dart';
import 'attriax_notification_event.dart';
import 'internal/attriax_logger.dart';
import 'internal/attriax_native_runtime.dart';
import 'internal/attriax_runtime_interface.dart';
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
///     projectToken: 'ax_your_project_token',
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
  }) : _runtime = _buildRuntime(config: config, logger: logger);

  /// Builds the native engine behind the shared runtime interface.
  ///
  /// Every supported target runs the native engine via
  /// `attriax_flutter_platform_interface`. iOS and macOS drive the `AttriaxCore`
  /// KMP XCFramework through the Swift plugin; Windows and Linux drive the same
  /// KMP core through its C-ABI shared library over `dart:ffi` (the
  /// `attriax_flutter_windows` / `attriax_flutter_linux` plugins, over
  /// `attriax_core.dll` / `libattriax_core.so`); the web drives the sdk-js
  /// engine (`@attriax/js`) through the `attriax_flutter_web` plugin; Android
  /// drives the KMP core through its AAR (the `attriax_flutter_android` Kotlin
  /// plugin). All route through `AttriaxPlatform.instance`. The native engine
  /// owns deep-link capture and resolution, surfacing events through the
  /// platform interface's `attriax/events/*` streams (bridged by
  /// `AttriaxNativeRuntime`).
  static AttriaxRuntimeInterface _buildRuntime({
    required AttriaxConfig config,
    required AttriaxLogger logger,
  }) => AttriaxNativeRuntime(config: config, logger: logger);

  final AttriaxRuntimeInterface _runtime;

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

  /// Tracking, revenue, and user-association helpers.
  late final AttriaxTracking tracking = AttriaxTracking._(_runtime);

  /// Startup and deep-link referrer lookups.
  late final AttriaxReferrer referrer = AttriaxReferrer._(_runtime);

  /// Deep-link state and stream access for immediate, initial, and deferred links.
  ///
  /// Deferred deep links resolved from the app-open flow are surfaced through
  /// these helpers alongside regular incoming links.
  late final AttriaxDeepLinks deepLinks = AttriaxDeepLinks._(_runtime);

  /// Regulation-scoped consent helpers.
  late final AttriaxConsent consent = AttriaxConsent(_runtime);

  /// SKAdNetwork state and update helpers.
  late final AttriaxSkan skan = AttriaxSkan._(_runtime);

  /// Synchronization state and events.
  late final AttriaxSynchronization synchronization = AttriaxSynchronization(
    _runtime,
  );

  /// Initializes the SDK runtime.
  ///
  /// This restores persisted flags, generates or loads the SDK device ID,
  /// captures the immediate context snapshot, and starts listeners.
  ///
  /// App-open tracking is always scheduled automatically in the background.
  /// Use `tracking.enabled` before or after [init] to control event-style
  /// tracking independently.
  Future<void> init() => _runtime.init();

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
    required String receipt,
    bool test = false,
    String? provider,
    String? environment,
    String? productId,
    String? transactionId,
  }) => _runtime.validateReceipt(
    receipt: receipt,
    test: test,
    provider: provider,
    environment: environment,
    productId: productId,
    transactionId: transactionId,
  );

  /// Releases listeners, closes streams, and disposes runtime resources.
  Future<void> dispose() => _runtime.dispose();
}
