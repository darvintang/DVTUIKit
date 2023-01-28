//
//  DVTUIButton.swift
//  DVTUIKit
//
//  Created by darvin on 2022/8/8.
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

#if canImport(DVTUIKitExtension)
    import DVTUIKitExtension
#endif

/// 可以设置图片位置的按钮
///
/// 通过UIButtonConfiguration初始化的按钮设置图片方向按钮大小未验证
///
open class DVTUIButton: UIButton {
    public enum ImagePosition: Int {
        case left = 0, right, top, bottom
        var isHorizontal: Bool {
            [.left, .right].contains(self)
        }

        var isVertical: Bool {
            [.top, .bottom].contains(self)
        }
    }

    open var position: ImagePosition = .left {
        didSet {
            if oldValue != self.position {
                self.setNeedsLayout()
            }
        }
    }

    open var spacing: CGFloat = .zero {
        didSet {
            if oldValue != self.spacing {
                self.setNeedsLayout()
            }
        }
    }

    override open var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
        didSet {
            if oldValue != self.contentVerticalAlignment {
                self.setNeedsLayout()
            }
        }
    }

    override open var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        didSet {
            if oldValue != self.contentHorizontalAlignment {
                self.setNeedsLayout()
            }
        }
    }

    private var imageSize: CGSize {
        self.imageView?.dvt.size ?? .zero
    }

    private var titleSize: CGSize {
        return self.titleLabel?.sizeThatFits(.zero) ?? .zero
    }

    override open var imageView: UIImageView? {
        self.value(forKey: "_imageView") as? UIImageView
    }

    private var size: CGSize = .zero

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }

    open func didInitialize() {
    }

    override open func setNeedsLayout() {
        if !self.translatesAutoresizingMaskIntoConstraints {
            // 如果是自动布局，更新的时候将原计算出来的大小设置失效
            self.invalidateIntrinsicContentSize()
        }
        super.setNeedsLayout()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.size = self.frame.size
        self.calculateSubviewsFrame()
    }

    private func calculateSubviewsFrame() {
        let w = self.size.width
        let h = self.size.height

        var tx = self.titleLabel?.frame.origin.x ?? 0
        var ty = self.titleLabel?.frame.origin.y ?? 0
        var tw = self.titleSize.width
        var th = self.titleSize.height

        var ix = self.imageView?.frame.origin.x ?? 0
        var iy = self.imageView?.frame.origin.y ?? 0
        var iw = self.imageSize.width
        var ih = self.imageSize.height

        let top = self.contentEdgeInsets.top
        let left = self.contentEdgeInsets.left
        let bottom = self.contentEdgeInsets.bottom
        let right = self.contentEdgeInsets.right

        let lspacing = max(self.spacing, max(self.titleEdgeInsets.left, self.imageEdgeInsets.right))
        let rspacing = max(self.spacing, max(self.titleEdgeInsets.right, self.imageEdgeInsets.left))
        let tspacing = max(self.spacing, max(self.titleEdgeInsets.top, self.imageEdgeInsets.bottom))
        let bspacing = max(self.spacing, max(self.titleEdgeInsets.bottom, self.imageEdgeInsets.top))

        switch self.contentVerticalAlignment {
            case .center:
                if self.position.isVertical {
                    let ct = ((h - (top + bottom) - ih - th) - (self.position == .top ? tspacing : bspacing)) / 2
                    if self.position == .top {
                        iy = max(top, max(ct, self.imageEdgeInsets.top))
                        ty = iy + ih + tspacing
                    } else {
                        ty = max(top, max(ct, self.titleEdgeInsets.top))
                        iy = ty + th + bspacing
                    }
                } else {
                    ty = max(max(top, self.titleEdgeInsets.top), (h - th) / 2)
                    iy = max(max(top, self.imageEdgeInsets.top), (h - ih) / 2)
                }
            case .top:
                if self.position.isVertical {
                    if self.position == .top {
                        iy = max(top, self.imageEdgeInsets.top)
                        ty = iy + ih + tspacing
                    } else {
                        ty = max(top, self.titleEdgeInsets.top)
                        iy = ty + th + bspacing
                    }
                } else {
                    ty = max(top, self.titleEdgeInsets.top)
                    iy = max(top, self.imageEdgeInsets.top)
                }
            case .bottom:
                if self.position.isVertical {
                    if self.position == .top {
                        ty = h - th - max(bottom, self.titleEdgeInsets.bottom)
                        iy = ty - ih + tspacing
                    } else {
                        iy = h - ih - max(bottom, self.imageEdgeInsets.bottom)
                        ty = iy - th - bspacing
                    }
                } else {
                    ty = h - th - max(bottom, self.titleEdgeInsets.bottom)
                    iy = h - ih - max(bottom, self.imageEdgeInsets.bottom)
                }

            case .fill:
                if self.position == .top {
                    let sh = (h - max(top, self.imageEdgeInsets.top) - max(bottom, self.titleEdgeInsets.bottom) - tspacing) / (ih + th)
                    ih = ih * sh
                    th = th * sh
                    iy = max(top, self.imageEdgeInsets.top)
                    ty = iy + ih + tspacing
                } else if self.position == .bottom {
                    let sh = (h - max(bottom, self.imageEdgeInsets.bottom) - max(top, self.titleEdgeInsets.top) - bspacing) / (ih + th)
                    ih = ih * sh
                    th = th * sh
                    ty = max(top, self.titleEdgeInsets.top)
                    iy = ty + th + bspacing
                } else {
                    th = h - max(bottom, self.titleEdgeInsets.bottom) - max(top, self.titleEdgeInsets.top)
                    ih = h - max(bottom, self.imageEdgeInsets.bottom) - max(top, self.imageEdgeInsets.top)
                    ty = max(top, self.titleEdgeInsets.top)
                    iy = max(top, self.imageEdgeInsets.top)
                }
            @unknown default:
                break
        }

        switch self.contentHorizontalAlignment {
            case .center:
                if self.position.isVertical {
                    tx = max(max(left, self.titleEdgeInsets.left), (w - tw) / 2)
                    ix = max(max(left, self.imageEdgeInsets.left), (w - iw) / 2)
                } else {
                    let cl = ((w - (left + right) - iw - tw) - (self.position == .left ? lspacing : rspacing)) / 2
                    if self.position == .left {
                        ix = max(left, max(cl, self.imageEdgeInsets.left))
                        tx = ix + iw + lspacing
                    } else {
                        tx = max(left, max(cl, self.titleEdgeInsets.left))
                        ix = tx + tw + rspacing
                    }
                }
            case .left, .leading:
                if self.position.isVertical {
                    tx = max(left, self.titleEdgeInsets.left)
                    ix = max(left, self.imageEdgeInsets.left)
                } else {
                    if self.position == .left {
                        ix = max(left, self.imageEdgeInsets.left)
                        tx = ix + iw + lspacing
                    } else {
                        tx = max(left, self.titleEdgeInsets.left)
                        ix = tx + tw + rspacing
                    }
                }
            case .right, .trailing:
                if self.position.isVertical {
                    tx = w - tw - max(right, self.titleEdgeInsets.right)
                    ix = w - iw - max(right, self.imageEdgeInsets.right)
                } else {
                    if self.position == .right {
                        ix = w - iw - max(right, self.imageEdgeInsets.right)
                        tx = ix - tw - lspacing
                    } else {
                        tx = w - tw - max(right, self.titleEdgeInsets.right)
                        ix = tx - iw - rspacing
                    }
                }
            case .fill:
                if self.position == .left {
                    let sw = (w - max(left, self.imageEdgeInsets.left) - max(right, self.titleEdgeInsets.right) - lspacing) / (iw + tw)
                    iw = iw * sw
                    tw = tw * sw
                    ix = max(left, self.imageEdgeInsets.left)
                    tx = ix + iw + lspacing
                } else if self.position == .right {
                    let sw = (w - max(right, self.imageEdgeInsets.right) - max(left, self.titleEdgeInsets.left) - rspacing) / (iw + tw)
                    iw = iw * sw
                    tw = tw * sw
                    tx = max(left, self.titleEdgeInsets.left)
                    ix = tx + tw + rspacing
                } else {
                    tw = w - max(left, self.titleEdgeInsets.left) - max(right, self.titleEdgeInsets.right)
                    iw = h - max(left, self.imageEdgeInsets.left) - max(right, self.imageEdgeInsets.right)
                    tx = max(left, self.titleEdgeInsets.left)
                    ix = max(left, self.imageEdgeInsets.left)
                }
            @unknown default:
                break
        }

        self.titleLabel?.frame = CGRect(x: tx, y: ty, width: tw, height: th)
        self.imageView?.frame = CGRect(x: ix, y: iy, width: iw, height: ih)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        self.titleLabel?.sizeThatFits(.zero)
        return super.sizeThatFits(size)
    }

    override open func sizeToFit() {
        super.sizeToFit()
    }

    override open func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        self.sizeToFit()
    }

    override open func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        self.sizeToFit()
    }

    /// 如果是自动布局会走到这里来，计算其大小
    override open var intrinsicContentSize: CGSize {
        self.calculateSize(super.intrinsicContentSize)
        return self.size
    }

    private func calculateSize(_ size: CGSize) {
        var w = size.width
        var h = size.height
        let lspacing = max(self.spacing, max(self.titleEdgeInsets.left, self.imageEdgeInsets.right))
        let rspacing = max(self.spacing, max(self.titleEdgeInsets.right, self.imageEdgeInsets.left))
        let tspacing = max(self.spacing, max(self.titleEdgeInsets.top, self.imageEdgeInsets.bottom))
        let bspacing = max(self.spacing, max(self.titleEdgeInsets.bottom, self.imageEdgeInsets.top))

        let top = self.contentEdgeInsets.top
        let left = self.contentEdgeInsets.left
        let bottom = self.contentEdgeInsets.bottom
        let right = self.contentEdgeInsets.right

        let titleSize = self.titleSize
        let imageSize = self.imageSize

        if self.position.isHorizontal {
            w = titleSize.width + imageSize.width
            if self.position == .right {
                w += (rspacing + max(left, self.titleEdgeInsets.left) + max(right, self.imageEdgeInsets.right))
            } else {
                w += (lspacing + max(left, self.imageEdgeInsets.left) + max(right, self.titleEdgeInsets.right))
            }
            h = max(max(top, self.imageEdgeInsets.top) + imageSize.height + max(bottom, self.imageEdgeInsets.bottom), max(top, self.titleEdgeInsets.top) + titleSize.height + max(bottom, self.titleEdgeInsets.bottom))
        } else {
            h = titleSize.height + imageSize.height
            if self.position == .bottom {
                h += (bspacing + max(top, self.titleEdgeInsets.top) + max(bottom, self.imageEdgeInsets.bottom))
            } else {
                h += (tspacing + max(top, self.imageEdgeInsets.top) + max(bottom, self.titleEdgeInsets.bottom))
            }
            w = max(max(left, self.imageEdgeInsets.left) + imageSize.width + max(right, self.imageEdgeInsets.right), max(left, self.titleEdgeInsets.left) + titleSize.width + max(right, self.titleEdgeInsets.right))
        }
        self.size = CGSize(width: w, height: h)
    }
}
