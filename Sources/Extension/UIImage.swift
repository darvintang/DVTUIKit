//
//  UIImage.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2021/5/11.
//

/*

 MIT License

 Copyright (c) 2023 darvin http://blog.tcoding.cn

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 */

import DVTFoundation
import UIKit

extension UIImage: NameSpace {}
public extension BaseWrapper where BaseType: UIImage {
    @available(*, deprecated, renamed: "image(corner:cornerRadii:)", message: "2.0.1版本之后弃用该方法")
    func cornerRadius(corner: UIRectCorner = .allCorners, _ radius: CGFloat) -> UIImage? {
        self.image(corner: corner, cornerRadii: radius)
    }

    @available(*, deprecated, renamed: "image(width:)", message: "2.0.1版本之后弃用该方法")
    func to(new width: CGFloat) -> UIImage? {
        self.image(width: width)
    }
}

public extension BaseWrapper where BaseType: UIImage {
    /// 图片绘制圆角
    /// - Parameters:
    ///   - corner: 圆角位置
    ///   - radius: 圆角半径，会忽略小于1的圆角
    /// - Returns: 绘制后的图片
    func image(corner: UIRectCorner = .allCorners, cornerRadii radius: CGFloat) -> UIImage? {
        if radius < 1 || corner.isEmpty {
            return self.base
        }
        UIGraphicsBeginImageContextWithOptions(self.base.size, false, self.base.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.saveGState()
        let scale = self.base.scale
        let rect = CGRect(origin: .zero, size: self.base.size)
        context.addPath(UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: radius * scale, height: radius * scale)).cgPath)
        context.clip()
        if let cgImage = self.base.cgImage {
            context.draw(cgImage, in: rect)
        }
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        context.restoreGState()
        return outImage
    }

    /// 修改图片的宽度，等比修改高度
    /// - Parameter width: 新的宽度
    /// - Returns: 修改后的图片
    func image(width: CGFloat, scale: CGFloat = 0) -> UIImage? {
        let newScale = max(scale, self.base.scale)
        if width == self.base.size.width, newScale == self.base.scale {
            return self.base
        }
        let height = self.base.size.height / self.base.size.width * width
        let newSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, newScale)
        self.base.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// 修改图片的尺寸，等比
    /// - Parameters:
    ///   - rate: 比例
    /// - Returns: 修改后的图片
    func image(rate scale: CGFloat) -> UIImage? {
        self.image(width: self.base.size.width * scale)
    }

    /// 修改图片的倍率，三倍图
    /// - Parameters:
    ///   - scale: 倍率
    /// - Returns: 修改后的图片
    func image(scale: CGFloat) -> UIImage? {
        self.image(width: self.base.size.width / scale * self.base.scale, scale: scale)
    }

    /// 旋转图片
    /// - Parameter orientation: 方向
    /// - Returns: 旋转后的图片
    func image(orientation: UIImage.Orientation) -> UIImage? {
        guard let cgImage = self.base.cgImage else {
            return nil
        }
        var rotate: Double = 0.0
        var rect: CGRect
        var translateX: CGFloat = 0.0
        var translateY: CGFloat = 0.0
        var scaleX: CGFloat = 1.0
        var scaleY: CGFloat = 1.0

        switch orientation {
            case .left:
                rotate = .pi / 2
                rect = CGRect(x: 0, y: 0, width: self.base.size.height, height: self.base.size.width)
                translateX = 0
                translateY = -rect.size.width
                scaleY = rect.size.width / rect.size.height
                scaleX = rect.size.height / rect.size.width
            case .right:
                rotate = 3 * .pi / 2
                rect = CGRect(x: 0, y: 0, width: self.base.size.height, height: self.base.size.width)
                translateX = -rect.size.height
                translateY = 0
                scaleY = rect.size.width / rect.size.height
                scaleX = rect.size.height / rect.size.width
            case .down:
                rotate = .pi
                rect = CGRect(x: 0, y: 0, width: self.base.size.width, height: self.base.size.height)
                translateX = -rect.size.width
                translateY = -rect.size.height
            default:
                rotate = 0.0
                rect = CGRect(x: 0, y: 0, width: self.base.size.width, height: self.base.size.height)
                translateX = 0
                translateY = 0
        }

        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        // 做CTM变换
        context.translateBy(x: 0.0, y: rect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat(rotate))
        context.translateBy(x: translateX, y: translateY)
        context.scaleBy(x: scaleX, y: scaleY)

        // 绘制图片
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 从图片中截取二维码的图像
    /// - Parameter feature: 编码信息
    /// - Returns: 截取的后的图片
    func image(feature: CIQRCodeFeature) -> UIImage? {
        let rect = self.rect(feature)
        return self.cropping(to: rect)
    }

    /// 在图片中心添加图片
    /// - Parameters:
    ///   - image: 要添加的图片
    ///   - size: 图片大小
    /// - Returns: 重新绘制的图片
    func add(image: UIImage, size: CGSize? = nil) -> UIImage? {
        let baseScale = self.base.scale
        let imageScale = image.scale
        let srcSize = self.base.size
        let logoSize = size ?? CGSize(width: image.size.width / imageScale * baseScale, height: image.size.height / imageScale * baseScale)

        UIGraphicsBeginImageContextWithOptions(srcSize, false, baseScale)
        self.base.draw(in: CGRect(origin: .zero, size: self.base.size))
        let logoRect = CGRect(x: srcSize.width / 2 - logoSize.width / 2,
                              y: srcSize.height / 2 - logoSize.height / 2,
                              width: logoSize.width,
                              height: logoSize.height)
        image.draw(in: logoRect)
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultingImage
    }

    /// 图片截取
    /// - Parameter rect: 截取的范围
    /// - Returns: 截取的后的图片
    func cropping(to rect: CGRect) -> UIImage? {
        guard let imagePartRef = self.base.cgImage?.cropping(to: rect.dvt.to(rate: self.base.scale)) else {
            return nil
        }
        return UIImage(cgImage: imagePartRef)
    }

    /// 图片里面的二维码
    var qrCodes: [CIQRCodeFeature] {
        guard let ciImage = CIImage(image: self.base), let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            return []
        }
        let features = detector.features(in: ciImage)
        return features.filter { $0.isKind(of: CIQRCodeFeature.self) }.compactMap { $0 as? CIQRCodeFeature }
    }

    // 获取二维码的图像区域，根据图片的倍率计算CGRect
    func rect(_ feature: CIQRCodeFeature) -> CGRect {
        let scale = self.base.scale
        return feature.bounds.dvt.to(rate: 1 / scale)
    }
}

