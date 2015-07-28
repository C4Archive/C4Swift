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
    override func layoutSubviews() {
        super.layoutSubviews()
        upadteOffsetIfNeeded()
    }

    internal func upadteOffsetIfNeeded() {
        var curr = self.contentOffset
        if curr.x < 0 {
            curr.x = self.contentSize.width-self.frame.size.width
            contentOffset = curr
        } else if curr.x >= self.contentSize.width - self.frame.size.width {
            curr.x = 0
            contentOffset = curr
        }
    }
}