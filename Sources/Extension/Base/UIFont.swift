//
//  File.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2021/10/13.
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

extension UIFont: NameSpace { }

public extension BaseWrapper where BaseType == UIFont {
    static func ultraLight(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .ultraLight) }
    static func thin(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .thin) }
    static func light(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .light) }
    static func regular(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .regular) }
    static func medium(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .medium) }
    static func semibold(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .semibold) }
    static func bold(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .bold) }
    static func heavy(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .heavy) }
    static func black(of fontSize: CGFloat) -> UIFont { .systemFont(ofSize: fontSize, weight: .black) }
}
