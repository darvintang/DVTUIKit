//
//  UINavigationBar.swift
//
//
//  Created by darvin on 2023/1/9.
//

import UIKit
import DVTFoundation

public extension BaseWrapper where BaseType: UINavigationBar {
    // MARK: Internal
    var backgroundView: UIView? {
        self.base.value(forKey: "_" + "background" + "View") as? UIView
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

    // MARK: Private
    private var effectView: UIView? {
        self.backgroundView?.subviews.filter { $0.isMember(of: UIVisualEffectView.layerClass) }.first
    }
}
