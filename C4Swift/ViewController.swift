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
    var p: UIPanGestureRecognizer!
    var lines = [(C4Line,C4Line)]()

    override func setup() {
        for _ in 0..<5 {
            let v = C4Line((C4Point(),C4Point(0,canvas.height)))
            let h = C4Line((C4Point(),C4Point(canvas.width,0)))
            lines.append((v,h))
            canvas.add(v)
            canvas.add(h)
        }

        canvas.backgroundColor = darkGray

        canvas.addPanGestureRecognizer { (location, translation, velocity, state, locations) -> () in
            for i in 0..<self.lines.count {
                let v = self.lines[i].0
                let h = self.lines[i].1

                C4ViewAnimation(duration: 0) {
                    if i < locations.count {
                        v.origin = C4Point(locations[i].x,0)
                        h.origin = C4Point(0,locations[i].y)
                    } else {
                        v.origin = C4Point(-1,0)
                        h.origin = C4Point(0,-1)
                    }
                }.animate()
            }
        }
    }
}