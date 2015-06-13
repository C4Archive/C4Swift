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
    let dx = 2.0
    
    var poly = C4Shape()
    
    override func setup() {
        displaylink = CADisplayLink(target: self, selector: Selector("update"))
        displaylink?.frameInterval = 2
        displaylink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)

        canvas.frame = C4Rect(674,120,276,180)
        poly.frame = canvas.bounds
        poly.fillColor = clear
        poly.lineWidth = 3.0
        poly.shadow.opacity = 0.66
        poly.shadow.radius = 0.5
        poly.shadow.offset = C4Size(1,1)
        poly.strokeColor = white
        poly.lineCap = .Round
        canvas.add(poly)
        points.append(C4Point(0,poly.height/2.0))
        println(self.canvas.width)
    }
    
    func updatePoints() -> Bool {
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
        var path = C4Path()
        path.moveToPoint(points[0])
        for i in 1..<points.count {
            var point = points[i]
            point.x = Double(i)*dx
            path.addLineToPoint(point)
        }
        if let p = points.last {
            path.addEllipse(C4Rect(Double(points.count)*dx-2.0,p.y-2,4.0,4.0))
        }
        self.poly.path = path
    }
    
    func update() {
        if updatePoints() {
            updatePath()
        }
    }

}