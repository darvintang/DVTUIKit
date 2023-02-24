//
//  UIColor.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2021/4/23.
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

import UIKit
import DVTFoundation

extension UIColor: NameSpace { }

public extension BaseWrapper where BaseType == UIColor {
    /// 获取随机的颜色
    static var random: UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        return color
    }

    var isDynamic: Bool {
        guard let cls = NSClassFromString("UI" + "Dynamic" + "Color") else {
            return false
        }
        return self.base.isKind(of: cls)
    }

    var rgbaValue: UInt64 {
        let ciColor = CIColor(cgColor: self.base.cgColor)
        return UInt64(ciColor.red * 255) << 24 + UInt64(ciColor.green * 255) << 16 + UInt64(ciColor.blue * 255) << 8 + UInt64(ciColor.alpha * 255)
    }

    /// 0xrgba
    var rgbaString: String {
        return "0x" + String(self.rgbaValue, radix: 16)
    }

    var red: CGFloat {
        let ciColor = CIColor(cgColor: self.base.cgColor)
        return ciColor.red
    }

    var green: CGFloat {
        let ciColor = CIColor(cgColor: self.base.cgColor)
        return ciColor.green
    }

    var blue: CGFloat {
        let ciColor = CIColor(cgColor: self.base.cgColor)
        return ciColor.blue
    }

    var alpha: CGFloat {
        let ciColor = CIColor(cgColor: self.base.cgColor)
        return ciColor.alpha
    }

    /// 将当前颜色转化成跟随系统的动态颜色，基准为浅色，如果该颜色已经是动态的了就不会再转化了
    /// - Returns: 返回一个动态颜色
    func dynamic() -> UIColor {
        if self.isDynamic {
            return self.base
        }
        return UIColor.init { trait in
            if trait.userInterfaceStyle == .light {
                return self.base
            } else {
                let ciColor = CIColor(cgColor: self.base.cgColor)
                return UIColor(red: 1 - ciColor.red, green: 1 - ciColor.green, blue: 1 - ciColor.blue, alpha: ciColor.alpha)
            }
        }
    }

    /// 给现有的颜色添加一个透明度
    /// - Parameter alpha: 透明度
    /// - Returns: 新的颜色
    func alpha(_ alpha: CGFloat) -> UIColor {
        return self.base.withAlphaComponent(alpha)
    }
}

public extension UIColor {
    /// 通过16进制的字符串获取颜色，支持0x、#或不带前缀
    /// - Parameters:
    ///   -  hex: 颜色的16进制字符串，可以包括透明通道
    ///   -  alpha: 透明度
    convenience init(dvt hex: String, alpha: CGFloat = 1) {
        let tempHex = hex.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "")
        assert(tempHex.count == 6 || tempHex.count == 8, "16进制字符串格式不对")
        var hexInt: UInt64 = 0
        var aHexInt: UInt64 = 255
        var tempAlpha = alpha

        Scanner(string: String(tempHex.prefix(6))).scanHexInt64(&hexInt)

        if tempHex.count == 8 {
            Scanner(string: String(tempHex.suffix(2))).scanHexInt64(&aHexInt)
            tempAlpha = CGFloat(aHexInt) / 255.0
        }
        self.init(dvt: hexInt, alpha: tempAlpha)
    }

    /// 通过16进制的整数及透明度获取颜色
    /// - Parameters:
    ///   - hex: 颜色的16进制数值，支持透明通道
    ///   - alpha: 透明度
    convenience init(dvt hex: UInt64, alpha: CGFloat = 1) {
        var tempHex = hex
        var tempAlpha = alpha
        if hex > 0xFFFFFF {
            tempAlpha = CGFloat(hex % 256) / 255.0
            tempHex = hex >> 8
        }
        let red = CGFloat((tempHex >> 16) % 256) / 255.0
        let green = CGFloat((tempHex >> 8) % 256) / 255.0
        let blue = CGFloat(tempHex % 256) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: tempAlpha)
    }

    convenience init(dvt light: UIColor, dark: UIColor) {
        self.init {
            $0.userInterfaceStyle == .light ? light : dark
        }
    }

    convenience init(dvt light: UInt64, dark: UInt64) {
        self.init {
            $0.userInterfaceStyle == .light ? UIColor(dvt: light) : UIColor(dvt: dark)
        }
    }

    convenience init(dvt light: String, dark: String) {
        self.init {
            $0.userInterfaceStyle == .light ? UIColor(dvt: light) : UIColor(dvt: dark)
        }
    }
}
