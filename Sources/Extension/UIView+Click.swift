//
//  UIView+Base.swift
//  DVTUIKit
//
//  Created by darvin on 2021/10/11.
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
import ObjectiveC
import UIKit

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

public extension BaseWrapper where BaseType: UIView {
    @available(*, deprecated, renamed: "addTapGesture(_:touchs:block:)", message: "2.0.1版本之后弃用该方法")
    func addTap(_ taps: Int = 1, touchs: Int = 1, block clickBlock: @escaping (BaseType) -> Void) {
        self.addTapGesture(taps, touchs: touchs, block: clickBlock)
    }
}

public extension BaseWrapper where BaseType: UIView {
    /// 给视图添加点击手势
    /// - Parameters:
    ///   - taps: 点击次数
    ///   - touchs: 触摸点数
    ///   - clickBlock: 执行的闭包
    func addTapGesture(_ taps: Int = 1, touchs: Int = 1, block clickBlock: @escaping (BaseType) -> Void) {
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
