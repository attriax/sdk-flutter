import Flutter
import UIKit
import AttriaxCore

/// iOS implementation of the Attriax Flutter plugin (Phase 5 re-wrap).
///
/// The engine lives in the KMP core (shipped as the `AttriaxCore` XCFramework). This
/// plugin is a THIN shim: it holds the KMP `Attriax` engine — built via `AttriaxApple`
/// — and forwards the dispatchable command surface to the core's canonical
/// `AttriaxDispatcher.execute(engine:method:params:)` table (the same table the Android
/// JNI wrapper and the C-ABI shared library forward to), OFF the platform thread,
/// bridging the engine's synchronization-state + deep-link events to their
/// `EventChannel`s. A handful of methods stay engine-direct on purpose (see `handle`).
public class AttriaxIosPlugin: NSObject, FlutterPlugin {

    private var engine: Attriax?
    private let workQueue = DispatchQueue(label: "com.attriax.sdk.plugin", qos: .utility)

    private let syncStream = AttriaxEventStream()
    private let deepLinkStream = AttriaxEventStream()
    private let rawDeepLinkStream = AttriaxEventStream()
    private let initialDeepLinkStream = AttriaxEventStream()

    private var syncListener: SyncStateListener?
    private var deepLinkListener: DeepLinkListener?
    private var rawDeepLinkListener: RawDeepLinkListener?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let plugin = AttriaxIosPlugin()

        let methodChannel = FlutterMethodChannel(name: "attriax", binaryMessenger: messenger)
        registrar.addMethodCallDelegate(plugin, channel: methodChannel)

