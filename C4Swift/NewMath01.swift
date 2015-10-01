//
//  NewMath01.swift
//  C4Examples
//
//  Created by Oliver Andrews on 2015-09-21.
//  Copyright © 2015 Slant. All rights reserved.
//

import C4
import UIKit

class NewMath01: C4CanvasController {
    var mainPoints = [C4Point]()
    var modifiedPoints = [C4Point]()
    var insetFrame = C4Rect()
    override func setup() {
        let margin = canvas.frame.size.height * 0.1
        insetFrame = inset(canvas.frame, dx: margin, dy: margin)
        createPoints()

        let path = MathComparePaths(frame: canvas.frame, insetFrame: insetFrame, points: mainPoints, modifiedPoints: modifiedPoints)
        path.center = canvas.center
        canvas.add(path)
    }

    func createPoints() {
        var x = 0.0
        repeat {
            //normalize position of x to frame width
            let nX = x / insetFrame.size.width
            //define period for curve
            let period = 2 * M_PI
            //define scale (-1 inverts from CoreGraphics orientation)
            let scale = -1 * insetFrame.size.height / 2.0
            //define offset for y
            let offset = insetFrame.size.height / 2.0
            //calculate y
            let my = clamp(sin(nX * period), min: -0.5, max: 0.5) * scale + offset
            let y = sin(nX * period) * scale + offset

            let mp = C4Point(x+insetFrame.origin.x,my+insetFrame.origin.y)
            let p = C4Point(x+insetFrame.origin.x,y+insetFrame.origin.x)

            //append the point to the array
            modifiedPoints.append(mp)
            mainPoints.append(p)
            //increment x
            x += 1.0
        } while x < insetFrame.size.width
    }
}

class MathComparePaths : C4View {
    var whitePath : C4Shape?
    var grayPath : C4Shape?
    var maskPath : C4Shape?
    var button : C4Shape?
    var gradient : C4Gradient?

    var mainPoints : [C4Point]?
    var modifiedPoints : [C4Point]?
    var distances = [0.0]
    var totalDistance = 0.0
    var dIndex = 0.0
    var insetFrame = C4Rect()

    convenience init(frame: C4Rect, insetFrame: C4Rect, points: [C4Point], modifiedPoints: [C4Point]) {
        self.init()
        self.frame = frame
        self.insetFrame = insetFrame
        self.mainPoints = points
        self.modifiedPoints = modifiedPoints

        calculateDistances()
        createMaskPath()
        createGradient()
        createWhitePath()
        createGrayPath()
        createButton()

        self.add(gradient)
        self.add(grayPath)
        self.add(whitePath)
        self.add(button)
    }

    func calculateDistances() {
        if let mp = modifiedPoints {
            var prev = mp.first!

            for i in 1..<mp.count {
                let curr = mp[i]
                var d = distance(prev, rhs: curr)
                d += distances.last!
                distances.append(d)
                prev = curr
            }

            dIndex = Double(distances.count) / 100.0
            totalDistance = distances.last!
        }
    }

    func createGradient() {
        let gr = C4Gradient(frame: frame, colors: [C4Blue,C4Purple], locations: [0,1])
        gr.startPoint = C4Point(insetFrame.origin.x/width,0)
        gr.endPoint = C4Point(insetFrame.max.x/width,0)
        gradient = gr
        gradient?.layer?.mask = maskPath?.layer
    }

    func createMaskPath() {
        let mp = C4Polygon(modifiedPoints!)
        mp.lineWidth = 35.0
        mp.fillColor = clear
        mp.strokeEnd = 0.00001
        maskPath = mp
    }

    func createWhitePath() {
        let wp = C4Polygon(modifiedPoints!)
        wp.lineWidth = 2.0
        wp.fillColor = clear
        wp.strokeColor = white
        wp.opacity = 0.15
        whitePath = wp
    }

    func createGrayPath() {
        let gp = C4Polygon(mainPoints!)
        gp.lineWidth = 3.0
        gp.fillColor = clear
        gp.strokeColor = black
        gp.opacity = 0.1
        grayPath = gp
    }

    func createButton() {
        var s = Shadow()
        s.opacity = 1.0
        s.offset = C4Size(0,2)
        s.radius = 1
        s.opacity = 0.5

        let b = C4Circle(center: C4Point(), radius: 15)
        b.fillColor = white
        b.strokeColor = clear
        b.center = modifiedPoints!.first!
        b.shadow = s

        let kfa = CAKeyframeAnimation()
        kfa.path = maskPath?.path?.CGPath
        kfa.duration = 1.0
        kfa.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        b.layer?.addAnimation(kfa, forKey: "position")
        b.layer?.speed = 0.0

        button = b

        button?.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            C4ShapeLayer.disableActions = true
            guard let b = self.button else {
                print("Could not extract button")
                return
            }

            var converted = self.convert(location, from: b)
            converted.x -= self.insetFrame.origin.x
            converted.x = clamp(converted.x, min: 0, max: self.insetFrame.size.width-0.01)
            converted.x /= self.insetFrame.size.width
            let index = Int(converted.x * 100.0 * self.dIndex)
            b.layer?.timeOffset = CFTimeInterval(clamp(converted.x, min: 0, max: 1.0))

            self.maskPath?.strokeEnd = clamp(self.distances[index]/self.totalDistance, min: 0.00001, max: 1.0)

            if state == .Ended {
                if let pl = b.layer?.presentationLayer() as? CALayer {
                    b.center = C4Point(pl.position)
                }
            }
        }
    }
}
