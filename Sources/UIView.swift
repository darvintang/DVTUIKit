//
//  UIView.swift
//
//
//  Created by darvintang on 2021/10/11.
//

import DVTFoundation
import UIKit

extension UIView: NameSpace {}

public extension BaseWrapper where BaseType: UIView {
    var origin: CGPoint {
        get { self.base.frame.origin }
        set { self.base.frame = CGRect(origin: newValue, size: self.size) }
    }

    var size: CGSize {
        get { self.base.frame.size }
        set { self.base.frame = CGRect(origin: self.origin, size: newValue) }
    }

    var x: CGFloat {
        get { self.origin.x }
        set { self.origin = CGPoint(x: newValue, y: self.y) }
    }

    var y: CGFloat {
        get { self.origin.y }
        set { self.origin = CGPoint(x: self.x, y: newValue) }
    }

    var maxX: CGFloat {
        get { self.x + self.width }
        set { if newValue > self.x { self.width = newValue - self.x }}
    }

    var maxY: CGFloat {
        get { self.y + self.height }
        set { if newValue > self.y { self.height = newValue - self.y }}
    }

    var width: CGFloat {
        get { self.size.width }
        set { self.size = CGSize(width: newValue, height: self.height) }
    }

    var height: CGFloat {
        get { self.size.height }
        set { self.size = CGSize(width: self.width, height: newValue) }
    }

    var cornerRadius: CGFloat {
        get { self.base.layer.cornerRadius }
        set { self.base.layer.cornerRadius = newValue; self.base.clipsToBounds = true }
    }

    func addCorner(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.base.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.base.bounds
        maskLayer.path = maskPath.cgPath
        self.base.layer.mask = maskLayer
    }
}
