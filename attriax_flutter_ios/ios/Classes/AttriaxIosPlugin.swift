import Flutter
import Security
import SafariServices
import StoreKit
import UIKit
import WebKit
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

private func attriaxReadEntitlementValue(_ key: String) -> Any? {
    guard let task = SecTaskCreateFromSelf(nil) else {
        return nil
    }

    var error: Unmanaged<CFError>?
    let value = SecTaskCopyValueForEntitlement(
        task,
        key as CFString,
        &error
    )
    error?.release()
    return value
}

private func attriaxReadEntitlementString(_ key: String) -> String? {
    attriaxReadEntitlementValue(key) as? String
}

private func attriaxReadEntitlementStringArray(_ key: String) -> [String] {
    guard let values = attriaxReadEntitlementValue(key) as? [Any] else {
        return []
    }

    return values.compactMap { $0 as? String }
}

private func attriaxHardwareModel() -> String? {
    var systemInfo = utsname()
    guard uname(&systemInfo) == 0 else {
        return nil
    }

    return withUnsafePointer(to: &systemInfo.machine) { pointer in
        pointer.withMemoryRebound(to: CChar.self, capacity: 1) {
            String(cString: $0)
        }
    }
}

private func attriaxInterfaceIdiom(_ idiom: UIUserInterfaceIdiom) -> String {
    switch idiom {
    case .phone:
        return "phone"
    case .pad:
        return "pad"
    case .mac:
        return "mac"
    case .tv:
        return "tv"
    case .carPlay:
        return "carPlay"
    default:
        return "unspecified"
    }
}

