//
//  UIApplication.swift
//
//
//  Created by darvin on 2021/10/12.
//

/*

 MIT License

 Copyright (c) 2021 darvin http://blog.tcoding.cn

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

extension UIApplication: NameSpace { }

public extension BaseWrapper where DT == UIApplication {
    static var activeWindow: UIWindow? {
        var window: UIWindow?
        if let tempWindow = UIApplication.shared.delegate?.window {
            window = tempWindow
        }
        if window == nil, #available(iOS 13.0, *) {
            if UIApplication.shared.connectedScenes.count == 1 {
                window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
            } else {
                window = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).compactMap({ $0 as? UIWindowScene }).first?.windows.first
            }
        }
        return window
    }
}
