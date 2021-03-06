Pod::Spec.new do |s|
  s.name             = 'DVTUIKit'
  s.version          = '1.2.1'
  s.summary          = 'DVTUIKit'

  s.description      = <<-DESC
  TODO:
    DVTUIKit
  DESC

  s.homepage         = 'https://github.com/darvintang/DVTUIKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xt-input' => 'input@tcoding.cn' }
  s.source           = { :git => 'https://github.com/darvintang/DVTUIKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/**/*.swift'

  s.dependency 'DVTFoundation', '~> 1.3.0'

  s.swift_version = '5'
  s.requires_arc  = true
end
