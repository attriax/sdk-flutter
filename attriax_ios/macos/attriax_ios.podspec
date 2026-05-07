Pod::Spec.new do |s|
  s.name             = 'attriax_ios'
  s.version          = '1.0.0'
  s.summary          = 'macOS implementation of the Attriax Flutter plugin.'
  s.homepage         = 'https://attriax.com'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Attriax' => 'tim@attriax.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'FlutterMacOS'
  s.platform         = :osx, '10.15'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end