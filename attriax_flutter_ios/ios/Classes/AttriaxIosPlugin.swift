import Flutter
import Security
import StoreKit
import UIKit
import Darwin
#if canImport(AdSupport)
import AdSupport
#endif
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

private let attriaxPendingCrashKey = "attriax.pending_crash"
private var attriaxPreviousExceptionHandler: NSUncaughtExceptionHandler?
private var attriaxCrashHandlerInstalled = false

private func attriaxHandleUncaughtException(_ exception: NSException) {
    AttriaxIosPlugin.persistPendingCrash(exception: exception)
    attriaxPreviousExceptionHandler?(exception)
}

public final class AttriaxIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
    private var eventSink: FlutterEventSink?
    private var initialLink: String?
    private var initialLinkSent = false
    private var latestLink: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "attriax", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(
            name: "attriax/deep_links/events",
            binaryMessenger: registrar.messenger()
        )
        let instance = AttriaxIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
        registrar.addApplicationDelegate(instance)
        registrar.addSceneDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "collectNativeContext":
            result(collectNativeContext(call: call))
        case "collectInstallReferrer":
            result(collectInstallReferrer())
        case "setAutomaticCrashReportingEnabled":
            let arguments = call.arguments as? [String: Any]
            if arguments?["enabled"] as? Bool == true {
                Self.installCrashReporter()
            } else {
                Self.restoreCrashReporter()
            }
            result(nil)
        case "getTrackingAuthorizationStatus":
            result(currentTrackingAuthorizationStatus())
        case "requestTrackingAuthorization":
            requestTrackingAuthorization(result: result)
        case "consumePendingCrashReport":
            result(consumePendingCrashReport())
        case "updateSkanConversionValue":
            updateSkanConversionValue(call: call, result: result)
        case "getInitialLink":
            result(initialLink)
        case "getLatestLink":
            result(latestLink)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events

        if !initialLinkSent, let initialLink {
            initialLinkSent = true
            events(initialLink)
        }

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([Any]) -> Void
    ) -> Bool {
        if let url = userActivity.webpageURL {
            handleLink(url: url)
        }

        return false
    }

    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        handleLink(url: url)
        return false
    }

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
        guard let connectionOptions else {
            return false
        }

        _ = self.scene(scene, openURLContexts: connectionOptions.urlContexts)

        for userActivity in connectionOptions.userActivities {
            _ = self.scene(scene, continue: userActivity)
        }

        return false
    }

    public func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) -> Bool {
        for context in URLContexts {
            handleLink(url: context.url)
        }

        return false
    }

    public func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) -> Bool {
        if let url = userActivity.webpageURL {
            handleLink(url: url)
        }

        return false
    }

    private func collectInstallReferrer() -> [String: Any] {
        ["metadata": ["source": "ios_install_referrer"]]
    }

    private func consumePendingCrashReport() -> [String: Any]? {
        let defaults = UserDefaults.standard
        let payload = defaults.dictionary(forKey: attriaxPendingCrashKey) as? [String: Any]
        defaults.removeObject(forKey: attriaxPendingCrashKey)
        return payload
    }

    private func collectNativeContext(call: FlutterMethodCall) -> [String: Any] {
        let device = UIDevice.current
        let screen = UIScreen.main
        let screenBounds = screen.bounds
        let bundle = Bundle.main
        let hardwareModel = readHardwareModelIdentifier()
        let preciseDeviceModel = resolvePreciseDeviceModel(
            fallbackModel: device.model,
            hardwareModel: hardwareModel
        )
        let appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let appBuildNumber = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
            as? String

        // Top-level payload picked up by the SDK init request. Keys here
        // map 1:1 to columns the backend uses for multi-signal attribution
        // matching, so any change must be coordinated with the API.
        var payload: [String: Any] = [
            "screenWidth": Int(screenBounds.width * screen.scale),
            "screenHeight": Int(screenBounds.height * screen.scale),
            "devicePixelRatio": screen.scale,
        ]

        let arguments = call.arguments as? [String: Any]
        let collectAdvertisingId = arguments?["collectAdvertisingId"] as? Bool ?? true

        if let idfa = readAdvertisingIdentifier(collectAdvertisingId: collectAdvertisingId) {
            payload["advertisingId"] = idfa
        }

        var metadata: [String: Any] = [
            "source": "ios_native",
            "timezone": TimeZone.current.identifier,
            "locale": Locale.current.identifier,
            "regionCode": Locale.current.regionCode as Any,
            "preferredLanguages": Locale.preferredLanguages,
            "appVersion": appVersion as Any,
            "appBuildNumber": appBuildNumber as Any,
            "packageName": bundle.bundleIdentifier as Any,
            "keychainDeviceId": readOrCreateKeychainDeviceId() as Any,
            "vendorIdentifier": device.identifierForVendor?.uuidString as Any,
            "name": device.name,
            "localizedModel": device.localizedModel,
            "model": preciseDeviceModel,
            "deviceModel": preciseDeviceModel,
            "hardwareModel": hardwareModel,
            "bundleIdentifier": bundle.bundleIdentifier as Any,
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
            "screenWidthPoints": screenBounds.width,
            "screenHeightPoints": screenBounds.height,
            "screenScale": screen.scale,
            "isLowPowerModeEnabled": ProcessInfo.processInfo.isLowPowerModeEnabled,
        ]

        if let flutterDeepLinkingEnabled = Bundle.main.object(
            forInfoDictionaryKey: "FlutterDeepLinkingEnabled"
        ) as? Bool {
            metadata["flutterDeepLinkingEnabled"] = flutterDeepLinkingEnabled
        }

        let associatedDomains = readEntitlementStringArray(
            key: "com.apple.developer.associated-domains"
        )
        if !associatedDomains.isEmpty {
            metadata["associatedDomains"] = associatedDomains
        }

        if let applicationIdentifier = readEntitlementString(key: "application-identifier") {
            metadata["applicationIdentifier"] = applicationIdentifier
            if let teamIdentifier = applicationIdentifier.split(separator: ".").first {
                metadata["teamIdentifier"] = String(teamIdentifier)
            }
        }

        if let explicitTeamIdentifier = readEntitlementString(
            key: "com.apple.developer.team-identifier"
        ) {
            metadata["teamIdentifier"] = explicitTeamIdentifier
        }

        // Interface idiom: phone, pad, mac, tv, carPlay, vision, unspecified
        switch device.userInterfaceIdiom {
        case .phone:   metadata["interfaceIdiom"] = "phone"
        case .pad:     metadata["interfaceIdiom"] = "pad"
        case .mac:     metadata["interfaceIdiom"] = "mac"
        case .tv:      metadata["interfaceIdiom"] = "tv"
        case .carPlay: metadata["interfaceIdiom"] = "carPlay"
        default:       metadata["interfaceIdiom"] = "unspecified"
        }

#if targetEnvironment(simulator)
        metadata["isSimulator"] = true
    metadata["isPhysicalDevice"] = false
#else
        metadata["isSimulator"] = false
    metadata["isPhysicalDevice"] = true
#endif

        payload["metadata"] = metadata
        return payload
    }

    private func readHardwareModelIdentifier() -> String? {
        var systemInfo = utsname()
        guard uname(&systemInfo) == 0 else {
            return nil
        }

        var machine = systemInfo.machine
        let machineSize = MemoryLayout.size(ofValue: machine)
        let identifier = withUnsafePointer(to: &machine) { machinePointer in
            machinePointer.withMemoryRebound(
                to: CChar.self,
                capacity: machineSize
            ) {
                String(cString: $0)
            }
        }

        let normalizedIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedIdentifier.isEmpty {
            return nil
        }

#if targetEnvironment(simulator)
        if normalizedIdentifier == "x86_64" || normalizedIdentifier == "arm64" {
            let simulatedIdentifier = ProcessInfo.processInfo.environment[
                "SIMULATOR_MODEL_IDENTIFIER"
            ]?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let simulatedIdentifier, !simulatedIdentifier.isEmpty {
                return simulatedIdentifier
            }
        }
#endif

        return normalizedIdentifier
    }

    private func resolvePreciseDeviceModel(
        fallbackModel: String,
        hardwareModel: String?
    ) -> String {
        guard let hardwareModel,
              !hardwareModel.isEmpty,
              fallbackModel == "iPhone" || fallbackModel == "iPad" || fallbackModel == "iPod touch"
        else {
            return fallbackModel
        }

        return hardwareModel
    }

    /**
     * Read the IDFA via `ASIdentifierManager`. AdSupport is a system
     * framework so no external dependency is needed. ATT is requested only
     * through the explicit `requestTrackingAuthorization` method or the Dart
     * startup flag; collection here only reads when already authorized.
     */
    private func readAdvertisingIdentifier(collectAdvertisingId: Bool) -> String? {
        guard collectAdvertisingId else {
            return nil
        }
#if canImport(AdSupport)
#if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
                return nil
            }
        }
