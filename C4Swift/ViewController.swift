//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import C4

class ViewController: C4CanvasController {
    override func setup() {
        let c = C4Image("chop")
        let r = C4Image(c4image: c!)
        canvas.add(r)

        let a = C4ViewAnimation(duration:1.0) {
            c?.contents = r.contents
        }
        a.delay = 1.0
        a.animate()
    }
}