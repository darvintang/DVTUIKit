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

#if canImport(DVTUIKit_Label)
    import DVTUIKit_Label
#endif

private class BadgeInfo {
    var isShow = true
    /// 值，如果只显示圆点就设置为false
    var isValue = true

    var color: UIColor = .red
    var size = CGSize(width: 8, height: 8)

    var number: UInt = 0
    var string = ""

    var font: UIFont = .dvt.regular(of: 12)
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .red

    var offset: CGPoint = .zero
    var offsetLandscape: CGPoint = .zero
    var contentEdgeInsets: UIEdgeInsets = .zero
}

extension UIView: DVTBadgeProtocol {
    public var dvt_view: UIView? {
        Self.badge_swizzleed()
        return self
    }
}

private extension UIView {
    // MARK: Internal
    var dvt_badgeInfo: BadgeInfo {
        set {
            objc_setAssociatedObject(self, &Self.UIView_Badge_dvt_badgeInfo_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let info = objc_getAssociatedObject(self, &Self.UIView_Badge_dvt_badgeInfo_key) as? BadgeInfo {
                return info
            }
            let info = BadgeInfo()
            objc_setAssociatedObject(self, &Self.UIView_Badge_dvt_badgeInfo_key, info, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return info
        }
    }

    var dvt_badgeLabel: DVTUILabel {
        set {
            objc_setAssociatedObject(self, &Self.UIView_Badge_dvt_badgeLabel_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let label = objc_getAssociatedObject(self, &Self.UIView_Badge_dvt_badgeLabel_key) as? DVTUILabel {
                return label
            }
            let label = DVTUILabel()
            objc_setAssociatedObject(self, &Self.UIView_Badge_dvt_badgeLabel_key, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return label
        }
    }

    static func badge_swizzleed() {
        DispatchQueue.dvt.once {
            self.dvt_swizzleInstanceSelector(#selector(self.layoutSubviews), swizzle: #selector(self.dvt_badge_layoutSubviews))
        }
    }

    // MARK: Private
    private static var UIView_Badge_dvt_badgeInfo_key: UInt8 = 0
    private static var UIView_Badge_dvt_badgeLabel_key: UInt8 = 0

    @objc private func dvt_badge_layoutSubviews() {
        self.dvt_badge_layoutSubviews()
        let info = self.dvt_badgeInfo
        self.dvt_badgeLabel.isHidden = !info.isShow
        if !info.isShow { return }

        if (info.isValue && info.number == 0 && info.string.isEmpty)
            || (!info.isValue && info.color.dvt.alpha <= 0.01 && !info.size.dvt.isEmpty) {
            self.dvt_badgeLabel.isHidden = true
            return
        }
        // 布局
        self.dvt_updateBadgeLabel()
        self.clipsToBounds = false
    }

    private func dvt_updateBadgeLabel() {
        if self.dvt_badgeLabel.superview == nil {
            self.addSubview(self.dvt_badgeLabel)
        }
        var label = self.dvt_badgeLabel
        let info = self.dvt_badgeInfo
        label.textAlignment = .center

        var size = info.size

        if info.isValue {
            label.contentEdgeInsets = info.contentEdgeInsets.dvt.insetsConcat(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
            if info.number > 0 {
                label.text = "\(info.number)"
            } else {
                label.text = info.string
            }
            label.textColor = info.textColor
            label.backgroundColor = info.backgroundColor
            label.font = info.font
            label.sizeToFit()
            size = label.frame.size
            if label.text?.count ?? 0 == 1 {
                size = CGSize(width: max(size.width, size.height), height: max(size.width, size.height))
            }
        } else {
            label.contentEdgeInsets = .zero
            label.text = ""
            label.backgroundColor = info.color
        }

        label.dvt.cornerRadius = size.height / 2

        var x: CGFloat = 0
        var y: CGFloat = self.dvt.height
        var flag = false
        self.subviews.forEach { view in
            if view != label {
                x = max(view.frame.maxX, x)
                y = min(view.frame.minY, y)
                flag = true
            }
        }
        if !flag {
            x = self.dvt.width
            y = 0
        }

        y -= size.height

        if .dvt.isLandscape {
            x += info.offsetLandscape.x
            y += info.offsetLandscape.y
        } else {
            x += info.offset.x
            y += info.offset.y
        }

        label.frame = CGRect(origin: CGPoint(x: x, y: max(y, 0)), size: size)
        self.bringSubviewToFront(self.dvt_badgeLabel)
    }
}

private extension DVTBadgeProtocol {
    var badgeInfo: BadgeInfo? {
        set { if let newValue = newValue { self.dvt_view?.dvt_badgeInfo = newValue }}
        get { self.dvt_view?.dvt_badgeInfo }
    }
}

public extension BaseWrapper where BaseType: DVTBadgeProtocol {
    /// 控制显示和隐藏
    var badgeIsShow: Bool {
        set {
            if self.badgeIsShow != newValue {
                self.base.badgeInfo?.isShow = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.isShow ?? true }
    }

    /// 标记是否是数值，如果不是数值就会使用圆点
    var badgeIsValue: Bool {
        set {
            if self.badgeIsValue != newValue {
                self.base.badgeInfo?.isValue = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.isValue ?? true }
    }

    /// 使用圆点的时候，标记的颜色
    var badgeColor: UIColor {
        set {
            if self.badgeColor != newValue {
                self.base.badgeInfo?.color = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.color ?? .red }
    }

    /// 使用圆点的时候，标记的大小
    var badgeSize: CGSize {
        set {
            if self.badgeSize != newValue {
                self.base.badgeInfo?.size = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.size ?? CGSize(width: 8, height: 8) }
    }

    /// 用数字设置未读数，优先级高于badgeString
    var badgeNumber: UInt {
        set {
            if self.badgeNumber != newValue {
                self.base.badgeInfo?.number = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.number ?? 0 }
    }

    /// 用字符串设置未读数，优先级低于badgeNumber
    var badgeString: String {
        set {
            if self.badgeString != newValue {
                self.base.badgeInfo?.string = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.string ?? "" }
    }

    /// 未读数字体，默认 regular 12
    var badgeFont: UIFont {
        set {
            if self.badgeFont != newValue {
                self.base.badgeInfo?.font = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.font ?? .dvt.regular(of: 12) }
    }

    /// 未读数字体颜色，默认白色
    var badgeTextColor: UIColor {
        set {
            if self.badgeTextColor != newValue {
                self.base.badgeInfo?.textColor = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.textColor ?? .white }
    }

    /// 未读数背景颜色，默认红色
    var badgeBackgroundColor: UIColor {
        set {
            if self.badgeBackgroundColor != newValue {
                self.base.badgeInfo?.backgroundColor = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.backgroundColor ?? .red }
    }

    /// 默认 badge 的布局处于 view 右上角
    ///
    /// 如果视图没有子视图，布局为右上角（x = view.width, y = -badge.height）
    /// 如果视图存在子视图，布局为右上角（x = max(subvuews.maxX), y = min(subvuews.minY) - badge.height）
    /// 通过这个属性可以调整 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
    var badgeOffset: CGPoint {
        set {
            if self.badgeOffset != newValue {
                self.base.badgeInfo?.offset = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.offset ?? .zero }
    }

    /// 横屏的时候偏移，和badgeOffset一样的
    var badgeOffsetLandscape: CGPoint {
        set {
            if self.badgeOffsetLandscape != newValue {
                self.base.badgeInfo?.offsetLandscape = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.offsetLandscape ?? .zero }
    }

    /// 未读数字与圆圈之间的 padding，会影响最终 badge 的大小。
    ///
    /// 当只有一位数字时，会取宽/高中最大的值作为最终的宽高，以保证整个 badge 是正圆。
    var badgeContentEdgeInsets: UIEdgeInsets {
        set {
            if self.badgeContentEdgeInsets != newValue {
                self.base.badgeInfo?.contentEdgeInsets = newValue
                self.base.dvt_updateBadge()
            }
        }
        get { self.base.badgeInfo?.contentEdgeInsets ?? .zero }
    }

    /// 同步标记设置
    mutating func synchronizeBaege(_ view: UIView) {
        self.base.badgeInfo = view.dvt_badgeInfo
        self.base.dvt_updateBadge()
    }
}
