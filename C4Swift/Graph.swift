//
//  Graph.swift
//  C4Swift
//
//  Created by travis on 2015-06-12.
//  Copyright (c) 2015 C4. All rights reserved.
//

import Foundation
import C4Core
import C4UI
import C4Animation

class Graph : C4CanvasController {
    var displaylink : CADisplayLink?
    var points = [C4Point]()
    let dx = 5.0
    let filteringFactor = 0.3
    var accel = 0.0
    var accels : [Double] = [0.0,0.0,0.0,0.0,0.0]
    var circle = C4Circle(center: C4Point(), radius: 4)

    var poly = C4Shape()
    
    override func setup() {
        displaylink = CADisplayLink(target: self, selector: Selector("update"))
        displaylink?.frameInterval = 2
        displaylink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)

        canvas.frame = C4Rect(674,122,280,180)
        poly.frame = canvas.bounds
        poly.fillColor = clear
        poly.lineWidth = 2.0
        poly.shadow.opacity = 0.66
        poly.shadow.radius = 0.5
        poly.shadow.offset = C4Size(1,1)
        poly.strokeColor = white
        poly.lineCap = .Round
        canvas.add(poly)
        points.append(C4Point(0,canvas.height/2.0))
        println(self.canvas.width)

        circle.fillColor = white
        circle.shadow = poly.shadow
        circle.strokeColor = clear
        circle.center = points.last!
        canvas.add(circle)
    }

    func updateAccelerometerData(var val: Double) -> Bool {
        if var pt : C4Point = points.last {
            if abs(val) < 0.03 {
                val = 0.0
            }
            accels.removeAtIndex(0)
            accels.append(val)

            var avg = 0.0
            for v in accels {
                avg += v
            }
            avg /= Double(accels.count)

            var y = avg * 100

            if abs(y) < 2 { y = 0 }

            y *= dx
            y += canvas.height/2.0

            y = clamp(y, 0.0, canvas.height)
            pt.y = y

            points.append(pt)
            if points.count > Int(canvas.width/dx)  {
                points.removeAtIndex(0)
            }
            updatePath()
            return true
        }
        return false
    }

    func filter(val: Double) -> Double{
        accel = val * filteringFactor + accel * (1.0-filteringFactor)
        return val - accel
    }
    
    func updatePoints() -> Bool {
        //grabs last point, creates new random point
        if var pt : C4Point = points.last {
            pt.y += Double(random(-3, 4))
            points.append(pt)
            if points.count > Int(canvas.width/dx)  {
                points.removeAtIndex(0)
            }
            return true
        }
        return false
    }
    
    func updatePath() {
        C4ViewAnimation(duration: 0.0) {
            var path = C4Path()
            path.moveToPoint(self.points[0])
            for i in 1..<self.points.count {
                var point = self.points[i]
                point.x = Double(i)*self.dx
                path.addLineToPoint(point)
            }
            self.poly.path = path
            self.circle.center = path.currentPoint
        }.animate()
    }
    
    func update() {
//        if updatePoints() {
//            updatePath()
//        }
    }

}