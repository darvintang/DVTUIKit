//
//  UIViewController.swift
//  DVTUIKit
//
//  Created by darvin on 2022/1/1.
//

/*

 MIT License

 Copyright (c) 2022 darvin http://blog.tcoding.cn

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

extension UIViewController: NameSpace { }

public extension BaseWrapper where BaseType: UIViewController {
    /// 转场动画的闭包
    /// - Parameters:
    ///   - animate: 动画
    ///   - completion: 完成
    func animateAlongsideTransition(_ animate: ((_ context: UIViewControllerTransitionCoordinatorContext?) -> Void)? = nil, completion: ((_ context: UIViewControllerTransitionCoordinatorContext?) -> Void)?) {
        if let coordinator = self.base.transitionCoordinator {
            if !coordinator.animate(alongsideTransition: { context in
                animate?(context)
            }, completion: { context in
                completion?(context)
            }) {
                animate?(nil)
            }
        } else {
            animate?(nil)
            completion?(nil)
        }
    }

    @discardableResult
    func dismissOrPop(animated: Bool = true, completion: (() -> Void)? = nil) -> UIViewController? {
        if let navigationController = self.base.navigationController {
            return navigationController.dvt.popViewController(animated: animated, completion: completion)
        } else {
            self.base.dismiss(animated: animated, completion: completion)
            return self.base
        }
    }
}