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
        for i in 1...5 {
            let left = canvas.addSwipeGestureRecognizer() { location, state, direction in
                let a = Arrows(count: i, direction: direction)
                a.center = location
                self.canvas.add(a)
            }
            left.numberOfTouchesRequired = i
            left.direction = .Left

            let down = canvas.addSwipeGestureRecognizer() { location, state, direction in
                let a = Arrows(count: i, direction: direction)
                a.center = location
                self.canvas.add(a)
            }
            down.numberOfTouchesRequired = i
            down.direction = .Down

            let right = canvas.addSwipeGestureRecognizer() { location, state, direction in
                let a = Arrows(count: i, direction: direction)
                a.center = location
                self.canvas.add(a)
            }
            right.numberOfTouchesRequired = i

            let up = canvas.addSwipeGestureRecognizer() { location, state, direction in
                let a = Arrows(count: i, direction: direction)
                a.center = location
                self.canvas.add(a)
            }
            up.numberOfTouchesRequired = i
            up.direction = .Up
        }
    }
}

class Arrows: C4View {
    convenience init(count: Int, direction: UISwipeGestureRecognizerDirection) {
        C4ShapeLayer.disableActions = true
        self.init(frame: C4Rect(0,0,10,10))
        switch direction {
        case UISwipeGestureRecognizerDirection.Up:
            self.transform = C4Transform.makeRotation(M_PI_2)
        case UISwipeGestureRecognizerDirection.Left:
            self.transform = C4Transform.makeRotation(M_PI)
        case UISwipeGestureRecognizerDirection.Down:
            self.transform = C4Transform.makeRotation(-M_PI_2)
        default:
            _ = ""
        }

        let offset = C4Point(0,-Double(count) / 2.0 * 10.0)
        C4ShapeLayer.disableActions = false

        var anims = [C4ViewAnimation]()
        for i in 0..<count {
            let point = offset + C4Point(0,10) * i
            let c = C4Circle(center: point, radius: 5)
            add(c)

            let anim = C4ViewAnimation(duration: 0.25) {
                c.center = C4Point(100,c.center.y)
            }
            anim.addCompletionObserver() {
                c.removeFromSuperview()
            }
            anims.append(anim)
        }
        C4ViewAnimationGroup(animations: anims).animate()
    }
}