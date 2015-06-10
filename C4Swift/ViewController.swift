//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import C4UI
import C4Core
import C4Animation

class ViewController: C4CanvasController {
    var displaylink : CADisplayLink?
    var points = [C4Point]()
    let dx = 2.0
    
    var poly = C4Shape()
    var polyPath = C4Path()
    
    override func viewDidLoad() {
        displaylink = CADisplayLink(target: self, selector: Selector("update"))
        displaylink?.frameInterval = 2
        displaylink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        poly.frame = C4Rect(0,200,canvas.width,200)
        poly.border.width = 1.0
        poly.fillColor = clear
        poly.lineWidth = 2.0
        poly.shadow.opacity = 0.66
        poly.shadow.radius = 0.5
        poly.shadow.offset = C4Size(1,1)
        poly.strokeColor = C4Blue
        canvas.add(poly)
        points.append(C4Point(0,poly.height/2.0))
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
        self.poly.path = path
    }
    
    func update() {
        if updatePoints() {
            updatePath()
        }
    }
}