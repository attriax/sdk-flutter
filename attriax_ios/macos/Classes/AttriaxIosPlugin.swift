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
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func collectNativeContext() -> [String: Any] {
        [
            "metadata": [
                "source": "macos_native",
                "timezone": TimeZone.current.identifier,
                "locale": Locale.current.identifier,
                "regionCode": Locale.current.regionCode as Any,
                "preferredLanguages": Locale.preferredLanguages,
                "bundleIdentifier": Bundle.main.bundleIdentifier as Any,
                "keychainDeviceId": readKeychainDeviceId() as Any,
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