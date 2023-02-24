//
//  DVTUIButton.swift
//  DVTUIKit_Button
//
//  Created by darvin on 2022/8/8.
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

/// 可以设置图片位置的按钮
///
/// 重新定义了 UIButton.titleEdgeInests、imageEdgeInsets、contentEdgeInsets 这三者的布局逻辑，
/// 会把 titleEdgeInests 和 imageEdgeInsets 也考虑在内，以使这三个接口的使用更符合直觉。
///
///
/// 通过UIButtonConfiguration初始化的按钮设置图片方向按钮大小未验证
///
open class DVTUIButton: UIButton {
    // MARK: Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }

    open func didInitialize() { assert(self.buttonType == .custom, "只支持UIButton.ButtonType.custom") }

    // MARK: Open
    open var position: ImagePosition = .left {
        didSet {
            if oldValue != self.position { self.setNeedsLayout() }
        }
    }

    @IBInspectable open var spacing: CGFloat = .zero {
        didSet {
            if oldValue != self.spacing { self.setNeedsLayout() }
        }
    }

    override open var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
        didSet {
            if oldValue != self.contentVerticalAlignment { self.setNeedsLayout() }
        }
    }

    override open var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        didSet {
            if oldValue != self.contentHorizontalAlignment { self.setNeedsLayout() }
        }
    }

    override open var imageView: UIImageView? { self.value(forKey: "_imageView") as? UIImageView }

    /// 如果是自动布局会走到这里来，计算其大小
    override open var intrinsicContentSize: CGSize {
        self.calculateSize(super.intrinsicContentSize)
    }

    override open func setNeedsLayout() {
        // 如果是自动布局，更新的时候将原计算出来的大小设置失效
        if !self.translatesAutoresizingMaskIntoConstraints { self.invalidateIntrinsicContentSize() }
        super.setNeedsLayout()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if self.needUpdatePosition { self.calculateSubviewsFrame() }
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        self.titleLabel?.sizeThatFits(.zero)
        return super.sizeThatFits(size)
    }

    override open func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        self.sizeToFit()
    }

    override open func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        self.sizeToFit()
    }

    // MARK: Public
    @objc
    public enum ImagePosition: Int {
        case top = 0, left, bottom, right

        // MARK: Internal
        var isHorizontal: Bool { [.left, .right].contains(self) }

        var isVertical: Bool { [.top, .bottom].contains(self) }
    }

    ///  当空间不够的时候是否确保图片不被压缩
    public var ensureImage = true

    // MARK: Private
    private var size: CGSize = .zero

    private var imageSize: CGSize { (self.image(for: self.state) ?? self.image(for: .normal))?.size ?? .zero }

    private var titleSize: CGSize {
        self.titleLabel?.text = self.title(for: self.state) ?? self.title(for: .normal)
        return self.titleLabel?.sizeThatFits(.zero) ?? .zero
    }

    private var needUpdatePosition: Bool { self.imageSize != .zero && self.titleSize != .zero }

    private func calculateSubviewsFrame() {
        let contentFrame = CGRect(origin: CGPoint(x: self.contentEdgeInsets.left,
                                                  y: self.contentEdgeInsets.top),
                                  size: CGSize(width: self.dvt.width - (self.contentEdgeInsets.left + self.contentEdgeInsets.right),
                                               height: self.dvt.height - (self.contentEdgeInsets.top + self.contentEdgeInsets.bottom)))
        let contentOrigin = contentFrame.origin
        let contentSize = contentFrame.size

        var tx: CGFloat = self.titleLabel?.frame.origin.x ?? 0
        var ty: CGFloat = self.titleLabel?.frame.origin.y ?? 0
        var tw = self.titleSize.width
        var th = self.titleSize.height

        var ix: CGFloat = self.imageView?.frame.origin.x ?? 0
        var iy: CGFloat = self.imageView?.frame.origin.y ?? 0
        var iw = self.imageSize.width
        var ih = self.imageSize.height

        let lspacing = max(self.spacing, max(self.titleEdgeInsets.left, self.imageEdgeInsets.right))
        let rspacing = max(self.spacing, max(self.titleEdgeInsets.right, self.imageEdgeInsets.left))
        let tspacing = max(self.spacing, max(self.titleEdgeInsets.top, self.imageEdgeInsets.bottom))
        let bspacing = max(self.spacing, max(self.titleEdgeInsets.bottom, self.imageEdgeInsets.top))

        tw = min(contentSize.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right, tw)
        iw = min(contentSize.width - self.imageEdgeInsets.left - self.imageEdgeInsets.right, iw)
        th = min(contentSize.height - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom, th)
        ih = min(contentSize.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom, ih)

        if self.position.isHorizontal {
            switch self.contentVerticalAlignment {
                case .center:
                    iy = max(self.imageEdgeInsets.top, (contentSize.height - ih) / 2)
                    ty = max(self.titleEdgeInsets.top, (contentSize.height - th) / 2)
                case .top:
                    iy = self.imageEdgeInsets.top
                    ty = self.titleEdgeInsets.top
                case .bottom:
                    iy = contentSize.height - ih - self.imageEdgeInsets.bottom
                    ty = contentSize.height - ih - self.titleEdgeInsets.bottom
                default:
                    break
            }

            var offsetx: CGFloat = 0
            switch self.contentHorizontalAlignment {
                case .center, .fill:
                    offsetx = max(0, (contentSize.width - iw - tw -
                            (self
                                .position == .left ? (self.imageEdgeInsets.left + self.titleEdgeInsets.right + lspacing) :
                                (self.imageEdgeInsets.right + self.titleEdgeInsets.left + rspacing))) / 2)
                case .leading, .left:
                    offsetx = 0
                case .right, .trailing:
                    offsetx = max(0, contentSize.width - iw - tw -
                        (self
                            .position == .left ? (self.imageEdgeInsets.left + self.titleEdgeInsets.right + lspacing) :
                            (self.imageEdgeInsets.right + self.titleEdgeInsets.left + rspacing)))
                default:
                    break
            }

            if self.position == .left {
                ix = offsetx + self.imageEdgeInsets.left
                let compress = contentSize.width < (self.imageEdgeInsets.left + iw + lspacing + tw + self.titleEdgeInsets.right)
                if !compress { tx = ix + iw + lspacing }
                else {
                    if self.contentHorizontalAlignment == .fill {
                        let scale = contentSize.width / (self.imageEdgeInsets.left + iw + lspacing + tw + self.titleEdgeInsets.right)
                        iw *= scale
                        tw *= scale
                        ix = self.imageEdgeInsets.left
                        tx = ix + iw + lspacing
                    } else {
                        if self.ensureImage {
                            tx = ix + iw + lspacing
                            tw = contentSize.width - tx - self.titleEdgeInsets.right - offsetx
                        } else {
                            tx = contentSize.width - tw - self.titleEdgeInsets.right - offsetx
                            iw = tx - lspacing
                        }
                    }
                }

            } else {
                tx = offsetx + self.titleEdgeInsets.left
                let compress = contentSize.width < (self.imageEdgeInsets.right + iw + rspacing + tw + self.titleEdgeInsets.left)
                if !compress { ix = tx + tw + rspacing }
                else {
                    if self.contentHorizontalAlignment == .fill {
                        let scale = contentSize.width / (self.imageEdgeInsets.right + iw + rspacing + tw + self.titleEdgeInsets.left)
                        iw *= scale
                        tw *= scale
                        tx = self.titleEdgeInsets.left
                        ix = tx + tw + rspacing
                    } else {
                        if self.ensureImage {
                            ix = contentSize.width - iw - self.imageEdgeInsets.right - offsetx
                            tw = ix - rspacing
                        } else {
                            ix = tx + tw + rspacing
                            iw = contentSize.width - self.imageEdgeInsets.right - offsetx - ix
                        }
                    }
                }
            }
        }

        if self.position.isVertical {
            switch self.contentHorizontalAlignment {
                case .center:
                    tx = max(self.titleEdgeInsets.left, (contentSize.width - tw) / 2)
                    ix = max(self.imageEdgeInsets.left, (contentSize.width - iw) / 2)
                case .leading, .left:
                    tx = self.titleEdgeInsets.left
                    ix = self.imageEdgeInsets.left
                case .right, .trailing:
                    tx = contentSize.width - tw - self.titleEdgeInsets.right
                    ix = contentSize.width - iw - self.imageEdgeInsets.right
                default:
                    break
            }
            var offsety: CGFloat = 0
            switch self.contentVerticalAlignment {
                case .center, .fill:
                    offsety = max(0, (contentSize.height - ih - th -
                            (self
                                .position == .top ? (self.imageEdgeInsets.top + self.titleEdgeInsets.bottom + tspacing) :
                                (self.imageEdgeInsets.bottom + self.titleEdgeInsets.top + bspacing))) / 2)
                case .top:
                    offsety = 0
                case .bottom:
                    offsety = max(0, contentSize.height - ih - th -
                        (self
                            .position == .top ? (self.imageEdgeInsets.top + self.titleEdgeInsets.bottom + tspacing) :
                            (self.imageEdgeInsets.bottom + self.titleEdgeInsets.top + bspacing)))
                default:
                    break
            }
            if self.position == .top {
                iy = offsety + self.imageEdgeInsets.top
                let compress = contentSize.height < (self.imageEdgeInsets.top + ih + tspacing + th + self.titleEdgeInsets.bottom)
                if !compress { ty = iy + ih + tspacing }
                else {
                    if self.contentVerticalAlignment == .fill {
                        let scale = contentSize.height / (self.imageEdgeInsets.top + ih + tspacing + th + self.titleEdgeInsets.bottom)
                        ih *= scale
                        th *= scale
                        iy = self.imageEdgeInsets.top
                        ty = iy + ih + tspacing
                    } else {
                        if self.ensureImage {
                            ty = iy + ih + tspacing
                            th = contentSize.height - ty - self.titleEdgeInsets.bottom - offsety
                        } else {
                            ty = contentSize.height - th - self.titleEdgeInsets.bottom - offsety
                            ih = ty - tspacing
                        }
                    }
                }

            } else {
                ty = offsety + self.titleEdgeInsets.top
                let compress = contentSize.height < (self.imageEdgeInsets.bottom + ih + bspacing + th + self.titleEdgeInsets.top)
                if !compress { iy = ty + th + bspacing }
                else {
                    if self.contentVerticalAlignment == .fill {
                        let scale = contentSize.height / (self.imageEdgeInsets.bottom + ih + bspacing + th + self.titleEdgeInsets.top)
                        ih *= scale
                        th *= scale
                        ty = self.titleEdgeInsets.top
                        iy = ty + th + bspacing
                    } else {
                        if self.ensureImage {
                            iy = contentSize.height - ih - self.imageEdgeInsets.bottom - offsety
                            th = iy - bspacing
                        } else {
                            iy = ty + th + bspacing
                            ih = contentSize.height - self.imageEdgeInsets.bottom - offsety - iy
                        }
                    }
                }
            }
        }

        self.titleLabel?.frame = CGRect(x: tx + contentOrigin.x, y: ty + contentOrigin.y, width: tw, height: th)
        self.imageView?.frame = CGRect(x: ix + contentOrigin.x, y: iy + contentOrigin.y, width: iw, height: ih)
    }

    private func calculateSize(_ size: CGSize) -> CGSize {
        var width = size.width
        var height = size.height

        if self.position.isHorizontal {
            height += (max(self.titleEdgeInsets.top, self.imageEdgeInsets.top) + max(self.titleEdgeInsets.bottom, self.imageEdgeInsets.bottom))
            if self.needUpdatePosition {
                if self.position == .left {
                    width +=
                        (self.imageEdgeInsets.left + max(self.spacing, max(self.imageEdgeInsets.right, self.titleEdgeInsets.left)) + self.titleEdgeInsets.right)
                } else {
                    width +=
                        (self.imageEdgeInsets.right + max(self.spacing, max(self.imageEdgeInsets.left, self.titleEdgeInsets.right)) + self.titleEdgeInsets.left)
                }
            } else if self.imageSize == .zero {
                width += (self.titleEdgeInsets.left + self.titleEdgeInsets.right)
            } else {
                width += (self.imageEdgeInsets.left + self.imageEdgeInsets.right)
            }
        } else {
            width = max(self.imageSize.width, self.titleSize.width) + self.contentEdgeInsets.left + self.contentEdgeInsets.right
            height = self.imageSize.height + self.titleSize.height + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom

            width += (max(self.titleEdgeInsets.left, self.imageEdgeInsets.left) + max(self.titleEdgeInsets.right, self.imageEdgeInsets.right))
            if self.needUpdatePosition {
                if self.position == .top {
                    height +=
                        (self.imageEdgeInsets.top + max(self.spacing, max(self.imageEdgeInsets.bottom, self.titleEdgeInsets.top)) + self.titleEdgeInsets.bottom)
                } else {
                    height +=
                        (self.imageEdgeInsets.bottom + max(self.spacing, max(self.imageEdgeInsets.top, self.titleEdgeInsets.bottom)) + self.titleEdgeInsets.top)
                }
            } else if self.imageSize == .zero {
                height += (self.titleEdgeInsets.top + self.titleEdgeInsets.bottom)
            } else {
                height += (self.imageEdgeInsets.top + self.imageEdgeInsets.bottom)
            }
        }

        return CGSize(width: width, height: height)
    }
}
