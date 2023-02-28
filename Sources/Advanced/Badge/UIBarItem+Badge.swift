//
//  UIBarItem+Badge.swift
//  DVTUIKit_Badge
//
//  Created by darvin on 2023/2/24.
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

extension UIBarItem: NameSpace {
    // MARK: Fileprivate
    fileprivate static func badge_swizzleed() {
        if self.UIBarItem_DVTUIKit_Badge_swizzleed_flag { return }
        self.dvt_swizzleInstanceSelector(NSSelectorFromString("setView:"), swizzle: #selector(dvt_setView(_:)))
        self.UIBarItem_DVTUIKit_Badge_swizzleed_flag = true
    }

    // MARK: Private
    private static var UIBarItem_DVTUIKit_Badge_swizzleed_flag = false
    private static var UIBarItem_DVTUIKit_Badge_tempView_key: UInt8 = 0

    /// 用于在Item没有完成初始化之前保存角标信息
    private var tempView: UIView {
        set { objc_setAssociatedObject(self, &Self.UIBarItem_DVTUIKit_Badge_tempView_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get {
            if let view = objc_getAssociatedObject(self, &Self.UIBarItem_DVTUIKit_Badge_tempView_key) as? UIView { return view }
            let view = UIView(); objc_setAssociatedObject(self, &Self.UIBarItem_DVTUIKit_Badge_tempView_key, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return view
        }
    }

    @objc private func dvt_setView(_ view: UIView?) {
        var tempView = view
        if self.dvt_view == self.tempView { tempView?.dvt.synchronizeBaege(self.tempView) }
        self.dvt_setView(tempView)
    }
}

extension UIBarItem: DVTBadgeProtocol {
    public var dvt_view: UIView? {
        Self.badge_swizzleed()
        var view: UIView?
        NSException.dvt.ignore { view = self.value(forKey: "view") as? UIView }
        return view ?? self.tempView
    }
}
