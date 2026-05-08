import Cocoa
import FlutterMacOS
import Security

public final class AttriaxIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "attriax", binaryMessenger: registrar.messenger)
        let eventChannel = FlutterEventChannel(
            name: "attriax/deep_links/events",
            binaryMessenger: registrar.messenger
        )
        let instance = AttriaxIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "collectNativeContext":
            result(collectNativeContext())
        case "collectInstallReferrer":
            result(collectInstallReferrer())
        case "setAutomaticCrashReportingEnabled":
            result(nil)
        case "getTrackingAuthorizationStatus":
            result("not_supported")
        case "requestTrackingAuthorization":
            result("not_supported")
        case "consumePendingCrashReport":
            result(nil)
        case "getInitialLink":
            result(nil)
        case "getLatestLink":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        nil
    }

    private func collectNativeContext() -> [String: Any] {
        let bundle = Bundle.main
        let processInfo = ProcessInfo.processInfo
        return [
            "metadata": [
                "source": "macos_native",
                "timezone": TimeZone.current.identifier,
                "locale": Locale.current.identifier,
                "regionCode": Locale.current.regionCode as Any,
                "preferredLanguages": Locale.preferredLanguages,
                "appVersion": bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as Any,
                "appBuildNumber": bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
                    as Any,
                "packageName": bundle.bundleIdentifier as Any,
                "bundleIdentifier": bundle.bundleIdentifier as Any,
                "keychainDeviceId": readOrCreateKeychainDeviceId() as Any,
                "computerName": Host.current().localizedName as Any,
                "hostName": processInfo.hostName,
                "operatingSystemVersionString": processInfo.operatingSystemVersionString,
                "isPhysicalDevice": true,
            ],
        ]
    }

    private func collectInstallReferrer() -> [String: Any] {
        [
            "metadata": [
                "source": "macos_install_referrer",
                "installReferrerStatus": "unsupported_macos",
            ],
        ]
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
}