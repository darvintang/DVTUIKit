//
//  UINavigationBar+Transition.swift
//  DVTUIKit_Navigation
//
//  Created by darvin on 2023/1/10.
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
import ObjectiveC
import UIKit

#if canImport(DVTUIKit_Extension)
    import DVTUIKit_Extension
#endif

fileprivate extension DVTTransitionNavigationBar {
    @objc func dvt_didMove(_ from: UIWindow?, to window: UIWindow?) {
        self.dvt_didMove(from, to: window)
    }

    @objc func dvt_accessibility_navigationController() -> UINavigationController? {
        let didOSel = NSSelectorFromString("dvt_accessibility_navigationController")
        if let oBar = self.originalBar {
            return oBar.perform(didOSel)?.takeUnretainedValue() as? UINavigationController
        }
        return self.perform(didOSel)?.takeUnretainedValue() as? UINavigationController
    }
}

open class DVTTransitionNavigationBar: UINavigationBar {
    public var shouldPreventRender: Bool = false
    public weak var originalBar: UINavigationBar?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        Self.swizzleedMethod()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        Self.swizzleedMethod()
    }

    override open func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if subview == self.dvt.backgroundView {
            let sel = NSSelectorFromString("updateBackground")
            if subview.responds(to: sel) {
                subview.perform(sel)
            }
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
    }

    private static var SwizzleedMethod = false
    private static func swizzleedMethod() {
        if !self.SwizzleedMethod {
            if #available(iOS 15.0, *) {
                let didOSel = NSSelectorFromString("_didMove" + "FromWindow:" + "toWindow:")
                let didSSel = NSSelectorFromString("dvt_didMove(_:to:)")
                self.swizzleSelector(didOSel, swizzle: didSSel)
            }
            if #available(iOS 14.0, *) {
                let didOSel = NSSelectorFromString("_accessibility_navigationController")
                let didSSel = NSSelectorFromString("dvt_accessibility_navigationController")
                self.swizzleSelector(didOSel, swizzle: didSSel)
            }

            self.SwizzleedMethod = true
        }
    }
}

public class DVTUINavigationBarStyle {
    private let id = UUID().uuidString
    private static var _default = DVTUINavigationBarStyle(UINavigationBarAppearance())
    public static var `default`: DVTUINavigationBarStyle {
        get {
            _default
        }
        set {
            if _default.id != newValue.id {
                dvtuiloger.error("仅允许修改属性，不允许直接修改对象")
            } else {
                _default = newValue
            }
        }
    }

    public init(_ delegate: DVTUINavigationBarStyleDelegate? = nil) {
        self.dvt_navigationBarHidden = delegate?.dvt_navigationBarHidden ?? false
        self.dvt_navigationBarTintColor = delegate?.dvt_navigationBarTintColor

        self.dvt_titleViewTintColor = delegate?.dvt_titleViewTintColor
        self.dvt_titleViewFont = delegate?.dvt_titleViewFont
        self.dvt_titleViewLargeFont = delegate?.dvt_titleViewLargeFont

        self.dvt_navigationBarBackgroundColor = delegate?.dvt_navigationBarBackgroundColor
        self.dvt_navigationBarBackgroundEffect = delegate?.dvt_navigationBarBackgroundEffect
        self.dvt_navigationBarBackgroundImage = delegate?.dvt_navigationBarBackgroundImage

        self.dvt_navigationBarShadowColor = delegate?.dvt_navigationBarShadowColor
        self.dvt_navigationBarShadowImage = delegate?.dvt_navigationBarShadowImage

        self.dvt_navigationBarBackTitle = delegate?.dvt_navigationBarBackTitle
        self.dvt_backImage = delegate?.dvt_backImage
    }

