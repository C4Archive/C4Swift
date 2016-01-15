//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import C4

class DisplayLink: NSObject {

    override init() {
        super.init()
    }

    func update() {

    }
}

class ViewController: C4CanvasController {
    var line: RandomLine!
    var line2: RandomLine!
    var line3: RandomLine!

    var timer: C4Timer!

    var displayLink: CADisplayLink!

    override func setup() {
        line = RandomLine(frame: C4Rect(0,0,canvas.width,100))
        line.setup()
        line.line.fillColor = C4Purple
        line.center = canvas.center
        canvas.add(line)

        line2 = RandomLine(frame: C4Rect(0,0,canvas.width,100))
        line2.setup()
        line2.line.fillColor = C4Blue
        line2.center = canvas.center
        canvas.add(line2)

        line3 = RandomLine(frame: C4Rect(0,0,canvas.width,100))
        line3.setup()
        line3.center = canvas.center
        canvas.add(line3)

        displayLink = CADisplayLink(target: self, selector: "update")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    func update() {
        line.update()
        line2.update()
        line3.update()
    }
}

class RandomLine: C4View {
    var line: C4Polygon!

    func setup() {
        var points = [C4Point]()
        var x = 0.0
        repeat {
            points.append(C4Point(x,height/2.0))
            x += 4.0
        } while x < width
        points.append(C4Point(x,height/2.0))

        line = C4Polygon(points)
        line.fillColor = C4Pink
        line.strokeColor = clear
        add(line)
    }

    func update() {
        var points = line.points
        for _ in 1...40 {
            let index = random(below: points.count)

            let dir = round(random01()) == 0 ? -1.0 : 1.0

            let dy = random01() * 20 * dir

            round(random01() * 3.0) == 0 ? points[index].y = height/2.0 : (points[index].y += dy)
        }

        C4ViewAnimation(duration: 1/60.0) {
            self.line.points = points
        }.animate()
    }
}