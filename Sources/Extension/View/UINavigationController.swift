//
//  UINavigationController.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2023/1/13.
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

public extension BaseWrapper where BaseType: UINavigationController {
    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        let navigationController = self.base
        navigationController.pushViewController(viewController, animated: animated)
        navigationController.dvt.animateAlongsideTransition { _ in
            completion?()
        }
    }

    @discardableResult func popViewController(animated: Bool = true, completion: (() -> Void)? = nil) -> UIViewController? {
        let navigationController = self.base
        let result = navigationController.popViewController(animated: animated)
        navigationController.dvt.animateAlongsideTransition { _ in
            completion?()
        }
        return result
    }

    @discardableResult func popToViewController(_ viewController: UIViewController, animated: Bool = true,
                                                completion: (() -> Void)? = nil) -> [UIViewController]? {
        let navigationController = self.base
        let result = navigationController.popToViewController(viewController, animated: animated)
        navigationController.dvt.animateAlongsideTransition { _ in
            completion?()
        }
        return result
    }

    @discardableResult func popToRootViewController(animated: Bool = true, completion: (() -> Void)? = nil) -> [UIViewController]? {
        let navigationController = self.base
        let result = navigationController.popToRootViewController(animated: animated)
        navigationController.dvt.animateAlongsideTransition { _ in
            completion?()
        }
        return result
    }
}
