//
//  UIView+Layout.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2023/2/1.
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

public extension BaseWrapper where BaseType: UIView {
    class Constraint {
        public var attribute: NSLayoutConstraint.Attribute = .notAnAttribute
        public var related: NSLayoutConstraint.Relation = .equal
        public var toAttribute: NSLayoutConstraint.Attribute?
        public var multiplier: CGFloat = 1
        public var constant: CGFloat = 0
        public var priority: UILayoutPriority = .required
    }

    func superviews() -> [UIView] {
        if let view = self.base.superview {
            var list = view.dvt.superviews()
            list.append(view)
            return list
        }
        return []
    }

    /// 添加自动布局的约束
    ///
    /// 会自动移除原来的相同的约束，判断的依据是attribute以及item
    ///
    /// - Parameters:
    ///   - view: 参考的view
    ///   - closure: 约束条件
    /// - Returns: 生成的约束对象
    @discardableResult
    func addConstraint(_ view: UIView? = nil, closure: (_ make: Constraint) -> Void) -> NSLayoutConstraint? {
        let selfView = self.base
        guard let superview = selfView.superview else {
            return nil
        }
        selfView.translatesAutoresizingMaskIntoConstraints = false
        let make = Constraint()
        closure(make)
        let constraint = NSLayoutConstraint(item: selfView, attribute: make.attribute,
                                            relatedBy: make.related, toItem: view, attribute: make.toAttribute ?? make.attribute,
                                            multiplier: make.multiplier, constant: make.constant)
        constraint.priority = make.priority
        if superview == view || view?.dvt.superviews().contains(superview) ?? false {
            if let tconstraint = superview.constraints.first(where: {
                $0.firstAttribute == make.attribute && $0.firstItem as? UIView == selfView
                    && $0.secondItem as? UIView == view && $0.secondAttribute == make.attribute
            }) {
                superview.removeConstraint(tconstraint)
            }
            superview.addConstraint(constraint)
        } else {
            if let tconstraint = selfView.constraints.first(where: {
                $0.firstAttribute == make.attribute && $0.firstItem as? UIView == selfView
                    && $0.secondItem as? UIView == view && $0.secondAttribute == make.attribute
            }) {
                selfView.removeConstraint(tconstraint)
            }
            selfView.addConstraint(constraint)
        }
        return constraint
    }
}
