//
//  UINavigationBar.swift
//
//
//  Created by darvin on 2023/1/9.
//

import DVTFoundation
import UIKit

public extension BaseWrapper where BaseType: UINavigationBar {
    private var effectView: UIView? {
        self.backgroundView?.subviews.filter({ $0.isMember(of: UIVisualEffectView.layerClass) }).first
    }

    func removeEffect() {
        self.effectView?.isHidden = true
    }

    func resetEffect() {
        self.effectView?.isHidden = false
    }

    func removeBackground() {
        self.backgroundView?.layer.mask = CALayer()
    }

    func resetBackground() {
        self.backgroundView?.layer.mask = nil
    }

    var backgroundView: UIView? {
        self.base.value(forKey: "_" + "background" + "View") as? UIView
    }
}
