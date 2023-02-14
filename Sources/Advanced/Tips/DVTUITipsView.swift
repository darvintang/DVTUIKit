//
//  DVTUITipsView.swift
//  DVTUIKit_Tips
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

#if canImport(DVTUIKit_Public)
    import DVTUIKit_Extension
    import DVTUIKit_Public
#endif

public enum DVTUITipsPosition {
    case top, center, bottom
}

public enum DVTUITipsAnimationType {
    case fade, zoom, slide
}

/// 动画协议，可以自行实现，然后修改DVTUITipsStyle.tipsAnimation
public protocol DVTUITipsAnimationDelegate {
    func show(_ views: [UIView], completion: @escaping (_ finished: Bool) -> Void)
    func hide(_ views: [UIView], completion: @escaping (_ finished: Bool) -> Void)
}

public class DVTUITipsStyle {
    private static let _default = DVTUITipsStyle(true)
    public static var `default`: DVTUITipsStyle {
        _default
    }

    private init(_ flag: Bool) {
    }

    public init(backgroundColor: UIColor? = nil, tintColor: UIColor? = nil,
                textFont: UIFont? = nil, detailTextFont: UIFont? = nil,
                timeout: TimeInterval? = nil, paddingInsets: UIEdgeInsets? = nil,
                marginInsets: UIEdgeInsets? = nil, tipsAnimation: DVTUITipsAnimationDelegate? = nil) {
        self.backgroundColor = backgroundColor ?? Self.default.backgroundColor
        self.tintColor = tintColor ?? Self.default.tintColor
        self.textFont = textFont ?? Self.default.textFont
        self.detailTextFont = detailTextFont ?? Self.default.detailTextFont
        self.timeout = timeout ?? Self.default.timeout
        self.paddingInsets = paddingInsets ?? Self.default.paddingInsets
        self.marginInsets = marginInsets ?? Self.default.marginInsets
        self.tipsAnimation = tipsAnimation ?? Self.default.tipsAnimation
    }

    public var backgroundColor: UIColor = .black

    public var tintColor: UIColor = .white

    public var textFont: UIFont = .dvt.medium(of: 16)

    public var detailTextFont: UIFont = .dvt.regular(of: 15)

    /// 超时时间
    public var timeout: TimeInterval = 30
    /// 内容内部间距
    public var paddingInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    /// 内容外部间距
    public var marginInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    /// 如果使用自定义动画修改该属性
    public var tipsAnimation: DVTUITipsAnimationDelegate = DVTUITipsAnimation()
}

// MARK: - fileprivate

