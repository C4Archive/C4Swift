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
        let star = C4Star(center: canvas.center, pointCount: 10, innerRadius: 50, outerRadius: 80)
        let g = C4Gradient(frame:star.frame, colors: [C4Blue, C4Pink])
        star.gradientFill = g
        let c = C4Circle(center: canvas.center, radius: 25)

        c.gradientFill = g
        canvas.add(star)
        canvas.add(c)

        var b = false
        let a = C4ViewAnimation(duration:1.0) {
            if b {
                g.frame = star.frame
                star.gradientFill = g
            } else {
                star.fillColor = C4Pink
            }
            b = !b
        }

        canvas.addTapGestureRecognizer { (location, state) -> () in
            a.animate()
        }
    }
}