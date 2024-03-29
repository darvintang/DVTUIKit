//
//  DVTUIProgressView.swift
//  DVTUIKit_Progress
//
//  Created by darvin on 2022/8/15.
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

#if canImport(DVTUIKit_Public)
    import DVTUIKit_Public
#endif

private extension UIImage {
    // MARK: Internal
    static func image(_ named: String) -> UIImage? {
        let realName = "DVTUIKit_Progress_\(named)"
        // (main) OR (cocoapods default) OR (cocoapods Frameworks (generate_multiple_pod_projects)) OR (Bundle SPM)
        return UIImage(named: "main_" + realName) ?? UIImage(named: realName) ?? .dvt.image(DVTUIProgressView.self, named: realName) ?? .dvt
            .image(self.bundleName, named: realName)
    }

    // MARK: Private
    private static let bundleName = "DVTUIKit_DVTUIKit.Progress"
}

open class DVTUIProgressView: DVTUIView {
    // MARK: Lifecycle
    override open func setupSubviews() {
        super.setupSubviews()
        self.addSubview(self.trackView)

        self.trackView.addSubview(self.progressMarkView)
        self.progressMarkView.addSubview(self.progressView)
        self.setDefault()
    }

    // MARK: Open
    /// 进度条的高度
    open var progressHeight: CGFloat = 8 {
        didSet {
            if oldValue != self.progressHeight {
                self.updaterRound()
            }
        }
    }

    /// 是否使用圆角，默认 true
    open var isRound = true {
        didSet {
            if oldValue != self.isRound {
                self.updaterRound()
            }
        }
    }

    open var progressColor: UIColor? {
        didSet {
            if let color = self.progressColor {
                let size = self.selfFrame.size
                self.progressImage = UIImage(dvt: color, size: size == .zero ? CGSize(width: 50, height: 50) : size)
            } else {
                self.progressView.image = nil
            }
        }
    }

    open var progressColors: [UIColor]? {
        didSet {
            if let colors = self.progressColors, !colors.isEmpty {
                let size = self.selfFrame.size
                self.progressImage = UIImage(dvt: colors, size: size == .zero ? CGSize(width: 50, height: 50) : size)
            } else {
                self.progressView.image = nil
            }
        }
    }

    /// 进度的图片
    open var progressImage: UIImage? {
        set {
            let image = newValue
            if image != nil {
                self.progressView.backgroundColor = .clear
            } else {
                self.progressColor = nil
                self.progressColors = nil
                self.progressView.backgroundColor = UIColor(dvt: 0xEEEEEE)
            }
            self.progressView.image = image
        }
        get {
            self.progressView.image
        }
    }

    /// 当前进度，默认 0
    open var progress: CGFloat {
        set {
            if newValue < 0 || newValue > 1 {
                return
            }
            self.queue.sync {
                if _progress != newValue {
                    DispatchQueue.main.async {
                        self.setSubviewsNewFrame()
                    }
                }
                _progress = newValue
            }
        }
        get {
            _progress
        }
    }

    open var trackColor: UIColor? {
        didSet {
            if let color = self.trackColor {
                let size = self.selfFrame.size
                self.trackImage = UIImage(dvt: color, size: size == .zero ? CGSize(width: 50, height: 50) : size)
            } else {
                self.trackView.image = nil
            }
        }
    }

    open var trackColors: [UIColor]? {
        didSet {
            if let colors = self.trackColors {
                let size = self.selfFrame.size
                self.trackImage = UIImage(dvt: colors, size: size == .zero ? CGSize(width: 50, height: 50) : size)
            } else {
                self.trackView.image = nil
            }
        }
    }

    /// 进度轨道图片
    open var trackImage: UIImage? {
        set {
            let image = newValue
            if image != nil {
                self.trackView.backgroundColor = .clear
            } else {
                self.trackColor = nil
                self.trackColors = nil
                self.trackView.backgroundColor = UIColor(dvt: 0xEEEEEE)
            }
            self.trackView.image = image
        }
        get {
            self.trackView.image
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.selfFrame = self.frame
    }

    // MARK: Fileprivate
    fileprivate lazy var progressView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(dvt: 0x888888)
        view.contentMode = .scaleToFill
        return view
    }()

