import FlutterMacOS
import Cocoa
import AttriaxCore

/// macOS implementation of the Attriax Flutter plugin (Phase 5 re-wrap).
///
/// The engine lives in the KMP core (shipped as the `AttriaxCore` XCFramework). This
/// plugin is a THIN shim: it holds the KMP `Attriax` engine — built via `AttriaxApple`
/// — and implements the expanded platform-interface command surface by delegating to
/// the engine (and its `tracking` / `consent` / `skan` / `deepLinks` sub-surfaces) OFF
/// the platform thread, bridging the engine's synchronization-state + deep-link events
/// to their `EventChannel`s. The old native signal-provider code is superseded by the
/// KMP Apple adapters (transport, store, ATT/SKAN/ASA/App-Attest, the real WKWebView UA).
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
        let messenger = registrar.messenger
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
        // ---- lifecycle ----
        case "initialize": initialize(a, result)
        case "flush": run(result) { $0.flush(); return nil }
        case "reset": run(result) { $0.reset(); return nil }
        case "dispose":
            run(result) { engine in
                self.detachListeners(engine)
                engine.dispose()
                self.engine = nil
                return nil
            }
        case "submitAsaToken":
            run(result) { $0.submitAsaToken(token: a["token"] as? String ?? ""); return nil }

        // ---- primitive getters / setters ----
        case "getDeviceId": run(result) { $0.deviceId }
        case "getIsInitialized": run(result) { $0.isInitialized }
        case "getIsFirstLaunch": run(result) { $0.isFirstLaunch }
        case "getSdkEnabled": run(result) { $0.enabled }
        case "setSdkEnabled": run(result) { $0.enabled = self.bool(a, "enabled", true); return nil }
        case "getAnonymousTracking": run(result) { $0.anonymousTrackingEnabled }
        case "setAnonymousTracking": run(result) { $0.anonymousTrackingEnabled = self.bool(a, "enabled", true); return nil }
        case "getEventTrackingEnabled": run(result) { $0.tracking.enabled }
        case "getIsSynchronized": run(result) { $0.synchronization.isSynchronized }
        case "getIsWaitingForGdprConsent": run(result) { $0.consent.gdpr.isWaitingForConsent }
        case "getSdkSnapshot": run(result) { self.serializeSnapshot($0.sdkSnapshot) }
        case "getSkanState": run(result) { self.serializeSkanState($0.skan.state) }

        // ---- tracking ----
        case "recordEvent":
            run(result) { $0.recordEvent(name: a["name"] as? String ?? "",
                                         eventData: a["eventData"] as? [String: Any],
                                         flushImmediately: self.bool(a, "flushImmediately", false)); return nil }
        case "recordPageView":
            run(result) { $0.tracking.recordPageView(
                pageName: a["pageName"] as? String ?? "",
                pageClass: a["pageClass"] as? String,
                pageTitle: a["pageTitle"] as? String,
                previousPageName: a["previousPageName"] as? String,
                parameters: a["parameters"] as? [String: Any],
                source: a["source"] as? String ?? "manual",
                flushImmediately: self.bool(a, "flushImmediately", false)); return nil }
        case "recordPurchase":
            run(result) { $0.tracking.recordPurchase(
                revenue: self.double(a, "revenue", 0), currency: a["currency"] as? String ?? "",
                revenueInMicros: self.bool(a, "revenueInMicros", false),
                purchaseType: a["purchaseType"] as? String, productId: a["productId"] as? String,
                transactionId: a["transactionId"] as? String, originalTransactionId: a["originalTransactionId"] as? String,
                validationProvider: a["validationProvider"] as? String, validationEnvironment: a["validationEnvironment"] as? String,
                purchaseToken: a["purchaseToken"] as? String, receiptData: a["receiptData"] as? String,
                signedPayload: a["signedPayload"] as? String, receiptSignature: a["receiptSignature"] as? String,
                isRenewal: self.kbool(a["isRenewal"]), quantity: self.int32(a, "quantity", 1),
                store: a["store"] as? String, packageName: a["packageName"] as? String,
                voided: self.kbool(a["voided"]), test: self.kbool(a["test"]),
                validationId: a["validationId"] as? String, metadata: a["metadata"] as? [String: Any],
                flushImmediately: self.bool(a, "flushImmediately", false)); return nil }
        case "recordRefund":
            run(result) { $0.tracking.recordRefund(
                revenue: self.double(a, "revenue", 0), currency: a["currency"] as? String ?? "",
                revenueInMicros: self.bool(a, "revenueInMicros", false),
                purchaseType: a["purchaseType"] as? String, productId: a["productId"] as? String,
                transactionId: a["transactionId"] as? String, originalTransactionId: a["originalTransactionId"] as? String,
                quantity: self.int32(a, "quantity", 1), store: a["store"] as? String, packageName: a["packageName"] as? String,
                voided: self.kbool(a["voided"]), test: self.kbool(a["test"]), reason: a["reason"] as? String,
                metadata: a["metadata"] as? [String: Any], flushImmediately: self.bool(a, "flushImmediately", false)); return nil }
        case "recordAdRevenue":
            run(result) { $0.tracking.recordAdRevenue(
                revenue: self.double(a, "revenue", 0), currency: a["currency"] as? String ?? "",
                revenueInMicros: self.bool(a, "revenueInMicros", false),
                adNetwork: a["adNetwork"] as? String, adFormat: a["adFormat"] as? String, adType: a["adType"] as? String,
                adPlacement: a["adPlacement"] as? String, test: self.kbool(a["test"]),
                metadata: a["metadata"] as? [String: Any], flushImmediately: self.bool(a, "flushImmediately", false)); return nil }
        case "recordAdEvent":
            run(result) { $0.tracking.recordAdEvent(
                type: self.adEventType(a["type"] as? String),
                adNetwork: a["adNetwork"] as? String, mediationNetwork: a["mediationNetwork"] as? String,
                adUnitId: a["adUnitId"] as? String, adPlacement: a["adPlacement"] as? String,
                adFormat: a["adFormat"] as? String, adType: a["adType"] as? String,
                failureReason: a["failureReason"] as? String, loadLatencyMs: self.kdouble(a["loadLatencyMs"]),
                rewardType: a["rewardType"] as? String, rewardAmount: self.kdouble(a["rewardAmount"]),
                test: self.kbool(a["test"]), metadata: a["metadata"] as? [String: Any],
                flushImmediately: self.bool(a, "flushImmediately", false)); return nil }
        case "recordNotification":
            run(result) { $0.tracking.recordNotification(
                type: self.notificationType(a["type"] as? String),
                notificationId: a["notificationId"] as? String ?? "",
                linkId: a["linkId"] as? String, campaignId: a["campaignId"] as? String, title: a["title"] as? String,
                source: self.notificationSource(a["source"] as? String), payload: a["payload"] as? [String: Any],
                metadata: a["metadata"] as? [String: Any], flushImmediately: self.bool(a, "flushImmediately", false)); return nil }
        case "recordError":
            run(result) { $0.tracking.recordError(
                error: KotlinThrowable(message: a["message"] as? String ?? (a["error"] as? String ?? "error")),
                stackTrace: a["stackTrace"] as? String, fatal: self.bool(a, "fatal", false),
                source: a["source"] as? String ?? "manual", reason: a["reason"] as? String,
                metadata: a["metadata"] as? [String: Any]); return nil }
        case "setUser":
            run(result) { $0.tracking.setUser(userId: a["userId"] as? String, userName: a["userName"] as? String); return nil }
        case "setUserProperty":
            run(result) { $0.tracking.setUserProperty(name: a["name"] as? String ?? "", value: a["value"] ?? nil); return nil }
        case "setUserProperties":
            run(result) { $0.tracking.setUserProperties(properties: a["properties"] as? [String: Any] ?? [:]); return nil }
        case "clearUserProperties":
            run(result) { $0.tracking.clearUserProperties(propertyNames: a["propertyNames"] as? [String]); return nil }
        case "registerPushToken":
            run(result) { engine in
                let token = a["token"] as? String
                let metadata = a["metadata"] as? [String: Any]
                if (a["provider"] as? String) == "apns" {
                    engine.tracking.registerApplePushToken(token: token, metadata: metadata)
                } else {
                    engine.tracking.registerFirebaseMessagingToken(token: token, metadata: metadata)
                }
                return nil
            }

        // ---- consent (GDPR / CCPA / ATT) ----
        case "setGdprConsent":
            run(result) { $0.consent.gdpr.setConsent(
                analytics: self.bool(a, "analytics", false),
                attribution: self.bool(a, "attribution", false),
                adEvents: self.bool(a, "adEvents", false)); return nil }
        case "setGdprConsentNotRequired": run(result) { $0.consent.gdpr.setNotRequired(); return nil }
        case "resetGdprConsent": run(result) { $0.consent.gdpr.reset(); return nil }
        case "requestGdprDataErasure": run(result) { $0.consent.gdpr.requestDataErasure(); return nil }
        case "setCcpaConsent":
            run(result) { $0.consent.ccpa.set(doNotSell: self.kbool(a["doNotSell"]), usPrivacy: a["usPrivacy"] as? String); return nil }
        case "setTrackingAuthorizationStatus":
            run(result) { $0.consent.att.setStatus(status: self.attStatus(a["status"] as? String)); return nil }

        // ---- SKAN ----
        case "updateSkanConversionValue":
            run(result) { self.serializeSkanResult($0.skan.updateConversionValue(
                fineValue: self.int32(a, "fineValue", 0),
                coarseValue: self.coarse(a["coarseValue"] as? String),
                lockWindow: self.bool(a, "lockWindow", false))) }

        // ---- deep links ----
        case "handleIncomingLink":
            run(result) { $0.deepLinks.handleUri(rawUri: a["uri"] as? String ?? "",
                                                 isInitialLink: self.bool(a, "isInitialLink", false)); return nil }

        default:
            // Rich deep-link getters (getInitialDeepLink / getLatestDeepLink /
            // getRawInitialDeepLink / getIsInitialDeepLinkResolved / completeInitialDeepLink /
            // getRawInstallReferrer) and receipt validation return complex objects whose
            // exact wire shape is validated when the Dart facade rewire (Phase 4) activates
            // the native runtime path. Reported honestly rather than returning malformed data.
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
            // App Attest (DCAppAttestService) is iOS-only; on macOS the KMP framework
            // exposes no AttriaxAppAttestProvider, so attestation stays inert here.
            attestationProvider: nil,
            pinnedCertificateSha256Fingerprints: (m["pinnedCertificateSha256Fingerprints"] as? [String]) ?? [],
            automaticBrowserHandling: bool(m, "automaticBrowserHandling", true), attStatus: nil,
            requestTrackingAuthorizationOnInit: bool(m, "requestTrackingAuthorizationOnInit", false),
            trackingAuthorizationStatusTimeoutMs: int64(m, "trackingAuthorizationStatusTimeoutMs", 60_000),
            skan: nil, asaTokenCaptureEnabled: bool(m, "asaTokenCaptureEnabled", true),
            doNotSell: kbool(m["doNotSell"]), usPrivacy: m["usPrivacy"] as? String)
    }

    // MARK: - engine event listeners

    private func attachListeners(_ engine: Attriax) {
        let sync = SyncStateListener { [weak self] state in self?.syncStream.emit(state.name) }
        engine.synchronization.addStateListener(listener: sync); syncListener = sync

        let deep = DeepLinkListener { [weak self] event in self?.deepLinkStream.emit(self?.serializeDeepLinkEvent(event)) }
        engine.deepLinks.addListener(listener: deep); deepLinkListener = deep

        let raw = RawDeepLinkListener { [weak self] event in
            self?.rawDeepLinkStream.emit(["uri": event.uri, "receivedAtMs": event.receivedAtMs])
        }
        engine.deepLinks.addRawListener(listener: raw); rawDeepLinkListener = raw
    }

    private func detachListeners(_ engine: Attriax) {
        if let l = syncListener { engine.synchronization.removeStateListener(listener: l) }
        if let l = deepLinkListener { engine.deepLinks.removeListener(listener: l) }
        if let l = rawDeepLinkListener { engine.deepLinks.removeRawListener(listener: l) }
        syncListener = nil; deepLinkListener = nil; rawDeepLinkListener = nil
    }

    // MARK: - serialization (best-effort; validated against the Dart parsers when the
    // facade rewire activates the native runtime path)

    private func serializeSkanResult(_ r: AttriaxSkanUpdateResult) -> [String: Any?] {
        return ["status": r.status.wireValue, "message": r.message,
                "fineValue": r.fineValue, "coarseValue": r.coarseValue?.wireValue, "lockWindow": r.lockWindow]
    }

    private func serializeSkanState(_ s: AttriaxSkanState?) -> [String: Any?]? {
        guard let s = s else { return nil }
        return ["enabled": s.enabled, "fineValue": s.fineValue,
                "coarseValue": s.coarseValue?.wireValue, "lockWindow": s.lockWindow]
    }

    private func serializeSnapshot(_ s: AttriaxSdkSnapshot) -> [String: Any?] {
        return ["apiVersion": s.apiVersion, "packageVersion": s.packageVersion, "metadata": s.metadata]
    }

    private func serializeDeepLinkEvent(_ e: AttriaxDeepLinkEvent) -> [String: Any?] {
        return ["uri": e.uri.raw, "status": e.status.name, "trigger": e.trigger.name,
                "found": e.found, "handledBySdk": e.handledBySdk, "isDeferred": e.isDeferred,
                "isColdStart": e.isColdStart, "isForeground": e.isForeground, "data": e.data]
    }

    // MARK: - helpers

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

    private func bool(_ m: [String: Any?], _ k: String, _ d: Bool) -> Bool {
        (m[k] as? NSNumber)?.boolValue ?? (m[k] as? Bool) ?? d
    }
    private func int64(_ m: [String: Any?], _ k: String, _ d: Int64) -> Int64 { (m[k] as? NSNumber)?.int64Value ?? d }
    private func int32(_ m: [String: Any?], _ k: String, _ d: Int32) -> Int32 { (m[k] as? NSNumber)?.int32Value ?? d }
    private func double(_ m: [String: Any?], _ k: String, _ d: Double) -> Double { (m[k] as? NSNumber)?.doubleValue ?? d }
    private func kbool(_ v: Any??) -> KotlinBoolean? { (v as? NSNumber).map { KotlinBoolean(bool: $0.boolValue) } }
    private func kdouble(_ v: Any??) -> KotlinDouble? { (v as? NSNumber).map { KotlinDouble(double: $0.doubleValue) } }

    private func attStatus(_ w: String?) -> AttriaxAttStatus {
        switch w {
        case "authorized": return .authorized
        case "denied": return .denied
        case "restricted": return .restricted
        case "notDetermined", "not_determined": return .notDetermined
        default: return .unknown
        }
    }
    private func coarse(_ w: String?) -> AttriaxSkanCoarseValue? {
        switch w?.lowercased() { case "low": return .low; case "medium": return .medium; case "high": return .high; default: return nil }
    }
    private func adEventType(_ w: String?) -> AttriaxAdEventType {
        switch w { case "load_failed", "loadFailed": return .loadFailed; case "show": return .show
        case "show_failed", "showFailed": return .showFailed; case "impression": return .impression
        case "click": return .click; case "dismiss": return .dismiss; case "reward": return .reward
        default: return .request }
    }
    private func notificationType(_ w: String?) -> AttriaxNotificationEventType {
        switch w { case "opened": return .opened; case "dismissed": return .dismissed; default: return .received }
    }
    private func notificationSource(_ w: String?) -> AttriaxNotificationEventSource? {
        switch w { case "fcm": return .fcm; case "apns": return .apns; case "other": return .other; default: return nil }
    }
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
