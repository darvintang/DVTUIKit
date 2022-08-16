//
//  UIColor.swift
//  DVTUIKit
//
//  Created by darvin on 2021/4/23.
//

/*

 MIT License

 Copyright (c) 2022 darvin http://blog.tcoding.cn

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

extension UIColor: NameSpace {}

public extension BaseWrapper where BaseType == UIColor {
    @available(iOS 13.0, *)
    var isDynamic: Bool {
        guard let cls = NSClassFromString("UI" + "Dynamic" + "Color") else {
            return false
        }
        return self.base.isKind(of: cls)
    }

    /// 将当前颜色转化成跟随系统的动态颜色，基准为浅色，如果该颜色已经是动态的了就不会再转化了
    /// - Returns: 返回一个动态颜色
    @available(iOS 13.0, *)
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
        if #available(iOS 13.0, *) {
            if !self.isDynamic {
                let ciColor = CIColor(cgColor: self.base.cgColor)
                return UIColor(red: ciColor.red, green: ciColor.green, blue: ciColor.blue, alpha: alpha)
            }
            return UIColor.init { _ in
                let ciColor = CIColor(cgColor: self.base.cgColor)
                return UIColor(red: ciColor.red, green: ciColor.green, blue: ciColor.blue, alpha: alpha)
            }
        } else {
            let ciColor = CIColor(cgColor: self.base.cgColor)
            return UIColor(red: ciColor.red, green: ciColor.green, blue: ciColor.blue, alpha: alpha)
        }
    }

    /// 获取随机的颜色
    static var random: UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        return color
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

    @available(iOS 13.0, *)
    convenience init(dvtLight: UIColor, dark: UIColor? = nil) {
        self.init { trait in
            if trait.userInterfaceStyle == .light {
                return dvtLight
            } else {
                return dark ?? dvtLight
            }
        }
    }

    @available(iOS 13.0, *)
    convenience init(dvtLight: UInt64, dark: UInt64? = nil) {
        self.init { trait in
            var color = UIColor(dvt: dvtLight)
            if trait.userInterfaceStyle != .light {
                color = UIColor(dvt: dark ?? dvtLight)
            }
            return color
        }
    }

    @available(iOS 13.0, *)
    convenience init(dvtLight: String, dark: String? = nil) {
        self.init { trait in
            var color = UIColor(dvt: dvtLight)
            if trait.userInterfaceStyle != .light {
                color = UIColor(dvt: dark ?? dvtLight)
            }
            return color
        }
    }
}
