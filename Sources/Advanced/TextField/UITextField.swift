//
//  UITextField.swift
//  DVTUIKit_TextField
//
//  Created by darvin on 2023/2/10.
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

import DVTFoundation
import UIKit

#if canImport(DVTUIKit_Extension)
    import DVTUIKit_Extension
#endif

public extension BaseWrapper where BaseType: UITextField {
    var clearButton: UIButton? {
        return self.base.dvt.value(forKey: "clearButton") as? UIButton
    }

    func setClearButtonImage(_ image: UIImage?, for state: UIControl.State = .normal) {
        self.clearButton?.setImage(image, for: state)
    }

    func convertUITextRange(from range: NSRange) -> UITextRange? {
        if range.location == NSNotFound || NSMaxRange(range) > self.base.text?.count ?? 0 {
            return nil
        }

        let beginning = self.base.beginningOfDocument
        if let startPosition = self.base.position(from: beginning, offset: range.location), let endPosition = self.base.position(from: beginning, offset: NSMaxRange(range)) {
            return self.base.textRange(from: startPosition, to: endPosition)
        }
        return nil
    }

    func convertNSRange(from textRange: UITextRange) -> NSRange {
        let location = self.base.offset(from: self.base.beginningOfDocument, to: textRange.start)
        let length = self.base.offset(from: textRange.start, to: textRange.end)
        return NSRange(location: location, length: length)
    }

    var selectedRange: NSRange? {
        set {
            if let range = newValue {
                self.base.selectedTextRange = self.convertUITextRange(from: range)
            } else {
                self.base.selectedTextRange = nil
            }
        }
        get {
            if let textRange = self.base.selectedTextRange {
                return self.convertNSRange(from: textRange)
            }
            return nil
        }
    }
}
