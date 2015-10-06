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
    override func setup() {
        let b = C4Vector(x: self.canvas.center.x + 1, y: self.canvas.center.y)
        let c = C4Vector(canvas.center)

        canvas.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            let a = C4Vector(location)
            let angle = a.angleTo(b, basedOn: c)
            let reflex = a.y < b.y ? 2*M_PI-angle : angle
            print(reflex)
        }
    }
}

public extension C4Vector {
    init(_ point: C4Point) {
        self.init(x: point.x, y: point.y)
    }
}