//
//  DVTUIModalPresentationViewController.swift
//  DVTUIKit_ModalPresentation
//
//  Created by darvin on 2023/2/2.
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

#if canImport(DVTUIKit_Extension)
    import DVTUIKit_Extension
#endif

open class DVTUIModalPresentationViewController: UIViewController {
    // MARK: Lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Open
    override open var shouldAutorotate: Bool {
        if self.dvt.activeViewController != self {
            return self.dvt.activeViewController?.shouldAutorotate ?? true
        }
        return true
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if self.dvt.activeViewController != self {
            return self.dvt.activeViewController?.supportedInterfaceOrientations ?? .all
        }
        return self.supportedOrientationMask
    }

    // MARK: Public
    public enum AnimationStyle {
        case fade, // 渐现渐隐，默认
             popup, // 从中心点弹出
             slide // 从下往上升起
    }

    /// 要被弹出的浮层，适用于浮层以UIViewController的形式来管理的情况。
    /// 优先级比`contentView`高
    /// 当设置了`contentViewController`时，`contentViewController.view`会被当成`contentView`使用，因此不要再自行设置`contentView`
    /// 注意`contentViewController`是强引用，容易导致循环引用，使用时请注意
    public var contentViewController: UIViewController?

    /// 要被弹出的浮层
    /// 当设置了`contentView`时，不要再设置`contentViewController`
    public var contentView: UIView?

    /// 限制`contentView`布局时的最大宽度，默认为 greatestFiniteMagnitude，也即无限制。
    public var maximumContentViewWidth: CGFloat = .greatestFiniteMagnitude

    /// 如果 modal 是以 window 形式显示的话，控制在 modal 显示时是否要自动把 App 主界面置灰。
    /// 默认为 YES。
    /// 该属性在非 window 形式显示的情况下无意义。
    public var shouldDimmedAppAutomatically = true

    /// 设置`contentView`布局时与外容器的间距，默认为(20, 20, 20, 20)
    public var contentViewMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    ///  由于点击遮罩导致浮层即将被隐藏的回调
    public var willHideByDimmingViewTappedBlock: (() -> Void)?
    /// 由于点击遮罩导致浮层被隐藏后的回调（区分于`hideWithAnimated:completion:`里的completion，这里是特地用于点击遮罩的情况）
    public var didHideByDimmingViewTappedBlock: (() -> Void)?

    /// 控制当前是否以模态的形式存在。如果以模态的形式存在，则点击空白区域不会隐藏浮层。
    /// 默认为false，也即点击空白区域将会自动隐藏浮层。
    public var isModal = false
    /// 标志当前浮层的显示/隐藏状态，默认为NO。
    public var isVisible = false

    /// 修改当前界面要支持的横竖屏方向，默认为 SupportedOrientationMask。
    public var supportedOrientationMask: UIInterfaceOrientationMask = .all

    /// 设置要使用的显示/隐藏动画的类型，默认为`AnimationStyle.fade`。
    public var animationStyle: AnimationStyle = .fade

    /// 背景遮罩，默认为一个普通的`UIView`，背景色为黑色0.35透明度，可设置为自己的view，注意`dimmingView`的大小将会盖满整个控件。
    public var dimmingView: UIView? {
        didSet {
            // 添加手势
        }
    }

    // MARK: Private
    private var window: DVTModalPresentationWindow?
}

public class DVTModalPresentationWindow: UIWindow { }
