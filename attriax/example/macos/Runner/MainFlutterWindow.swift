import Cocoa
import FlutterMacOS
import Security

import attriax_flutter_ios
import connectivity_plus
import firebase_core
import share_plus
import shared_preferences_foundation

private let exampleAdhocCodeSignatureFlag: UInt32 = 0x0002

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    registerExamplePlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  private func registerExamplePlugins(registry: FlutterPluginRegistry) {
    if shouldRegisterFirebaseMessagingPlugin() {
      RegisterGeneratedPlugins(registry: registry)
      return
    }

    AttriaxIosPlugin.register(with: registry.registrar(forPlugin: "AttriaxIosPlugin"))
    ConnectivityPlusPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlusPlugin"))
    FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
    SharePlusMacosPlugin.register(with: registry.registrar(forPlugin: "SharePlusMacosPlugin"))
    SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  }

  private func shouldRegisterFirebaseMessagingPlugin() -> Bool {
    guard let signingInformation = signingInformation() else {
      return true
    }

    let signatureFlags = (signingInformation[kSecCodeInfoFlags as String] as? NSNumber)?
      .uint32Value ?? 0
    if signatureFlags & exampleAdhocCodeSignatureFlag != 0 {
      return false
    }

    let teamIdentifier = (signingInformation[kSecCodeInfoTeamIdentifier as String] as? String)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let teamIdentifier, !teamIdentifier.isEmpty else {
      return false
    }

    return true
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
}
