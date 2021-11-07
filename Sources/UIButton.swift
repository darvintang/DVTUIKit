//
//  File.swift
//
//
//  Created by darvin on 2021/11/7.
//

import DVTFoundation
import UIKit

public extension BaseWrapper where DT: UIButton {
    mutating func add(for event: UIControl.Event = .touchUpInside, block clickBlock: @escaping (DT) -> Void) {
        let btn = self.base
        self.base.dvt_clickBlock = { () -> Void in
            clickBlock(btn)
        }
        self.base.addTarget(self.base, action: #selector(self.base.dvt_didClickSelf), for: event)
    }
}
