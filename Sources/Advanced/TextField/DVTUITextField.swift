//
//  DVTUITextField.swift
//  DVTUIKit_TextField
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

public protocol DVTUITextFieldDelegate: UITextFieldDelegate {
    /// 限制字符长度之后`textField(_:shouldChangeCharactersIn:replacementString:)`的副本
    ///
    /// 为了实现限制输入字符长度 `UITextFieldDelegate` 的 `textField(_:shouldChangeCharactersIn:replacementString:)` 失效
    ///
    /// - Parameters:
    ///   - value: 是否已经处理
    /// - Returns: 是否允许在`range`改变为`string`
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, original value: Bool) -> Bool
}

public extension DVTUITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, original value: Bool) -> Bool {
        value
    }
}

fileprivate class DVTUITextFieldDelegater: NSObject, UITextFieldDelegate {
    init(textField: DVTUITextField) {
        self.textField = textField
        super.init()
        textField.addTarget(self, action: #selector(self.handleTextChangeEvent(_:)), for: .editingChanged)
    }

    weak var textField: DVTUITextField?
    var delegater: DVTUITextFieldDelegate? {
        self.textField?.delegater
    }

    @objc func handleTextChangeEvent(_ textField: DVTUITextField) {
        if textField.maximumLength < .max && (textField.undoManager?.isUndoing ?? false || textField.undoManager?.isRedoing ?? false) {
            return
        }
        if textField.markedTextRange == nil {
            if textField.text?.count ?? 0 > textField.maximumLength, let text = textField.text {
                textField.text = text.dvt[0, length: textField.maximumLength]
            }
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegater?.textFieldShouldBeginEditing?(textField) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegater?.textFieldDidBeginEditing?(textField)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.delegater?.textFieldShouldEndEditing?(textField) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegater?.textFieldDidEndEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.delegater?.textFieldDidEndEditing?(textField, reason: reason)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var defaultReturn = true
        if let textField = textField as? DVTUITextField, let text = textField.text, textField.maximumLength < .max {
            if textField.markedTextRange != nil {
                // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil）
                // 是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符）
                // 所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
                defaultReturn = true
            } else if NSMaxRange(range) > text.dvt.nsCount {
                // 使用系统的摇一摇撤销输入会走到该位置，因上一次输入的内容可能已经被裁剪，所以会导致range异常
                // 如果 range 越界了，继续返回 YES 会造成 crash
                // 这里的做法是本次返回 NO，并将越界的 range 缩减到没有越界的范围，再手动做该范围的替换。
                let tRange = NSRange(location: range.location, length: range.length - (NSMaxRange(range) - text.dvt.nsCount))
                if tRange.length > 0, let textRange = self.textField?.dvt.convertUITextRange(from: tRange) {
                    self.textField?.replace(textRange, withText: string)
                    self.textField?.customTextDidChangeEvent()
                }
                defaultReturn = false
            } else if string.count > 0, text.dvt.nsCount - range.length + string.dvt.nsCount > textField.maximumLength {
                // string.count == 0 的时候是删除，所以直接跳过，走系统的逻辑
                // 将要插入的文字裁剪成这么长，就可以让它插入了
                let substringLength = textField.maximumLength - text.dvt.nsCount + range.length
                if substringLength > 0, string.count > substringLength {
                    let allowedText = string.dvt[0, length: substringLength]
                    textField.text = text.dvt.replacing(range.location, length: range.length, with: allowedText)
                    DispatchQueue.main.async {
                        self.textField?.dvt.selectedRange = NSRange(location: range.location + allowedText.dvt.nsCount, length: 0)
                    }
                }
                defaultReturn = false
            }
        }

        return self.delegater?.textField(self.textField ?? textField, shouldChangeCharactersIn: range, replacementString: string, original: defaultReturn) ?? defaultReturn
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.delegater?.textFieldDidChangeSelection?(textField)
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.delegater?.textFieldShouldClear?(textField) ?? true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegater?.textFieldShouldReturn?(textField) ?? true
    }

    @available(iOS 16.0, *)
    func textField(_ textField: UITextField, editMenuForCharactersIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        self.delegater?.textField?(textField, editMenuForCharactersIn: range, suggestedActions: suggestedActions)
    }

    @available(iOS 16.0, *)
    func textField(_ textField: UITextField, willPresentEditMenuWith animator: UIEditMenuInteractionAnimating) {
        self.delegater?.textField?(textField, willPresentEditMenuWith: animator)
    }

    @available(iOS 16.0, *)
    func textField(_ textField: UITextField, willDismissEditMenuWith animator: UIEditMenuInteractionAnimating) {
        self.delegater?.textField?(textField, willDismissEditMenuWith: animator)
    }
}

/// 输入框
///
/// 支持：
///
/// 1. 自定义 placeholderColor。
/// 2. 自定义 UITextField 的文字 padding。
/// 3. 支持限制输入的文字的长度。
open class DVTUITextField: UITextField {
    private var _delegater: DVTUITextFieldDelegater? {
        didSet {
            super.delegate = self._delegater
        }
    }

    open weak var delegater: DVTUITextFieldDelegate?

    /// 限制输入的文字的长度需要利用到`delegate`，`delegate`的功能由`delegater`代替
    ///
    /// 设置`delegate`本质是给`delegater`赋值
    override public weak var delegate: UITextFieldDelegate? {
        set {
            assert(newValue is DVTUITextFieldDelegate, "请使用`delegater`")
            self.delegater = newValue as? DVTUITextFieldDelegate
        }
        get {
            if self._delegater == nil {
                self._delegater = DVTUITextFieldDelegater(textField: self)
            }
            return self._delegater
        }
    }

    /// 最大长度，表情占两个单位长度(NSString)
    @IBInspectable public var maximumLength: Int = .max
    /// 占位字符颜色
    @IBInspectable public var placeholderColor: UIColor? {
        didSet {
            if oldValue != self.placeholderColor {
                self.updatePlaceholder()
            }
        }
    }

    override open var placeholder: String? {
        didSet {
            if oldValue != self.placeholder && self.placeholderColor != nil {
                self.updatePlaceholder()
            }
        }
    }

    private func updatePlaceholder() {
        if let color = self.placeholderColor {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: color])
        } else {
            super.placeholder = self.placeholder
        }
    }

    fileprivate func customTextDidChangeEvent() {
        self.sendActions(for: .editingChanged)
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
    }

    override open var text: String? {
        didSet {
            if oldValue != self.text {
                self.customTextDidChangeEvent()
            }
        }
    }

    /// 文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
    public var textInsets: UIEdgeInsets = .zero

    /// clearButton 在默认位置上的偏移
    public var clearBtnOffset: UIOffset = .zero

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let tBounds = bounds.inset(by: self.textInsets)
        return super.textRect(forBounds: tBounds)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let tBounds = bounds.inset(by: self.textInsets)
        return super.editingRect(forBounds: tBounds)
    }

    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        super.clearButtonRect(forBounds: bounds).offsetBy(dx: self.clearBtnOffset.horizontal, dy: self.clearBtnOffset.vertical)
    }

    override open var attributedText: NSAttributedString? {
        didSet {
            if oldValue != self.attributedText {
                self.customTextDidChangeEvent()
            }
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }

    open func didInitialize() {
    }
}
