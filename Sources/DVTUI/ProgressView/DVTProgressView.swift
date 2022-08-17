//
//  DVTProgressView.swift
//  DVTUIKit
//
//  Created by darvin on 2022/8/15.
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

import UIKit

open class DVTProgressView: DVTUIView {
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

    /// 进度条的高度
    open var progressHeight: CGFloat = 8 {
        didSet {
            if oldValue != self.progressHeight {
                self.updaterRound()
            }
        }
    }

    /// 是否使用圆角，默认 true
    open var isRound: Bool = true {
        didSet {
            if oldValue != self.isRound {
                self.updaterRound()
            }
        }
    }

    /// 切圆角
    fileprivate func updaterRound() {
        self.trackView.layer.cornerRadius = self.isRound ? (self.progressHeight / 2) : 0
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

    fileprivate var _progress: CGFloat = 0

    /// 当前进度，默认 0
    open var progress: CGFloat {
        set {
            if newValue < 0 || newValue > 1 {
                return
            }
            self.queue.sync {
                if _progress != newValue {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.1) {
                            self.setSubviewsNewFrame()
                        }
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

    /// 通过在layoutSubviews中拿到的视图frame确定各子视图的frame
    fileprivate var selfFrame: CGRect = .zero {
        didSet {
            if oldValue != self.selfFrame {
                self.setSubviewsNewFrame()
            }
        }
    }

    fileprivate func setSubviewsNewFrame() {
        guard self.selfFrame != .zero else {
            return
        }

        let frame = self.selfFrame

        let trackX: CGFloat = 0
        let trackY = frame.height - self.progressHeight

        let trackFrame = CGRect(x: trackX, y: trackY, width: frame.width, height: self.progressHeight)

        self.trackView.frame = trackFrame
        let progressWidth = trackFrame.width * self._progress
        let progressMarkFrame = CGRect(x: 0, y: 0, width: progressWidth, height: self.progressHeight)
        self.progressMarkView.frame = progressMarkFrame
        self.progressView.frame = CGRect(origin: .zero, size: trackFrame.size)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.selfFrame = self.frame
    }

    override open func setupSubviews() {
        super.setupSubviews()
        self.addSubview(self.trackView)

        self.trackView.addSubview(self.progressMarkView)
        self.progressMarkView.addSubview(self.progressView)
        self.setDefault()
    }

    fileprivate func setDefault() {
        self.backgroundColor = .clear
        self.updaterRound()
    }
}

open class DVTSlideView: DVTProgressView {
    fileprivate lazy var thumbImageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleToFill
        return view
    }()

    /// 滑块的大小，默认 (24, 24)
    open var thumbSize: CGSize = CGSize(width: 24, height: 24) {
        didSet {
            if oldValue != self.thumbSize {
                self.setSubviewsNewFrame()
            }
        }
    }

    /// 滑块的图片
    open var thumbImage: UIImage? {
        didSet {
            self.thumbImageView.image = self.thumbImage
        }
    }

    override fileprivate var _progress: CGFloat {
        didSet {
            // 设置进度提示位置和文案
            self.setProgressPrompt()
        }
    }

    public enum SlideStatus {
        case begin, changed, ended
    }

    public var slideCompletion: ((_ state: SlideStatus, _ progress: CGFloat) -> Void)?

    // MARK: - 进度比例提示

    /// 进度比例提示控件
    private lazy var progressPromptView: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        btn.titleLabel?.font = UIFont.dvt.regular(of: 15)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        btn.setBackgroundImage(UIImage(dvt: "bg_progress"), for: .normal)
        btn.sizeToFit()
        return btn
    }()

    /// 进度提示控件设置
    private func setProgressPrompt() {
        self.progressPromptView.setTitle("\(Int(self._progress * 100))%", for: .normal)

        self.configurationPrompt?(self.progressPromptView, self._progress)

        let x = self.thumbImageView.frame.midX
        let y = self.thumbImageView.frame.minY - self.progressPromptView.dvt.height / 2
        self.progressPromptView.center = CGPoint(x: x, y: y)
    }

    /// 自定义进度提示控件
    public var configurationPrompt: ((_ view: UIButton, _ progress: CGFloat) -> Void)?

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

    // MARK: - 手势

    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.gestureRecognizer(_:)))
        return panGesture
    }()

    private var oldPoint = CGPoint.zero
    @objc private func gestureRecognizer(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            if self.isPrompt {
                self.progressPromptView.isHidden = false
            }
            self.oldPoint = self.thumbImageView.center
            self.thumbImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            self.slideCompletion?(.begin, self._progress)
        }
        if pan.state == .changed {
            let offsetPoint = pan.translation(in: self)
            let newX = self.oldPoint.x + offsetPoint.x
            self.setThumbCenter(CGPoint(x: newX, y: self.oldPoint.y))
            self.slideCompletion?(.changed, self._progress)
        }

        if pan.state == .ended {
            if self.isPrompt {
                self.progressPromptView.isHidden = true
            }
            self.thumbImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.slideCompletion?(.ended, self._progress)
        }
    }

    private func setThumbCenter(_ point: CGPoint) {
        let newX = min(max(point.x, self.thumbSize.width / 2), self.dvt.width - self.thumbSize.width / 2)
        var frame = self.progressMarkView.frame
        frame.size.width = frame.size.width + (newX - frame.maxX) - (self.thumbSize.width / 2)

        UIView.animate(withDuration: 0.01) {
            self.thumbImageView.center = CGPoint(x: newX, y: point.y)
            self.progressMarkView.frame = frame
        } completion: { _ in
            self.queue.sync {
                self._progress = frame.size.width / self.trackView.frame.width
            }
        }
    }

    override open func setupSubviews() {
        super.setupSubviews()
        self.addSubview(self.progressPromptView)
        self.addSubview(self.thumbImageView)
    }

    override fileprivate func setDefault() {
        super.setDefault()
        self.isPrompt = true
        self.thumbImage = UIImage(dvt: "icon_thumb")
        self.thumbImageView.addGestureRecognizer(self.panGesture)
    }

    override fileprivate func setSubviewsNewFrame() {
        guard self.selfFrame != .zero else {
            return
        }

        let frame = self.selfFrame

        let trackX = self.thumbSize.width / 2
        let trackY = frame.height - (self.thumbSize.height / 2)

        let trackFrame = CGRect(x: trackX, y: trackY, width: frame.width - self.thumbSize.width, height: self.progressHeight)

        self.trackView.frame = trackFrame
        let progressWidth = trackFrame.width * self._progress

        let progressMarkFrame = CGRect(x: 0, y: 0, width: progressWidth, height: self.progressHeight)
        self.progressMarkView.frame = progressMarkFrame

        self.progressView.frame = CGRect(origin: .zero, size: trackFrame.size)

        self.thumbImageView.bounds = CGRect(origin: .zero, size: self.thumbSize)
        self.thumbImageView.center = CGPoint(x: progressMarkFrame.maxX + trackX, y: trackY + self.progressHeight / 2)
        self.setProgressPrompt()
    }
}