fileprivate class DVTUITipsContentView: DVTUIView {
    var text: String?
    var attributedText: NSAttributedString?
    var detailText: String?
    var attributedDetailText: NSAttributedString?

    var view: UIView?
    var style: DVTUITipsStyle = .default

    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()

    private lazy var detailTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()

    func updateSubviews() {
        self.backgroundColor = self.style.backgroundColor

        var lastView: UIView = self

        if let view = self.view {
            view.tintColor = self.style.tintColor
            if let view = view as? UIActivityIndicatorView {
                view.startAnimating()
                view.color = self.style.tintColor
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)

            view.dvt.addConstraint(self) { make in
                make.attribute = .top
                make.constant = self.style.paddingInsets.top
            }

            view.dvt.addConstraint(self) { make in
                make.attribute = .centerX
            }

            view.dvt.addConstraint(self) { make in
                make.attribute = .left
                make.related = .greaterThanOrEqual
                make.constant = self.style.paddingInsets.left
            }
            view.dvt.addConstraint(self) { make in
                make.attribute = .right
                make.related = .lessThanOrEqual
                make.constant = -self.style.paddingInsets.right
            }
            view.dvt.addConstraint { make in
                make.attribute = .width
                make.constant = view.frame.size.width
            }
            view.dvt.addConstraint { make in
                make.attribute = .height
                make.constant = view.frame.size.height
            }
            lastView = view
        }

        var needTextLabel = false
        if let text = self.text, !text.isEmpty {
            self.textLabel.text = text
            needTextLabel = true
        }
        if let text = self.attributedText, !text.string.isEmpty {
            self.textLabel.attributedText = text
            needTextLabel = true
        }

        if needTextLabel {
            self.textLabel.font = self.style.textFont
            self.textLabel.textColor = self.style.tintColor
            self.addSubview(self.textLabel)
            self.textLabel.dvt.addConstraint(lastView) { make in
                make.attribute = .top
                make.constant = self.style.paddingInsets.top
                if lastView != self {
                    make.toAttribute = .bottom
                }
            }
            self.textLabel.dvt.addConstraint(self) { make in
                make.attribute = .left
                make.related = .greaterThanOrEqual
                make.constant = self.style.paddingInsets.left
            }
            self.textLabel.dvt.addConstraint(self) { make in
                make.attribute = .centerX
            }
            self.textLabel.dvt.addConstraint(self) { make in
                make.attribute = .right
                make.related = .greaterThanOrEqual
                make.constant = -self.style.paddingInsets.right
            }
            lastView = self.textLabel
        }

        var needDetailTextLabel = false
        if let text = self.detailText, !text.isEmpty {
            self.detailTextLabel.text = text
            needDetailTextLabel = true
        }
        if let text = self.attributedDetailText, !text.string.isEmpty {
            self.detailTextLabel.attributedText = text
            needDetailTextLabel = true
        }
        if needDetailTextLabel {
            self.detailTextLabel.font = self.style.detailTextFont
            self.detailTextLabel.textColor = self.style.tintColor
            self.addSubview(self.detailTextLabel)
            self.detailTextLabel.dvt.addConstraint(lastView) { make in
                make.attribute = .top
                make.constant = self.style.paddingInsets.top
                if lastView != self {
                    make.toAttribute = .bottom
                }
                if lastView == self.textLabel {
                    make.constant = 8
                }
            }
            self.detailTextLabel.dvt.addConstraint(self) { make in
                make.attribute = .left
                make.related = .greaterThanOrEqual
                make.constant = self.style.paddingInsets.left
            }
            self.detailTextLabel.dvt.addConstraint(self) { make in
                make.attribute = .centerX
            }
            self.detailTextLabel.dvt.addConstraint(self) { make in
                make.attribute = .right
                make.related = .greaterThanOrEqual
                make.constant = -self.style.paddingInsets.right
            }
            lastView = self.detailTextLabel
        }
        lastView.dvt.addConstraint(self) { make in
            make.attribute = .bottom
            make.constant = -self.style.paddingInsets.bottom
        }
    }

    override func didInitialize() {
        super.didInitialize()
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.isOpaque = false
        self.layer.allowsGroupOpacity = false
        self.isUserInteractionEnabled = false
    }
}

