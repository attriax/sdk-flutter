import Flutter
import UIKit
import AttriaxCore

/// iOS implementation of the Attriax Flutter plugin (Phase 5 re-wrap).
///
/// The engine now lives in the KMP core (shipped as the `AttriaxCore` XCFramework).
/// This plugin is a THIN shim: it holds the KMP `Attriax` engine — built via
/// `AttriaxApple` — and implements the expanded platform-interface command surface by
/// delegating to it OFF the platform thread, then bridges the engine's
/// synchronization-state transitions to the `attriax/events/synchronization`
/// `EventChannel`. The old native signal-provider code is superseded by the KMP Apple
/// adapters (transport, store, ATT/SKAN/ASA/App-Attest, the real WKWebView UA).
public class AttriaxIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var engine: Attriax?
    private var syncSink: FlutterEventSink?
    private var syncListener: SyncStateListener?

    /// All engine work runs off the platform (main) thread, mirroring the Android
    /// binding and the KMP engine's own off-main threading model.
    private let workQueue = DispatchQueue(label: "com.attriax.sdk.plugin", qos: .utility)

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let plugin = AttriaxIosPlugin()

        let methodChannel = FlutterMethodChannel(name: "attriax", binaryMessenger: messenger)
        registrar.addMethodCallDelegate(plugin, channel: methodChannel)

        let syncChannel = FlutterEventChannel(
            name: "attriax/events/synchronization",
            binaryMessenger: messenger
        )
        syncChannel.setStreamHandler(plugin)
        // NOTE: the deep-link event channels (deep_links / raw_deep_links /
        // initial_deep_link) are wired in a follow-up slice with the deep-link bridge.
    }

    // MARK: - method channel

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any?] ?? [:]

        switch call.method {
        case "initialize":
            initialize(args, result)

        case "recordEvent":
            let name = args["name"] as? String ?? ""
            let eventData = args["eventData"] as? [String: Any]
            let flushImmediately = boolArg(args, "flushImmediately", false)
            withEngine(result) { engine in
                engine.recordEvent(name: name, eventData: eventData, flushImmediately: flushImmediately)
                return nil
            }

        case "flush":
            withEngine(result) { engine in engine.flush(); return nil }

        case "reset":
            withEngine(result) { engine in engine.reset(); return nil }

        case "dispose":
            withEngine(result) { engine in
                engine.dispose()
                self.detachSyncListener(engine)
                self.engine = nil
                return nil
            }

        case "submitAsaToken":
            let token = args["token"] as? String ?? ""
            withEngine(result) { engine in engine.submitAsaToken(token: token); return nil }

        default:
            // The remaining commands (tracking.recordPurchase/recordPageView/recordRefund,
            // consent.gdpr/att/ccpa, deepLinks.*, skan.updateConversionValue, receipt
            // validation, dynamic links) delegate to the corresponding engine sub-surface
            // (`engine.tracking`, `engine.consent`, `engine.skan`, `engine.deepLinks`) and
            // are wired in follow-up slices. Returning notImplemented keeps the contract
            // honest rather than silently succeeding.
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - initialize

    private func initialize(_ args: [String: Any?], _ result: @escaping FlutterResult) {
        guard let configMap = args["config"] as? [String: Any?] else {
            result(FlutterError(code: "bad_args", message: "initialize requires a config map", details: nil))
            return
        }
        workQueue.async {
            let config = self.buildConfig(configMap)
            // userAgent = nil → the KMP Apple layer resolves the REAL WKWebView Safari
            // UA itself (its off-main probe runs safely on this background queue), else
            // a Safari-shaped fallback — never a synthetic slug.
            let engine = AttriaxApple.shared.create(config: config, userAgent: nil)
            engine.doInit()
            self.engine = engine
            self.attachSyncListener(engine)
            DispatchQueue.main.async { result(nil) }
        }
    }

    /// Build the 30-field KMP `AttriaxConfig` from the platform-interface config map.
    /// Defaults mirror `AttriaxConfig`'s own defaults for any absent key.
    private func buildConfig(_ m: [String: Any?]) -> AttriaxConfig {
        let attestationEnabled = boolArg(m, "attestationEnabled", false)
        return AttriaxConfig(
            projectToken: m["projectToken"] as? String ?? "",
            apiBaseUrl: m["apiBaseUrl"] as? String ?? "https://api.attriax.com",
            appVersion: m["appVersion"] as? String,
            appBuildNumber: m["appBuildNumber"] as? String,
            appPackageName: m["appPackageName"] as? String,
            sdkMetadata: m["sdkMetadata"] as? [String: Any],
            deviceContext: nil, // KMP auto-captures the iOS device context.
            enableDebugLogs: boolArg(m, "enableDebugLogs", false),
            requestTimeoutMs: int64Arg(m, "requestTimeoutMs", 12_000),
            maxQueueSize: int32Arg(m, "maxQueueSize", 500),
            eventFlushIntervalMs: int64Arg(m, "eventFlushIntervalMs", 60_000),
            flushEventsImmediatelyOnFirstLaunch: boolArg(m, "flushEventsImmediatelyOnFirstLaunch", true),
            collectAdvertisingId: boolArg(m, "collectAdvertisingId", true),
            automaticCrashReportingEnabled: boolArg(m, "automaticCrashReportingEnabled", true),
            gdprEnabled: boolArg(m, "gdprEnabled", false),
            anonymousTracking: boolArg(m, "anonymousTracking", true),
            sessionTrackingEnabled: boolArg(m, "sessionTrackingEnabled", true),
            sessionHeartbeatIntervalMs: int64Arg(m, "sessionHeartbeatIntervalMs", 300_000),
            firstLaunchSessionHeartbeatIntervalMs: int64Arg(m, "firstLaunchSessionHeartbeatIntervalMs", 30_000),
            installReferrerEnabled: boolArg(m, "installReferrerEnabled", true),
            attestationEnabled: attestationEnabled,
            // App Attest is opt-in; supply the provider only when attestation is enabled.
            attestationProvider: attestationEnabled
                ? AttriaxAppAttestProvider(defaults: UserDefaults(suiteName: "com.attriax.sdk.prefs") ?? .standard)
                : nil,
            pinnedCertificateSha256Fingerprints: (m["pinnedCertificateSha256Fingerprints"] as? [String]) ?? [],
            automaticBrowserHandling: boolArg(m, "automaticBrowserHandling", true),
            attStatus: nil, // resolved by the KMP ATT seam.
            requestTrackingAuthorizationOnInit: boolArg(m, "requestTrackingAuthorizationOnInit", false),
            trackingAuthorizationStatusTimeoutMs: int64Arg(m, "trackingAuthorizationStatusTimeoutMs", 60_000),
            skan: nil, // default AttriaxSkanConfig (enabled).
            asaTokenCaptureEnabled: boolArg(m, "asaTokenCaptureEnabled", true),
            doNotSell: (m["doNotSell"] as? NSNumber).map { KotlinBoolean(bool: $0.boolValue) },
            usPrivacy: m["usPrivacy"] as? String
        )
    }

    // MARK: - synchronization EventChannel

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        syncSink = events
        // Emit the current state immediately so late subscribers are consistent.
        if let engine = engine {
            events(syncWire(engine.synchronization.state))
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        syncSink = nil
        return nil
    }

    private func attachSyncListener(_ engine: Attriax) {
        let listener = SyncStateListener { [weak self] state in
            guard let self = self else { return }
            let wire = self.syncWire(state)
            DispatchQueue.main.async { self.syncSink?(wire) }
        }
        syncListener = listener
        engine.synchronization.addStateListener(listener: listener)
    }

    private func detachSyncListener(_ engine: Attriax) {
        if let listener = syncListener {
            engine.synchronization.removeStateListener(listener: listener)
        }
        syncListener = nil
    }

    /// Map the KMP sync state to the wire string the Dart platform interface parses
    /// (it accepts the enum name in either case).
    private func syncWire(_ state: AttriaxSynchronizationState) -> String {
        return state.name
    }

    // MARK: - helpers

    /// Run [block] on the engine off the platform thread, replying on the main thread.
    private func withEngine(_ result: @escaping FlutterResult, _ block: @escaping (Attriax) -> Any?) {
        workQueue.async {
            guard let engine = self.engine else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "not_initialized", message: "Attriax is not initialized", details: nil))
                }
                return
            }
            let value = block(engine)
            DispatchQueue.main.async { result(value) }
        }
    }

    private func boolArg(_ m: [String: Any?], _ key: String, _ fallback: Bool) -> Bool {
        (m[key] as? NSNumber)?.boolValue ?? (m[key] as? Bool) ?? fallback
    }

    private func int64Arg(_ m: [String: Any?], _ key: String, _ fallback: Int64) -> Int64 {
        (m[key] as? NSNumber)?.int64Value ?? fallback
    }

    private func int32Arg(_ m: [String: Any?], _ key: String, _ fallback: Int32) -> Int32 {
        (m[key] as? NSNumber)?.int32Value ?? fallback
    }
}

/// Bridges the KMP `AttriaxSynchronizationStateListener` protocol to a Swift closure.
private final class SyncStateListener: NSObject, AttriaxSynchronizationStateListener {
    private let onChange: (AttriaxSynchronizationState) -> Void
    init(_ onChange: @escaping (AttriaxSynchronizationState) -> Void) { self.onChange = onChange }
    func onSynchronizationStateChanged(state: AttriaxSynchronizationState) { onChange(state) }
}
