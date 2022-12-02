//
//  UIView+Filter.swift
//  DVTUIKit
//
//  Created by darvin on 2022/12/2.
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
    static var FilterViewKey: Int8 = 0
    static var dvt_hook = false
    var filterView: UIView {
        guard let view = objc_getAssociatedObject(self, &Self.FilterViewKey) as? UIView else {
            let view = UIView()
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            objc_setAssociatedObject(self, &Self.FilterViewKey, view, .OBJC_ASSOCIATION_RETAIN)
            return view
        }
        return view
    }

    static func hook() {
        defer {
            Self.dvt_hook = true
        }
        if Self.dvt_hook {
            return
        }
        let selectors = [
            [#selector(addSubview(_:)), #selector(dvt_addSubview(_:))],
            [#selector(layoutSubviews), #selector(dvt_layoutSubviews)],
        ]

        selectors.forEach { list in
            if list.count == 2, let o = list.first, let s = list.last {
                UIView.swizzleSelector(o, swizzle: s)
            }
        }
    }

    @objc func dvt_layoutSubviews() {
        self.dvt_layoutSubviews()
        self.filterView.frame = self.bounds
    }

    @objc func dvt_addSubview(_ view: UIView) {
        self.dvt_addSubview(view)
        if self.filterView.superview == self {
            self.bringSubviewToFront(self.filterView)
        }
    }

    func addFilterView(_ color: UIColor, filter: String) {
        Self.hook()
        if self.filterView.superview != self {
            self.filterView.removeFromSuperview()
            self.addSubview(self.filterView)
        }
        self.filterView.backgroundColor = color
        self.filterView.layer.compositingFilter = filter
    }

    func removeFilter() {
        self.filterView.removeFromSuperview()
    }
}

public extension BaseWrapper where BaseType: UIView {
    /// 添加滤镜，默认黑白滤镜
    /// - Parameter color: 滤镜颜色
    /// - Parameter name: 滤镜的名字，具体查看CIFilter
    func addFilter(_ color: UIColor = .black, filter name: String = "saturationBlendMode") {
        self.base.addFilterView(color, filter: name)
    }

    /// 移除滤镜
    func removeFilter() {
        self.base.removeFilter()
    }
}