        FlutterEventChannel(name: "attriax/events/synchronization", binaryMessenger: messenger)
            .setStreamHandler(plugin.syncStream)
        FlutterEventChannel(name: "attriax/events/deep_links", binaryMessenger: messenger)
            .setStreamHandler(plugin.deepLinkStream)
        FlutterEventChannel(name: "attriax/events/raw_deep_links", binaryMessenger: messenger)
            .setStreamHandler(plugin.rawDeepLinkStream)
        FlutterEventChannel(name: "attriax/events/initial_deep_link", binaryMessenger: messenger)
            .setStreamHandler(plugin.initialDeepLinkStream)
    }

    // MARK: - method channel

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let a = call.arguments as? [String: Any?] ?? [:]

        switch call.method {
        // ---- lifecycle: engine construction / teardown stay plugin-side ----
        // `execute` operates on an already-built engine, so it can neither create
        // (initialize) nor tear down (dispose) it.
        case "initialize": initialize(a, result)
        case "dispose":
            run(result) { engine in
                self.detachListeners(engine)
                engine.dispose()
                self.engine = nil
                return nil
            }

        // ---- Dart command names that ARE the canonical dispatch key ----
        // The arg map flows straight through and the canonical `Ok.value` shape is
        // exactly what the Dart parsers consume (snapshot / skan-state / skan-update /
        // receipt / referrer maps are produced inside AttriaxDispatcher).
        case "flush", "reset",
             "getDeviceId", "getIsInitialized", "getIsFirstLaunch",
             "getAnonymousTracking", "setAnonymousTracking",
             "getIsSynchronized", "getIsWaitingForGdprConsent",
             "getSdkSnapshot", "getSkanState", "getSynchronizationState",
             "recordEvent", "recordPageView", "recordPurchase", "recordRefund",
             "recordAdRevenue", "recordNotification", "recordError",
             "setUser", "setUserProperty", "setUserProperties", "clearUserProperties",
             "setGdprConsent", "setGdprConsentNotRequired", "resetGdprConsent",
             "requestGdprDataErasure", "setCcpaConsent",
             "updateSkanConversionValue", "handleIncomingLink", "submitAsaToken",
             "validateReceipt",
             "getOriginalInstallReferrer", "getReinstallReferrer", "getRawInstallReferrer",
             "getSessionReferrer", "getLatestDeepLinkReferrer":
            forward(result, call.method, a)

        // ---- Dart command names that differ from the dispatch key ----
        case "getSdkEnabled": forward(result, "getEnabled", a)
        case "setSdkEnabled": forward(result, "setEnabled", a)
        // The platform interface sends the resolved reserved event name under
        // `eventName`; the dispatch table reads it under `type` (it resolves the enum by
        // name OR eventName), so alias it across before forwarding.
        case "recordAdEvent":
            var p = a; p["type"] = a["eventName"] ?? nil
            forward(result, "recordAdEvent", p)
        // One Dart command → the provider-split registration dispatch keys.
        case "registerPushToken":
            forward(result,
                    (a["provider"] as? String) == "apns" ? "registerApplePushToken" : "registerFirebaseMessagingToken",
                    a)

        // ---- kept engine-direct: genuinely wrapper-specific, not duplication ----
        // `tracking.enabled` has no dispatch key.
        case "getEventTrackingEnabled": run(result) { $0.tracking.enabled }
        // ATT stays direct on purpose: the Dart `AttriaxTrackingAuthorizationStatus` is a
        // RICHER enum (8 values incl. notSupported / disabled / timedOut) than the
        // engine's canonical 5-value `AttriaxAttStatus`, and snake_cased (`not_determined`)
        // vs the engine wireValue (`notDetermined`). The wrapper's tolerant mapper
        // normalizes 8→5 inbound and 5→snake outbound; the dispatch keys
        // (get/setAttStatus, requestAttAuthorization) emit the canonical camelCase
        // wireValue, so forwarding would relocate wrapper-only logic.
        case "setTrackingAuthorizationStatus":
            run(result) { $0.consent.att.setStatus(status: self.attStatus(a["status"] as? String)); return nil }
        case "getTrackingAuthorizationStatus":
            run(result) { self.attStatusWire($0.consent.att.status) }
        case "requestTrackingAuthorization":
            run(result) { self.attStatusWire($0.consent.att.requestAuthorization(timeoutMs: nil)) }

        // ---- kept engine-direct: not a canonical dispatch key ----
        // createDynamicLink takes richer typed inputs (social preview / utms / redirects)
        // and is not in the command table, so the wrapper builds the call directly.
        case "createDynamicLink":
            run(result) { self.serializeDynamicLinkResult($0.deepLinks.createDynamicLink(
                name: a["name"] as? String, destinationUrl: a["destinationUrl"] as? String,
                group: a["group"] as? String, prefix: a["prefix"] as? String,
                socialPreview: self.socialPreview(a["socialPreview"] as? [String: Any?]),
                utms: self.utms(a["utms"] as? [String: Any?]),
                redirects: self.redirects(a["redirects"] as? [String: Any?]),
                data: a["data"] as? [String: Any])) }

        default:
            // The remaining deep-link snapshot getters (getInitialDeepLink /
            // getLatestDeepLink / getRawInitialDeepLink / getIsInitialDeepLinkResolved /
            // completeInitialDeepLink) are served from AttriaxNativeRuntime's cache +
            // the deep-link event streams rather than a per-call round-trip.
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - initialize

    private func initialize(_ a: [String: Any?], _ result: @escaping FlutterResult) {
        guard let configMap = a["config"] as? [String: Any?] else {
            result(FlutterError(code: "bad_args", message: "initialize requires a config map", details: nil)); return
        }
        workQueue.async {
            let config = self.buildConfig(configMap)
            // userAgent nil → the KMP Apple layer resolves the REAL WKWebView Safari UA
            // (its off-main probe runs safely here), else a Safari-shaped fallback.
            let engine = AttriaxApple.shared.create(config: config, userAgent: nil)
            engine.doInit()
            self.engine = engine
            self.attachListeners(engine)
            DispatchQueue.main.async { result(nil) }
        }
    }

    private func buildConfig(_ m: [String: Any?]) -> AttriaxConfig {
        let attestationEnabled = bool(m, "attestationEnabled", false)
        return AttriaxConfig(
            projectToken: m["projectToken"] as? String ?? "",
            apiBaseUrl: m["apiBaseUrl"] as? String ?? "https://api.attriax.com",
            appVersion: m["appVersion"] as? String, appBuildNumber: m["appBuildNumber"] as? String,
            appPackageName: m["appPackageName"] as? String, sdkMetadata: m["sdkMetadata"] as? [String: Any],
            deviceContext: nil, enableDebugLogs: bool(m, "enableDebugLogs", false),
            requestTimeoutMs: int64(m, "requestTimeoutMs", 12_000), maxQueueSize: int32(m, "maxQueueSize", 500),
            eventFlushIntervalMs: int64(m, "eventFlushIntervalMs", 60_000),
            flushEventsImmediatelyOnFirstLaunch: bool(m, "flushEventsImmediatelyOnFirstLaunch", true),
            collectAdvertisingId: bool(m, "collectAdvertisingId", true),
            automaticCrashReportingEnabled: bool(m, "automaticCrashReportingEnabled", true),
            gdprEnabled: bool(m, "gdprEnabled", false), anonymousTracking: bool(m, "anonymousTracking", true),
            sessionTrackingEnabled: bool(m, "sessionTrackingEnabled", true),
            sessionHeartbeatIntervalMs: int64(m, "sessionHeartbeatIntervalMs", 300_000),
            firstLaunchSessionHeartbeatIntervalMs: int64(m, "firstLaunchSessionHeartbeatIntervalMs", 30_000),
            installReferrerEnabled: bool(m, "installReferrerEnabled", true),
            attestationEnabled: attestationEnabled,
            attestationProvider: attestationEnabled
                ? AttriaxAppAttestProvider(defaults: UserDefaults(suiteName: "com.attriax.sdk.prefs") ?? .standard)
                : nil,
            pinnedCertificateSha256Fingerprints: (m["pinnedCertificateSha256Fingerprints"] as? [String]) ?? [],
            automaticBrowserHandling: bool(m, "automaticBrowserHandling", true), attStatus: nil,
            requestTrackingAuthorizationOnInit: bool(m, "requestTrackingAuthorizationOnInit", false),
            trackingAuthorizationStatusTimeoutMs: int64(m, "trackingAuthorizationStatusTimeoutMs", 60_000),
            skan: nil, asaTokenCaptureEnabled: bool(m, "asaTokenCaptureEnabled", true),
            doNotSell: kbool(m["doNotSell"]), usPrivacy: m["usPrivacy"] as? String)
    }

    // MARK: - engine event listeners (out-of-band; NOT routed through execute)

    private func attachListeners(_ engine: Attriax) {
        let sync = SyncStateListener { [weak self] state in self?.syncStream.emit(state.name) }
        engine.synchronization.addStateListener(listener: sync); syncListener = sync

        let deep = DeepLinkListener { [weak self] event in self?.deepLinkStream.emit(self?.serializeDeepLinkEvent(event)) }
        engine.deepLinks.addListener(listener: deep); deepLinkListener = deep

        let raw = RawDeepLinkListener { [weak self] event in
            self?.rawDeepLinkStream.emit(["uri": event.uri.raw, "receivedAtMs": event.receivedAtMs])
        }
        engine.deepLinks.addRawListener(listener: raw); rawDeepLinkListener = raw
    }

    private func detachListeners(_ engine: Attriax) {
        if let l = syncListener { engine.synchronization.removeStateListener(listener: l) }
        if let l = deepLinkListener { engine.deepLinks.removeListener(listener: l) }
        if let l = rawDeepLinkListener { engine.deepLinks.removeRawListener(listener: l) }
        syncListener = nil; deepLinkListener = nil; rawDeepLinkListener = nil
    }

    // MARK: - deep-link event serialization for the EventChannel
    // (Command-result shaping — snapshot / skan-state / skan-update / receipt / referrer
    // — now lives inside AttriaxDispatcher.)

    private func serializeDeepLinkEvent(_ e: AttriaxDeepLinkEvent) -> [String: Any?] {
        return ["uri": e.uri.raw, "status": e.status.name, "trigger": e.trigger.name,
                "found": e.found, "handledBySdk": e.handledBySdk, "isDeferred": e.isDeferred,
                "isColdStart": e.isColdStart, "isForeground": e.isForeground, "data": e.data]
    }

    // MARK: - createDynamicLink shaping (kept engine-direct — not a dispatch key)

    private func serializeDynamicLinkResult(_ r: AttriaxCreateDynamicLinkResult) -> [String: Any?] {
        // KMP exposes `record`; the Dart parser reads a nested `link` map.
        return ["link": self.serializeDynamicLinkRecord(r.record)]
    }

    private func serializeDynamicLinkRecord(_ rec: AttriaxDynamicLinkRecord) -> [String: Any?] {
        return ["id": rec.id, "path": rec.path, "shortUrl": rec.shortUrl, "name": rec.name,
                "destinationUrl": rec.destinationUrl, "group": rec.group, "prefix": rec.prefix,
                "data": rec.data]
    }

    private func socialPreview(_ m: [String: Any?]?) -> AttriaxDynamicLinkSocialPreview? {
        guard let m = m else { return nil }
        return AttriaxDynamicLinkSocialPreview(title: m["title"] as? String, description: m["description"] as? String)
    }
    private func utms(_ m: [String: Any?]?) -> AttriaxDynamicLinkUtms? {
        guard let m = m else { return nil }
        return AttriaxDynamicLinkUtms(source: m["source"] as? String, medium: m["medium"] as? String,
                                      campaign: m["campaign"] as? String, term: m["term"] as? String,
                                      content: m["content"] as? String)
    }
    private func redirects(_ m: [String: Any?]?) -> AttriaxDynamicLinkRedirects? {
        guard let m = m else { return nil }
        return AttriaxDynamicLinkRedirects(ios: self.kbool(m["ios"]), android: self.kbool(m["android"]))
    }

    // MARK: - ATT wire mapping (kept engine-direct)

    private func attStatusWire(_ s: AttriaxAttStatus) -> String {
        // KMP wireValue is camelCase (notDetermined); the Dart channel decoder expects
        // snake_case (not_determined).
        switch s.wireValue {
        case "authorized": return "authorized"
        case "denied": return "denied"
        case "restricted": return "restricted"
        case "notDetermined": return "not_determined"
        default: return "unknown"
        }
    }

    private func attStatus(_ w: String?) -> AttriaxAttStatus {
        switch w {
        case "authorized": return .authorized
        case "denied": return .denied
        case "restricted": return .restricted
        case "notDetermined", "not_determined": return .notDetermined
        default: return .unknown
        }
    }

    // MARK: - helpers

    /// Run an engine-direct command OFF the platform thread. Used for the handful of
    /// methods that are NOT canonical dispatch keys (ATT normalization, createDynamicLink,
    /// tracking.enabled) and for lifecycle teardown.
    private func run(_ result: @escaping FlutterResult, _ block: @escaping (Attriax) -> Any?) {
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

    /// Forward a command to the KMP core's canonical `AttriaxDispatcher.execute` OFF the
    /// platform thread and map its `AttriaxDispatchResult` onto the reply. `execute` does
    /// not catch engine exceptions — same as the old per-method dispatch — so behavior is
    /// preserved.
    private func forward(_ result: @escaping FlutterResult, _ method: String, _ args: [String: Any?]) {
        workQueue.async {
            guard let engine = self.engine else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "not_initialized", message: "Attriax is not initialized", details: nil))
                }
                return
            }
            // Flutter delivers Dart null as NSNull, so dropping nil values keeps key
            // presence identical to the previous per-method extraction; the dispatch table
            // reads via `as?`, treating NSNull like an absent value.
            let params = args.compactMapValues { $0 }
            let outcome = AttriaxDispatcher.shared.execute(engine: engine, method: method, params: params)
            DispatchQueue.main.async {
                switch outcome {
                case let ok as AttriaxDispatchResultOk: result(ok.value)
                case let err as AttriaxDispatchResultErr: result(FlutterError(code: "error", message: err.message, details: nil))
                default: result(FlutterMethodNotImplemented)
                }
            }
        }
    }

    private func bool(_ m: [String: Any?], _ k: String, _ d: Bool) -> Bool {
        (m[k] as? NSNumber)?.boolValue ?? (m[k] as? Bool) ?? d
    }
    private func int64(_ m: [String: Any?], _ k: String, _ d: Int64) -> Int64 { (m[k] as? NSNumber)?.int64Value ?? d }
    private func int32(_ m: [String: Any?], _ k: String, _ d: Int32) -> Int32 { (m[k] as? NSNumber)?.int32Value ?? d }
    private func kbool(_ v: Any??) -> KotlinBoolean? { (v as? NSNumber).map { KotlinBoolean(bool: $0.boolValue) } }
}

