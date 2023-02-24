//
//  UIViewController+DVT.swift
//  DVTUIKit_Navigation
//
//  Created by darvin on 2023/1/9.
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

#if canImport(DVTUIKit_Extension)
    import DVTUIKit_Extension
#endif

public extension DVTUINavigationBarStyleDelegate {
    var dvt_navigationBarHidden: Bool { DVTUINavigationBarStyle.default.dvt_navigationBarHidden }
    var dvt_navigationBarTintColor: UIColor? { DVTUINavigationBarStyle.default.dvt_navigationBarTintColor }

    var dvt_titleViewTintColor: UIColor? { DVTUINavigationBarStyle.default.dvt_titleViewTintColor }
    var dvt_titleViewFont: UIFont? { DVTUINavigationBarStyle.default.dvt_titleViewFont }
    var dvt_titleViewLargeFont: UIFont? { DVTUINavigationBarStyle.default.dvt_titleViewLargeFont }

    var dvt_navigationBarBackgroundColor: UIColor? { DVTUINavigationBarStyle.default.dvt_navigationBarBackgroundColor }
    var dvt_navigationBarBackgroundImage: UIImage? { DVTUINavigationBarStyle.default.dvt_navigationBarBackgroundImage }
    var dvt_navigationBarBackgroundEffect: UIBlurEffect? { DVTUINavigationBarStyle.default.dvt_navigationBarBackgroundEffect }

    var dvt_navigationBarShadowColor: UIColor? { DVTUINavigationBarStyle.default.dvt_navigationBarShadowColor }
    var dvt_navigationBarShadowImage: UIImage? { DVTUINavigationBarStyle.default.dvt_navigationBarShadowImage }

    var dvt_navigationBarBackTitle: String? { DVTUINavigationBarStyle.default.dvt_navigationBarBackTitle }
    var dvt_backImage: UIImage? { DVTUINavigationBarStyle.default.dvt_backImage }
    var dvt_backImageColor: UIColor? { DVTUINavigationBarStyle.default.dvt_backImageColor }

    func dvt_revealNavigationBarBackTitle(_ viewController: UIViewController) -> String? { nil }
}

extension BaseWrapper where BaseType == UIViewController {
    static func navigation_swizzleed() {
        if BaseType.UIViewController_navigation_swizzleed_flag { return }
        defer { BaseType.UIViewController_navigation_swizzleed_flag = true }
        BaseType.dvt_swizzleInstanceSelector(#selector(BaseType.viewWillAppear(_:)), swizzle: #selector(BaseType.dvt_viewWillAppear(_:)))
    }
}

protocol DVTUINavigationBridgeDelegate: UINavigationController {
    func dvt_subVC_viewWillAppear(_ appear: UIViewController, animated: Bool)
}

private extension UIViewController {
    static var UIViewController_navigation_swizzleed_flag = false

    @objc func dvt_viewWillAppear(_ animated: Bool) {
        self.dvt.renderNavigationBarStyle(animated)
        self.dvt_viewWillAppear(animated)
        if let navVC = self.navigationController as? DVTUINavigationBridgeDelegate {
            navVC.dvt_subVC_viewWillAppear(self, animated: animated)
        }
    }

    @objc func dvt_viewWillLayoutSubviews() {
        if self.dvt.replaceNavigationBar != nil {
            self.dvt.layoutTransitionNavigationBar()
        }
        self.dvt_viewWillLayoutSubviews()
    }
}

public extension BaseWrapper where BaseType: UIViewController {
    var navigationBarStyle: DVTUINavigationBarStyle? {
        self.base.dvt_navigationBarStyle
    }

    var replaceNavigationBar: DVTTransitionNavigationBar? {
        self.base.dvt_replaceNavigationBar
    }

    var navigationBar: UINavigationBar? {
        self.base.navigationController?.navigationBar
    }

    func setNavigationBarStyle(_ style: DVTUINavigationBarStyle?) {
        self.base.dvt_navigationBarStyle = style
        self.base.dvt_navigationBarStyleModified = true
    }

    func showReplaceNavigationBar() {
        if self.base.dvt_navigationBarStyle?.dvt_navigationBarHidden ?? false {
            return
        }
        self.replaceNavigationBar?.removeFromSuperview()
        guard let old = self.base.navigationController?.navigationBar, let appearance = self.navigationBarStyle?.getAppearance() else { return }
        let new = DVTTransitionNavigationBar()
        new.originalBar = old
        new.standardAppearance = appearance
        new.scrollEdgeAppearance = appearance
        self.base.view.addSubview(new)
        self.base.dvt_replaceNavigationBar = new
        self.layoutTransitionNavigationBar()
    }

