# Package.swift (ios/attriax_flutter_ios/Package.swift) is the PRIMARY dependency-manager
# path as of Flutter 3.44 (SwiftPM default). This podspec remains as the CocoaPods fallback
# for Flutter < 3.44 (Flutter's official dual-support recommendation) and points at the same
# relocated source/resource/framework tree the Swift package uses.
Pod::Spec.new do |s|
  pubspec_path = File.expand_path('../pubspec.yaml', __dir__)
  pubspec_version = File.exist?(pubspec_path) ? File.read(pubspec_path)[/^version:\s*(.+)$/, 1] : nil

  s.name             = 'attriax_flutter_ios'
  s.version          = pubspec_version || '0.0.1'
  s.summary          = 'iOS implementation of the Attriax Flutter plugin.'
  s.homepage         = 'https://attriax.com'
  s.license          = { :type => 'Apache-2.0' }
  s.author           = { 'Attriax' => 'hello@attriax.com' }
  s.source           = { :path => '.' }
  # Shared with Package.swift's SwiftPM target (sources moved under the SwiftPM package dir).
  s.source_files     = 'attriax_flutter_ios/Sources/attriax_flutter_ios/**/*.swift'
  s.resource_bundles = {
    'attriax_flutter_ios_privacy' => ['attriax_flutter_ios/Sources/attriax_flutter_ios/PrivacyInfo.xcprivacy']
  }
  s.dependency 'Flutter'
  # The Attriax engine now lives in the KMP core, shipped as a static XCFramework
  # (AttriaxCore) produced by `sdk-kmp` (`./gradlew :core:assembleAttriaxCoreXCFramework`)
  # and vendored here. The Swift plugin is a thin shim that drives the KMP `Attriax`
  # engine via `AttriaxApple` (see Sources/attriax_flutter_ios/AttriaxIosPlugin.swift).
  s.vendored_frameworks = 'attriax_flutter_ios/Frameworks/AttriaxCore.xcframework'
  # System frameworks the static KMP framework references (App Tracking Transparency,
  # AdServices/ASA, StoreKit/SKAN, DeviceCheck/App Attest, Network/NWPathMonitor,
  # WebKit for the real WKWebView UA, plus the transport/security deps). These ship
  # with the OS — no third-party dependency is introduced.
  s.frameworks       = 'AdSupport', 'SafariServices', 'AppTrackingTransparency',
                       'AdServices', 'StoreKit', 'DeviceCheck', 'Network', 'WebKit',
                       'Security', 'SystemConfiguration', 'CoreGraphics'
  # ATT + App Attest + AdServices require iOS 14+.
  s.platform         = :ios, '14.0'
  s.swift_version    = '5.0'
end
