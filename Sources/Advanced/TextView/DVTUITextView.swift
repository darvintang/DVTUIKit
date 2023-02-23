//
//  DVTUITextView.swift
//  DVTUIKit_TextView
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

#if canImport(DVTUIKit_Extension)
    import DVTUIKit_Extension
#endif

open class DVTUITextView: UITextView {
    /// placeholder 的文字
    @IBInspectable public var placeholder: String = "" {
        didSet {
            self.updatePlaceholderStyle()
        }
    }

    @IBInspectable public var placeholderColor: UIColor = UIColor(dvt: 0x43434450) {
        didSet {
            self.updatePlaceholderStyle()
        }
    }

    /// placeholder 在默认位置上的偏移（默认位置会自动根据 textContainerInset、contentInset 来调整）
    public var placeholderMargins: UIEdgeInsets = .zero {
        didSet {
            self.updatePlaceholderStyle()
        }
    }

    override open var textAlignment: NSTextAlignment {
        didSet {
            self.updatePlaceholderStyle()
        }
    }

    override open var textColor: UIColor? {
        didSet {
            self.updatePlaceholderStyle()
        }
    }

    override open var font: UIFont? {
        didSet {
            self.updatePlaceholderStyle()
        }
    }

    override open var typingAttributes: [NSAttributedString.Key: Any] {
        didSet {
            self.updatePlaceholderStyle()
        }
    }

    override open var contentOffset: CGPoint {
        set {
            if self.shouldRejectSystemScroll {
                return
            }
            super.contentOffset = newValue
        }
        get {
            super.contentOffset
        }
    }

    override open var frame: CGRect {
        set {
            let tNewValue = newValue.dvt.flat
            // 系统的 UITextView 只要调用 setFrame: 不管 rect 有没有变化都会触发 setContentOffset，引起最后一行输入过程中文字抖动的问题，所以这里屏蔽掉
            let sizeChanged = tNewValue.size != super.frame.size
            if !sizeChanged { self.shouldRejectSystemScroll = true }
            super.frame = tNewValue
            if !sizeChanged { self.shouldRejectSystemScroll = false }
        }
        get {
            super.frame
        }
    }

    override open var bounds: CGRect {
        set {
            super.bounds = newValue.dvt.flat
        }
        get {
            super.bounds
        }
    }

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.didInitialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }

    open func didInitialize() {
        self.contentInsetAdjustmentBehavior = .never
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlaceholderLabelHidden), name: UITextView.textDidChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var resSize = size
        if resSize.width <= 0 { resSize.width = CGFLOAT_MAX }
        if resSize.height <= 0 { resSize.height = CGFLOAT_MAX }
        var result = CGSize.zero
        if !self.placeholder.isEmpty, self.text.isEmpty {
            let allInsets = self.allInsets
            let frame = self.preferredPlaceholderFrame(resSize)
            result.width = frame.width + allInsets.dvt.horizontal
            result.height = frame.height + allInsets.dvt.vertical
        } else {
            result = super.sizeThatFits(resSize)
        }
        return result
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if !self.placeholder.isEmpty {
            self.placeholderLabel.frame = self.preferredPlaceholderFrame(self.dvt.size)
        }
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        self.updatePlaceholderLabelHidden()
    }

    override open func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if !self.shouldRejectSystemScroll {
            super.setContentOffset(contentOffset, animated: animated)
        }
    }

    // 如果在 handleTextChanged: 里主动调整 contentOffset，则为了避免被系统的自动调整覆盖，
    // 会利用这个标记去屏蔽系统对 setContentOffset: 的调用
    private var shouldRejectSystemScroll = false

    fileprivate lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .dvt.regular(of: 12)
        label.alpha = 0
        label.numberOfLines = 0
        label.textColor = self.placeholderColor
        self.addSubview(label)
        return label
    }()

    private var allInsets: UIEdgeInsets {
        self.textContainerInset.dvt.insetsConcat(self.placeholderMargins).dvt.insetsConcat(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)).dvt.insetsConcat(self.adjustedContentInset)
    }

    private func updatePlaceholderStyle() {
        self.placeholderLabel.attributedText = NSAttributedString(string: self.placeholder, attributes: self.typingAttributes)
        self.placeholderLabel.textColor = self.placeholderColor
        self.sendSubviewToBack(self.placeholderLabel)
        self.setNeedsLayout()
        self.updatePlaceholderLabelHidden()
    }

    @objc private func updatePlaceholderLabelHidden() {
        self.placeholderLabel.alpha = self.text.isEmpty && !self.placeholder.isEmpty ? 1 : 0
    }

    private func preferredPlaceholderFrame(_ size: CGSize) -> CGRect {
        if self.placeholder.isEmpty { return .zero }
        let allInsets = self.allInsets
        let labelMargins = UIEdgeInsets(top: allInsets.top - self.adjustedContentInset.top,
                                        left: allInsets.left - self.adjustedContentInset.left,
                                        bottom: allInsets.bottom - self.adjustedContentInset.bottom,
                                        right: allInsets.right - self.adjustedContentInset.right)
        let limitWidth = size.width - allInsets.dvt.horizontal
        let limitHeight = size.height - allInsets.dvt.vertical
        var labelSize = self.placeholderLabel.sizeThatFits(CGSize(width: limitWidth, height: limitHeight))
        // 当 limitWidth 为 CGFLOAT_MAX 时，意味着此时是 sizeToFit 触发的 sizeThatFits:，从而调用到这里，
        // 此时语义上希望得到 placeholder 的实际内容宽高，于是拿 labelSize.width 作为返回值。如果不是那边过来的，
        // 则让 placeholderLabel 宽度撑满，从而适配 NSTextAlignmentRight。
        labelSize.width = limitWidth == CGFLOAT_MAX ? min(limitWidth, labelSize.width) : limitWidth
        labelSize.height = min(limitHeight, labelSize.height)
        return CGRect(x: labelMargins.left, y: labelMargins.top, width: labelSize.width, height: labelSize.height)
    }
}
