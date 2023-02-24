//
//  DVTUIKit_ExtensionConfig.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2022/8/25.
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
import DVTLoger

public let dvtuiloger = {
    let loger = Loger("DVTUIKit")
    loger.toFileLevel = .off
    #if !DEBUG
        loger.toConsole = true
    #endif
    return loger
}()

public struct DVTUIKitConfig {
    public static var logerLevel: Loger.Level = .all {
        didSet {
            dvtuiloger.logLevel = logerLevel
        }
    }

    /// 需要提前hook的功能在这个函数里进行hook
    /// 例如获取UIViewController的状态，必须hook它的生命周期函数才能获取，如果等使用的时候再hook，第一次的结果会不准确
    public static func beginHook() {
        dvtuiloger.debug("启动DVTUIKit")
        UIViewController.dvt.extension_swizzleed()
    }
}
