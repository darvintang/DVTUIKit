//
//  UIView+Filter.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2022/12/2.
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
import ObjectiveC
import DVTFoundation

private extension UIView {
    static var UIView_Extension_dvt_filterView_Key: Int8 = 0
    static var UIView_Extension_dvt_hook_flag = false

    var dvt_filterView: UIView {
        guard let view = objc_getAssociatedObject(self, &Self.UIView_Extension_dvt_filterView_Key) as? UIView else {
            let view = UIView()
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            objc_setAssociatedObject(self, &Self.UIView_Extension_dvt_filterView_Key, view, .OBJC_ASSOCIATION_RETAIN)
            return view
        }
        return view
    }

    static func hook() {
        if Self.UIView_Extension_dvt_hook_flag { return }
        defer { Self.UIView_Extension_dvt_hook_flag = true }
        let selectors = [[#selector(addSubview(_:)), #selector(dvt_filter_addSubview(_:))],
                         [#selector(layoutSubviews), #selector(dvt_filter_layoutSubviews)]]

        selectors.forEach { list in
            if list.count == 2, let o = list.first, let s = list.last {
                UIView.dvt_swizzleInstanceSelector(o, swizzle: s)
            }
        }
    }

    @objc func dvt_filter_layoutSubviews() {
        self.dvt_filter_layoutSubviews()
        self.dvt_filterView.frame = self.bounds
    }

    @objc func dvt_filter_addSubview(_ view: UIView) {
        self.dvt_filter_addSubview(view)
        if self.dvt_filterView.superview == self {
            self.bringSubviewToFront(self.dvt_filterView)
        }
    }

    func addFilterView(_ color: UIColor, filter: String) {
        Self.hook()
        if self.dvt_filterView.superview != self {
            self.dvt_filterView.removeFromSuperview()
            self.addSubview(self.dvt_filterView)
        }
        self.dvt_filterView.backgroundColor = color
        self.dvt_filterView.layer.compositingFilter = filter
    }

    func removeFilter() {
        self.dvt_filterView.removeFromSuperview()
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
