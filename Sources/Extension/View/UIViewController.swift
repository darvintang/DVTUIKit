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

import UIKit
import DVTFoundation

extension UIViewController: NameSpace { }

public extension BaseWrapper where BaseType: UIViewController {
    /// 转场动画的闭包
    /// - Parameters:
    ///   - animate: 动画
    ///   - completion: 完成
    func animateAlongsideTransition(_ animate: ((_ context: UIViewControllerTransitionCoordinatorContext?) -> Void)? = nil,
                                    completion: ((_ context: UIViewControllerTransitionCoordinatorContext?) -> Void)?) {
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
}

public extension UIViewController {
    enum VisibleState: UInt8, Comparable {
        case unknow = 0, didLoad, willAppear, didAppear, willDisappear, didDisappear, unowned = 255

        // MARK: Public
        public static func < (lhs: UIViewController.VisibleState, rhs: UIViewController.VisibleState) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        // MARK: Internal
        var isVisible: Bool {
            self == .willAppear || self == .didAppear
        }
    }
}

private extension UIViewController {
    static var UIViewController_Extension_dvt_Extension_visibleState_key: UInt8 = 0

    var dvt_extension_visibleState: UIViewController.VisibleState {
        set {
            UIViewController_dvt_extension_Swizzleed_flag = true
            objc_setAssociatedObject(self, &Self.UIViewController_Extension_dvt_Extension_visibleState_key, newValue.rawValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            let rawValue = objc_getAssociatedObject(self, &Self.UIViewController_Extension_dvt_Extension_visibleState_key) as? UInt8 ?? 0
            return UIViewController.VisibleState(rawValue: rawValue) ?? .unknow
        }
    }

    @objc
    func dvt_extension_viewDidLoad(_ animated: Bool) {
        self.dvt_extension_viewDidLoad(animated)
        self.dvt_extension_visibleState = .didLoad
    }

    @objc
    func dvt_extension_viewWillAppear(_ animated: Bool) {
        self.dvt_extension_viewWillAppear(animated)
        self.dvt_extension_visibleState = .willAppear
    }

    @objc
    func dvt_extension_viewDidAppear(_ animated: Bool) {
        self.dvt_extension_viewDidAppear(animated)
        self.dvt_extension_visibleState = .didAppear
    }

    @objc
    func dvt_extension_viewWillDisappear(_ animated: Bool) {
        self.dvt_extension_viewWillDisappear(animated)
        self.dvt_extension_visibleState = .willDisappear
    }

    @objc
    func dvt_extension_viewDidDisappear(_ animated: Bool) {
        self.dvt_extension_viewDidDisappear(animated)
        self.dvt_extension_visibleState = .didDisappear
    }
}

private var UIViewController_dvt_extension_Swizzleed_flag = false

public extension BaseWrapper where BaseType: UIViewController {
    var visibleState: UIViewController.VisibleState {
        if !UIViewController_dvt_extension_Swizzleed_flag {
            dvtuiloger.warning("请在应用初始化的时候调用DVTUIKitConfig.beginHook，否则获取的visibleState会不准确")
        }
        BaseWrapper<BaseType>.extension_swizzleed()
        return self.base.dvt_extension_visibleState
    }

    internal static func extension_swizzleed() {
        DispatchQueue.dvt.once {
            BaseType.dvt_swizzleInstanceSelector(#selector(BaseType.viewDidLoad), swizzle: #selector(BaseType.dvt_extension_viewDidLoad))
            BaseType.dvt_swizzleInstanceSelector(#selector(BaseType.viewWillAppear(_:)), swizzle: #selector(BaseType.dvt_extension_viewWillAppear(_:)))
            BaseType.dvt_swizzleInstanceSelector(#selector(BaseType.viewDidAppear(_:)), swizzle: #selector(BaseType.dvt_extension_viewDidAppear(_:)))
            BaseType.dvt_swizzleInstanceSelector(#selector(BaseType.viewWillDisappear(_:)), swizzle: #selector(BaseType.dvt_extension_viewWillDisappear(_:)))
            BaseType.dvt_swizzleInstanceSelector(#selector(BaseType.viewDidDisappear(_:)), swizzle: #selector(BaseType.dvt_extension_viewDidDisappear(_:)))
        }
    }
}

public extension BaseWrapper where BaseType: UIViewController {
    // MARK: Internal
    /// 当前显示活跃的控制器
    var activeViewController: UIViewController? {
        return UIApplication.dvt.activeWindow?.rootViewController?.dvt._activeViewController
    }

    /// 当控制器作为其它的控制器的子控制器时获取持有它的控制器
    ///
    /// 如果直接作为控制器使用就返回自己
    /// 如果没有添加到window上返回nil
    var fatherViewController: UIViewController? {
        let vc = self.base
        if vc.presentingViewController == nil,
           vc.navigationController == nil,
           vc.tabBarController == nil,
           vc != vc.view.window?.rootViewController {
            var next = vc.next
            repeat {
                if let tvc = next as? UIViewController {
                    return tvc.dvt.fatherViewController
                }
                next = next?.next
            } while next != nil
            return nil
        }
        return vc
    }

    @discardableResult func dismiss(_ animated: Bool = true, completion: ((_ vc: UIViewController) -> Void)? = nil) -> [UIViewController] {
        let vc = self.base
        if let presentedViewController = vc.presentedViewController {
            let list = presentedViewController.dvt.dismiss(animated, completion: completion)
            return [vc] + list
        }
        vc.dismiss(animated: animated) {
            completion?(vc)
        }
        return [vc]
    }

    // MARK: Private
    private var _activeViewController: UIViewController? {
        let vc = self.base
        if let presentController = vc.presentedViewController {
            return presentController.dvt._activeViewController
        }

        if let tabbarController = vc as? UITabBarController {
            return tabbarController.selectedViewController?.dvt._activeViewController
        }

        if let navigationController = vc as? UINavigationController {
            return navigationController.visibleViewController?.dvt._activeViewController
        }

        if vc.dvt.visibleState.isVisible {
            return vc
        } else {
            return nil
        }
    }
}
