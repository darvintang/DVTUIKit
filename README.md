# DVTUIKit

[![Version](https://img.shields.io/cocoapods/v/DVTUIKit.svg?style=flat)](https://cocoapods.org/pods/DVTUIKit)[![License](https://img.shields.io/cocoapods/l/DVTUIKit.svg?style=flat)](https://cocoapods.org/pods/DVTUIKit)[![Platform](https://img.shields.io/cocoapods/p/DVTUIKit.svg?style=flat)](https://cocoapods.org/pods/DVTUIKit)[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)

UIKit的一些扩展合集，提供了一些UI上的常用的接口

接口有点多，例如:

> UIImage().dvt 调用 : 

```swift

    /// 图片绘制圆角
    /// - Parameters:
    ///   - corner: 圆角位置
    ///   - radius: 圆角半径
    /// - Returns: 绘制后的图片
    public func image(corner: UIRectCorner = .allCorners, cornerRadii radius: CGFloat) -> UIImage?

    /// 修改图片的宽度，等比修改高度
    /// - Parameter width: 新的宽度
    /// - Returns: 修改后的图片
    public func image(width: CGFloat) -> UIImage?

    /// 修改图片的尺寸，等比
    /// - Parameters:
    ///   - rate: 比例
    /// - Returns: 修改后的图片
    public func image(rate scale: CGFloat) -> UIImage?

    /// 旋转图片
    /// - Parameter orientation: 方向
    /// - Returns: 旋转后的图片
    public func image(orientation: UIImage.Orientation) -> UIImage?

    /// 从图片中截取二维码的图像
    /// - Parameter feature: 编码信息
    /// - Returns: 截取的后的图片
    public func image(feature: CIQRCodeFeature) -> UIImage?

    /// 在图片中心添加图片
    /// - Parameters:
    ///   - image: 要添加的图片
    ///   - size: 图片大小
    /// - Returns: 重新绘制的图片
    public func add(image: UIImage, size: CGSize? = nil) -> UIImage?
```
> 自定义的图片初始化
```swift
public extension UIImage {

    /// 创建一张纯色的图片
    /// - Parameters:
    ///   - color: 图片颜色
    ///   - size: 图片大小，逻辑像素
    ///   - scale: 倍率
    convenience public init?(dvt color: UIColor, size: CGSize = CGSize(width: 10, height: 10), scale: CGFloat = UIScreen.main.scale)
}

public extension UIImage {

    public enum GraphicDirection {

        case left2right, top2bottom, leftTop2rightBottom, leftBottom2rightTop
    }

    /// 创建一张渐变的图片
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - size: 图片大小
    ///   - direction: 渐变方向
    convenience public init?(dvt colors: [UIColor], size: CGSize = CGSize(width: 10, height: 10), direction: GraphicDirection = .left2right)
}

public extension UIImage {

    /// 将编码字符串转图片，比较耗时。必须在主线程执行
    ///
    /// 支持编码类别：CIAztecCodeGenerator、CICode128BarcodeGenerator、 CIPDF417BarcodeGenerator、CIQRCodeGenerator
    /// 默认CIQRCodeGenerator
    ///
    /// - Parameters:
    ///   - code: 编码字符串
    ///   - type: 编码类别，CIAztecCodeGenerator、CICode128BarcodeGenerator、 CIPDF417BarcodeGenerator、CIQRCodeGenerator，默认CIQRCodeGenerator
    ///   - width: 编码尺寸宽度
    ///   - qrColor: 编码颜色
    ///   - bkColor: 编码背景颜色
    convenience public init?(dvt code: String, type: String = "CIQRCodeGenerator", width: CGFloat = 0, color: UIColor = .black, bkColor: UIColor = .white)
}

```

具体接口请阅读源码，后期有时间会完善文档