    fileprivate lazy var trackView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(dvt: 0xEEEEEE)
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleToFill
        return view
    }()

    fileprivate lazy var progressMarkView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    /// 设置进度的队列，预防开发者在外部设置进度和内部设置进度时产生的多线程问题
    fileprivate lazy var queue: DispatchQueue = {
        let queue = DispatchQueue(label: UUID().uuidString)
        return queue
    }()

    fileprivate var _progress: CGFloat = 0

    /// 通过在layoutSubviews中拿到的视图frame确定各子视图的frame
    fileprivate var selfFrame: CGRect = .zero {
        didSet {
            if oldValue != self.selfFrame {
                self.setSubviewsNewFrame()
            }
        }
    }

    /// 切圆角
    fileprivate func updaterRound() {
        self.trackView.layer.cornerRadius = self.isRound ? (self.progressHeight / 2) : 0
    }

    fileprivate func setSubviewsNewFrame() {
        guard self.selfFrame != .zero else {
            return
        }

        let frame = self.selfFrame
        if frame.height < self.progressHeight {
            self.bounds = self.bounds.dvt.setHeight(self.progressHeight)
        }

        let trackX: CGFloat = 0
        let trackY = (self.bounds.height - self.progressHeight) / 2

        let trackFrame = CGRect(x: trackX, y: trackY, width: frame.width, height: self.progressHeight)

        self.trackView.frame = trackFrame
        let progressWidth = trackFrame.width * self._progress
        let progressMarkFrame = CGRect(x: 0, y: 0, width: progressWidth, height: self.progressHeight)
        self.progressMarkView.frame = progressMarkFrame
        self.progressView.frame = CGRect(origin: .zero, size: trackFrame.size)
    }

    fileprivate func setDefault() {
        self.backgroundColor = .clear
        self.updaterRound()
    }
}