    func layoutTransitionNavigationBar() {
        if self.base.isViewLoaded, let replaceNavigationBar = self.replaceNavigationBar,
           let navigationController = self.base.navigationController as? DVTUINavigationController {
            if replaceNavigationBar.superview == self.base.view, let backgroundView = navigationController.navigationBar.dvt.backgroundView {
                let rect = backgroundView.superview?.convert(backgroundView.frame, to: self.base.view) ?? .zero
                replaceNavigationBar.frame = CGRect(origin: CGPoint(x: 0, y: rect.dvt.y), size: rect.size)
                self.base.view.bringSubviewToFront(replaceNavigationBar)
            }
        }
    }

    func hideReplaceNavigationBar() {
        self.replaceNavigationBar?.removeFromSuperview()
    }

    /// 处理导航栏的显隐、样式
    /// - Parameter animated: 是否使用动画
    func renderNavigationBarStyle(_ animated: Bool, useDelegate use: Bool = true) {
        guard self.base.navigationController?.viewControllers.contains(self.base) ?? false else { return }
        // 必须先更新导航栏外观才能控制它的显示和隐藏，不然在iOS15以下系统两个控制器导航栏显示状态不一样的时候会出现异常
        self.renderNavigationBarAppearance(useDelegate: use)
        if let barStyle = self as? DVTUINavigationBarStyleDelegate {
            self.base.navigationController?.setNavigationBarHidden(barStyle.dvt_navigationBarHidden, animated: animated)
        } else if let barStyle = self.navigationBarStyle {
            self.base.navigationController?.setNavigationBarHidden(barStyle.dvt_navigationBarHidden, animated: animated)
        }
    }

    /// 处理导航栏的样式
    func renderNavigationBarAppearance(useDelegate use: Bool = true) {
        guard self.base.navigationController?.viewControllers.contains(self.base) ?? false,
              let navigationBar = self.base.navigationController?.navigationBar else {
            return
        }

        if use, let barStyle = self.base as? DVTUINavigationBarStyleDelegate, !self.base.dvt_navigationBarStyleModified {
            let navigationBarStyle = DVTUINavigationBarStyle(barStyle)
            self.base.dvt_navigationBarStyle = navigationBarStyle
        }
        if let appearance = self.navigationBarStyle?.getAppearance() {
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
    }

    func updateNavigationBarAppearance(useDelegate use: Bool = false) {
        if use {
            self.base.dvt_navigationBarStyleModified = false
        }
        self.navigationBar?.setBackgroundImage(self.navigationBarStyle?.dvt_navigationBarBackgroundImage ?? UIImage(), for: .default)
        self.renderNavigationBarStyle(true, useDelegate: use)
    }
}

private extension UIViewController {
    // MARK: Internal
    var dvt_navigationBarStyle: DVTUINavigationBarStyle? {
        set {
            objc_setAssociatedObject(self, &Self.UIViewController_dvt_navigationBarStyle_Key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let value = objc_getAssociatedObject(self, &Self.UIViewController_dvt_navigationBarStyle_Key) as? DVTUINavigationBarStyle {
                return value
            }
            if let barDelegate = self as? DVTUINavigationBarStyleDelegate {
                let navigationBarStyle = DVTUINavigationBarStyle(barDelegate)
                objc_setAssociatedObject(self, &Self.UIViewController_dvt_navigationBarStyle_Key, navigationBarStyle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return navigationBarStyle
            }
            return nil
        }
    }

    var dvt_navigationBarStyleModified: Bool {
        set {
            objc_setAssociatedObject(self, &Self.UIViewController_dvt_navigationBarStyleModified_Key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            objc_getAssociatedObject(self, &Self.UIViewController_dvt_navigationBarStyleModified_Key) as? Bool ?? false
        }
    }

    var dvt_replaceNavigationBar: DVTTransitionNavigationBar? {
        set {
            let weakContainer = DVTWeakObjectContainer(object: newValue)
            objc_setAssociatedObject(self, &Self.UIViewController_dvt_replaceNavigationBar_Key, weakContainer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            (objc_getAssociatedObject(self, &Self.UIViewController_dvt_replaceNavigationBar_Key) as? DVTWeakObjectContainer<DVTTransitionNavigationBar>)?
                .object as? DVTTransitionNavigationBar
        }
    }

    // MARK: Private
    private static var UIViewController_dvt_navigationBarStyle_Key: Int8 = 0
    private static var UIViewController_dvt_navigationBarStyleModified_Key: Int8 = 0
    private static var UIViewController_dvt_replaceNavigationBar_Key: Int8 = 0
}