/// A reusable `FlutterStreamHandler` that buffers the latest value until a listener
/// attaches and forwards subsequent values to the sink on the main thread.
private final class AttriaxEventStream: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events; return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? { sink = nil; return nil }
    func emit(_ value: Any?) {
        DispatchQueue.main.async { self.sink?(value) }
    }
}

private final class SyncStateListener: NSObject, AttriaxSynchronizationStateListener {
    private let cb: (AttriaxSynchronizationState) -> Void
    init(_ cb: @escaping (AttriaxSynchronizationState) -> Void) { self.cb = cb }
    func onSynchronizationStateChanged(state: AttriaxSynchronizationState) { cb(state) }
}
private final class DeepLinkListener: NSObject, AttriaxDeepLinkListener {
    private let cb: (AttriaxDeepLinkEvent) -> Void
    init(_ cb: @escaping (AttriaxDeepLinkEvent) -> Void) { self.cb = cb }
    func onDeepLink(event: AttriaxDeepLinkEvent) { cb(event) }
}
private final class RawDeepLinkListener: NSObject, AttriaxRawDeepLinkListener {
    private let cb: (AttriaxRawDeepLinkEvent) -> Void
    init(_ cb: @escaping (AttriaxRawDeepLinkEvent) -> Void) { self.cb = cb }
    func onRawDeepLink(event: AttriaxRawDeepLinkEvent) { cb(event) }
}
