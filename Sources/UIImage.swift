//
//  UIImage+.swift
//
//
//  Created by darvintang on 2021/5/11.
//

/*

 MIT License

 Copyright (c) 2021 darvintang http://blog.tcoding.cn

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

import UIKit

public extension UIImage {
    /// 创建一张纯色的图片
    /// - Parameters:
    ///   - color: 图片颜色
    ///   - size: 图片大小
    convenience init?(dvt color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
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
        self.init(cgImage: cgImage)
    }

    /// 将二维码字符串转图片，比较耗时。必须在主线程执行
    /// - Parameters:
    ///   - qrCode: 二维码字符串
    ///   - width: 二维码尺寸宽度
    convenience init?(dvt qrCode: String, width: CGFloat = 0) {
        guard let stringData = qrCode.data(using: .utf8, allowLossyConversion: false), let ciFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        ciFilter.setValue(stringData, forKey: "inputMessage")
        ciFilter.setValue("M", forKey: "inputCorrectionLevel")
        guard let ciImage = ciFilter.outputImage else {
            return nil
        }
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(ciImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
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

    enum GraphicDirection {
        case left2right, top2bottom, leftTop2rightBottom, leftBottom2rightTop
    }

    /// 创建一张渐变的图片
    convenience init?(dvt colors: [UIColor], size: CGSize = CGSize(width: 10, height: 10), direction: GraphicDirection = .left2right) {
        guard !colors.isEmpty else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.saveGState()

        var startPoint: CGPoint = .zero
        var endPoint: CGPoint = .zero

        switch direction {
            case .left2right:
                startPoint = CGPoint(x: 0, y: 0.5 * size.height)
                endPoint = CGPoint(x: size.width, y: 0.5 * size.height)
            case .top2bottom:
                startPoint = CGPoint(x: 0.5 * size.width, y: 0)
                endPoint = CGPoint(x: 0.5 * size.width, y: size.height)
            case .leftTop2rightBottom:
                startPoint = CGPoint(x: 0, y: 0)
                endPoint = CGPoint(x: size.width, y: size.height)
            case .leftBottom2rightTop:
                startPoint = CGPoint(x: 0, y: size.height)
                endPoint = CGPoint(x: size.width, y: 0)
        }

        let interval = 1.0 / CGFloat(colors.count)
        let startLocation = interval / 2
        var locations: [CGFloat] = []
        for i in 0 ..< colors.count {
            let num = interval * CGFloat(i) + startLocation
            locations.append(num)
        }
        let colorSpace = colors.first!.cgColor.colorSpace
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors.compactMap({ $0.cgColor }) as CFArray, locations: &locations) else {
            return nil
        }
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        context.restoreGState()
        if let cgImage = outImage?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
