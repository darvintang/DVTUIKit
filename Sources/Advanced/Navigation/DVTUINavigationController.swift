//
//  DVTUINavigationController.swift
//  DVTUIKit_Navigation
//
//  Created by darvin on 2023/1/9.
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

fileprivate extension BaseWrapper where BaseType: UIView {
    // 拦截点击导航栏返回按钮pop事件
    static func exchangeNavigationBarContentView() {
        guard let cls = NSClassFromString("_" + "UINavigationBar" + "ContentView"), !BaseType.ExchangeNavigationBarContentViewFlag else {
            return
        }
        let oSel = NSSelectorFromString("__" + "backButtonAction:")
        let sSel = NSSelectorFromString("dvt__backButton:")
        if let originMethod = class_getInstanceMethod(cls, oSel),
           let swizzleMethod = class_getInstanceMethod(BaseType.self, sSel) {
            method_exchangeImplementations(originMethod, swizzleMethod)
        }
        BaseType.ExchangeNavigationBarContentViewFlag = true
    }
}

fileprivate extension UIView {
    static var ExchangeNavigationBarContentViewFlag = false
    /// 点击导航栏返回按钮的操作
    @objc func dvt__backButton(_ action: UIButton?) {
        if let bar = self.superview as? DVTTransitionNavigationBar, let navVC = bar.delegate as? DVTUINavigationController {
            if !navVC.canPop(navVC.topViewController, by: false) {
                return
            }
        }
        self.dvt__backButton(action)
    }
}

private class DVTUINavigationControllerGestureDelegateContainer: NSObject, UIGestureRecognizerDelegate {
    weak var viewController: DVTUINavigationController?
    convenience init(_ viewController: DVTUINavigationController) {
        self.init()
        self.viewController = viewController
    }

//      // 这部分代码来源于QMUIKit UINavigationController+QMUI.m，处理添加`leftBarButtonItem`之后的手势返回
//      // 不方便测试，所以忽略iOS16以下系统添加`leftBarButtonItem`后手势失效问题
//    @objc func _gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceiveEvent event: UIEvent) -> Bool {
//        if gestureRecognizer == self.viewController?.interactivePopGestureRecognizer {
//            if let odelegate = self.viewController?.interactivePopGestureRecognizerDelegate {
//                let sel = NSSelectorFromString("_gestureRecognizer:shouldReceiveEvent:")
//                if odelegate.responds(to: sel) {
//                    print(odelegate.perform(sel, with: gestureRecognizer, with: event))
//                    let value = odelegate.perform(sel, with: gestureRecognizer, with: event)?.takeUnretainedValue() as? Bool ?? true
//                    if !value {
//                        // `UINavigationController`添加`leftBarButtonItem`之后，在这里返回`true`，可以恢复系统的返回手势
//                    }
//                    return value
//                }
//            }
//        }
//        return true
//    }
//
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.viewController?.interactivePopGestureRecognizer {
            if let odelegate = self.viewController?.interactivePopGestureRecognizerDelegate {
                return odelegate.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) ?? true
            }
        }
        return true
    }

    // 在这里拦截返回手势和按钮点击
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.viewController?.interactivePopGestureRecognizer {
            if self.viewController?.canPop(self.viewController?.topViewController, by: true) ?? false {
                if let odelegate = self.viewController?.interactivePopGestureRecognizerDelegate {
                    return odelegate.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true
                }
            } else {
                return false
            }
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.viewController?.interactivePopGestureRecognizer {
            if let odelegate = self.viewController?.interactivePopGestureRecognizerDelegate {
                return odelegate.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? false
            }
        }
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.viewController?.interactivePopGestureRecognizer
    }
}

public protocol DVTUINavigationControllerPopAndBackButtonHandlerDelegate {
    func shouldPopViewController(by popGesture: Bool) -> Bool
}

public extension DVTUINavigationControllerPopAndBackButtonHandlerDelegate {
    func shouldPopViewController(by popGesture: Bool) -> Bool { true }
}

public typealias DVTUINavigationControllerDelegate = DVTUINavigationControllerPopAndBackButtonHandlerDelegate & DVTUINavigationBarStyleDelegate

