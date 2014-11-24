//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import C4iOS
import C4Core
import C4Animation

class ViewController: UIViewController {
    let dx = 8.0
    let dy = 8.0 / 1.9
    
    override func viewDidLoad() {
        for x in 0...200 {
            for y in 0...200 {
                let p = isometric(C4Point(Double(x),Double(y)))
                if C4Rect(self.view.frame).contains(p) {
                    addEllipse(p)
                }
                
                if y > Int(self.view.frame.size.height) {
                    break
                }
            }
        }
    }
    
    func isometric(var point: C4Point) -> C4Point {
        point = rotate(point, 45)
        point = C4Point(point.x * dx, point.y*dy)
        point = point + C4Vector(x: Double(self.view.center.x), y:10)
        return point
    }
    
    func rotate(point: C4Point, _ degrees: Double) -> C4Point {
        let s = sin(degrees * M_PI / 180.0)
        let c = cos(degrees * M_PI / 180.0)
        return C4Point(c * point.x - s * point.y, s * point.x + c * point.y);
    }
    
    func addEllipse(at: C4Point) {
            var e = Ellipse(C4Rect(0,0,4,4))
            e.center = CGPoint(at)
            self.view.add(e)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}