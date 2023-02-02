//
//  DVTTips.swift
//  DVTUIKitTips
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

import DVTFoundation
import UIKit

#if canImport(DVTUIKitExtension)
    import DVTUIKitExtension
#endif

#if canImport(DVTUIKitPublic)
    import DVTUIKitPublic
#endif

fileprivate extension UIImage {
    private static let bundleName = "DVTUIKit_DVTUIKitTips"

    static func image(_ named: String) -> UIImage? {
        let realName = "DVTUIKit_Tips_\(named)"
        // (main) OR (cocoapods default) OR (cocoapods Frameworks (generate_multiple_pod_projects)) OR (Bundle SPM)
        return UIImage(named: "main_" + realName) ?? UIImage(named: realName) ?? .dvt.image(DVTTipsView.classForCoder(), named: realName) ?? .dvt.image(self.bundleName, named: realName)
    }
}

public class DVTTips {
    public static var laodingTimeOut: TimeInterval = 30
    public static var defaultTimeOut: TimeInterval = 1.5
}

public extension BaseWrapper where BaseType: UIView {
    /// 隐藏所有的tipsView
    /// - Parameter animation: 是否需要动画
    func hideAllTipsView(_ animation: Bool = true) {
        self.base.subviews.forEach { view in
            if let tipsView = view as? DVTTipsView {
                tipsView.hide(animation)
            }
        }
    }

    /// 获取所有的tipsView
    var allTipsViews: [DVTTipsView] {
        self.base.subviews.compactMap({ $0 as? DVTTipsView })
    }
}

public extension BaseWrapper where BaseType: UIView {
    @discardableResult
    func show(_ text: String? = nil, detailText: String? = nil,
              attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
              view: UIView? = nil, style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut),
              position: DVTTipsPosition = .center) -> DVTTipsView {
        let tipsView = DVTTipsView(text, detailText: detailText,
                                   attributedText: attributedText, attributedDetailText: attributedDetailText,
                                   view: view, style: style,
                                   position: position)
        tipsView.show(superview: self.base)
        return tipsView
    }

    @discardableResult
    func showLoading(_ text: String? = nil, detailText: String? = nil,
                     attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                     style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.laodingTimeOut),
                     position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.show(text, detailText: detailText,
                         attributedText: attributedText, attributedDetailText: attributedDetailText,
                         view: UIActivityIndicatorView(style: .large), style: style, position: position)
    }

    @discardableResult
    func showText(_ text: String? = nil, detailText: String? = nil,
                  attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                  style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut), position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.show(text, detailText: detailText,
                         attributedText: attributedText, attributedDetailText: attributedDetailText,
                         view: nil, style: style, position: position)
    }

    @discardableResult
    func showInfo(_ text: String? = nil, detailText: String? = nil,
                  attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                  style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut), position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.show(text, detailText: detailText,
                         attributedText: attributedText, attributedDetailText: attributedDetailText,
                         view: UIImageView(image: .image("info")), style: style, position: position)
    }

    @discardableResult
    func showError(_ text: String? = nil, detailText: String? = nil,
                   attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                   style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut), position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.show(text, detailText: detailText,
                         attributedText: attributedText, attributedDetailText: attributedDetailText,
                         view: UIImageView(image: .image("error")), style: style, position: position)
    }

    @discardableResult
    func showSuccess(_ text: String? = nil, detailText: String? = nil,
                     attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                     style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut), position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.show(text, detailText: detailText,
                         attributedText: attributedText, attributedDetailText: attributedDetailText,
                         view: UIImageView(image: .image("done")), style: style, position: position)
    }

    @discardableResult
    func showOnly(_ text: String? = nil, detailText: String? = nil,
                  attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                  view: UIView? = nil, style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut),
                  position: DVTTipsPosition = .center) -> DVTTipsView {
        self.hideAllTipsView(false)
        return self.show(text, detailText: detailText,
                         attributedText: attributedText, attributedDetailText: attributedDetailText,
                         view: view, style: style, position: position)
    }

    @discardableResult
    func showOnlyLoading(_ text: String? = nil, detailText: String? = nil,
                         attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                         style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.laodingTimeOut),
                         position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.showOnly(text, detailText: detailText,
                             attributedText: attributedText, attributedDetailText: attributedDetailText,
                             view: UIActivityIndicatorView(style: .large), style: style, position: position)
    }

    @discardableResult
    func showOnlyText(_ text: String? = nil, detailText: String? = nil,
                      attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                      style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut), position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.showOnly(text, detailText: detailText,
                             attributedText: attributedText, attributedDetailText: attributedDetailText,
                             view: nil, style: style, position: position)
    }

    @discardableResult
    func showOnlyInfo(_ text: String? = nil, detailText: String? = nil,
                      attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                      style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut), position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.showOnly(text, detailText: detailText,
                             attributedText: attributedText, attributedDetailText: attributedDetailText,
                             view: UIImageView(image: .image("info")), style: style, position: position)
    }

    @discardableResult
    func showOnlyError(_ text: String? = nil, detailText: String? = nil,
                       attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                       style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut), position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.showOnly(text, detailText: detailText,
                             attributedText: attributedText, attributedDetailText: attributedDetailText,
                             view: UIImageView(image: .image("error")), style: style, position: position)
    }

    @discardableResult
    func showOnlySuccess(_ text: String? = nil, detailText: String? = nil,
                         attributedText: NSAttributedString? = nil, attributedDetailText: NSAttributedString? = nil,
                         style: DVTTipsStyle = DVTTipsStyle(timeout: DVTTips.defaultTimeOut), position: DVTTipsPosition = .center) -> DVTTipsView {
        return self.showOnly(text, detailText: detailText,
                             attributedText: attributedText, attributedDetailText: attributedDetailText,
                             view: UIImageView(image: .image("done")), style: style, position: position)
    }
}
