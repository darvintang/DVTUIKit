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
    convenience init(xti color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let cgImage = image?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
    }

    /// 将二维码字符串转图片，比较耗时。必须在主线程执行
    /// - Parameters:
    ///   - qrCode: 二维码字符串
    ///   - width: 二维码尺寸宽度
    convenience init(xti_of qrCode: String, width: CGFloat = 0) {
        if let stringData = qrCode.data(using: .utf8, allowLossyConversion: false), let ciFilter = CIFilter(name: "CIQRCodeGenerator") {
            ciFilter.setValue(stringData, forKey: "inputMessage")
            ciFilter.setValue("M", forKey: "inputCorrectionLevel")
            if let ciImage = ciFilter.outputImage {
                let colorFilter = CIFilter(name: "CIFalseColor")!
                colorFilter.setDefaults()
                colorFilter.setValue(ciImage, forKey: "inputImage")
                colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
                colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
                if let outputImage = colorFilter.outputImage {
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
                    return
                }
            }
        }
        self.init()
    }
}
