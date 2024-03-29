//
//  DVTKeyboardManager.swift
//  DVTUIKit_Public
//
//  Created by darvin on 2023/2/1.
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
import DVTFoundation

#if canImport(DVTUIKit_Extension)
    import DVTUIKit_Extension
#endif

public struct KeyboardInfo {
    // MARK: Lifecycle
    fileprivate init(_ notify: Notification) {
        if let dict = notify.userInfo as? [String: Any] {
            self.beginFrame = (dict[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect) ?? .zero
            self.endFrame = (dict[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
            self.animationCurve = (dict[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve) ?? .easeInOut
            self.animationDuration = (dict[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat) ?? 0.25
            self.bounds = (dict["UIKeyboardBoundsUserInfoKey"] as? CGRect) ?? .zero
        }
        if self.bounds == .zero {
            self.bounds = CGRect(origin: .zero, size: self.endFrame.size)
        }
    }

    // MARK: Public
    public private(set) var animationDuration: CGFloat = 0.25

    public private(set) var bounds: CGRect = .zero
    public private(set) var animationCurve: UIView.AnimationCurve = .easeInOut

    public private(set) var beginFrame: CGRect = .zero
    public private(set) var endFrame: CGRect = .zero
    public private(set) var targetResponder: UIResponder?

    public var minY: CGFloat {
        self.endFrame.origin.y
    }

    public var height: CGFloat {
        self.bounds.height
    }

    public var width: CGFloat {
        self.bounds.width
    }

    public func height(in view: UIView?) -> CGFloat {
        guard let view = view else {
            return self.height
        }
        let keyboardRect = DVTKeyboardManager.convert(keyboard: self.endFrame, to: view)
        let visibleRect = CGRectIntersection(view.bounds.dvt.flat, keyboardRect.dvt.flat)
        if !visibleRect.dvt.isValidated {
            return 0
        }
        return visibleRect.size.height
    }
}

public class DVTKeyboardManager {
    // MARK: Lifecycle
    private init() {
        dvtuiloger.debug("开始监听键盘状态")
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidChange(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

    // MARK: Public
    public typealias KeyboardBlock = (_ info: KeyboardInfo) -> Void

    public static var `default`: DVTKeyboardManager {
        _default
    }

    public private(set) var info: KeyboardInfo?
    public private(set) var isVisible = false

    public static func convert(keyboard rect: CGRect, to view: UIView?) -> CGRect {
        if rect.dvt.isEmpty { return rect }
        guard let mainWindow = UIApplication.dvt.activeWindow else {
            if let view = view {
                return view.convert(rect, from: nil)
            }
            return rect
        }

        var resRect = mainWindow.convert(rect, from: nil)
        guard let view = view else {
            return mainWindow.convert(resRect, to: nil)
        }

        if view == mainWindow {
            return resRect
        }

        guard let toWindow = view as? UIWindow ?? view.window, toWindow != mainWindow else {
            return mainWindow.convert(resRect, to: view)
        }

        resRect = mainWindow.convert(resRect, to: mainWindow)
        resRect = toWindow.convert(resRect, from: mainWindow)
        resRect = view.convert(resRect, from: toWindow)

        return resRect
    }

    // MARK: Fileprivate
    fileprivate class KeyboardMonitor {
        // MARK: Lifecycle
        init(_ observer: AnyObject, executable block: @escaping KeyboardBlock) {
            self.observer = observer
            self.block = block
        }

        // MARK: Internal
        private(set) weak var observer: AnyObject?
        private(set) var block: KeyboardBlock?
    }

    fileprivate var willShowMonitors: [KeyboardMonitor] = []
    fileprivate var didShowMonitors: [KeyboardMonitor] = []

    fileprivate var willHideMonitors: [KeyboardMonitor] = []
    fileprivate var didHideMonitors: [KeyboardMonitor] = []

    fileprivate var willChangeMonitors: [KeyboardMonitor] = []
    fileprivate var didChangeMonitors: [KeyboardMonitor] = []

    // MARK: Private
    private static let _default = DVTKeyboardManager()

    private func handleNotification(_ status: KeyboardStatus, notify: Notification) {
        let info = KeyboardInfo(notify)
        self.info = info
        switch status {
            case .willShow:
                self.willShowMonitors.removeAll { $0.observer == nil }
                self.willShowMonitors.forEach { monitor in
                    monitor.block?(info)
                }
            case .didShow:
                self.isVisible = true
                self.didShowMonitors.removeAll { $0.observer == nil }
                self.didShowMonitors.forEach { monitor in
                    monitor.block?(info)
                }
            case .willChange:
                self.willChangeMonitors.removeAll { $0.observer == nil }
                self.willChangeMonitors.forEach { monitor in
                    monitor.block?(info)
                }
            case .didChange:
                self.didChangeMonitors.removeAll { $0.observer == nil }
                self.didChangeMonitors.forEach { monitor in
                    monitor.block?(info)
                }
            case .willHide:
                self.willHideMonitors.removeAll { $0.observer == nil }
                self.willHideMonitors.forEach { monitor in
                    monitor.block?(info)
                }
            case .didHide:
                self.isVisible = false
                self.didHideMonitors.removeAll { $0.observer == nil }
                self.didHideMonitors.forEach { monitor in
                    monitor.block?(info)
                }
        }
    }

    @objc
    private func keyboardWillShow(_ notify: Notification) {
        self.handleNotification(.willShow, notify: notify)
    }

    @objc
    private func keyboardDidShow(_ notify: Notification) {
        self.handleNotification(.didShow, notify: notify)
    }

    @objc
    private func keyboardWillHide(_ notify: Notification) {
        self.handleNotification(.willHide, notify: notify)
    }

    @objc
    private func keyboardDidHide(_ notify: Notification) {
        self.handleNotification(.didHide, notify: notify)
    }

    @objc
    private func keyboardWillChange(_ notify: Notification) {
        self.handleNotification(.willChange, notify: notify)
    }

    @objc
    private func keyboardDidChange(_ notify: Notification) {
        self.handleNotification(.didChange, notify: notify)
    }
}

public extension DVTKeyboardManager {
    enum KeyboardStatus {
        case willShow, didShow, willChange, didChange, willHide, didHide
    }

    func test() { }

    func addMonitor(_ observer: AnyObject, status: KeyboardStatus, block: @escaping KeyboardBlock) {
        switch status {
            case .willShow:
                self.willShowMonitors.append(KeyboardMonitor(observer, executable: block))
            case .didShow:
                self.didShowMonitors.append(KeyboardMonitor(observer, executable: block))
            case .willChange:
                self.willChangeMonitors.append(KeyboardMonitor(observer, executable: block))
            case .didChange:
                self.didChangeMonitors.append(KeyboardMonitor(observer, executable: block))
            case .willHide:
                self.willHideMonitors.append(KeyboardMonitor(observer, executable: block))
            case .didHide:
                self.didHideMonitors.append(KeyboardMonitor(observer, executable: block))
        }
    }

    func addWillShowMonitor(_ observer: AnyObject, block: @escaping KeyboardBlock) {
        self.addMonitor(observer, status: .willShow, block: block)
    }

    func addDidShowMonitor(_ observer: AnyObject, block: @escaping KeyboardBlock) {
        self.addMonitor(observer, status: .didShow, block: block)
    }

    func addWillChangeMonitor(_ observer: AnyObject, block: @escaping KeyboardBlock) {
        self.addMonitor(observer, status: .willChange, block: block)
    }

    func addDidChangeMonitor(_ observer: AnyObject, block: @escaping KeyboardBlock) {
        self.addMonitor(observer, status: .didChange, block: block)
    }

    func addWillHideMonitor(_ observer: AnyObject, block: @escaping KeyboardBlock) {
        self.addMonitor(observer, status: .willHide, block: block)
    }

    func addDidHideMonitor(_ observer: AnyObject, block: @escaping KeyboardBlock) {
        self.addMonitor(observer, status: .didHide, block: block)
    }
}
