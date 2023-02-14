//
//  UIControl.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2021/11/7.
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

private extension UIControl {
    static var TargetsKey: Int8 = 0
    var targets: [UIControlEventTarget] {
        set {
            objc_setAssociatedObject(self, &Self.TargetsKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            var reslist: [UIControlEventTarget] = []
            if let list = objc_getAssociatedObject(self, &Self.TargetsKey) as? [UIControlEventTarget] {
                reslist = list
            } else {
                self.targets = reslist
            }
            return reslist
        }
    }

    func addEvent(_ event: UIControl.Event, and clickBlock: @escaping (UIControl) -> Void) {
        let target = UIControlEventTarget(self, for: event) {
            clickBlock(self)
        }
        self.addTarget(target, action: #selector(target.didClick), for: event)

        if let index = self.targets.firstIndex(where: { ttarget in
            ttarget.event == event
        }) {
            self.targets[index] = target
        } else {
            self.targets.append(target)
        }
    }

    class UIControlEventTarget {
        init(_ btn: UIControl, for event: UIControl.Event, and clickBlock: @escaping () -> Void) {
            self.btn = btn
            self.event = event
            self.clickBlock = clickBlock
        }

        let btn: UIControl
        let event: UIControl.Event
        let clickBlock: () -> Void

        @objc func didClick() {
            self.clickBlock()
        }
    }
}

public extension BaseWrapper where BaseType: UIControl {
    func add(for event: UIControl.Event = .touchUpInside, block clickBlock: @escaping (BaseType) -> Void) {
        self.base.addEvent(event) { tbtn in
            if let ttbtn = tbtn as? BaseType {
                clickBlock(ttbtn)
            }
        }
    }
}
