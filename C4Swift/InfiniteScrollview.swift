//
//  InfiniteScrollview.swift
//  C4Swift
//
//  Created by travis on 2015-03-16.
//  Copyright (c) 2015 C4. All rights reserved.
//

import Foundation
import UIKit

class InfiniteScrollView : UIScrollView {
    internal var normalizedPosition = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateNormalizedPosition()
    }

    internal func calculateNormalizedPosition() {
        var curr = self.contentOffset
        if curr.x < 0 {
            curr.x = self.contentSize.width-self.frame.size.width
        } else if curr.x >= self.contentSize.width - self.frame.size.width {
            curr.x = 0
        }
        self.contentOffset = curr
        normalizedPosition = 1.0 - Double(curr.x / self.frame.size.width)
    }
}