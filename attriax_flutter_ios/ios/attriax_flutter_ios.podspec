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
  s.source_files     = 'Classes/**/*'
  s.resource_bundles = {
    'attriax_flutter_ios_privacy' => ['Resources/PrivacyInfo.xcprivacy']
  }
  s.dependency 'Flutter'
  # AdSupport ships with the iOS SDK — no third-party dependency is
  # introduced. It is required for the IDFA lookup in
  # `AttriaxIosPlugin.collectNativeContext()`.
  s.frameworks       = 'AdSupport'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
end
