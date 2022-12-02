//
//  DVTAlignCollectionViewFlowLayout.swift
//  DVTUIKit
//
//  Created by darvin on 2022/11/17.
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

extension UICollectionView {
    public static let elementKindSectionBackground = "DVTUIKit.UICollectionView.ElementKindSectionBackground"
}

public protocol DPIDecorationCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    associatedtype DecorationType: Equatable
    /// 装饰控件的属性设置
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, decorationLayoutAttributeForSectionAt section: Int) -> UICollectionViewLayoutAttributes?
    /// 装饰控件的装饰属性
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundDecorationForSectionAt section: Int) -> DecorationType?
}

extension DPIDecorationCollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, decorationLayoutAttributeForSectionAt section: Int) -> UICollectionViewLayoutAttributes? {
        let attribute = DVTDecorationCollectionViewLayoutAttributes<DecorationType>(forDecorationViewOfKind: UICollectionView.elementKindSectionBackground, with: IndexPath(item: 0, section: section))
        attribute.extAttribute = self.collectionView(collectionView, layout: collectionViewLayout, backgroundDecorationForSectionAt: section)
        return attribute
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundDecorationForSectionAt section: Int) -> DecorationType? {
        nil
    }
}

/// UICollectionView的装饰类，会发生复用，UI更新请在 extAttribute 的 didSet 内完成
open class DVTDecorationCollectionReusableView<DecorationType: Equatable>: UICollectionReusableView {
    open var extAttribute: DecorationType?
    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attribute = layoutAttributes as? DVTDecorationCollectionViewLayoutAttributes<DecorationType> {
            if let color = attribute.extAttribute as? UIColor {
                self.backgroundColor = color
            }
            self.extAttribute = attribute.extAttribute
        }
    }
}

open class DVTDecorationCollectionViewLayoutAttributes<DecorationType: Equatable>: UICollectionViewLayoutAttributes {
    open var extAttribute: DecorationType?
    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone)
        (copy as? DVTDecorationCollectionViewLayoutAttributes)?.extAttribute = self.extAttribute
        return copy
    }

    override open func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? DVTDecorationCollectionViewLayoutAttributes else {
            return false
        }
        if self.extAttribute != obj.extAttribute {
            return false
        } else {
            return super.isEqual(object)
        }
    }

    public convenience init(forDecorationViewOfKind kind: String = UICollectionView.elementKindSectionBackground, with section: Int) {
        self.init(forDecorationViewOfKind: kind, with: IndexPath(item: 0, section: section))
    }
}

extension UICollectionView {
    public func register<DecorationType: Equatable>(_ viewClass: DVTDecorationCollectionReusableView<DecorationType>.Type, forDecorationViewOf kind: String) {
        if let layout = self.collectionViewLayout as? DVTAlignCollectionViewFlowLayout {
            layout.register(viewClass, forDecorationViewOf: kind)
        }
    }
}

