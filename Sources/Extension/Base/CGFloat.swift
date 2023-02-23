//
//  CGFloat.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2022/8/6.
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
        return UIApplication.dvt.activeWindowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }

    /// 异形屏 机型 顶部安全高度
    static var safeTopHeight: CGFloat {
        if .dvt.isAlienScreen {
            return UIApplication.dvt.activeWindow?.safeAreaInsets.top ?? 0
        }
        return Bool.dvt.isLandscape ? 0 : 20.0
    }

    /// 异形屏 机型 底部控制栏高度
    static var safeBottomHeight: CGFloat {
        if .dvt.isAlienScreen {
            return UIApplication.dvt.activeWindow?.safeAreaInsets.bottom ?? 0
        }
        return 0
    }

    /// 异形屏 机型 左边保留区域宽度，横屏的时候有效
    static var safeLeftWidth: CGFloat {
        if .dvt.isAlienScreen {
            return UIApplication.dvt.activeWindow?.safeAreaInsets.left ?? 0
        }
        return 0
    }

    /// 异形屏 机型 右边保留区域宽度，横屏的时候有效
    static var safeRightWidth: CGFloat {
        if .dvt.isAlienScreen {
            return UIApplication.dvt.activeWindow?.safeAreaInsets.right ?? 0
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
        return (value / 375.0 * Swift.min(self.screenWidth, self.screenHeight)).dvt.flat
    }

    /// 基于当前设备的屏幕倍数，进行像素取整。
    var flat: CGFloat {
        if self.base == CGFLOAT_MIN {
            return 0
        }
        let scale = UIScreen.main.scale
        return ceil(self.base * scale) / scale
    }
}