fileprivate class DVTUITipsAnimation: NSObject {
    var type: DVTUITipsAnimationType = .fade

    private var views: [UIView]?
    private var animationCompletion: ((_ finished: Bool) -> Void)?

    private func fadeAnimation(_ show: Bool, completion: @escaping (_ finished: Bool) -> Void) {
        if show {
            self.views?.forEach({ view in
                view.alpha = show ? 0 : 1
            })
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
            self.views?.forEach({ view in
                view.alpha = show ? 1 : 0
            })
        } completion: { finished in
            completion(finished)
        }
    }

    private func zoomAnimation(_ show: Bool, completion: @escaping (_ finished: Bool) -> Void) {
        let alpha: CGFloat = show ? 1 : 0
        let small = CGAffineTransformMakeScale(0.5, 0.5)
        let endTransform = show ? CGAffineTransform.identity : small

        if show {
            self.views?.forEach({ view in
                view.transform = small
            })
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
            self.views?.forEach({ view in
                view.transform = endTransform
                view.alpha = alpha
            })
        } completion: { finished in
            self.views?.forEach({ view in
                view.transform = endTransform
            })
            completion(finished)
        }
    }

    private func slideAnimation(_ show: Bool, completion: @escaping (_ finished: Bool) -> Void) {
        self.animationCompletion = completion
        self.views?.forEach({ view in
            if show {
                self.showSlideAnimation(view)
            } else {
                self.hideSlideAnimation(view)
            }
        })
    }

    private func showSlideAnimation(_ view: UIView) {
        let animationY = CABasicAnimation(keyPath: "transform.translation.y")
        animationY.fromValue = -(CGFloat.dvt.screenHeight + view.dvt.height) / 2
        animationY.toValue = 0
        animationY.duration = 0.6
        animationY.isRemovedOnCompletion = false
        animationY.fillMode = .both
        animationY.timingFunction = CAMediaTimingFunction(controlPoints: 0.51, 1.24, 0.02, 0.99)
        animationY.delegate = self
        view.layer.add(animationY, forKey: "showView")

        let animationZ = CABasicAnimation(keyPath: "transform.rotation.z")
        animationZ.fromValue = 2 * CGFloat.pi / 180
        animationZ.toValue = 0
        animationZ.duration = 0.17
        animationZ.beginTime = CACurrentMediaTime() + 0.16
        animationZ.isRemovedOnCompletion = false
        animationZ.fillMode = .both
        animationZ.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
        view.layer.add(animationZ, forKey: "showRotateKey")

        let animationOpacity = CABasicAnimation(keyPath: "opacity")
        animationOpacity.fromValue = 0
        animationOpacity.toValue = 1
        animationOpacity.duration = 0.27
        animationOpacity.beginTime = CACurrentMediaTime() + 0.03
        animationOpacity.isRemovedOnCompletion = false
        animationOpacity.fillMode = .both
        animationOpacity.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
        view.layer.add(animationZ, forKey: "showOpacityKey")
    }

    private func hideSlideAnimation(_ view: UIView) {
        let animationY = CABasicAnimation(keyPath: "transform.translation.y")
        animationY.fromValue = 0
        animationY.toValue = (CGFloat.dvt.screenHeight + view.dvt.height) / 2
        animationY.duration = 0.7
        animationY.isRemovedOnCompletion = false
        animationY.fillMode = .both
        animationY.timingFunction = CAMediaTimingFunction(controlPoints: 0.73, -0.38, 0.03, 1.41)
        animationY.delegate = self
        view.layer.add(animationY, forKey: "hideView")

        let animationZ = CABasicAnimation(keyPath: "transform.rotation.z")
        animationZ.fromValue = 0
        animationZ.toValue = 3 * CGFloat.pi / 180
        animationZ.duration = 0.4
        animationZ.beginTime = CACurrentMediaTime() + 0.05
        animationZ.isRemovedOnCompletion = false
        animationZ.fillMode = .both
        animationZ.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
        view.layer.add(animationZ, forKey: "hideRotateView")

        let animationOpacity = CABasicAnimation(keyPath: "opacity")
        animationOpacity.fromValue = 1
        animationOpacity.toValue = 0
        animationOpacity.duration = 0.25
        animationOpacity.beginTime = CACurrentMediaTime() + 0.15
        animationOpacity.isRemovedOnCompletion = false
        animationOpacity.fillMode = .both
        animationOpacity.timingFunction = CAMediaTimingFunction(controlPoints: 0.53, 0.92, 1, 1)
        view.layer.add(animationZ, forKey: "hideOpacityKey")
    }
}

extension DVTUITipsAnimation: CAAnimationDelegate, DVTUITipsAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.animationCompletion?(flag)
    }

    func show(_ views: [UIView], completion: @escaping (_ finished: Bool) -> Void) {
        self.views = views
        switch self.type {
            case .fade:
                self.fadeAnimation(true, completion: completion)
            case .zoom:
                self.zoomAnimation(true, completion: completion)
            case .slide:
                self.slideAnimation(true, completion: completion)
        }
        self.views = []
    }

    func hide(_ views: [UIView], completion: @escaping (_ finished: Bool) -> Void) {
        self.views = views
        switch self.type {
            case .fade:
                self.fadeAnimation(false, completion: completion)
            case .zoom:
                self.zoomAnimation(false, completion: completion)
            case .slide:
                self.slideAnimation(false, completion: completion)
        }
        self.views = []
    }
}

// MARK: - DVTUITipsView

/// 提示的控件，请不要在它出现后强引用它
public class DVTUITipsView: DVTUIView {
    public var uuid: String
    fileprivate static var allTips: [DVTUITipsView] = []

