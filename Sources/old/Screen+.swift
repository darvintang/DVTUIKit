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


import UIKit

/// 判断设备类型

fileprivate var Bool_isAlienScreen: Bool?
fileprivate var SCREENInfo_SafeAreaInsets: UIEdgeInsets?

public extension Bool {
    static var xti_isMainThread: Bool {
        return OperationQueue.current?.underlyingQueue?.label == DispatchQueue.main.label
    }

    static var xti_isIphone5: Bool {
        let size = CGSize.xti_screenSize
        return size.equalTo(CGSize(width: 320, height: 568)) || size.equalTo(CGSize(width: 568, height: 320))
    }

    static var xti_isIphone: Bool {
        let size = CGSize.xti_screenSize
        return size.equalTo(CGSize(width: 375, height: 667)) || size.equalTo(CGSize(width: 667, height: 375))
    }

    static var xti_isIphonePuls: Bool {
        let size = CGSize.xti_screenSize
        return size.equalTo(CGSize(width: 414, height: 736)) || size.equalTo(CGSize(width: 736, height: 414))
    }

    static var xti_isAlienScreen: Bool {
        if #available(iOS 11.0, *) {
            if Bool_isAlienScreen == nil {
                if SCREENInfo_SafeAreaInsets == nil {
                    if Bool.xti_isMainThread {
                        SCREENInfo_SafeAreaInsets = UIWindow(frame: CGRect.xti_screenBounds).safeAreaInsets
                    } else {
                        DispatchQueue.main.sync {
                            SCREENInfo_SafeAreaInsets = UIWindow(frame: CGRect.xti_screenBounds).safeAreaInsets
                        }
                    }
                }
                let safeAreaInsets = SCREENInfo_SafeAreaInsets ?? UIEdgeInsets.zero
                Bool_isAlienScreen = safeAreaInsets.bottom > 0
            }
            return Bool_isAlienScreen ?? false
        } else {
            return false
        }
    }

    static var xti_isLandscape: Bool {
        let orientation = UIApplication.shared.statusBarOrientation
        return orientation == .landscapeLeft || orientation == .landscapeRight
    }
}

/// 获取设备一些尺寸
public extension CGRect {
    static var xti_screenBounds: CGRect {
        return UIScreen.main.bounds
    }
}

public extension CGSize {
    /// 屏幕大小
    static var xti_screenSize: CGSize {
        return CGRect.xti_screenBounds.size
    }
}

fileprivate var CGFloat_STATUS_HEIGHT: CGFloat?

public extension CGFloat {
    /// 屏幕宽度
    static var xti_screenWidth: CGFloat {
        return CGSize.xti_screenSize.width
    }

    /// 屏幕高度
    static var xti_screenHeight: CGFloat {
        return CGSize.xti_screenSize.height
    }

    /// 状态栏安全高度
    static var xti_statusHeight: CGFloat {
        if #available(iOS 11.0, *) {
            if Bool.xti_isAlienScreen {
                if SCREENInfo_SafeAreaInsets == nil {
                    if Bool.xti_isMainThread {
                        SCREENInfo_SafeAreaInsets = UIWindow(frame: CGRect.xti_screenBounds).safeAreaInsets
                    } else {
                        DispatchQueue.main.sync {
                            SCREENInfo_SafeAreaInsets = UIWindow(frame: CGRect.xti_screenBounds).safeAreaInsets
                        }
                    }
                }
                let safeAreaInsets = SCREENInfo_SafeAreaInsets ?? UIEdgeInsets.zero
                return safeAreaInsets.top
            }
        }
        return Bool.xti_isLandscape ? 0 : 20.0
    }

    /// 异形屏 机型 底部控制栏高度
    static var xti_buttonHeight: CGFloat {
        if #available(iOS 11.0, *) {
            if Bool.xti_isAlienScreen {
                if SCREENInfo_SafeAreaInsets == nil {
                    if Bool.xti_isMainThread {
                        SCREENInfo_SafeAreaInsets = UIWindow(frame: CGRect.xti_screenBounds).safeAreaInsets
                    } else {
                        DispatchQueue.main.sync {
                            SCREENInfo_SafeAreaInsets = UIWindow(frame: CGRect.xti_screenBounds).safeAreaInsets
                        }
                    }
                }
                let safeAreaInsets = SCREENInfo_SafeAreaInsets ?? UIEdgeInsets.zero
                return safeAreaInsets.bottom
            }
        }
        return 0
    }

    /// tabbar的安全高度
    static var xti_tabbarHeight: CGFloat {
        return xti_buttonHeight + 49.0
    }

    /// 导航控制器安全高度
    static var xti_navbarHeight: CGFloat {
        return xti_statusHeight + 44.0
    }

    /// 以375为标准计算尺寸
    static func xti_375(_ value: CGFloat) -> CGFloat {
        return value * 375.0 / Swift.min(self.xti_screenWidth, self.xti_screenHeight)
    }
}
