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

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        var bezier = C4Path()
        bezier.moveToPoint(C4Point(110.81, 46.82))
        bezier.addCurveToPoint(C4Point(110.81, 44.02), control2: C4Point(113.01, 41.82), point: C4Point(115.81, 41.82))
        bezier.addCurveToPoint(C4Point(118.61, 41.82), control2: C4Point(120.81, 44.02), point: C4Point(120.81, 46.82))
        bezier.addCurveToPoint(C4Point(120.81, 58.32), control2: C4Point(105.11, 66.12), point: C4Point(105.11, 66.12))
        
        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        canvas.add(shape)
    }
}