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
    var timer: C4Timer!
    override func setup() {
        var lines = [C4Line]()
        let dx = 2.0
        var x = 0.5
        let points = (C4Point(),C4Point(0,100))
        repeat {
            let line = C4Line(points)
            line.center = C4Point(x,canvas.center.y)
            line.strokeStart = 0.5
            line.strokeEnd = 0.5
            canvas.add(line)
            lines.append(line)
            x += dx
        } while x < canvas.width

        timer = C4Timer(interval: 0.05, count: lines.count) { () -> () in
            let line = lines[self.timer.step]
            self.createAnimation(line).animate()
        }
        timer.start()
    }

    func startAnimation() {

    }

    func createAnimation(line: C4Line) -> C4ViewAnimation {
        let a = C4ViewAnimation(duration: 1.0) {
            line.strokeStart = 0.0
            line.strokeEnd = 1.0
        }
        a.repeats = true
        a.autoreverses = true
        return a
    }
}