public extension BaseWrapper where BaseType: UIImage {
    static func image(_ bundle: Bundle, named: String) -> BaseType? {
        BaseType(named: named, in: bundle, compatibleWith: .none)
    }

    static func image(_ bundle: String, named: String) -> BaseType? {
        var tbundle: Bundle = .main
        if let path = Bundle.main.path(forResource: bundle, ofType: "bundle") {
            tbundle = Bundle(path: path) ?? .main
        }
        return self.image(tbundle, named: named)
    }

    static func image(_ current: AnyClass, named: String) -> BaseType? {
        return self.image(Bundle(for: current), named: named)
    }
}

// MARK: - 通过颜色初始化图片

public extension UIImage {
    /// 创建一张纯色的图片
    /// - Parameters:
    ///   - color: 图片颜色
    ///   - size: 图片大小，逻辑像素
    ///   - scale: 倍率
    convenience init?(dvt color: UIColor, size: CGSize = CGSize(width: 10, height: 10), scale: CGFloat = UIScreen.main.scale) {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(size.dvt.convertRect(scale), false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
}

// MARK: - 通过颜色初始化渐变图片

public extension UIImage {
    enum GraphicDirection {
        case left2right, top2bottom, leftTop2rightBottom, leftBottom2rightTop
    }

    /// 创建一张渐变的图片
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - size: 图片大小
    ///   - direction: 渐变方向
    convenience init?(dvt colors: [UIColor], size: CGSize = CGSize(width: 10, height: 10), direction: GraphicDirection = .left2right) {
        guard !colors.isEmpty else {
            return nil
        }
        if colors.count == 1, let color = colors.first {
            self.init(dvt: color)
        } else {
            var startPoint: CGPoint = .zero
            var endPoint: CGPoint = .zero

            switch direction {
                case .left2right:
                    startPoint = CGPoint(x: 0, y: 0.5)
                    endPoint = CGPoint(x: 1, y: 0.5)
                case .top2bottom:
                    startPoint = CGPoint(x: 0.5, y: 0)
                    endPoint = CGPoint(x: 0.5, y: 1)
                case .leftTop2rightBottom:
                    startPoint = CGPoint(x: 0, y: 0)
                    endPoint = CGPoint(x: 1, y: 1)
                case .leftBottom2rightTop:
                    startPoint = CGPoint(x: 0, y: 1)
                    endPoint = CGPoint(x: 1, y: 0)
            }

            let interval = 1.0 / CGFloat(colors.count)
            let startLocation = interval / 2
            var locations: [NSNumber] = []
            for i in 0 ..< colors.count {
                let num = NSNumber(floatLiteral: interval * CGFloat(i) + startLocation)
                locations.append(num)
            }
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors.map({ $0.cgColor })
            gradientLayer.locations = locations
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            gradientLayer.isOpaque = false
            if let cgImage = gradientLayer.dvt.cgImage {
                self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            } else {
                return nil
            }
        }
    }
}

// MARK: - 通过编码初始化图片

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
    convenience init?(dvt code: String, type: String = "CIQRCodeGenerator", width: CGFloat = 0, color: UIColor = .black, bkColor: UIColor = .white) {
        guard let stringData = code.data(using: .utf8), let ciFilter = CIFilter(name: type) else {
            return nil
        }
        ciFilter.setValue(stringData, forKey: "inputMessage")
        ciFilter.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = ciFilter.outputImage else {
            return nil
        }
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(ciImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: color), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: bkColor), forKey: "inputColor1")
        guard let outputImage = colorFilter.outputImage else {
            return nil
        }

        if width == 0 {
            self.init(ciImage: outputImage)
        } else {
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: width), false, scale)
            let image = UIImage(ciImage: outputImage)
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: width))
            if let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
                self.init(cgImage: cgImage, scale: scale, orientation: .up)
            } else {
                self.init(ciImage: outputImage)
            }
            UIGraphicsEndImageContext()
        }
    }
}

public extension UIImage {
    convenience init?(base64 string: String, scale: CGFloat = UIScreen.main.scale) {
        guard let data = string.dvt.base64Data else {
            return nil
        }
        self.init(data: data, scale: scale)
    }
}
