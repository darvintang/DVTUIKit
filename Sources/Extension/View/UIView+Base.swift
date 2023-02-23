//
//  UIView+Base.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2021/10/11.
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

extension UIView: NameSpace {
    static var UIView_dvt_viewControllerKey: UInt8 = 0
    fileprivate var dvt_viewController: UIViewController? {
        set {
            let container = DVTWeakObjectContainer(object: newValue)
            objc_setAssociatedObject(self, &Self.UIView_dvt_viewControllerKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            (objc_getAssociatedObject(self, &Self.UIView_dvt_viewControllerKey) as? DVTWeakObjectContainer)?.object
        }
    }
}

public extension BaseWrapper where BaseType: UIView {
    var origin: CGPoint {
        set { self.base.frame = CGRect(origin: newValue, size: self.size) }
        get { self.base.frame.origin }
    }

    var size: CGSize {
        set { self.base.frame = CGRect(origin: self.origin, size: newValue) }
        get { self.base.frame.size }
    }

    var x: CGFloat {
        set { self.origin = CGPoint(x: newValue, y: self.y) }
        get { self.origin.x }
    }

    var y: CGFloat {
        set { self.origin = CGPoint(x: self.x, y: newValue) }
        get { self.origin.y }
    }

    var maxX: CGFloat {
        self.x + self.width
    }

    var maxY: CGFloat {
        self.y + self.height
    }

    var width: CGFloat {
        set { self.size = CGSize(width: newValue, height: self.height) }
        get { self.size.width }
    }

    var height: CGFloat {
        set { self.size = CGSize(width: self.width, height: newValue) }
        get { self.size.height }
    }

    /// 设置视图的圆角
    var cornerRadius: CGFloat {
        set { self.base.layer.cornerRadius = newValue; self.base.clipsToBounds = newValue > 0 }
        get { self.base.layer.cornerRadius }
    }

    /// 添加指定圆角
    ///
    /// 注意，该方法请在视图大小确定后调用，不然会出故障
    ///
    /// - Parameters:
    ///   - corners: 指定的圆角
    ///   - radius: 圆角的大小
    func add(corners: UIRectCorner, radius: CGFloat) {
        var maskedCorners: CACornerMask = []
        if corners.contains(.topLeft) {
            maskedCorners.insert(.layerMinXMinYCorner)
        }
        if corners.contains(.topRight) {
            maskedCorners.insert(.layerMaxXMinYCorner)
        }
        if corners.contains(.bottomLeft) {
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        if corners.contains(.bottomRight) {
            maskedCorners.insert(.layerMaxXMaxYCorner)
        }
        if corners == .allCorners {
            maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        }
        self.add(corners: maskedCorners, radius: radius)
    }

    /// 添加指定圆角
    ///
    /// 注意，该方法请在视图大小确定后调用，不然会出故障
    ///
    /// - Parameters:
    ///   - corners: 指定的圆角
    ///   - radius: 圆角的大小
    func add(corners: CACornerMask, radius: CGFloat) {
        self.base.layer.maskedCorners = corners
        self.base.layer.cornerRadius = radius
    }
}

public extension BaseWrapper where BaseType: UIView {
    /// 获取当前视图所在的窗口，直接往superview查找，直到拿到窗口
    ///
    /// 因其使用递归实现，尽量少用
    var currentWindow: UIView? {
        if self.base.superview is UIWindow {
            return self.base.superview
        } else {
            return self.base.superview?.dvt.currentWindow
        }
    }
}

public extension BaseWrapper where BaseType: UIView {
    /// 视图截图
    var image: UIImage? {
        self.base.layer.dvt.image
    }
}

public extension BaseWrapper where BaseType: UIView {
    func removeAllSubView(where: (_ view: UIView) -> Bool = { _ in true }) {
        let subviews = self.base.subviews
        for view in subviews {
            if `where`(view) {
                view.removeFromSuperview()
            }
        }
    }
}

fileprivate extension UIView {
    func printNSException(_ exception: NSException) {
        var logerinfo = exception.name.rawValue
        let reason = exception.reason ?? ""
        if !reason.isEmpty {
            logerinfo += "<\(reason)>"
        }
        dvtuiloger.error("使用 KVC 访问了 \(self) 的私有属性，触发了系统的 NSException: \(logerinfo)")
    }
}

public extension BaseWrapper where BaseType: UIView {
    func value(forKey key: String) -> Any? {
        var res: Any?
        NSException.dvt.ignoreHandler { [weak base = self.base] in
            res = base?.value(forKey: key)
        } completion: { [weak base = self.base] exception in
            base?.printNSException(exception)
        }
        return res
    }

    func setValue(_ value: Any?, forKey key: String) {
        NSException.dvt.ignoreHandler { [weak base = self.base] in
            base?.setValue(value, forKey: key)
        } completion: { [weak base = self.base] exception in
            base?.printNSException(exception)
        }
    }

    func value(forKeyPath keyPath: String) -> Any? {
        var res: Any?
        NSException.dvt.ignoreHandler { [weak base = self.base] in
            res = base?.value(forKeyPath: keyPath)
        } completion: { [weak base = self.base] exception in
            base?.printNSException(exception)
        }
        return res
    }

    func setValue(_ value: Any?, forKeyPath keyPath: String) {
        NSException.dvt.ignoreHandler { [weak base = self.base] in
            base?.setValue(value, forKeyPath: keyPath)
        } completion: { [weak base = self.base] exception in
            base?.printNSException(exception)
        }
    }
}

public extension BaseWrapper where BaseType: UIView {
    var visible: Bool {
        let view = self.base
        if view.isHidden || view.alpha <= 0.01 {
            return false
        }

        if view.window != nil {
            return true
        }
        if let window = view as? UIWindow {
            return window.windowScene != nil
        }
        return self.viewController?.dvt.visibleState.isVisible ?? false
    }

    var isControllerRootView: Bool {
        self.viewController?.view == self.base
    }

    var viewController: UIViewController? {
        if let vc = self.base.dvt_viewController {
            return vc
        }
        var next = self.base.next
        repeat {
            if let vc = next as? UIViewController {
                self.base.dvt_viewController = vc
                return vc
            }
            next = next?.next
        } while next != nil
        return nil
    }
}

// public extension UIView {
//    class WatermarkView: UIView {
//        @available(*, unavailable, message: "禁止修改")
//        override public var isUserInteractionEnabled: Bool {
//            willSet {
//                fatalError("不能修改isUserInteractionEnabled属性")
//            }
//        }
//
//        override public init(frame: CGRect) {
//            super.init(frame: frame)
//            super.isUserInteractionEnabled = false
//        }
//
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//    }
//
//    private static var WatermarkKey: Int8 = 0
//    fileprivate var watermarkView: WatermarkView {
//        guard let view = objc_getAssociatedObject(self, &Self.WatermarkKey) as? WatermarkView else {
//            let view = WatermarkView()
//            self.addSubview(view)
//            objc_setAssociatedObject(self, &Self.WatermarkKey, view, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//            return view
//        }
//        return view
//    }
// }
//
// public extension BaseWrapper where BaseType: UIView {
//    var watermark: UIView.WatermarkView {
//        self.base.watermarkView
//    }
// }