    fileprivate lazy var contentView: DVTUITipsContentView = {
        let contentView = DVTUITipsContentView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    fileprivate lazy var smaskView: UIView = {
        UIButton(type: .custom)
    }()

    fileprivate var tipsAnimation: DVTUITipsAnimationDelegate?

    fileprivate var timer: GCDTimer?
    fileprivate var timeout: TimeInterval?
    fileprivate var marginInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    @available(*, deprecated, message: "请使用self.init(_:detailText:view:style:position:)")
    override public init(frame: CGRect) {
        assertionFailure("请使用self.init(_:detailText:view:style:position:)")
        self.uuid = UUID().uuidString
        super.init(frame: frame)
        self.didInitialize()
    }

    @available(*, deprecated, message: "请使用self.init(_:detailText:view:style:position:)")
    public required init?(coder: NSCoder) {
        assertionFailure("请使用self.init(_:detailText:view:style:position:)")
        self.uuid = UUID().uuidString
        super.init(coder: coder)
        self.didInitialize()
    }

    private var positionConstraint: NSLayoutConstraint? {
        didSet {
            if let oldConstraint = oldValue, self.constraints.contains(oldConstraint) {
                self.removeConstraint(oldConstraint)
            }
        }
    }

    public var position: DVTUITipsPosition = .center {
        didSet {
            self.updateContentPosition()
        }
    }

    public var offset: CGPoint = .zero {
        didSet {
        }
    }

    public init(_ text: String? = nil, detailText: String? = nil,
                attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                view: UIView? = nil, style: DVTUITipsStyle = DVTUITipsStyle.default,
                position: DVTUITipsPosition = .center) {
        self.timeout = style.timeout
        self.marginInsets = style.marginInsets
        self.position = position
        self.tipsAnimation = style.tipsAnimation
        self.uuid = UUID().uuidString
        super.init(frame: .zero)

        self.contentView.text = text
        self.contentView.attributedText = attributedText

        self.contentView.detailText = detailText
        self.contentView.attributedDetailText = attributedDetailText

        self.contentView.view = view
        self.contentView.style = style
        self.contentView.updateSubviews()

        DVTKeyboardManager.default.addDidHideMonitor(self) { [weak self] info in
            UIView.animate(withDuration: info.animationDuration) {
                self?.updateContentPosition()
            }
        }
        DVTKeyboardManager.default.addDidShowMonitor(self) { [weak self] info in
            UIView.animate(withDuration: info.animationDuration) {
                self?.updateContentPosition()
            }
        }
    }

    override public func didInitialize() {
        super.didInitialize()
    }

    override public func setupSubviews() {
        super.setupSubviews()
        self.addSubview(self.smaskView)
        self.smaskView.dvt.addConstraint(self) { make in
            make.attribute = .top
        }
        self.smaskView.dvt.addConstraint(self) { make in
            make.attribute = .left
        }
        self.smaskView.dvt.addConstraint(self) { make in
            make.attribute = .bottom
        }
        self.smaskView.dvt.addConstraint(self) { make in
            make.attribute = .right
        }
        self.addSubview(self.contentView)
    }

    override public func addSubview(_ view: UIView) {
        if view != self.smaskView, view != self.contentView {
            return
        }
        super.addSubview(view)
    }

    override public func layoutSubviews() {
        self.contentView.dvt.addConstraint(self) { make in
            make.attribute = .centerX
            make.constant = self.offset.x
        }

        self.contentView.dvt.addConstraint(self) { make in
            make.attribute = .left
            make.related = .greaterThanOrEqual
            make.constant = self.marginInsets.left + (self.superview?.safeAreaInsets.left ?? 0)
        }

        self.contentView.dvt.addConstraint(self) { make in
            make.attribute = .right
            make.related = .lessThanOrEqual
            make.constant = -self.marginInsets.right - (self.superview?.safeAreaInsets.right ?? 0)
        }

        self.updateContentPosition()
        // 横竖屏切换后左右间隙有异常，所以先更新设置约束然后再调用系统的layoutSubviews
        super.layoutSubviews()
    }

    private func updateContentPosition() {
        self.positionConstraint = self.contentView.dvt.addConstraint(self, closure: { make in
            switch self.position {
                case .top:
                    make.attribute = .top
                    make.constant = self.marginInsets.top + (self.superview?.safeAreaInsets.top ?? 0) + self.offset.y
                case .center:
                    make.attribute = .centerY
                    make.constant = self.offset.y
                    if DVTKeyboardManager.default.isVisible {
                        make.constant = -(DVTKeyboardManager.default.info?.height ?? 0) / 2 + self.offset.y
                    }
                case .bottom:
                    make.attribute = .bottom
                    make.constant = -self.marginInsets.bottom - (self.superview?.safeAreaInsets.bottom ?? 0) + self.offset.y
            }
        })
        if self.position != .bottom {
            self.contentView.dvt.addConstraint(self) { make in
                make.attribute = .bottom
                make.related = .lessThanOrEqual
                make.constant = -self.marginInsets.bottom - (self.superview?.safeAreaInsets.bottom ?? 0)
                if DVTKeyboardManager.default.isVisible {
                    make.constant = -self.marginInsets.bottom - (DVTKeyboardManager.default.info?.height ?? 0)
                }
            }
        }
        if self.position != .top {
            self.contentView.dvt.addConstraint(self) { make in
                make.attribute = .top
                make.related = .greaterThanOrEqual
                make.constant = self.marginInsets.top + (self.superview?.safeAreaInsets.top ?? 0)
            }
        }
        self.updateConstraintsIfNeeded()
    }

    public fileprivate(set) var isAnimating = false

    fileprivate static var _allTipsViews: [DVTWeakObjectContainer<DVTUITipsView>] = []

    deinit {
        Self._allTipsViews.removeAll(where: { $0 == self })
    }
}

public extension DVTUITipsView {
    static var allTipsViews: [DVTUITipsView] {
        _allTipsViews.compactMap({ $0.object })
    }

