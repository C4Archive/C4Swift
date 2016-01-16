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
    var inner: C4Polygon!
    var innerMask: C4Polygon!
    var outer: C4Polygon!

//pink burst
    var pointCount = 90
    var radius = (60.0,50.0)
    var lineWidths = (1.0,0.5)
    var primaryColor = C4Pink

    func randomize(points: [C4Point], radius: Double) -> [C4Point] {
        var newPoints = [C4Point]()
        for i in 0..<points.count {
            var r = radius
            let rand = random01()
            if rand < 0.9 {
                let percentage = Double(random(min: 90, max: 110)) / 100.0
                let d = distance(C4Point(), rhs: points[i])
                r = d * percentage
            }
            let θ = Double(i) / 45.0 * M_PI
            newPoints.append(C4Point(r * sin(θ), r * cos(θ)))
        }
        return newPoints
    }


//pink change update method
//    var pointCount = 90
//    var radius = (60.0,50.0)
//    var lineWidths = (1.0,0.5)
//    var primaryColor = C4Pink
//
//    func randomize(var points: [C4Point], var radius r: Double) -> [C4Point] {
//        for i in 0..<points.count {
//            if random(below: 1000) > 600  {
//                r = distance(C4Point(), rhs: points[i]) * Double(random(min: 95, max: 105)) / 100.0
//            }
//            let θ = Double(i) / 45.0 * M_PI
//            points[i] = C4Point(r * sin(θ), r * cos(θ))
//            if i == 0 {
//                print(r)
//            }
//        }
//        return points
//    }

//pink
//    var pointCount = 90
//    var radius = (60.0,50.0)
//    var lineWidths = (1.0,0.5)
//    var primaryColor = C4Pink
//
//    func randomize(var points: [C4Point], var radius r: Double) -> [C4Point] {
//        for i in 0..<points.count {
//            if random(below: 10) > 4  {
//                r = distance(C4Point(), rhs: points[i]) * Double(random(min: 95, max: 105)) / 100.0
//
//            }
//            let θ = Double(i) / 45.0 * M_PI
//            points[i] = C4Point(r * sin(θ), r * cos(θ))
//        }
//        return points
//    }

//blue
//    var pointCount = 90
//    var radius = (50.0,58.0)
//    var lineWidths = (2.0,0.5)
//    var primaryColor = C4Blue
//
//    func randomize(var points: [C4Point], var radius r: Double) -> [C4Point] {
//        for _ in 0..<points.count {
//            let index = random(below: points.count)
//            if random(below: 10) > 6  {
//                r = distance(C4Point(), rhs: points[index]) * Double(random(min: 95, max: 105)) / 100.0
//            }
//            let θ = Double(index) / 45.0 * M_PI
//            points[index] = C4Point(r * sin(θ), r * cos(θ))
//        }
//        return points
//    }

    override func setup() {
        canvas.backgroundColor = black
        createInner()
        createInnerMask()
        createOuter()
        positionShapes()
        initializeDisplayLink()
//        animateCanvas()
    }

    func createInner() {
        inner = createPoly(radius: radius.0)
        inner.lineWidth = lineWidths.0
        inner.fillColor = black
        inner.strokeColor = primaryColor
    }

    func createInnerMask() {
        innerMask = createPoly(radius: radius.1)
        innerMask.fillColor = primaryColor
        inner.mask = innerMask
    }

    func createOuter() {
        outer = C4Polygon(innerMask.points)
        outer.strokeColor = primaryColor
        outer.fillColor = primaryColor.colorWithAlpha(0.2)
        outer.lineWidth = lineWidths.1
        outer.close()
    }

    func positionShapes() {
        let container = C4View(frame: C4Rect(0,0,1,1))
        container.add(outer)
        container.add(inner)
        container.center = canvas.center
        canvas.add(container)
    }

    func initializeDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: "update")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        canvas.addTapGestureRecognizer { (location, state) -> () in
            self.update()
        }
    }

    func animateCanvas() {
        let a = C4ViewAnimation(duration: 1.0) {
            self.canvas.transform.rotate(M_PI)
        }
        a.curve = .Linear
        a.repeats = true
        a.animate()
    }

    func update() {
        C4ViewAnimation(duration: 0) {
            self.inner.points = self.randomize(self.inner.points, radius: self.radius.1)
            let maskPoints = self.randomize(self.innerMask.points, radius: self.radius.0)
            self.innerMask.points = maskPoints
            self.outer.points = maskPoints
        }.animate()
    }
    
    func createPoly(radius r: Double) -> C4Polygon {
        var points = [C4Point]()
        for i in 0..<pointCount {
            let θ = Double(i) * M_PI * 2.0 / Double(pointCount)
            let pt = C4Point(r * sin(θ), r * cos(θ))
            points.append(pt)
        }
        let poly = C4Polygon(points)
        poly.close()
        return poly
    }
}