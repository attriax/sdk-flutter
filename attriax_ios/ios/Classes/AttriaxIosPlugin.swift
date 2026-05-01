import Flutter
import Security
import UIKit
#if canImport(AdSupport)
import AdSupport
#endif

public final class AttriaxIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
    private var eventSink: FlutterEventSink?
    private var initialLink: String?
    private var initialLinkSent = false
    private var latestLink: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
#if DEBUG
        let messenger = (registrar as? NSObject)?.value(forKey: "messenger")
        if messenger == nil {
            print("Flutter application in debug mode can only be launched from Flutter tooling, use profile or release modes instead.")
            return
        }
#endif

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
            result(collectNativeContext())
        case "collectInstallReferrer":
            result(collectInstallReferrer())
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

    private func collectNativeContext() -> [String: Any] {
        let device = UIDevice.current
        let screen = UIScreen.main
        let screenBounds = screen.bounds

        // Top-level payload picked up by the SDK init request. Keys here
        // map 1:1 to columns the backend uses for multi-signal attribution
        // matching, so any change must be coordinated with the API.
        var payload: [String: Any] = [
            "screenWidth": Int(screenBounds.width * screen.scale),
            "screenHeight": Int(screenBounds.height * screen.scale),
            "devicePixelRatio": screen.scale,
        ]

        // IDFA — the official advertising identifier on iOS. Apple returns
        // the zero-UUID sentinel unless the user grants ATT permission;
        // we drop that value so the backend never tries to deterministically
        // match opted-out users against each other.
        if let idfa = readAdvertisingIdentifier() {
            payload["advertisingId"] = idfa
        }

        var metadata: [String: Any] = [
            "source": "ios_native",
            "timezone": TimeZone.current.identifier,
            "locale": Locale.current.identifier,
            "regionCode": Locale.current.regionCode as Any,
            "preferredLanguages": Locale.preferredLanguages,
            "keychainDeviceId": readKeychainDeviceId() as Any,
            "vendorIdentifier": device.identifierForVendor?.uuidString as Any,
            "deviceModel": device.model,
            "bundleIdentifier": Bundle.main.bundleIdentifier as Any,
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
#else
        metadata["isSimulator"] = false
#endif

        payload["metadata"] = metadata
        return payload
    }

    /**
     * Read the IDFA via `ASIdentifierManager`. AdSupport is a system
     * framework so no external dependency is needed. We do not trigger
     * the App Tracking Transparency prompt — that is the host app's
     * decision and out of scope for an attribution SDK. When ATT has
     * not been granted, iOS returns the all-zero UUID; we drop that so
     * the backend never persists an opted-out sentinel.
     */
    private func readAdvertisingIdentifier() -> String? {
#if canImport(AdSupport)
        let value = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if value == "00000000-0000-0000-0000-000000000000" {
            return nil
        }
        return value
#else
        return nil
#endif
    }

    private func readEntitlementValue(key: String) -> Any? {
        guard let task = SecTaskCreateFromSelf(nil) else {
            return nil
        }

        return SecTaskCopyValueForEntitlement(task, key as CFString, nil)
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
}
