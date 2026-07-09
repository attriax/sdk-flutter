Pod::Spec.new do |s|
  pubspec_path = File.expand_path('../pubspec.yaml', __dir__)
  pubspec_version = File.exist?(pubspec_path) ? File.read(pubspec_path)[/^version:\s*(.+)$/, 1] : nil

  s.name             = 'attriax_flutter_ios'
  s.version          = pubspec_version || '0.0.1'
  s.summary          = 'macOS implementation of the Attriax Flutter plugin.'
  s.homepage         = 'https://attriax.com'
  s.license          = { :type => 'Apache-2.0' }
  s.author           = { 'Attriax' => 'tim@attriax.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.resource_bundles = {
    'attriax_macos_privacy' => ['Resources/PrivacyInfo.xcprivacy']
  }
  s.dependency 'FlutterMacOS'

  # The Attriax engine ships in the KMP core as the AttriaxCore XCFramework (the
  # macos-arm64_x86_64 slice), produced by sdk-kmp and vendored here. The Swift
  # plugin is a thin shim driving the KMP `Attriax` engine via `AttriaxApple`.
  s.vendored_frameworks = 'Frameworks/AttriaxCore.xcframework'
  # System frameworks the static KMP framework references on macOS (ATT is available
  # on macOS 11+; Network/WebKit/AppKit-backed browser open + transport/security deps).
  s.frameworks = 'AppTrackingTransparency', 'Network', 'WebKit', 'AppKit',
                 'Security', 'SystemConfiguration', 'CoreGraphics'

  # ATT (AppTrackingTransparency) requires macOS 11+.
  s.platform = :osx, '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end