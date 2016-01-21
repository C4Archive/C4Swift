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
    var gradients = [C4Gradient]()
    var points = [C4Point]()
    var timer: C4Timer!

    override func setup() {
        var x = 1.0
        let w = 1.0
        repeat {
            gradients.append(createBar(C4Point(x,canvas.center.y), width: w))
            x += w * 2.0
        } while x < canvas.width
        timer = C4Timer(interval: 0.02, count: gradients.count) { () -> () in
            let g = self.gradients[self.timer.step]
            self.createAnim(g)
        }
        timer.start()
    }

    func createBar(point: C4Point, width: Double) -> C4Gradient {
        let g = C4Gradient(frame: C4Rect(0,0,1.0,1.0), locations: [0,1])
        g.endPoint = C4Point(0,1.0)
        g.transform.rotate(0.05)
        g.center = point
        switch random(below: 2) {
        case 0:
            g.colors = [C4Blue,C4Pink]
        default:
            g.colors = [C4Pink,C4Blue]
        }
        canvas.add(g)
        return g
    }
    
    func createAnim(g: C4Gradient) {
        let anim = C4ViewAnimation(duration: 2.0) {
            var f = g.frame
            let c = g.center
            f.height = 100
            f.center = c
            g.frame = f
        }
        anim.curve = .EaseInOut
        anim.autoreverses = true
        anim.repeats = true
        anim.animate()
    }
}