/// 调整cell对其方式，必须确保cell等宽或等高(水平等高，垂直等宽)，为UICollectionView分段背景添加装饰视图
open class DVTAlignCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private var decorationViewAttrs: [UICollectionViewLayoutAttributes] = []

    /// 是否启用分组背景
    private var useDecoration: Bool {
        !self.kinds.isEmpty
    }

    public enum AlignType {
        case none, left, center, right
    }

    open var type: AlignType = .none

    public convenience init(_ type: AlignType) {
        self.init()
        self.type = type
    }

    private var kinds: [String] = []

    public func register<DecorationType: Equatable>(_ viewClass: DVTDecorationCollectionReusableView<DecorationType>.Type, forDecorationViewOf kind: String) {
        self.register(viewClass, forDecorationViewOfKind: kind)
        self.kinds.append(kind)
    }

    override open func prepare() {
        super.prepare()
        guard self.useDecoration, let collectionView = self.collectionView, let delegate = collectionView.delegate as? (any DPIDecorationCollectionViewDelegateFlowLayout) else {
            return
        }
        let numberOfSections = collectionView.numberOfSections

        for section in 0 ..< numberOfSections {
            guard let numberOfItems = self.collectionView?.numberOfItems(inSection: section), numberOfItems > 0 else {
                continue
            }
            guard let firstItem = self.layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                  let lastItem = self.layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section))
            else {
                continue
            }
            let sectionInset = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? self.sectionInset
            var sectionFrame = firstItem.frame.union(lastItem.frame)
            sectionFrame.origin.x -= sectionInset.left
            sectionFrame.origin.y -= sectionInset.top
            if self.scrollDirection == .horizontal {
                sectionFrame.size.width += sectionInset.left + sectionInset.right
                sectionFrame.size.height = collectionView.dvt.height - collectionView.contentInset.top - collectionView.contentInset.bottom
            } else {
                sectionFrame.size.width = collectionView.dvt.width - collectionView.contentInset.left - collectionView.contentInset.left
                sectionFrame.size.height += sectionInset.top + sectionInset.bottom
            }
            if let attribute = delegate.collectionView(collectionView, layout: self, decorationLayoutAttributeForSectionAt: section), let kind = attribute.representedElementKind, self.kinds.contains(kind) {
                attribute.frame = sectionFrame
                attribute.zIndex = -1
                self.decorationViewAttrs.append(attribute)
            }
        }
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElements(in: rect)
        if self.useDecoration {
            layoutAttributes?.append(contentsOf: self.decorationViewAttrs.filter { attributes in rect.intersects(attributes.frame) })
        }
        if self.type == .none {
            return layoutAttributes
        }
        var attributes = [UICollectionViewLayoutAttributes]()

        for row in 0 ..< (layoutAttributes?.count ?? 0) {
            guard let currentAttribute = layoutAttributes?[row], currentAttribute.representedElementKind == nil else {
                continue
            }
            let previousAttribute = row == 0 ? nil : layoutAttributes?[row - 1]
            let nextAttribute = row + 1 == (layoutAttributes?.count ?? 0) ? nil : layoutAttributes?[row + 1]
            attributes.append(currentAttribute)

            let previous = self.scrollDirection == .horizontal ? (previousAttribute?.frame.minX) ?? 0 : (previousAttribute?.frame.minY ?? 0)
            let current = self.scrollDirection == .horizontal ? currentAttribute.frame.minX : currentAttribute.frame.minY
            let next = self.scrollDirection == .horizontal ? (nextAttribute?.frame.minX) ?? 0 : (nextAttribute?.frame.minY ?? 0)
            // 将分组头，装饰等控件排除
            if currentAttribute.representedElementKind == nil {
                attributes.removeAll(where: { $0 == currentAttribute })
            }
            // 如果当前cell是单独一行 // 最后一行 // 如果下一个cell在本行，当前的cell是本行最后一个，开始调整Frame位置
            if current != previous && current != next || nextAttribute == nil || current != next {
                self.setCellFrame(attributes)
                attributes.removeAll()
            }
        }

        return layoutAttributes
    }

    open func setCellFrame(_ attributes: [UICollectionViewLayoutAttributes]) {
        guard let collectionView = self.collectionView, let section = attributes.first?.indexPath.section else {
            return
        }

        let sectionInset = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? self.sectionInset

        var newY: CGFloat = -1
        var newX: CGFloat = -1
        let rowSumCellWidth = attributes.reduce(0) { partialResult, attribute in
            partialResult + attribute.frame.width
        }
        let rowSumCellHeight = attributes.reduce(0) { partialResult, attribute in
            partialResult + attribute.frame.height
        }
        // 确定第一个的起始位置
        switch self.type {
            case .left:
                newY = sectionInset.top
                newX = sectionInset.left
            case .center:
                newY = (collectionView.dvt.height - rowSumCellHeight - CGFloat(attributes.count - 1) * self.minimumInteritemSpacing - sectionInset.top - sectionInset.bottom) / 2 + sectionInset.top
                newX = (collectionView.dvt.width - rowSumCellWidth - CGFloat(attributes.count - 1) * self.minimumInteritemSpacing - sectionInset.left - sectionInset.right) / 2 + sectionInset.left
            case .right:
                newY = collectionView.dvt.height - rowSumCellHeight - CGFloat(attributes.count - 1) * self.minimumInteritemSpacing - sectionInset.top - sectionInset.bottom + sectionInset.top
                newX = collectionView.dvt.width - rowSumCellWidth - CGFloat(attributes.count - 1) * self.minimumInteritemSpacing - sectionInset.left - sectionInset.right + sectionInset.left
            default:
                break
        }

        if self.scrollDirection == .horizontal, newY >= 0 {
            for attribute in attributes {
                var newFrame = attribute.frame
                newFrame.origin.y = newY
                attribute.frame = newFrame
                newY = newFrame.maxY + self.minimumLineSpacing
            }
        } else if newX >= 0 {
            for attribute in attributes {
                var newFrame = attribute.frame
                newFrame.origin.x = newX
                attribute.frame = newFrame
                newX = newFrame.maxX + self.minimumInteritemSpacing
            }
        }
    }
}
