//
//  UIColor+.swift
//
//
//  Created by darvintang on 2021/4/23.
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

public extension UIColor {
    var xti_isDynamic: Bool {
        guard let cls = NSClassFromString("UIDynamicColor") else {
            return false
        }
        return self.isKind(of: cls)
    }

    convenience init(xti light: UIColor, dark: UIColor? = nil) {
        if #available(iOS 13.0, *) {
            self.init { trait in
                if trait.userInterfaceStyle == .light {
                    return light
                } else {
                    return dark ?? light
                }
            }
        } else {
            self.init(ciColor: light.ciColor)
        }
    }

    convenience init(xti light: UInt64, dark: UInt64? = nil) {
        if #available(iOS 13.0, *) {
            self.init { trait in
                if trait.userInterfaceStyle == .light {
                    return .xti_hex(light)
                } else {
                    return .xti_hex(dark ?? light)
                }
            }
        } else {
            self.init(ciColor: UIColor.xti_hex(light).ciColor)
        }
    }

    convenience init(xti light: String, dark: String? = nil) {
        if #available(iOS 13.0, *) {
            self.init { trait in
                if trait.userInterfaceStyle == .light {
                    return .xti_hex(light)
                } else {
                    return .xti_hex(dark ?? light)
                }
            }
        } else {
            self.init(ciColor: UIColor.xti_hex(light).ciColor)
        }
    }

    /// 将当前颜色转化成跟随系统的动态颜色，基准为浅色，如果该颜色已经是动态的了就不会再转化了
    /// - Returns: 返回一个动态颜色
    func xti_dynamic() -> UIColor {
        if self.xti_isDynamic {
            return self
        }
        if #available(iOS 13.0, *) {
            return UIColor.init { trait in
                if trait.userInterfaceStyle == .light {
                    return self
                } else {
                    let ciColor = CIColor(cgColor: self.cgColor)
                    return UIColor(red: 1 - ciColor.red, green: 1 - ciColor.green, blue: 1 - ciColor.blue, alpha: ciColor.alpha)
                }
            }
        } else {
            return self
        }
    }

    /// 给现有的颜色添加一个透明度
    /// - Parameter alpha: 透明度
    /// - Returns: 新的颜色
    func xit_alpha(_ alpha: CGFloat = 1) -> UIColor {
        if #available(iOS 13.0, *) {
            if !self.xti_isDynamic {
                let ciColor = CIColor(cgColor: self.cgColor)
                return UIColor(red: ciColor.red, green: ciColor.green, blue: ciColor.blue, alpha: alpha)
            }
            return UIColor.init { _ in
                let ciColor = CIColor(cgColor: self.cgColor)
                return UIColor(red: ciColor.red, green: ciColor.green, blue: ciColor.blue, alpha: alpha)
            }
        } else {
            let ciColor = CIColor(cgColor: self.cgColor)
            return UIColor(red: ciColor.red, green: ciColor.green, blue: ciColor.blue, alpha: alpha)
        }
    }

    /// 通过16进制的字符串获取颜色，支持0x、#或不带前缀
    /// - Parameter hex: 颜色的16进制字符串，可以包括透明通道
    static func xti_hex(_ hex: String, alpha: CGFloat = 1) -> UIColor {
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

        return self.xti_hex(hexInt, alpha: tempAlpha)
    }

    /// 通过16进制的整数及透明度获取颜色
    /// - Parameters:
    ///   - hex: 颜色的16进制数值，不包括透明通道
    ///   - alpha: 透明度
    /// - Returns: 得到的颜色
    static func xti_hex(_ hex: UInt64, alpha: CGFloat = 1) -> UIColor {
        let red = CGFloat((hex >> 16) % 256) / 255.0
        let green = CGFloat((hex >> 8) % 256) / 255.0
        let blue = CGFloat(hex % 256) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }

    /// 获取随机的颜色
    static var xti_random: UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        return color
    }
}
