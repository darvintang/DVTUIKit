//
//  CGGeometry+.swift
//
//
//  Created by darvintang on 2020/12/24.
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

import DVTFoundation
import UIKit

/// 判断设备类型

extension Bool: NameSpace {}
public extension BaseWrapper where BaseType == Bool {
    /// 判断当前线程是否是主线程
    static var isMainThread: Bool {
        return OperationQueue.current?.underlyingQueue?.label == DispatchQueue.main.label
    }

    /// 判断是否是4寸屏iPhone，逻辑像素(320*568)
    static var isIphone5: Bool {
        let size = CGSize.dvt.screenSize
        return size.equalTo(CGSize(width: 320, height: 568)) || size.equalTo(CGSize(width: 568, height: 320))
    }

    /// 判断是否是4寸屏iPhone，逻辑像素(320*568)
    static var isIphone: Bool {
        let size = CGSize.dvt.screenSize
        return size.equalTo(CGSize(width: 375, height: 667)) || size.equalTo(CGSize(width: 667, height: 375))
    }

    /// 5.5寸Puls大屏
    static var isIphonePuls: Bool {
        let size = CGSize.dvt.screenSize
        return size.equalTo(CGSize(width: 414, height: 736)) || size.equalTo(CGSize(width: 736, height: 414))
    }

    /// 刘海屏
    @available(iOS 11.0, *)
    static var isAlienScreen: Bool {
        (UIApplication.dvt.mainWindow?.safeAreaInsets.bottom ?? 0) > 0
    }

    static var isLandscape: Bool {
        let orientation = UIApplication.shared.statusBarOrientation
        return orientation == .landscapeLeft || orientation == .landscapeRight
    }
}

extension CGRect: NameSpace {}
public extension BaseWrapper where BaseType == CGRect {
    static var screenBounds: CGRect {
        return UIScreen.main.bounds
    }
}

extension CGSize: NameSpace {}
public extension BaseWrapper where BaseType == CGSize {
    /// 屏幕大小
    static var screenSize: CGSize {
        return CGRect.dvt.screenBounds.size
    }
}

fileprivate var CGFloat_STATUS_HEIGHT: CGFloat?
extension CGFloat: NameSpace {}
public extension BaseWrapper where BaseType == CGFloat {
    /// 屏幕宽度
    static var screenWidth: CGFloat {
        return CGSize.dvt.screenSize.width
    }

    /// 屏幕高度
    static var screenHeight: CGFloat {
        return CGSize.dvt.screenSize.height
    }

    /// 状态栏安全高度
    static var statusHeight: CGFloat {
        if #available(iOS 11.0, *) {
            if Bool.dvt.isAlienScreen {
                return UIApplication.dvt.mainWindow?.safeAreaInsets.top ?? 0
            }
        }
        return Bool.dvt.isLandscape ? 0 : 20.0
    }

    /// 异形屏 机型 底部控制栏高度
    static var safeBottomHeight: CGFloat {
        if #available(iOS 11.0, *) {
            if .dvt.isAlienScreen {
                return UIApplication.dvt.mainWindow?.safeAreaInsets.bottom ?? 0
            }
        }
        return 0
    }

    /// tabbar的安全高度
    static var tabBarHeight: CGFloat {
        return self.safeBottomHeight + 49.0
    }

    /// 导航控制器安全高度
    static var navigationBarHeight: CGFloat {
        return self.statusHeight + 44.0
    }

    /// 以375为标准计算尺寸
    static func with375(_ value: CGFloat) -> CGFloat {
        return value / 375.0 * Swift.min(self.screenWidth, self.screenHeight)
    }
}
