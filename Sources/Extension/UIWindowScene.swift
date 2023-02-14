//
//  UIWindowScene.swift
//
//
//  Created by darvin on 2022/9/14.
//

import DVTFoundation
import UIKit

extension UIWindowScene: NameSpace {
    public static var main: UIWindowScene? {
        UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
}

public extension BaseWrapper where BaseType: UIWindowScene {
    /// 设置屏幕方向
    /// - Parameter orientation: 屏幕方向
    @discardableResult
    func rotate(to orientation: UIInterfaceOrientation) -> Bool {
        if #available(iOS 16.0, *) {
            let toOrientation = UIInterfaceOrientationMask(rawValue: 1 << orientation.rawValue)
            self.base.requestGeometryUpdate(UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: toOrientation))
        } else {
            if let toOrientation = UIDeviceOrientation(rawValue: orientation.rawValue) {
                UIDevice.current.setValue(toOrientation.rawValue, forKey: "orientation")
            } else {
                return false
            }
        }
        return true
    }
}
