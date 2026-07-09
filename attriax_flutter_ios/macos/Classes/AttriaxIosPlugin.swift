import Cocoa
import FlutterMacOS
import AttriaxCore

/// macOS implementation of the Attriax Flutter plugin (Phase 5 re-wrap).
///
/// The engine now lives in the KMP core (shipped as the `AttriaxCore` XCFramework;
/// the `macos-arm64_x86_64` slice). This plugin is a THIN shim: it holds the KMP
/// `Attriax` engine — built via `AttriaxApple` — implements the platform-interface
/// command surface by delegating OFF the platform thread, and bridges the engine's
/// synchronization-state transitions to the `attriax/events/synchronization`
/// `EventChannel`. Mirrors the iOS plugin; only the Flutter macOS registrar API +
/// Cocoa import differ. The old native signal-provider code is superseded by the KMP
/// Apple adapters.
public final class AttriaxIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var engine: Attriax?
    private var syncSink: FlutterEventSink?
    private var syncListener: SyncStateListener?
    private let workQueue = DispatchQueue(label: "com.attriax.sdk.plugin", qos: .utility)

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger
        let plugin = AttriaxIosPlugin()

        let methodChannel = FlutterMethodChannel(name: "attriax", binaryMessenger: messenger)
        registrar.addMethodCallDelegate(plugin, channel: methodChannel)

        let syncChannel = FlutterEventChannel(
            name: "attriax/events/synchronization",
            binaryMessenger: messenger
        )
        syncChannel.setStreamHandler(plugin)
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
            let engine = AttriaxApple.shared.create(config: config, userAgent: nil)
            engine.doInit()
            self.engine = engine
            self.attachSyncListener(engine)
            DispatchQueue.main.async { result(nil) }
        }
    }

    private func buildConfig(_ m: [String: Any?]) -> AttriaxConfig {
        let attestationEnabled = boolArg(m, "attestationEnabled", false)
        return AttriaxConfig(
            projectToken: m["projectToken"] as? String ?? "",
            apiBaseUrl: m["apiBaseUrl"] as? String ?? "https://api.attriax.com",
            appVersion: m["appVersion"] as? String,
            appBuildNumber: m["appBuildNumber"] as? String,
            appPackageName: m["appPackageName"] as? String,
            sdkMetadata: m["sdkMetadata"] as? [String: Any],
            deviceContext: nil,
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
            // App Attest is iOS-only; on macOS the provider is inert, so leave it nil.
            attestationProvider: nil,
            pinnedCertificateSha256Fingerprints: (m["pinnedCertificateSha256Fingerprints"] as? [String]) ?? [],
            automaticBrowserHandling: boolArg(m, "automaticBrowserHandling", true),
            attStatus: nil,
            requestTrackingAuthorizationOnInit: boolArg(m, "requestTrackingAuthorizationOnInit", false),
            trackingAuthorizationStatusTimeoutMs: int64Arg(m, "trackingAuthorizationStatusTimeoutMs", 60_000),
            skan: nil,
            asaTokenCaptureEnabled: boolArg(m, "asaTokenCaptureEnabled", true),
            doNotSell: (m["doNotSell"] as? NSNumber).map { KotlinBoolean(bool: $0.boolValue) },
            usPrivacy: m["usPrivacy"] as? String
        )
    }

    // MARK: - synchronization EventChannel

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        syncSink = events
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

    private func syncWire(_ state: AttriaxSynchronizationState) -> String {
        return state.name
    }

    // MARK: - helpers

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