#endif
        let value = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if value == "00000000-0000-0000-0000-000000000000" {
            return nil
        }
        return value
#else
        return nil
#endif
    }

    private func requestTrackingAuthorization(result: @escaping FlutterResult) {
#if canImport(AppTrackingTransparency)
        guard #available(iOS 14, *) else {
            result("not_supported")
            return
        }

        DispatchQueue.main.async {
            ATTrackingManager.requestTrackingAuthorization { status in
                result(Self.trackingAuthorizationStatusString(status))
            }
        }
#else
        result("not_supported")
#endif
    }

    private func updateSkanConversionValue(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let arguments = call.arguments as? [String: Any]
        let fineValue = (arguments?["fineValue"] as? NSNumber)?.intValue
        let coarseValue = arguments?["coarseValue"] as? String
        let lockWindow = arguments?["lockWindow"] as? Bool ?? false

        guard let fineValue else {
            result([
                "status": "invalid_value",
                "message": "fineValue is required for SKAdNetwork conversion updates."
            ])
            return
        }

        guard (0...63).contains(fineValue) else {
            result([
                "status": "invalid_value",
                "message": "fineValue must be between 0 and 63."
            ])
            return
        }

        DispatchQueue.main.async {
            if #available(iOS 16.1, *) {
                SKAdNetwork.updatePostbackConversionValue(
                    fineValue,
                    coarseValue: self.skanCoarseValue(from: coarseValue),
                    lockWindow: lockWindow
                ) { error in
                    if let error {
                        result([
                            "status": "error",
                            "message": error.localizedDescription,
                            "fineValue": fineValue,
                            "coarseValue": coarseValue as Any,
                            "lockWindow": lockWindow,
                        ])
                    } else {
                        result([
                            "status": "updated",
                            "fineValue": fineValue,
                            "coarseValue": coarseValue as Any,
                            "lockWindow": lockWindow,
                        ])
                    }
                }
                return
            }

            if #available(iOS 15.4, *) {
                SKAdNetwork.updatePostbackConversionValue(fineValue) { error in
                    if let error {
                        result([
                            "status": "error",
                            "message": error.localizedDescription,
                            "fineValue": fineValue,
                            "lockWindow": false,
                        ])
                    } else {
                        result([
                            "status": "updated",
                            "fineValue": fineValue,
                            "lockWindow": false,
                        ])
                    }
                }
                return
            }

            result([
                "status": "not_supported",
                "message": "SKAdNetwork conversion updates require iOS 15.4 or later.",
                "fineValue": fineValue,
                "lockWindow": false,
            ])
        }
    }

    @available(iOS 16.1, *)
    private func skanCoarseValue(from rawValue: String?) -> SKAdNetwork.CoarseConversionValue? {
        switch rawValue {
        case "low":
            return .low
        case "medium":
            return .medium
        case "high":
            return .high
        default:
            return nil
        }
    }

    private func currentTrackingAuthorizationStatus() -> String {
#if canImport(AppTrackingTransparency)
        guard #available(iOS 14, *) else {
            return "not_supported"
        }

        return Self.trackingAuthorizationStatusString(
            ATTrackingManager.trackingAuthorizationStatus
        )
