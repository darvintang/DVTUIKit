//
//  UIScrollView.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2023/2/17.
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

private extension UIScrollView {
    static var UIScrollView_dvt_hasSetInitialContentInset_Key: UInt8 = 0
    static var UIScrollView_dvt_initialContentInset_Key: UInt8 = 0

    var hasSetInitialContentInset: Bool {
        set {
            objc_setAssociatedObject(self, &Self.UIScrollView_dvt_hasSetInitialContentInset_Key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            (objc_getAssociatedObject(self, &Self.UIScrollView_dvt_hasSetInitialContentInset_Key) as? Bool) ?? false
        }
    }

    var initialContentInset: UIEdgeInsets {
        set {
            objc_setAssociatedObject(self, &Self.UIScrollView_dvt_initialContentInset_Key, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.contentInset = newValue
            self.scrollIndicatorInsets = newValue
        }
        get {
            (objc_getAssociatedObject(self, &Self.UIScrollView_dvt_initialContentInset_Key) as? UIEdgeInsets) ?? .zero
        }
    }
}

public extension BaseWrapper where BaseType: UIScrollView {
    ///  判断UIScrollView是否已经处于顶部（当UIScrollView内容不够多不可滚动时，也认为是在顶部）
    var alreadyAtTop: Bool {
        false
    }

    /// 判断UIScrollView是否已经处于底部（当UIScrollView内容不够多不可滚动时，也认为是在底部）
    var alreadyAtBottom: Bool {
        false
    }

    /// 判断当前的scrollView内容是否足够滚动
    var canScroll: Bool {
        let view = self.base

        if view.bounds.size.dvt.isEmpty {
            return false
        }
        return (view.bounds.height < view.contentSize.height + view.adjustedContentInset.dvt.vertical)
            || (view.bounds.width < view.contentSize.width + view.adjustedContentInset.dvt.horizontal)
    }

//    /// `UIScrollView` 默认的 contentInset，会自动将 contentInset 和 scrollIndicatorInsets 都设置为这个值
//    /// 并且调用一次 scrollToTopUponContentInsetTopChange 设置默认的 contentOffset，一般用于 UIScrollViewContentInsetAdjustmentNever 的列表。
//    ///
//    /// 如果 scrollView 被添加到某个 viewController 上，则只有在 viewController viewDidAppear 之前（不包含 viewDidAppear）设置这个属性才会自动滚到顶部，
//    /// 如果在 viewDidAppear 之后才添加到 viewController 上，则只有第一次设置 qmui_initialContentInset 时才会滚动到顶部。
//    /// 这样做的目的是为了避免在 scrollView 已经显示出来并滚动到列表中间后，由于某些原因，contentInset 发生了中间值的变动（也即一开始是正确的值，中间变成错误的值，再变回正确的值），此时列表会突然跳到顶部的问题。
//    var initialContentInset: UIEdgeInsets {
//        get {
//            self.base.initialContentInset
//        }
//        set {
//            self.base.initialContentInset = newValue
//            if !self.base.hasSetInitialContentInset || self.base.dvt.viewController?.dvt.visibleState ?? .unowned < .didAppear {
//                self.scrollToTopUponContentInsetTopChange()
//            }
//            self.base.hasSetInitialContentInset = true
//        }
//    }
//
//    func scrollToTopUponContentInsetTopChange() {
//    }
}
