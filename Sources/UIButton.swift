//
//  File.swift
//
//
//  Created by darvin on 2021/11/7.
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

private extension UIButton {
    static var TargetsKey: Int8 = 0
    var targets: [UIButtonEventTarget] {
        set {
            objc_setAssociatedObject(self, &Self.TargetsKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            var reslist: [UIButtonEventTarget] = []
            if let list = objc_getAssociatedObject(self, &Self.TargetsKey) as? [UIButtonEventTarget] {
                reslist = list
            } else {
                self.targets = reslist
            }
            return reslist
        }
    }

    func addEvent(_ event: UIControl.Event, and clickBlock: @escaping (UIButton) -> Void) {
        let target = UIButtonEventTarget(self, for: event) {
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

    class UIButtonEventTarget {
        init(_ btn: UIButton, for event: UIControl.Event, and clickBlock: @escaping () -> Void) {
            self.btn = btn
            self.event = event
            self.clickBlock = clickBlock
        }

        let btn: UIButton
        let event: UIControl.Event
        let clickBlock: () -> Void

        @objc func didClick() {
            self.clickBlock()
        }
    }
}

public extension BaseWrapper where DT: UIButton {
    mutating func add(for event: UIControl.Event = .touchUpInside, block clickBlock: @escaping (DT) -> Void) {
        self.base.addEvent(event) { tbtn in
            if let ttbtn = tbtn as? DT {
                clickBlock(ttbtn)
            }
        }
    }
}
