//
//  UIView.swift
//
//
//  Created by darvin on 2021/10/11.
//

/*

 MIT License

 Copyright (c) 2021 darvin http://blog.tcoding.cn

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

extension UIView: NameSpace {}
public extension BaseWrapper where DT: UIView {
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
    func addCorner(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.base.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.base.bounds
        maskLayer.path = maskPath.cgPath
        self.base.layer.mask = maskLayer
    }
}

private extension UIView {
    static var ClickBlockKey: Int8 = 0

    var clickBlock: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &Self.ClickBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let block = objc_getAssociatedObject(self, &Self.ClickBlockKey) {
                return block as? () -> Void
            }
            return nil
        }
    }

    @objc func didClickSelf() {
        self.clickBlock?()
    }
}

public extension BaseWrapper where DT: UIView {
    @available(*, unavailable, message: "请使用addTapGesture(_:touchs:block:)")
    func addTap(_ taps: Int = 1, touchs: Int = 1, block clickBlock: @escaping (DT) -> Void) {
        self.addTapGesture(taps, touchs: touchs, block: clickBlock)
    }

    /// 给视图添加点击手势
    /// - Parameters:
    ///   - taps: 点击次数
    ///   - touchs: 触摸点数
    ///   - clickBlock: 执行的闭包
    func addTapGesture(_ taps: Int = 1, touchs: Int = 1, block clickBlock: @escaping (DT) -> Void) {
        if self.base is UIButton {
            assert(false, "不能给\(self.base.classForCoder)添加点击事件")
            return
        }
        self.base.isUserInteractionEnabled = true
        let view = self.base
        self.base.clickBlock = {
            clickBlock(view)
        }
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = taps
        tap.numberOfTouchesRequired = touchs
        tap.addTarget(self.base, action: #selector(self.base.didClickSelf))
        self.base.addGestureRecognizer(tap)
    }
}

public extension BaseWrapper where DT: UIView {
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