#else
        return "not_supported"
#endif
    }

#if canImport(AppTrackingTransparency)
    @available(iOS 14, *)
    private static func trackingAuthorizationStatusString(
        _ status: ATTrackingManager.AuthorizationStatus
    ) -> String {
        switch status {
        case .notDetermined: return "not_determined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorized: return "authorized"
        @unknown default: return "unknown"
        }
    }
#endif
    private func readEntitlementValue(key _: String) -> Any? {
        nil
    }

    private func readEntitlementString(key: String) -> String? {
        return readEntitlementValue(key: key) as? String
    }

    private func readEntitlementStringArray(key: String) -> [String] {
        if let values = readEntitlementValue(key: key) as? [String] {
            return values
        }

        if let values = readEntitlementValue(key: key) as? [NSString] {
            return values.map { String($0) }
        }

        return []
    }

    private func readOrCreateKeychainDeviceId() -> String? {
        if let existingValue = readKeychainDeviceId() {
            return existingValue
        }

        let newValue = UUID().uuidString
        let service = Bundle.main.bundleIdentifier ?? "com.attriax.sdk"
        let account = "attriax.device_id"
        let addQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: Data(newValue.utf8),
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status == errSecSuccess {
            return newValue
        }
        if status == errSecDuplicateItem {
            return readKeychainDeviceId()
        }
        return nil
    }

    private func readKeychainDeviceId() -> String? {
        let service = Bundle.main.bundleIdentifier ?? "com.attriax.sdk"
        let account = "attriax.device_id"
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        guard let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func handleLink(url: URL) {
        let link = url.absoluteString

        latestLink = link

        if initialLink == nil {
            initialLink = link
        }

        guard let eventSink, latestLink != nil else {
            return
        }

        initialLinkSent = true
        eventSink(link)
    }

    private static func installCrashReporter() {
        guard !attriaxCrashHandlerInstalled else {
            return
        }
        attriaxCrashHandlerInstalled = true
        attriaxPreviousExceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(attriaxHandleUncaughtException)
    }

    private static func restoreCrashReporter() {
        guard attriaxCrashHandlerInstalled else {
            return
        }
        NSSetUncaughtExceptionHandler(nil)
        attriaxPreviousExceptionHandler = nil
        attriaxCrashHandlerInstalled = false
    }

    fileprivate static func persistPendingCrash(exception: NSException) {
        let payload: [String: Any] = [
            "source": "ios_uncaught_exception",
            "isFatal": true,
            "exceptionType": exception.name.rawValue,
            "message": exception.reason ?? exception.name.rawValue,
            "stackTrace": exception.callStackSymbols.joined(separator: "\n"),
            "occurredAt": ISO8601DateFormatter().string(from: Date()),
            "reason": exception.reason as Any,
            "metadata": [
                "name": exception.name.rawValue,
            ],
        ]
        UserDefaults.standard.set(payload, forKey: attriaxPendingCrashKey)
    }
}
