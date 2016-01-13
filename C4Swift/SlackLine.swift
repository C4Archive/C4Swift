//
//  SlackLine.swift
//  SlackClass
//
//  Created by travis on 2016-01-04.
//  Copyright © 2016 C4. All rights reserved.
//

import C4

var squareCenterOffset = 30.0

class SlackLine: C4View {
    var isSquares = false {
        didSet {
            line.hidden = isSquares
            square.hidden = !isSquares
        }
    }

    var strokeColor: C4Color = C4Blue {
        didSet {
            line.strokeColor = strokeColor
        }
    }
    var squareColor: C4Color = C4Pink {
        didSet {
            square.fillColor = squareColor
        }
    }
    var length: Double
    var squareEdge: Double
    var line: C4Line!
    var square: C4Rectangle!
    var squareMask: C4Line!

    override init() {
        length = 106.0
        squareEdge = 18.0
        square = C4Rectangle(frame: C4Rect(squareCenterOffset-squareEdge/2.0,0,squareEdge,squareEdge))
        line = C4Line(C4Point(squareEdge/2.0,squareEdge/2.0),C4Point(length-squareEdge/2.0,squareEdge/2.0))
        let maskXOffset = square.origin.x - line.points[0].x
        squareMask = C4Line(C4Point(-maskXOffset,squareEdge/2.0),C4Point(line.points[1].x-line.points[0].x-maskXOffset,squareEdge/2.0))
        super.init()
        self.frame = C4Rect(0,0,106,squareEdge)
        setup()
    }
    
    func setup() {
        line.lineWidth = squareEdge
        add(line)

        square.corner = C4Size()
        square.lineWidth = 0
        square.hidden = true
        add(square)
        squareMask.lineWidth = squareEdge
        square.mask = squareMask
    }
    
    func animate() {

        let strokeStartTo1 = C4ViewAnimation(duration: 0.35*10) {
            self.line.strokeStart = 1.0
            self.squareMask.strokeStart = 1.0
        }
        strokeStartTo1.curve = .EaseInOut

        let animateIn = C4ViewAnimation(duration: 0.15*10) {
            var point = self.line.center
            point.x -= 22
            point.y += 22
            self.line.center = point
        }
        animateIn.delay = 0.3
        animateIn.curve = .EaseOut
        let animateOut = C4ViewAnimation(duration: 0.15*10) {
            var point = self.line.center
            point.x += 22
            point.y -= 22
            self.line.center = point
        }
        animateOut.curve = .EaseIn

        let strokeStartTo0 = C4ViewAnimation(duration: 0.35*10) {
            self.line.strokeStart = 0.0
            self.squareMask.strokeStart = 0.0
        }
        strokeStartTo0.curve = .EaseInOut
        strokeStartTo0.delay = 0.25
        let seq = C4ViewAnimationSequence(animations: [strokeStartTo1, animateIn, animateOut, strokeStartTo0])
        seq.animate()

    }
    
}