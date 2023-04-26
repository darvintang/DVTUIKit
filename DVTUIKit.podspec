Pod::Spec.new do |s|
  s.name             = 'DVTUIKit'
  s.version          = '2.0.2'
  s.summary          = 'DVTUIKit'

  s.description      = <<-DESC
  TODO:
    UIKit的一些扩展合集，提供了一些UI上的常用的接口；以及一些自定义封装的控件
  DESC

  s.homepage         = 'https://github.com/darvintang/DVTUIKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'darvin' => 'darvin@tcoding.cn' }
  s.source           = { :git => 'https://github.com/darvintang/DVTUIKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.subspec 'Advanced' do |ss|
    ss.subspec 'Alert' do |sss|
      sss.source_files = 'Sources/Advanced/Alert/**.swift'
      sss.dependency "DVTUIKit/Advanced/ModalPresentation"
    end

    ss.subspec 'Button' do |sss|
      sss.source_files = 'Sources/Advanced/Button/**.swift'
      sss.dependency "DVTUIKit/Extension"
    end

    ss.subspec 'Badge' do |sss|
      sss.source_files = 'Sources/Advanced/Badge/**.swift'
      sss.dependency "DVTUIKit/Extension"
      sss.dependency "DVTUIKit/Advanced/Label"
    end

    ss.subspec 'Collection' do |sss|
      sss.source_files = 'Sources/Advanced/Collection/**.swift'
      sss.dependency "DVTUIKit/Extension"
    end

    ss.subspec 'EmptyView' do |sss|
      sss.source_files = 'Sources/Advanced/EmptyView/**.swift'
      sss.dependency "DVTUIKit/Advanced/Public"
    end

    ss.subspec 'Label' do |sss|
      sss.source_files = 'Sources/Advanced/Label/**.swift'
      sss.dependency "DVTUIKit/Extension"
    end

    ss.subspec 'ModalPresentation' do |sss|
      sss.source_files = 'Sources/Advanced/ModalPresentation/**.swift'
      sss.dependency "DVTUIKit/Extension"
    end

    ss.subspec 'MoreOperation' do |sss|
      sss.source_files = 'Sources/Advanced/MoreOperation/**.swift'
      sss.dependency "DVTUIKit/Advanced/ModalPresentation"
    end

    ss.subspec 'Navigation' do |sss|
      sss.source_files = 'Sources/Advanced/Navigation/**.swift'
      sss.dependency "DVTUIKit/Extension"
    end

    ss.subspec 'Progress' do |sss|
      sss.source_files = 'Sources/Advanced/Progress/**.swift'
      sss.resources = 'Sources/Advanced/Progress/**.{xcassets,xib}'
      sss.dependency "DVTUIKit/Advanced/Public"
    end

    ss.subspec 'Public' do |sss|
      sss.source_files = 'Sources/Advanced/Public/**.swift'
      sss.dependency "DVTUIKit/Extension"
    end

    ss.subspec 'TextField' do |sss|
      sss.source_files = 'Sources/Advanced/TextField/**.swift'
      sss.dependency "DVTUIKit/Extension"
    end

    ss.subspec 'TextView' do |sss|
      sss.source_files = 'Sources/Advanced/TextView/**.swift'
      sss.dependency "DVTUIKit/Extension"
    end

    ss.subspec 'Tips' do |sss|
      sss.source_files = 'Sources/Advanced/Tips/**.swift'
      sss.resources = 'Sources/Advanced/Tips/**.{xcassets,xib}'
      sss.dependency "DVTUIKit/Advanced/Public"
    end
  end

  s.subspec 'Extension' do |ss|
    ss.source_files = 'Sources/Extension/**/*.swift', 'Sources/Extension/*.swift'
    ss.dependency 'DVTFoundation', '~> 2.0.1'
    ss.dependency 'DVTLoger', '~> 2.0.0'
  end

  s.source_files = 'Sources/**.swift'

  s.swift_version = '5'
  s.requires_arc  = true
end
