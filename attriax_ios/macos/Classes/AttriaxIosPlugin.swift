import Cocoa
import FlutterMacOS
import Security

public final class AttriaxIosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "attriax", binaryMessenger: registrar.messenger)
        let instance = AttriaxIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "collectNativeContext":
            result(collectNativeContext())
        case "collectInstallReferrer":
            result(collectInstallReferrer())
        case "consumePendingCrashReport":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func collectNativeContext() -> [String: Any] {
        let bundle = Bundle.main
        let processInfo = ProcessInfo.processInfo
        [
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
                "keychainDeviceId": readKeychainDeviceId() as Any,
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