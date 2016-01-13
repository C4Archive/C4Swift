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
        let lines = SlackLogo()
        let squares = SlackLogo()
        squares.isSquares = true
        let container = C4View(frame: lines.bounds)
//        container.center = canvas.center
//        let img = C4Image("slackLogo")
//        canvas.add(img)

        container.add(lines)
        container.add(squares)
        canvas.add(container)

        canvas.addTapGestureRecognizer { (location, state) -> () in
            lines.animate()
            squares.animate()
        }

    }
}