extension DVTUINavigationController: DVTUINavigationBridgeDelegate {
    /// 当present一个控制器之后dismiss不会调用`delegate`的`navigationController(_:willShow:animated:)`方法
    ///
    /// 该接口会调用`delegate`的`navigationController(_:willShow:animated:)`方法
    ///
    /// - Parameters:
    ///   - appear: 即将显示的控制器
    ///   - animated: 动画
    func dvt_subVC_viewWillAppear(_ appear: UIViewController, animated: Bool) {
        self.navigationController(self, willShow: appear, animated: animated)
    }
}

open class DVTUINavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    private enum DVTNavigationActionState {
        case unknow // 初始、各种动作的 completed 之后都会立即转入 unknown 状态，此时的 appearing、disappearingViewController 均为 nil

        case willPush // push 方法被触发，但尚未进行真正的 push 动作
        case didPush // 系统的 push 已经执行完，viewControllers 已被刷新
        case pushCompleted // push 动画结束（如果没有动画，则在 did push 后立即进入 completed）

        case willPop // pop 方法被触发，但尚未进行真正的 pop 动作
        case didPop // 系统的 pop 已经执行完，viewControllers 已被刷新（注意可能有 pop 失败的情况）
        case popCompleted // pop 动画结束（如果没有动画，则在 did pop 后立即进入 completed）

