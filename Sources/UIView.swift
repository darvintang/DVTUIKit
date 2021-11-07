//
//  UIView.swift
//
//
//  Created by darvintang on 2021/10/11.
//

import DVTFoundation
import ObjectiveC
import UIKit

extension UIView: NameSpace {}
public extension BaseWrapper where DT: UIView {
    var origin: CGPoint {
        set { self.base.frame = CGRect(origin: newValue, size: self.size) }
        get { self.base.frame.origin }
    }

    var size: CGSize {
        set { self.base.frame = CGRect(origin: self.origin, size: newValue) }
        get { self.base.frame.size }
    }

    var x: CGFloat {
        set { self.origin = CGPoint(x: newValue, y: self.y) }
        get { self.origin.x }
    }

    var y: CGFloat {
        set { self.origin = CGPoint(x: self.x, y: newValue) }
        get { self.origin.y }
    }

    var maxX: CGFloat {
        self.x + self.width
    }

    var maxY: CGFloat {
        self.y + self.height
    }

    var width: CGFloat {
        set { self.size = CGSize(width: newValue, height: self.height) }
        get { self.size.width }
    }

    var height: CGFloat {
        set { self.size = CGSize(width: self.width, height: newValue) }
        get { self.size.height }
    }

    var cornerRadius: CGFloat {
        set { self.base.layer.cornerRadius = newValue; self.base.clipsToBounds = newValue > 0 }
        get { self.base.layer.cornerRadius }
    }

    func addCorner(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.base.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.base.bounds
        maskLayer.path = maskPath.cgPath
        self.base.layer.mask = maskLayer
    }
}

private var DVT_UIViewClickBlockKey: Int8 = 0
extension UIView {
    var dvt_clickBlock: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &DVT_UIViewClickBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let block = objc_getAssociatedObject(self, &DVT_UIViewClickBlockKey) {
                return block as? () -> Void
            }
            return nil
        }
    }

    @objc func dvt_didClickSelf() {
        self.dvt_clickBlock?()
    }
}

public extension BaseWrapper where DT: UIView {
    mutating func addTap(_ taps: Int = 1, touchs: Int = 1, block clickBlock: @escaping (DT?) -> Void) {
        self.base.isUserInteractionEnabled = true
        let view = self.base
        self.base.dvt_clickBlock = { () -> Void in
            clickBlock(view)
        }
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = taps
        tap.numberOfTouchesRequired = touchs
        tap.addTarget(self.base, action: #selector(self.base.dvt_didClickSelf))
        self.base.addGestureRecognizer(tap)
    }
}
