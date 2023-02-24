//
//  UIView+Badge.swift
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

private extension UIView {
    // MARK: Internal
    var dvt_badgeInteger: UInt {
        set { objc_setAssociatedObject(self, &Self.UIView_Badge_dvt_badgeIntegerKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
        get { objc_getAssociatedObject(self, &Self.UIView_Badge_dvt_badgeIntegerKey) as? UInt ?? 0 }
    }

    var dvt_badgeString: String {
        set { objc_setAssociatedObject(self, &Self.UIView_Badge_dvt_badgeStringKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { objc_getAssociatedObject(self, &Self.UIView_Badge_dvt_badgeStringKey) as? String ?? "" }
    }

    // MARK: Private
    private static var UIView_Badge_dvt_badgeIntegerKey: UInt8 = 0
    private static var UIView_Badge_dvt_badgeStringKey: UInt8 = 0
}

public extension BaseWrapper where BaseType: UIView {
    /// 用数字设置未读数，0表示不显示未读数
    var badgeInteger: UInt {
        set { self.base.dvt_badgeInteger = newValue }
        get { self.base.dvt_badgeInteger }
    }

    /// 用数字设置未读数，0表示不显示未读数
    var badgeString: String {
        set { self.base.dvt_badgeString = newValue }
        get { self.base.dvt_badgeString }
    }

    func synchronizeBaege(_ view: UIView) {
        self.base.dvt_badgeInteger = view.dvt_badgeInteger
        self.base.dvt_badgeString = view.dvt_badgeString
    }
}
