Pod::Spec.new do |s|
  s.name             = 'DVTUIKit'
  s.version          = '2.1.0'
  s.summary          = 'DVTUIKit'

  s.description      = <<-DESC
  TODO:
    UIKit的一些扩展合集，提供了一些UI上的常用的接口
  DESC

  s.homepage         = 'https://github.com/darvintang/DVTUIKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'darvin' => 'darvin@tcoding.cn' }
  s.source           = { :git => 'https://github.com/darvintang/DVTUIKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.subspec 'Advanced' do |ss|
    ss.subspec 'Public' do |sss|
        sss.source_files = 'Sources/Advanced/Public/*.swift'
    end
    ss.subspec 'ProgressView' do |sss|
        sss.source_files = 'Sources/Advanced/ProgressView/*.swift'
        sss.resources = 'Sources/Advanced/ProgressView/*.{xcassets,xib}'
        sss.dependency "DVTUIKit/Extension"
        sss.dependency "DVTUIKit/Advanced/Public"
    end
    ss.subspec 'Collection' do |sss|
        sss.source_files = 'Sources/Advanced/Collection/*.swift'
        sss.dependency "DVTUIKit/Extension"
    end
    ss.subspec 'Button' do |sss|
        sss.source_files = 'Sources/Advanced/Button/*.swift'
        sss.dependency "DVTUIKit/Extension"
    end
    ss.subspec 'Navigation' do |sss|
        sss.source_files = 'Sources/Advanced/Navigation/*.swift'
        sss.dependency "DVTUIKit/Extension"
    end
  end

  s.subspec 'Extension' do |ss|
    ss.source_files = 'Sources/Extension/**.swift'
    ss.dependency 'DVTFoundation', '~> 2.0.6'
    ss.dependency 'DVTLoger'
  end

  s.swift_version = '5'
  s.requires_arc  = true
end
