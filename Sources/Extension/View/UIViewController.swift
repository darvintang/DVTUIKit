//
//  UIViewController.swift
//  DVTUIKit_Extension
//
//  Created by darvin on 2022/1/1.
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

public extension UIViewController {
    enum VisibleState: UInt8, Comparable {
        public static func < (lhs: UIViewController.VisibleState, rhs: UIViewController.VisibleState) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        case unknow = 0, didLoad, willAppear, didAppear, willDisappear, didDisappear, unowned = 255
        var isVisible: Bool {
            self == .willAppear || self == .didAppear
        }
    }
}

fileprivate extension UIViewController {
    static var UIViewController_dvt_extension_Swizzleed = false

    @objc func dvt_extension_viewDidLoad(_ animated: Bool) {
        self.dvt_extension_viewDidLoad(animated)
        self.dvt_extension_visibleState = .didLoad
    }

    @objc func dvt_extension_viewWillAppear(_ animated: Bool) {
        self.dvt_extension_viewWillAppear(animated)
        self.dvt_extension_visibleState = .willAppear
    }

    @objc func dvt_extension_viewDidAppear(_ animated: Bool) {
        self.dvt_extension_viewDidAppear(animated)
        self.dvt_extension_visibleState = .didAppear
    }

    @objc func dvt_extension_viewWillDisappear(_ animated: Bool) {
        self.dvt_extension_viewWillDisappear(animated)
        self.dvt_extension_visibleState = .willDisappear
    }

    @objc func dvt_extension_viewDidDisappear(_ animated: Bool) {
        self.dvt_extension_viewDidDisappear(animated)
        self.dvt_extension_visibleState = .didDisappear
    }

    static var UIViewController_dvt_Extension_visibleStateKey: UInt8 = 0

    var dvt_extension_visibleState: UIViewController.VisibleState {
        set {
            UIViewController_dvt_extension_Swizzleed_flag = true
            objc_setAssociatedObject(self, &Self.UIViewController_dvt_Extension_visibleStateKey, newValue.rawValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            let rawValue = objc_getAssociatedObject(self, &Self.UIViewController_dvt_Extension_visibleStateKey) as? UInt8 ?? 0
            return UIViewController.VisibleState(rawValue: rawValue) ?? .unknow
        }
    }
}

private var UIViewController_dvt_extension_Swizzleed_flag = false

public extension BaseWrapper where BaseType: UIViewController {
    internal static func extension_swizzleed() {
        if BaseType.UIViewController_dvt_extension_Swizzleed {
            return
        }

        BaseType.swizzleSelector(#selector(BaseType.viewDidLoad), swizzle: #selector(BaseType.dvt_extension_viewDidLoad))
        BaseType.swizzleSelector(#selector(BaseType.viewWillAppear(_:)), swizzle: #selector(BaseType.dvt_extension_viewWillAppear(_:)))
        BaseType.swizzleSelector(#selector(BaseType.viewDidAppear(_:)), swizzle: #selector(BaseType.dvt_extension_viewDidAppear(_:)))
        BaseType.swizzleSelector(#selector(BaseType.viewWillDisappear(_:)), swizzle: #selector(BaseType.dvt_extension_viewWillDisappear(_:)))
        BaseType.swizzleSelector(#selector(BaseType.viewDidDisappear(_:)), swizzle: #selector(BaseType.dvt_extension_viewDidDisappear(_:)))

        BaseType.UIViewController_dvt_extension_Swizzleed = true
    }

    var visibleState: UIViewController.VisibleState {
        if !UIViewController_dvt_extension_Swizzleed_flag {
            dvtuiloger.warning("请在应用初始化的时候调用DVTUIKitConfig.beginHook，否则获取的visibleState会不准确")
        }
        BaseWrapper<BaseType>.extension_swizzleed()
        return self.base.dvt_extension_visibleState
    }
}