    public init(_ appearance: UINavigationBarAppearance) {
        self.dvt_navigationBarTintColor = appearance.backButtonAppearance.normal.titleTextAttributes[.foregroundColor] as? UIColor

        self.dvt_titleViewTintColor = appearance.titleTextAttributes[.foregroundColor] as? UIColor
        self.dvt_titleViewFont = appearance.titleTextAttributes[.font] as? UIFont
        self.dvt_titleViewLargeFont = appearance.largeTitleTextAttributes[.font] as? UIFont

        self.dvt_navigationBarBackgroundColor = appearance.backgroundColor
        self.dvt_navigationBarBackgroundEffect = appearance.backgroundEffect
        self.dvt_navigationBarBackgroundImage = appearance.backgroundImage
        let image = appearance.shadowImage
        if #available(iOS 15.0, *) {
            self.dvt_navigationBarShadowColor = appearance.shadowColor ?? image == nil ? .clear : nil
        } else {
            self.dvt_navigationBarShadowColor = appearance.shadowColor
        }
        self.dvt_navigationBarShadowImage = image
        self.dvt_backImage = appearance.backIndicatorImage
    }

    public var dvt_navigationBarHidden: Bool = false

    public var dvt_navigationBarTintColor: UIColor?

    public var dvt_titleViewTintColor: UIColor?
    public var dvt_titleViewFont: UIFont?
    public var dvt_titleViewLargeFont: UIFont?

    public var dvt_navigationBarBackgroundColor: UIColor? {
        didSet {
            if self.dvt_navigationBarBackgroundColor != nil {
                self.dvt_navigationBarBackgroundImage = nil
            }
        }
    }

    public var dvt_navigationBarBackgroundImage: UIImage?
    public var dvt_navigationBarBackgroundEffect: UIBlurEffect?

    public var dvt_navigationBarShadowColor: UIColor? {
        didSet {
            if self.dvt_navigationBarShadowColor != nil {
                self.dvt_navigationBarShadowImage = nil
            }
        }
    }

    public var dvt_navigationBarShadowImage: UIImage? {
        didSet {
            if self.dvt_navigationBarShadowImage != nil {
                self.dvt_navigationBarShadowColor = nil
            }
        }
    }

    public var dvt_navigationBarBackTitle: String?
    public var dvt_backImage: UIImage?

    func getAppearance() -> UINavigationBarAppearance {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        // 导航栏title的颜色
        if let tintColor = self.dvt_titleViewTintColor {
            navigationBarAppearance.titleTextAttributes[.foregroundColor] = tintColor
            navigationBarAppearance.largeTitleTextAttributes[.foregroundColor] = tintColor
        }
        if let font = self.dvt_titleViewFont {
            navigationBarAppearance.titleTextAttributes[.font] = font
        }
        if let font = self.dvt_titleViewLargeFont {
            navigationBarAppearance.largeTitleTextAttributes[.font] = font
        }

        // 导航栏背景颜色/图片，图片优先
        navigationBarAppearance.backgroundColor = self.dvt_navigationBarBackgroundColor
        navigationBarAppearance.backgroundImage = self.dvt_navigationBarBackgroundImage

        // 如果设置的是背景图片，那么该属性设置为空的时候无效
        navigationBarAppearance.backgroundEffect = self.dvt_navigationBarBackgroundEffect

        // 导航栏分隔线颜色/图片，图片优先
        navigationBarAppearance.shadowColor = self.dvt_navigationBarShadowColor
        navigationBarAppearance.shadowImage = self.dvt_navigationBarShadowImage

        if let color = self.dvt_navigationBarTintColor {
            navigationBarAppearance.backButtonAppearance.normal.titleTextAttributes[.foregroundColor] = color
        }
        if let image = self.dvt_backImage?.withRenderingMode(.alwaysOriginal) {
            navigationBarAppearance.setBackIndicatorImage(image, transitionMaskImage: image)
        }
        return navigationBarAppearance
    }
}

public protocol DVTUINavigationBarStyleDelegate {
    /// 隐藏导航栏
    var dvt_navigationBarHidden: Bool { get }
    /// 导航栏上的控件色调颜色，主要用于设置返回按钮颜色
    var dvt_navigationBarTintColor: UIColor? { get }

    /// 导航栏的标题颜色
    var dvt_titleViewTintColor: UIColor? { get }
    /// 导航栏的标题字体
    var dvt_titleViewFont: UIFont? { get }
    /// 导航栏的标题字体
    var dvt_titleViewLargeFont: UIFont? { get }

    /// 导航栏背景图片，优先级高于颜色
    var dvt_navigationBarBackgroundImage: UIImage? { get }
    /// 导航栏背景颜色，优先级低于图片
    var dvt_navigationBarBackgroundColor: UIColor? { get }

    /// 导航栏背景模糊，如果为空并且设置背景颜色的时候就不会有模糊效果
    var dvt_navigationBarBackgroundEffect: UIBlurEffect? { get }

    /// 导航栏分割线图片，优先级高于颜色
    var dvt_navigationBarShadowImage: UIImage? { get }
    /// 导航栏分割线颜色，优先级低于图片
    var dvt_navigationBarShadowColor: UIColor? { get }

    /// 下一级界面返回按钮文字
    var dvt_navigationBarBackTitle: String? { get }
    /// 当前界面返回按钮显示的文字
    /// - Parameter viewController: 上一级界面
    /// - Returns: 当前界面返回按钮显示的文字
    func dvt_revealNavigationBarBackTitle(_ viewController: UIViewController) -> String?
    /// 返回按钮图标
    var dvt_backImage: UIImage? { get }
}
