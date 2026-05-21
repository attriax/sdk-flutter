import Cocoa
import FlutterMacOS
import Security

private enum AttriaxMacosKeychainMode {
    case standard
    case dataProtection
}

private let attriaxAdhocCodeSignatureFlag: UInt32 = 0x0002

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

        for mode in keychainModes() {
            var addQuery = baseKeychainQuery(service: service, account: account, mode: mode)
            addQuery[kSecValueData] = Data(newValue.utf8)

            let status = SecItemAdd(addQuery as CFDictionary, nil)
            if status == errSecSuccess {
                return newValue
            }
            if status == errSecDuplicateItem,
                let existingValue = readKeychainDeviceId(mode: mode)
            {
                return existingValue
            }
        }

        return nil
    }

    private func readKeychainDeviceId() -> String? {
        for mode in keychainModes() {
            if let existingValue = readKeychainDeviceId(mode: mode) {
                return existingValue
            }
        }

        return nil
    }

    private func readKeychainDeviceId(mode: AttriaxMacosKeychainMode) -> String? {
        let service = Bundle.main.bundleIdentifier ?? "com.attriax.sdk"
        let account = "attriax.device_id"
        var query = baseKeychainQuery(service: service, account: account, mode: mode)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

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

    private func keychainModes() -> [AttriaxMacosKeychainMode] {
        guard let signingInformation = signingInformation() else {
            return []
        }

        let signatureFlags = (signingInformation[kSecCodeInfoFlags as String] as? NSNumber)?
            .uint32Value ?? 0
        if signatureFlags & attriaxAdhocCodeSignatureFlag != 0 {
            return []
        }

        let teamIdentifier = (signingInformation[kSecCodeInfoTeamIdentifier as String] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let teamIdentifier, !teamIdentifier.isEmpty else {
            return []
        }

        if #available(macOS 10.15, *) {
            return [.dataProtection, .standard]
        }

        return [.standard]
    }

    private func signingInformation() -> [String: Any]? {
        guard let executableUrl = Bundle.main.executableURL else {
            return nil
        }

        var staticCode: SecStaticCode?
        let staticCodeStatus = SecStaticCodeCreateWithPath(
            executableUrl as CFURL,
            SecCSFlags(rawValue: 0),
            &staticCode
        )
        guard staticCodeStatus == errSecSuccess, let staticCode else {
            return nil
        }

        var signingInformation: CFDictionary?
        let signingStatus = SecCodeCopySigningInformation(
            staticCode,
            SecCSFlags(rawValue: kSecCSSigningInformation),
            &signingInformation
        )
        guard signingStatus == errSecSuccess,
            let signingInformation = signingInformation as? [String: Any]
        else {
            return nil
        }

        return signingInformation
    }

    private func baseKeychainQuery(
        service: String,
        account: String,
        mode: AttriaxMacosKeychainMode
    ) -> [CFString: Any] {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]

        if #available(macOS 10.15, *), mode == .dataProtection {
            // The data-protection keychain avoids login-keychain access prompts
            // for normal app-managed secrets on modern macOS.
            query[kSecUseDataProtectionKeychain] = kCFBooleanTrue
        }

        return query
    }
}