open class DVTUISlider: DVTUIProgressView {
    // MARK: Lifecycle
    override open func setupSubviews() {
        super.setupSubviews()
        self.addSubview(self.progressPromptView)
        self.addSubview(self.thumbImageView)
        self.thumbAnimate = { status in
            if status == .begin {
                self.thumbImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }
            if status == .ended {
                self.thumbImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }

    // MARK: Open
    /// 滑块的大小，默认 (24, 24)
    open var thumbSize = CGSize(width: 24, height: 24) {
        didSet {
            if oldValue != self.thumbSize {
                self.setSubviewsNewFrame()
            }
        }
    }

    /// 滑块的图片
    open var thumbImage: UIImage? {
        didSet {
            self.updateThumbImage()
        }
    }

    /// 滑块颜色
    open var thumbColor: UIColor? {
        didSet {
            self.updateThumbImage()
        }
    }

    // MARK: Public
    public enum SliderStatus {
        case begin, changed, ended
    }

    public var offset: UIEdgeInsets = .zero

    public var sliderCompletion: ((_ state: SliderStatus, _ progress: CGFloat) -> Void)?

    /// 自定义进度提示控件
    public var configurationPrompt: ((_ view: UIButton, _ progress: CGFloat) -> Void)?

    public var thumbAnimate: ((_ state: SliderStatus) -> Void)?

    /// 是否显示使用进度提示控件，如果使用会忽略父控件的边界限制(clipsToBounds = false)
    public var isPrompt = true {
        didSet {
            if !self.isPrompt {
                self.progressPromptView.isHidden = true
            }
            if self.isPrompt {
                self.clipsToBounds = !self.isPrompt
                self.layer.masksToBounds = !self.isPrompt
            }
        }
    }

    // MARK: Fileprivate
    override fileprivate var _progress: CGFloat {
        didSet {
            // 设置进度提示位置和文案
            self.setProgressPrompt()
        }
    }

    override fileprivate func setSubviewsNewFrame() {
        if self.frame.height < self.thumbSize.height {
            self.bounds = self.bounds.dvt.setHeight(self.thumbSize.height)
        }
        super.setSubviewsNewFrame()
        guard self.selfFrame != .zero else {
            return
        }

        let frame = self.trackView.frame
        let progressWidth = (frame.width - self.thumbSize.width - self.offset.dvt.horizontal) * self.progress
        let progressMarkFrame = CGRect(x: 0, y: 0, width: progressWidth + self.thumbSize.width / 2 + self.offset.left, height: self.progressHeight)
        self.progressMarkView.frame = progressMarkFrame
        self.thumbImageView.bounds = CGRect(origin: .zero, size: self.thumbSize)
        self.thumbImageView.center = CGPoint(x: progressMarkFrame.maxX, y: self.trackView.center.y)
        self.setProgressPrompt()
    }

    override fileprivate func setDefault() {
        super.setDefault()
        self.isPrompt = true
        self.thumbImage = .image("icon_thumb")
        self.thumbImageView.addGestureRecognizer(self.panGesture)
    }

    // MARK: Private
    private lazy var thumbImageView: UIImageView = {
        // MARK: Internal
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleToFill
        return view
    }()

    // MARK: - 进度比例提示

    /// 进度比例提示控件
    private lazy var progressPromptView: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        btn.titleLabel?.font = UIFont.dvt.regular(of: 15)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        btn.setBackgroundImage(.image("bg_progress_prompt"), for: .normal)
        btn.sizeToFit()
        return btn
    }()

    // MARK: - 手势

    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.gestureRecognizer(_:)))
        return panGesture
    }()

    private var oldPoint = CGPoint.zero

    /// 进度提示控件设置
    private func setProgressPrompt() {
        self.progressPromptView.setTitle("\(Int(self._progress * 100))%", for: .normal)

        self.configurationPrompt?(self.progressPromptView, self._progress)

        let x = self.thumbImageView.frame.midX
        let y = self.thumbImageView.frame.minY - self.progressPromptView.dvt.height / 2
        self.progressPromptView.center = CGPoint(x: x, y: y)
    }

    @objc
    private func gestureRecognizer(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            if self.isPrompt {
                self.progressPromptView.isHidden = false
            }
            self.oldPoint = self.thumbImageView.center
            self.thumbAnimate?(.begin)
            self.sliderCompletion?(.begin, self._progress)
        }
        if pan.state == .changed {
            let offsetPoint = pan.translation(in: self)
            let newX = self.oldPoint.x + offsetPoint.x
            self.setThumbCenter(CGPoint(x: newX, y: self.oldPoint.y))
            self.sliderCompletion?(.changed, self._progress)
            self.thumbAnimate?(.changed)
        }

        if pan.state == .ended {
            if self.isPrompt {
                self.progressPromptView.isHidden = true
            }
            self.thumbAnimate?(.ended)
            self.sliderCompletion?(.ended, self._progress)
        }
    }

    private func setThumbCenter(_ point: CGPoint) {
        let newX = min(max(point.x, self.thumbSize.width / 2 + self.offset.left), self.dvt.width - self.thumbSize.width / 2 - self.offset.right)

        var frame = self.progressMarkView.frame
        frame.size.width = newX

        UIView.animate(withDuration: 0.01) {
            self.thumbImageView.center = CGPoint(x: newX, y: point.y)
            self.progressMarkView.frame = frame
        } completion: { _ in
            self.queue.sync {
                self._progress = (frame.size.width - self.thumbSize.width / 2 - self.offset.left) / (self.trackView.frame.width - self.thumbSize.width - self.offset.dvt.horizontal)
            }
        }
    }

    private func updateThumbImage() {
        var image: UIImage? = self.thumbImage ?? .image("icon_thumb")
        if let color = self.thumbColor {
            image = image?.dvt.image(tintColor: color)
        }
        self.thumbImageView.image = image
    }
}
