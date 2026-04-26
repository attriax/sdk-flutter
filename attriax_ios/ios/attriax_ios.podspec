Pod::Spec.new do |s|
  s.name             = 'attriax_ios'
  s.version          = '1.0.0'
  s.summary          = 'iOS implementation of the Attriax Flutter plugin.'
  s.homepage         = 'https://attriax.com'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Attriax' => 'hello@attriax.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
end
