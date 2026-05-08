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

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end