public final class AttriaxIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
    private var eventSink: FlutterEventSink?
    private var initialLink: String?
    private var initialLinkSent = false
    private var latestLink: String?
    private var cachedWebViewUserAgent: String?
    private var webViewUserAgentProbe: WKWebView?

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
        case "readAttributionClipboard":
            readAttributionClipboard(result: result)
        case "collectWebViewUserAgent":
            collectWebViewUserAgent(result: result)
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
        case "openBrowserUrl":
            openBrowserUrl(call: call, result: result)
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

    private func readAttributionClipboard(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            let text = UIPasteboard.general.string?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            result(text?.isEmpty == false ? text : nil)
        }
    }

    private func collectWebViewUserAgent(result: @escaping FlutterResult) {
        if let cachedWebViewUserAgent, !cachedWebViewUserAgent.isEmpty {
            result(cachedWebViewUserAgent)
            return
        }

        DispatchQueue.main.async {
            let webView = WKWebView(frame: .zero)
            self.webViewUserAgentProbe = webView
            webView.evaluateJavaScript("navigator.userAgent") { value, _ in
                defer {
                    self.webViewUserAgentProbe = nil
                }

                let userAgent = (value as? String)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if let userAgent, !userAgent.isEmpty {
                    self.cachedWebViewUserAgent = userAgent
                    result(userAgent)
                    return
                }

                result(nil)
            }
        }
    }

    private func openBrowserUrl(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any],
              let urlString = arguments["url"] as? String,
              let url = URL(string: urlString)
        else {
            result(false)
            return
        }

        let openMode = (arguments["openMode"] as? String)?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) ?? "in_app"

        DispatchQueue.main.async {
            if openMode == "external" {
                UIApplication.shared.open(url, options: [:]) { opened in
                    result(opened)
                }
                return
            }

            guard let presenter = Self.topViewController() else {
                result(false)
                return
            }

            let controller = SFSafariViewController(url: url)
            presenter.present(controller, animated: true) {
                result(true)
            }
        }
    }

    private func consumePendingCrashReport() -> [String: Any]? {
        let defaults = UserDefaults.standard
        let payload = defaults.dictionary(forKey: attriaxPendingCrashKey) as? [String: Any]
        defaults.removeObject(forKey: attriaxPendingCrashKey)
        return payload
    }

    private func collectNativeContext(call: FlutterMethodCall) -> [String: Any] {
        let bundle = Bundle.main
        let appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let appBuildNumber = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
            as? String
        let flutterDeepLinkingEnabled = bundle.object(
            forInfoDictionaryKey: "FlutterDeepLinkingEnabled"
        ) as? Bool
        let device = UIDevice.current
        var payload: [String: Any] = [:]

        let arguments = call.arguments as? [String: Any]
        let collectAdvertisingId = arguments?["collectAdvertisingId"] as? Bool ?? true

        if let idfa = readAdvertisingIdentifier(collectAdvertisingId: collectAdvertisingId) {
            payload["advertisingId"] = idfa
        }

        var metadata: [String: Any] = [
            "source": "ios_native",
            "timezone": TimeZone.current.identifier,
            "locale": Locale.current.identifier,
            "appVersion": appVersion as Any,
            "appBuildNumber": appBuildNumber as Any,
            "packageName": bundle.bundleIdentifier as Any,
            "keychainDeviceId": readOrCreateKeychainDeviceId() as Any,
            "bundleIdentifier": bundle.bundleIdentifier as Any,
            "vendorIdentifier": device.identifierForVendor?.uuidString as Any,
            "deviceModel": device.model,
            "localizedModel": device.localizedModel,
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
        ]

#if TARGET_OS_SIMULATOR
        metadata["isSimulator"] = true
        metadata["isPhysicalDevice"] = false
#else
        metadata["isSimulator"] = false
        metadata["isPhysicalDevice"] = true
#endif

        if let flutterDeepLinkingEnabled {
            metadata["flutterDeepLinkingEnabled"] = flutterDeepLinkingEnabled
        }

        if let hardwareModel = attriaxHardwareModel(), !hardwareModel.isEmpty {
            metadata["hardwareModel"] = hardwareModel
        }

        let applicationIdentifier = attriaxReadEntitlementString(
            "application-identifier"
        )?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let applicationIdentifier, !applicationIdentifier.isEmpty {
            metadata["applicationIdentifier"] = applicationIdentifier
            if let derivedTeamIdentifier = applicationIdentifier.split(separator: ".").first,
               !derivedTeamIdentifier.isEmpty {
                metadata["teamIdentifier"] = String(derivedTeamIdentifier)
            }
        }

        let explicitTeamIdentifier = attriaxReadEntitlementString(
            "com.apple.developer.team-identifier"
        )?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let explicitTeamIdentifier, !explicitTeamIdentifier.isEmpty {
            metadata["teamIdentifier"] = explicitTeamIdentifier
        }

        let associatedDomains = attriaxReadEntitlementStringArray(
            "com.apple.developer.associated-domains"
        )
        if !associatedDomains.isEmpty {
            metadata["associatedDomains"] = associatedDomains
        }

        metadata["interfaceIdiom"] = attriaxInterfaceIdiom(device.userInterfaceIdiom)

        payload["metadata"] = metadata
        return payload
    }

    private static func topViewController(
        from base: UIViewController? = nil
    ) -> UIViewController? {
        let root = base ?? activeWindow()?.rootViewController
        if let navigationController = root as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }
        if let tabBarController = root as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewController(from: selectedViewController)
        }
        if let presentedViewController = root?.presentedViewController {
            return topViewController(from: presentedViewController)
        }
        return root
    }

    private static func activeWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else {
                    continue
                }
                if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    return window
                }
            }
            return nil
        }

        return UIApplication.shared.keyWindow
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

        let buildSkanErrorMessage: (Error) -> String = { error in
            let nsError = error as NSError
            var message = nsError.localizedDescription

            if message.isEmpty {
                message = "\(nsError.domain) error \(nsError.code)."
            } else {
                message += " [\(nsError.domain) \(nsError.code)]"
            }

            if nsError.domain == "SKANErrorDomain" && nsError.code == 10 {
                message += " This commonly means StoreKit does not have an eligible SKAdNetwork attribution context for this install. Simulator and direct-debug installs are not reliable for validating conversion-value updates; verify on a physical iOS device with an eligible attributed install."
            }

            return message
        }

        DispatchQueue.main.async {
            if #available(iOS 16.1, *) {
                let completion: (Error?) -> Void = { error in
                    if let error {
                        result([
                            "status": "error",
                            "message": buildSkanErrorMessage(error),
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

                if let resolvedCoarseValue = self.skanCoarseValue(from: coarseValue) {
                    SKAdNetwork.updatePostbackConversionValue(
                        fineValue,
                        coarseValue: resolvedCoarseValue,
                        lockWindow: lockWindow,
                        completionHandler: completion
                    )
                } else if lockWindow {
                    result([
                        "status": "invalid_value",
                        "message": "lockWindow requires a coarseValue on this iOS SDK.",
                        "fineValue": fineValue,
                        "lockWindow": lockWindow,
                    ])
                } else {
                    SKAdNetwork.updatePostbackConversionValue(
                        fineValue,
                        completionHandler: completion
                    )
                }
                return
            }

            if #available(iOS 15.4, *) {
                SKAdNetwork.updatePostbackConversionValue(fineValue) { error in
                    if let error {
                        result([
                            "status": "error",
                            "message": buildSkanErrorMessage(error),
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

            if #available(iOS 14.0, *) {
                SKAdNetwork.updateConversionValue(fineValue)
                result([
                    "status": "updated",
                    "fineValue": fineValue,
                    "lockWindow": false,
                ])
                return
            }

            result([
                "status": "not_supported",
                "message": "SKAdNetwork conversion updates require iOS 14.0 or later.",
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
    private func readOrCreateKeychainDeviceId() -> String? {
        if let existingValue = readKeychainDeviceId() {
            return existingValue
        }

        let newValue = UUID().uuidString
        let service = Bundle.main.bundleIdentifier ?? "com.attriax.sdk"
        let account = "attriax.device_id"
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData: Data(newValue.utf8),
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
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
