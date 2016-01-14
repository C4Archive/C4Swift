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
    var points: [C4Point]!
    var line: C4Polygon!
    var line2: C4Polygon!
    var timer: C4Timer!

    override func setup() {
        points = [C4Point]()

        var x = 0.0
        repeat {
            points.append(C4Point(x,canvas.center.y))
            x  += 4.0
        } while x <= canvas.width
        points.append(C4Point(x,canvas.center.y))

        line = C4Polygon(points)
        line.strokeColor = clear
        line.fillColor = C4Pink
        canvas.add(line)

        timer = C4Timer(interval: 1/30.0) {
            self.updatePoints()
            self.updateLine(self.timer.interval)
        }
        timer.start()
    }

    func updatePoints() {
        for _ in 1...40 {
            let index = random(below: points.count)

            let dir = round(random01()) == 0 ? -1.0 : 1.0

            let dy = random01() * 20 * dir

            round(random01() * 3.0) == 0 ? points[index].y = canvas.center.y : (points[index].y += dy)
        }
    }

    func updateLine(duration: Double) {

        let newLine = C4Polygon(points)

        C4ViewAnimation(duration: duration) {
            self.line.path = newLine.path
        }.animate()
    }
}