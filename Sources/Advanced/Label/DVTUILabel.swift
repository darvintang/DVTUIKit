//
//  DVTUILabel.swift
//  DVTUIKit_Label
//
//  Created by darvin on 2023/2/2.
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

open class DVTUILabel: UILabel {
    // MARK: Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Open
    open var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override open var intrinsicContentSize: CGSize {
        var preferredMaxLayoutWidth = self.preferredMaxLayoutWidth
        if preferredMaxLayoutWidth <= 0 {
            preferredMaxLayoutWidth = CGFloat.greatestFiniteMagnitude
        }
        return self.sizeThatFits(CGSize(width: preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
    }

    override open var isHighlighted: Bool {
        didSet {
            if let color = self.highlightedBackgroundColor {
                super.backgroundColor = self.isHighlighted ? color : self.originalBackgroundColor
            }
        }
    }

    override open var backgroundColor: UIColor? {
        set {
            self.originalBackgroundColor = newValue
            if self.isHighlighted, self.highlightedBackgroundColor != nil {
                return
            }
            super.backgroundColor = newValue
        }
        get {
            self.originalBackgroundColor
        }
    }

    override open var isUserInteractionEnabled: Bool {
        didSet {
            self.oldUserInteractionEnabled = self.isUserInteractionEnabled
        }
    }

    /// 点击了“复制”后的回调
    open var didCopyBlock: ((_ label: DVTUILabel, _ string: String) -> Void)? {
        didSet {
            if self.didCopyBlock != nil {
                // 添加长按手势
                // 保存之前的状态
                let tempEnabled = self.isUserInteractionEnabled
                self.isUserInteractionEnabled = true
                self.oldUserInteractionEnabled = tempEnabled

                if self.longGestureRecognizer == nil {
                    let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                    self.addGestureRecognizer(gestureRecognizer)
                    self.longGestureRecognizer = gestureRecognizer
                    NotificationCenter.default.addObserver(forName: UIMenuController.willHideMenuNotification, object: self, queue: .main) { [weak self] _ in
                        self?.isHighlighted = false
                    }
                }
            } else {
                // 移除长按手势
                // 恢复之前的状态
                self.isUserInteractionEnabled = self.isUserInteractionEnabled
                if let gesture = self.longGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                }
            }
        }
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let edgeInsets = self.contentEdgeInsets
        var tsize = super.sizeThatFits(CGSize(width: size.width - edgeInsets.left - edgeInsets.right, height: size.height - edgeInsets.top - edgeInsets.bottom))
        tsize.width += edgeInsets.left + edgeInsets.right
        tsize.height += edgeInsets.top + edgeInsets.bottom
        return tsize
    }

    override open func drawText(in rect: CGRect) {
        var resRect = rect.dvt.inset(self.contentEdgeInsets)
        // https://github.com/Tencent/QMUI_iOS/issues/529
        if self.numberOfLines == 1 && (self.lineBreakMode == .byCharWrapping || self.lineBreakMode == .byWordWrapping) {
            resRect = resRect.dvt.setHeight(resRect.height + self.contentEdgeInsets.top * 2)
        }
        super.drawText(in: resRect)
    }

    // MARK: Public
    /// “复制”按钮的标题
    ///
    /// 默认为“复制”
    public var menuCopyItemTitle = "复制"

    /// label 在 highlighted 时的背景色
    ///
    /// 通常用于两种场景：
    /// 1. 开启了 canPerformCopyAction 时，长按后的背景色
    /// 2. 作为 subviews 放在 UITableViewCell 上，当 cell highlighted 时，label 也会触发 highlighted，此时背景色也会显示为这个属性的值
    ///
    /// 默认为 nil
    public var highlightedBackgroundColor: UIColor?

    // MARK: Private
    private var originalBackgroundColor: UIColor?
    /// 长按手势
    private var longGestureRecognizer: UILongPressGestureRecognizer?

    /// 记录用户设定的isUserInteractionEnabled，用于移除长按功能后恢复
    private var oldUserInteractionEnabled = false
}

// MARK: - 长按复制功能
private extension DVTUILabel {
    @objc func copyString() {
        let pasteboard = UIPasteboard.general
        if let string = self.text {
            pasteboard.string = string
            self.didCopyBlock?(self, string)
        }
    }

    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer == self.longGestureRecognizer {
            if gestureRecognizer.state == .began {
                if #available(iOS 16.0, *) {
                    let location = gestureRecognizer.location(in: self)
                    let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
                    if let editMenu = self.interactions.first(where: { $0.isMember(of: UIEditMenuInteraction.self) }) as? UIEditMenuInteraction {
                        editMenu.presentEditMenu(with: configuration)
                    } else {
                        let editMenu = UIEditMenuInteraction(delegate: self)
                        self.addInteraction(editMenu)
                        editMenu.presentEditMenu(with: configuration)
                    }
                } else {
                    let menuController = UIMenuController.shared
                    let copyMenuItem = UIMenuItem(title: self.menuCopyItemTitle, action: #selector(self.copyString))
                    menuController.menuItems = [copyMenuItem]
                    menuController.showMenu(from: self, rect: self.bounds)
                }
                self.isHighlighted = true
            } else if gestureRecognizer.state == .possible {
                self.isHighlighted = false
            }
        }
    }
}

@available(iOS 16.0, *)
extension DVTUILabel: UIEditMenuInteractionDelegate {
    open func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration,
                                  suggestedActions: [UIMenuElement]) -> UIMenu? {
        let copyAction = UIAction(title: self.menuCopyItemTitle, handler: { [weak self] _ in
            self?.copyString()
        })
        return UIMenu(children: [copyAction])
    }

    open func editMenuInteraction(_ interaction: UIEditMenuInteraction, targetRectFor configuration: UIEditMenuConfiguration) -> CGRect {
        self.bounds
    }

    open func editMenuInteraction(_ interaction: UIEditMenuInteraction, willDismissMenuFor configuration: UIEditMenuConfiguration,
                                  animator: UIEditMenuInteractionAnimating) {
        self.isHighlighted = false
    }

    open func editMenuInteraction(_ interaction: UIEditMenuInteraction, willPresentMenuFor configuration: UIEditMenuConfiguration,
                                  animator: UIEditMenuInteractionAnimating) {
        self.isHighlighted = true
    }
}
