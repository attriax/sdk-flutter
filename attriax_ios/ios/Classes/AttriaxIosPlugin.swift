import Flutter
import Security
import UIKit

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

        var metadata: [String: Any] = [
            "source": "ios_native",
            "timezone": TimeZone.current.identifier,
            "locale": Locale.current.identifier,
            "regionCode": Locale.current.regionCode as Any,
            "preferredLanguages": Locale.preferredLanguages,
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

        return ["metadata": metadata]
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