        case willSet // setViewControllers 方法被触发，但尚未进行真正的 set 动作
        case didSet // 系统的 setViewControllers 已经执行完，viewControllers 已被刷新
        case setCompleted // setViewControllers 动画结束（如果没有动画，则在 did set 后立即进入 completed）
    }

    private weak var disappearingVC: UIViewController?
    private weak var appearingVC: UIViewController?
    private weak var dvt_delegate: UINavigationControllerDelegate?
    private var popGestureRecognizerDelegate: DVTUINavigationControllerGestureDelegateContainer?
    fileprivate weak var interactivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?

    /// 更新导航栏返回按钮的标题
    /// - Parameters:
    ///   - before: 上一级控制器
    ///   - appear: 当前显示的控制器
    private func updateNavigationBarBackButtonTitle() {
        guard let before = self.disappearingVC else { return }
        var title = DVTUINavigationBarStyle.default.dvt_navigationBarBackTitle

        if let fromVCStyle = before as? DVTUINavigationBarStyleDelegate, let temp = fromVCStyle.dvt_navigationBarBackTitle {
            title = temp
        }

        if let barStyle = self.appearingVC as? DVTUINavigationBarStyleDelegate, let temp = barStyle.dvt_revealNavigationBarBackTitle(before) {
            title = temp
        }

        before.navigationItem.backButtonTitle = title
        if #available(iOS 14.0, *) {
            if title?.isEmpty ?? false {
                before.navigationItem.backButtonDisplayMode = .minimal
            } else {
                before.navigationItem.backButtonDisplayMode = .default
            }
        }
    }

    /// 更新替换的导航栏
    /// - Parameter isShow: 显示状态
    private func updateReplaceNavigationBar(_ isShow: Bool) {
        guard isShow else {
            self.navigationBar.dvt.resetBackground()
            self.disappearingVC?.dvt.hideReplaceNavigationBar()
            self.appearingVC?.dvt.hideReplaceNavigationBar()
            return
        }

        guard let fromVCStyle = self.disappearingVC?.dvt.navigationBarStyle,
              let toVCStyle = self.appearingVC?.dvt.navigationBarStyle else {
            return
        }

        // 如果左右两个都隐藏，那就不显示假的
        guard fromVCStyle.dvt_navigationBarHidden == false || toVCStyle.dvt_navigationBarHidden == false else {
            return
        }
        if self.isPushing, let appearingStyleDelegate = self.appearingVC as? DVTUINavigationBarStyleDelegate {
            // 当Push到下一级页面导航栏是隐藏的时候真导航栏会提前变色渲染，所以需要显示假的
            if appearingStyleDelegate.dvt_navigationBarHidden, !self.navigationBar.isHidden {
                self.disappearingVC?.dvt.showReplaceNavigationBar()
                self.navigationBar.dvt.removeBackground()
                return
            }
        }
        if self.isPopping, let appearingStyleDelegate = self.appearingVC as? DVTUINavigationBarStyleDelegate {
            // 当Pop到下一级页面导航栏是隐藏的时候真导航栏会提前变色渲染，所以需要显示假的
            if appearingStyleDelegate.dvt_navigationBarHidden, !self.navigationBar.isHidden {
                self.disappearingVC?.dvt.showReplaceNavigationBar()
                self.navigationBar.dvt.removeBackground()
                return
            }
        }

        // 图片优先，先判断图片，没有图片则判断颜色。如果两个都是颜色并且都不为透明的，沿用系统的变色，否则显示假的，隐藏真的
        guard fromVCStyle.dvt_navigationBarBackgroundImage != nil ||
            toVCStyle.dvt_navigationBarBackgroundImage != nil ||
            fromVCStyle.dvt_navigationBarBackgroundColor == nil ||
            toVCStyle.dvt_navigationBarBackgroundColor == nil ||
            fromVCStyle.dvt_navigationBarBackgroundColor == .clear ||
            toVCStyle.dvt_navigationBarBackgroundColor == .clear else {
            return
        }
        // 这个时候需要处理显示假控制器
        self.disappearingVC?.dvt.showReplaceNavigationBar()
        self.appearingVC?.dvt.showReplaceNavigationBar()
        self.navigationBar.dvt.removeBackground()
    }

    /// 是否可以pop到上一级界面，点击返回按钮/手势
    /// - Parameters:
    ///   - viewController: 需要pop的控制器
    ///   - PopGesture: 是否是手势
    /// - Returns: 是否允许
    fileprivate func canPop(_ viewController: UIViewController?, by PopGesture: Bool) -> Bool {
        if let delegate = viewController as? DVTUINavigationControllerPopAndBackButtonHandlerDelegate {
            return delegate.shouldPopViewController(by: PopGesture)
        }
        return true
    }

    /// navigation操作状态
    private var actionState: DVTNavigationActionState = .unknow {
        didSet {
            switch self.actionState {
                case .didPush, .willSet, .willPop:
                    self.updateReplaceNavigationBar(true)
                case .pushCompleted, .popCompleted, .setCompleted:
                    self.updateReplaceNavigationBar(false)
                default: break
            }
        }
    }

    override public init(rootViewController: UIViewController) {
        super.init(navigationBarClass: DVTTransitionNavigationBar.classForCoder(), toolbarClass: nil)
        self.viewControllers = [rootViewController]
        self.didInitialize()
    }

    override public init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        if let cls = navigationBarClass as? DVTTransitionNavigationBar.Type {
            super.init(navigationBarClass: cls.self, toolbarClass: toolbarClass)
        } else {
            dvtuiloger.error("仅支持继承于DVTTransitionNavigationBar的类")
            super.init(navigationBarClass: DVTTransitionNavigationBar.self, toolbarClass: toolbarClass)
        }

        self.didInitialize()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.didInitialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didInitialize()
    }

    open func didInitialize() {
        UIViewController.dvt.navigation_swizzleed()
        UIView.dvt.exchangeNavigationBarContentView()
    }

    override open var delegate: UINavigationControllerDelegate? {
        didSet {
            if let value = self.delegate as? DVTUINavigationController, value != self {
                self.dvt_delegate = value
                super.delegate = self
            }
        }
    }

    override open var viewControllers: [UIViewController] {
        willSet {
            self.actionState = .willSet
        }
        didSet {
            let count = self.viewControllers.count
            if count >= 2 {
                self.disappearingVC = self.viewControllers[count - 2]
                self.appearingVC = self.viewControllers[count - 1]
                self.updateNavigationBarBackButtonTitle()
            }
            self.actionState = .didSet
            self.actionState = .setCompleted
        }
    }

    public var isPopping: Bool {
        self.actionState == .willPop || self.actionState == .didPop || self.actionState == .popCompleted
    }

    public var isPushing: Bool {
        self.actionState == .didPush || self.actionState == .pushCompleted
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.interactivePopGestureRecognizerDelegate = self.interactivePopGestureRecognizer?.delegate
        let gestureDelegateContainer = DVTUINavigationControllerGestureDelegateContainer(self)
        self.interactivePopGestureRecognizer?.delegate = gestureDelegateContainer
        self.popGestureRecognizerDelegate = gestureDelegateContainer
    }

    override open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if viewControllers.isEmpty {
            return
        }
        var controllers = viewControllers

        if controllers.count != Set<UIViewController>(controllers).count, let s = NSOrderedSet(array: controllers).array as? [UIViewController] {
            // 出现重复元素
            controllers = s
        }

        self.appearingVC = controllers.last == self.topViewController ? nil : controllers.last
        self.disappearingVC = self.topViewController

        self.actionState = .willSet
        super.setViewControllers(controllers, animated: animated)
        self.actionState = .didSet
        self.dvt.animateAlongsideTransition { [weak self] _ in
            self?.actionState = .setCompleted
            self?.actionState = .unknow
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let topVC = self.topViewController {
            self.navigationController(self, willShow: topVC, animated: animated)
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let topVC = self.topViewController {
            self.navigationController(self, didShow: topVC, animated: animated)
        }
    }

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let topVC = self.topViewController
        if topVC?.dvt.navigationBarStyle == nil {
            topVC?.dvt.setNavigationBarStyle(DVTUINavigationBarStyle(self.navigationBar.standardAppearance))
        }
        self.disappearingVC = topVC
        self.appearingVC = viewController
        self.updateNavigationBarBackButtonTitle()
        self.actionState = .willPush
        super.pushViewController(viewController, animated: animated)
        self.actionState = .didPush
        self.dvt.animateAlongsideTransition { [weak self] _ in
            self?.actionState = .pushCompleted
            self?.actionState = .unknow
        }
    }

    override open func popViewController(animated: Bool) -> UIViewController? {
        // 判断是否可以pop
        let count = self.viewControllers.count
        // 如果只有一个，并且目前不是默认状态就调用系统实现
        // 如果目前正在转场，系统会在转场完成之后再次调用该方法
        guard count >= 2, self.actionState == .unknow else {
            return super.popViewController(animated: animated)
        }
        self.disappearingVC = self.viewControllers.last
        self.appearingVC = self.viewControllers[count - 2]
        self.actionState = .willPop

        let viewController = super.popViewController(animated: animated)

        self.disappearingVC = viewController
        self.actionState = .didPop

        if viewController == nil { // 系统pop失败，手动设置状态
            self.actionState = .popCompleted
            self.actionState = .unknow
        } else {
            // 转场动画执行完成之后，设置状态
            self.dvt.animateAlongsideTransition { [weak self] _ in
                self?.actionState = .popCompleted
                self?.actionState = .unknow
            }
        }
        return viewController
    }

    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if !self.viewControllers.contains(viewController), self.topViewController == viewController, self.actionState != .unknow {
            return super.popToViewController(viewController, animated: animated)
        }
        self.disappearingVC = self.topViewController
        self.appearingVC = viewController
        self.actionState = .willPop
        let viewControllers = super.popToViewController(viewController, animated: animated)
        self.disappearingVC = viewController
        self.actionState = .didPop
        if viewControllers?.isEmpty ?? true { // 系统pop失败，手动设置状态
            self.actionState = .popCompleted
            self.actionState = .unknow
        } else {
            // 转场动画执行完成之后，设置状态
            self.dvt.animateAlongsideTransition { [weak self] _ in
                self?.actionState = .popCompleted
                self?.actionState = .unknow
            }
        }
        return viewControllers
    }

    override open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if self.viewControllers.count == 1, self.actionState != .unknow {
            return super.popToRootViewController(animated: animated)
        }
        self.disappearingVC = self.topViewController
        self.appearingVC = self.viewControllers.first
        self.actionState = .willPop
        let viewControllers = super.popToRootViewController(animated: animated)
        self.disappearingVC = self.viewControllers.first
        self.appearingVC = self.topViewController
        if viewControllers?.isEmpty ?? true { // 系统pop失败，手动设置状态
            self.actionState = .popCompleted
            self.actionState = .unknow
        } else {
            // 转场动画执行完成之后，设置状态
            self.dvt.animateAlongsideTransition { [weak self] _ in
                self?.actionState = .popCompleted
                self?.actionState = .unknow
            }
        }
        return viewControllers
    }

    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.dvt_delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.dvt_delegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    open func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.dvt_delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
    }

    open func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return self.dvt_delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
    }

    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.dvt_delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }

    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.dvt_delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}
