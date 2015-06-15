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
    var accelerationPoints = [C4Point]()
    var rawPoints = [C4Point]()
    let dx = 5.0
    let filteringFactor = 0.3
    var accel = 0.0
    var accels : [Double] = [0.0,0.0,0.0,0.0,0.0]
    var accelCircle = C4Circle(center: C4Point(), radius: 4)
    var rawCircle = C4Circle(center: C4Point(), radius: 2)

    var acceleration = C4Shape()
    var raw = C4Shape()
    
    override func setup() {
        displaylink = CADisplayLink(target: self, selector: Selector("update"))
        displaylink?.frameInterval = 2
        displaylink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)

        canvas.frame = C4Rect(674,124,280,176)

        raw.frame = canvas.bounds
        raw.fillColor = clear
        raw.lineWidth = 1.0
        raw.shadow.opacity = 0.33
        raw.shadow.radius = 0.25
        raw.shadow.offset = C4Size(1,1)
        raw.strokeColor = red
        raw.lineCap = .Round
        canvas.add(raw)

        acceleration.frame = canvas.bounds
        acceleration.fillColor = clear
        acceleration.lineWidth = 3.0
        acceleration.shadow.opacity = 0.66
        acceleration.shadow.radius = 0.5
        acceleration.shadow.offset = C4Size(1,1)
        acceleration.strokeColor = white
        acceleration.lineCap = .Round
        canvas.add(acceleration)

        accelerationPoints.append(C4Point(0,canvas.height/2.0))
        rawPoints.append(C4Point(0,canvas.height/2.0))

        rawCircle.fillColor = red
        rawCircle.shadow = accelCircle.shadow
        rawCircle.strokeColor = clear
        rawCircle.center = rawPoints.last!
        canvas.add(rawCircle)

        accelCircle.fillColor = white
        accelCircle.shadow = acceleration.shadow
        accelCircle.strokeColor = clear
        accelCircle.center = accelerationPoints.last!
        canvas.add(accelCircle)

    }

    func updateAccelerometerData(var val: Double) -> Bool {
        if var pt : C4Point = accelerationPoints.last {
            if abs(val) < 0.015 {
                val = 0.0
            }
            accels.removeAtIndex(0)
            accels.append(val)

            var avg = 0.0
            for v in accels {
                avg += v
            }
            avg /= Double(accels.count)
            avg = clamp(avg, -0.175, 0.175)
            avg /= 0.175

            var y = avg * canvas.height/2.0
            y += canvas.height/2.0

            pt.y = y

            accelerationPoints.append(pt)
            if accelerationPoints.count > Int(canvas.width/dx)  {
                accelerationPoints.removeAtIndex(0)
            }
            updateAccelerationPath()
            return true
        }
        return false
    }

    func updateRawData(var val: Double) -> Bool {
        if var pt : C4Point = rawPoints.last {
            pt.y = clamp(canvas.height/2.0 * (val + 1.0),0,canvas.height)
            rawPoints.append(pt)
            if rawPoints.count > Int(canvas.width/dx)  {
                rawPoints.removeAtIndex(0)
            }
            updateRawPath()
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
        if var pt : C4Point = accelerationPoints.last {
            pt.y += Double(random(-3, 4))
            accelerationPoints.append(pt)
            if accelerationPoints.count > Int(canvas.width/dx)  {
                accelerationPoints.removeAtIndex(0)
            }
            return true
        }
        return false
    }
    
    func updateAccelerationPath() {
        C4ViewAnimation(duration: 0.0) {
            var path = C4Path()
            path.moveToPoint(self.accelerationPoints[0])
            for i in 1..<self.accelerationPoints.count {
                var point = self.accelerationPoints[i]
                point.x = Double(i)*self.dx
                path.addLineToPoint(point)
            }
            self.acceleration.path = path
            self.accelCircle.center = path.currentPoint
            }.animate()
    }

    func updateRawPath() {
        C4ViewAnimation(duration: 0.0) {
            var path = C4Path()
            path.moveToPoint(self.rawPoints[0])
            for i in 1..<self.rawPoints.count {
                var point = self.rawPoints[i]
                point.x = Double(i)*self.dx
                path.addLineToPoint(point)
            }
            self.raw.path = path
            self.rawCircle.center = path.currentPoint
            }.animate()
    }

    func update() {
//        if updatePoints() {
//            updatePath()
//        }
    }

}