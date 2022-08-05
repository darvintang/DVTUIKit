//
//  CGRect.swift
//  DVTUIKit
//
//  Created by darvin on 2022/8/6.
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

import DVTFoundation
import UIKit

extension CGRect: NameSpace {}
public extension BaseWrapper where BaseType == CGRect {
    static var screenBounds: CGRect {
        return UIScreen.main.bounds
    }

    /// 按比例计算新的
    func to(rate scale: CGFloat) -> CGRect {
        CGRect(x: self.base.origin.x * scale, y: self.base.origin.y * scale, width: self.base.size.width * scale, height: self.base.size.height * scale)
    }

    /// 交换XY之后的结果
    var swapXY: CGRect {
        CGRect(origin: CGPoint(x: self.base.origin.y, y: self.base.origin.x), size: self.base.size)
    }

    var center: CGPoint {
        CGPoint(x: self.base.midX, y: self.base.midY)
    }

    var x: CGFloat {
        self.base.origin.x
    }

    var y: CGFloat {
        self.base.origin.y
    }

    /// 边界转换
    /// - Parameters:
    ///   - from: 参考
    ///   - to: 置入
    ///   - mode: 内容模式
    /// - Returns: 结果
    func into(from: CGRect, fromScale: CGFloat, to: CGRect, mode: UIView.ContentMode) -> CGRect {
        let showSize = to.size
        let oldSize = from.size

        let rect = self.base
        var scale: CGFloat = fromScale
        var offsetX: CGFloat = (showSize.width - oldSize.width * scale) / 2
        var offsetY: CGFloat = (showSize.height - oldSize.height * scale) / 2

        func updateOffset() {
            offsetX = (showSize.width - oldSize.width * scale) / 2
            offsetY = (showSize.height - oldSize.height * scale) / 2
        }
        switch mode {
            case .center:
                break
            case .scaleToFill:
                // 变形，单独计算
                let scalew = showSize.width / oldSize.width
                let scaleh = showSize.height / oldSize.height
                return CGRect(x: rect.dvt.x * scalew, y: rect.dvt.y * scaleh, width: rect.width * scalew, height: rect.height * scaleh)
            case .scaleAspectFit:
                scale = min(showSize.width / oldSize.width, showSize.height / oldSize.height)
                updateOffset()
            case .scaleAspectFill:
                scale = max(showSize.width / oldSize.width, showSize.height / oldSize.height)
                updateOffset()
            case .redraw:
                return .zero
            case .top:
                offsetY = 0
            case .bottom:
                offsetY = (showSize.height - oldSize.height * scale)
            case .left:
                offsetX = 0
            case .right:
                offsetX = (showSize.width - oldSize.width * scale)
            case .topLeft:
                offsetX = 0
                offsetY = 0
            case .topRight:
                offsetY = 0
                offsetX = (showSize.width - oldSize.width * scale)
            case .bottomLeft:
                offsetY = (showSize.height - oldSize.height * scale)
                offsetX = 0
            case .bottomRight:
                offsetY = (showSize.height - oldSize.height * scale)
                offsetX = (showSize.width - oldSize.width * scale)
            @unknown default:
                break
        }

        return rect.dvt.to(rate: scale).offsetBy(dx: offsetX, dy: offsetY)
    }
}