    func show(_ animation: Bool = true, superview: UIView) {
        if self.superview != nil, self.superview != superview {
            self.removeFromSuperview()
        }
        UIView.swizzleed()
        superview.addSubview(self)
        self.dvt.addConstraint(superview) { make in
            make.attribute = .top
        }
        self.dvt.addConstraint(superview) { make in
            make.attribute = .left
        }
        self.dvt.addConstraint(superview) { make in
            make.attribute = .bottom
        }
        self.dvt.addConstraint(superview) { make in
            make.attribute = .right
        }

        if animation, let tipsAnimation = self.tipsAnimation {
            self.isAnimating = true
            tipsAnimation.show([self.contentView]) { _ in
                self.isAnimating = false
            }
        }
        if let timeout = self.timeout {
            self.timer = GCDTimer(deadline: timeout - 0.25, eventHandler: { [weak self] in
                self?.hide()
            })
        }

        Self._allTipsViews.append(DVTWeakObjectContainer(object: self))
    }

    func hide(_ animation: Bool = true) {
        self.timer?.cancel()
        if animation, let tipsAnimation = self.tipsAnimation {
            self.isAnimating = true
            tipsAnimation.hide([self.contentView]) { _ in
                self.isAnimating = false
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
}

/// 为了防止在添加TipsView之后被新的视图覆盖，所以hook了UIView的添加和移动子视图的方法
/// 确保TipsView总是保持在最上层，如果有多个，按照添加的时间顺序处理
fileprivate extension UIView {
    static var UIView_DVTUITips_Swizzleed = false
    static func swizzleed() {
        if self.UIView_DVTUITips_Swizzleed {
            return
        }
        self.swizzleSelector(#selector(addSubview(_:)), swizzle: #selector(dvt_tips_addSubview(_:)))
        self.swizzleSelector(#selector(bringSubviewToFront(_:)), swizzle: #selector(dvt_tips_bringSubviewToFront(_:)))
        self.UIView_DVTUITips_Swizzleed = true
    }

    @objc func dvt_tips_addSubview(_ view: UIView) {
        if view.isMember(of: DVTUITipsView.self) {
            self.dvt_tips_addSubview(view)
        } else {
            let tipsViews = self.subviews.filter({ $0.isMember(of: DVTUITipsView.self) })
            if let tipsView = tipsViews.first {
                self.insertSubview(view, aboveSubview: tipsView)
            } else {
                self.dvt_tips_addSubview(view)
            }
        }
    }

    @objc func dvt_tips_bringSubviewToFront(_ view: UIView) {
        if !self.subviews.contains(view) {
            return
        }
        if view.isMember(of: DVTUITipsView.self) {
            self.dvt_tips_bringSubviewToFront(view)
        } else {
            let tipsViews = self.subviews.filter({ $0.isMember(of: DVTUITipsView.self) })
            if let tipsView = tipsViews.first {
                self.insertSubview(view, aboveSubview: tipsView)
            } else {
                self.dvt_tips_bringSubviewToFront(view)
            }
        }
    }
}
