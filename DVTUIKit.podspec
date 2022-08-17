Pod::Spec.new do |s|
  s.name             = 'DVTUIKit'
  s.version          = '2.0.3'
  s.summary          = 'DVTUIKit'

  s.description      = <<-DESC
  TODO:
    UIKit的一些扩展合集，提供了一些UI上的常用的接口
  DESC

  s.homepage         = 'https://github.com/darvintang/DVTUIKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'darvin' => 'darvin@tcoding.cn' }
  s.source           = { :git => 'https://github.com/darvintang/DVTUIKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/**/*.swift'

  s.dependency 'DVTFoundation', '~> 2.0.1'

  s.swift_version = '5'
  s.requires_arc  = true
end
