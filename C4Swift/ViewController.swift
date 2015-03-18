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
    var shapes = [String:C4Shape]()
    
    override func viewDidLoad() {
        taurus()
        aries()
        gemini()
        cancer()
        leo()
        virgo()
        libra()
        pices()
        aquarius()
        sagittarius()
        capricorn()
        scorpio()

        for shape in [C4Shape](shapes.values) {
            canvas.add(shape)
        }
        
        let anim = C4ViewAnimation(duration: 1.0) { () -> Void in
            for shape in [C4Shape](self.shapes.values) {
                if(shape.strokeEnd < 1.0) { shape.strokeEnd = 1.0 }
                else { shape.strokeEnd = 0.001 }
            }
        }

        canvas.addTapGestureRecognizer { (location, state) -> () in
            anim.animate()
        }
    }
    
    func taurus() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(0, 0))
        bezier.addCurveToPoint( C4Point(6.3, 0), control2:C4Point(6.4, 10.2), point: C4Point(15.2, 10.2))
        bezier.addCurveToPoint( C4Point(20.8, 10.2), control2:C4Point(25.4, 14.8), point: C4Point(25.4, 20.4))
        bezier.addCurveToPoint( C4Point(25.4, 26), control2:C4Point(20.8, 30.6), point: C4Point(15.2, 30.6))
        bezier.addCurveToPoint( C4Point(9.6, 30.6), control2:C4Point(5, 26), point: C4Point(5, 20.4))
        bezier.addCurveToPoint( C4Point(5, 14.8), control2:C4Point(9.6, 10.2), point: C4Point(15.2, 10.2))
        bezier.addCurveToPoint( C4Point(24, 10.2), control2:C4Point(24.1, 0), point: C4Point(30.4, 0))
        
        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
//        shape.shapeLayer.anchorPoint = CGPointZero
        
        shape.origin = C4Point(25,25)
        shapes["taurus"] = shape
    }

    func aries() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(2.8, 15.5))
        bezier.addCurveToPoint( C4Point(1.1, 13.9), control2:C4Point(0, 11.6), point: C4Point(0, 9))
        bezier.addCurveToPoint( C4Point(0, 4), control2:C4Point(4, 0), point: C4Point(9, 0))
        bezier.addCurveToPoint( C4Point(14, 0), control2:C4Point(18, 4), point: C4Point(18, 9))
        bezier.addLineToPoint(C4Point(18, 28.9))
        
        bezier.moveToPoint(C4Point(18, 28.9))
        bezier.addLineToPoint(C4Point(18, 9))
        bezier.addCurveToPoint( C4Point(18, 4), control2:C4Point(22, 0), point: C4Point(27, 0))
        bezier.addCurveToPoint( C4Point(32, 0), control2:C4Point(36, 4), point: C4Point(36, 9))
        bezier.addCurveToPoint( C4Point(36, 11.6), control2:C4Point(34.9, 13.9), point: C4Point(33.2, 15.5))
        
        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear

//        shape.shapeLayer.anchorPoint = CGPointMake(2.8, 15.5)
        
        shape.origin = C4Point(25,75)
        shapes["aries"] = shape
    }

    func gemini() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(26, 0))
        bezier.addCurveToPoint( C4Point(26, 0), control2:C4Point(24.2, 5.3), point: C4Point(13, 5.3))
        bezier.addCurveToPoint( C4Point(1.8, 5.3), control2:C4Point(0, 0), point: C4Point(0, 0))
        
        bezier.moveToPoint(C4Point(0.1, 34.7))
        bezier.addCurveToPoint( C4Point(0.1, 34.7), control2:C4Point(1.9, 29.4), point: C4Point(13.1, 29.4))
        bezier.addCurveToPoint( C4Point(24.3, 29.4), control2:C4Point(26.1, 34.7), point: C4Point(26.1, 34.7))
        
        bezier.moveToPoint(C4Point(8.1, 5))
        bezier.addLineToPoint(C4Point(8.1, 29.6))
        
        bezier.moveToPoint(C4Point(18, 5))
        bezier.addLineToPoint(C4Point(18, 29.6))

        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear

        shape.origin = C4Point(25,125)

        shapes["gemini"] = shape
    }

    func cancer() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(0, 8.1))
        bezier.addCurveToPoint( C4Point(1.9, 4.5), control2:C4Point(6.4, 0), point: C4Point(14.2, 0))
        bezier.addCurveToPoint( C4Point(22.1, 0), control2:C4Point(28.4, 4), point: C4Point(28.4, 8.8))
        bezier.addCurveToPoint( C4Point(28.4, 11.7), control2:C4Point(26.1, 14), point: C4Point(23.2, 14))
        bezier.addCurveToPoint( C4Point(20.3, 14), control2:C4Point(18, 11.7), point: C4Point(18, 8.8))
        bezier.addCurveToPoint( C4Point(18, 5.9), control2:C4Point(20.3, 3.6), point: C4Point(23.2, 3.6))
        bezier.addCurveToPoint( C4Point(26.1, 3.6), control2:C4Point(28.4, 5.9), point: C4Point(28.4, 8.8))

        bezier.moveToPoint(C4Point(28.4, 21.3))
        bezier.addCurveToPoint( C4Point(26.5, 24.9), control2:C4Point(22, 29.4), point: C4Point(14.2, 29.4))
        bezier.addCurveToPoint( C4Point(6.3, 29.4), control2:C4Point(0, 25.4), point: C4Point(0, 20.6))
        bezier.addCurveToPoint( C4Point(0, 17.7), control2:C4Point(2.3, 15.4), point: C4Point(5.2, 15.4))
        bezier.addCurveToPoint( C4Point(8.1, 15.4), control2:C4Point(10.4, 17.7), point: C4Point(10.4, 20.6))
        bezier.addCurveToPoint( C4Point(10.4, 23.5), control2:C4Point(8.1, 25.8), point: C4Point(5.2, 25.8))
        bezier.addCurveToPoint( C4Point(2.3, 25.8), control2:C4Point(0, 23.5), point: C4Point(0, 20.6))

        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
        shape.origin = C4Point(25, 175)
        
        shapes["cancer"] = shape
    }
    
    func leo() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(10.4, 19.6))
        bezier.addCurveToPoint( C4Point(10.4, 16.7), control2:C4Point(8.1, 14.4), point: C4Point(5.2, 14.4))
        bezier.addCurveToPoint( C4Point(2.3, 14.4), control2:C4Point(0, 16.7), point: C4Point(0, 19.6))
        bezier.addCurveToPoint( C4Point(0, 22.5), control2:C4Point(2.3, 24.8), point: C4Point(5.2, 24.8))
        bezier.addCurveToPoint( C4Point(8.1, 24.8), control2:C4Point(10.4, 22.4), point: C4Point(10.4, 19.6))
        bezier.addCurveToPoint( C4Point(10.4, 14.8), control2:C4Point(6, 15), point: C4Point(6, 9.1))
        bezier.addCurveToPoint( C4Point(6, 4), control2:C4Point(10.1, 0), point: C4Point(15.1, 0))
        bezier.addCurveToPoint( C4Point(20.1, 0), control2:C4Point(24.2, 4.1), point: C4Point(24.2, 9.1))
        bezier.addCurveToPoint( C4Point(24.2, 17.2), control2:C4Point(17, 18.5), point: C4Point(17, 25.6))
        bezier.addCurveToPoint( C4Point(17, 28.5), control2:C4Point(19.3, 30.8), point: C4Point(22.2, 30.8))
        bezier.addCurveToPoint( C4Point(25.1, 30.8), control2:C4Point(27.4, 28.5), point: C4Point(27.4, 25.6))
        
        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
        shape.origin = C4Point(25,225)
        
        shapes["leo"] = shape
    }

    func virgo() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(30, 12.2))
        bezier.addCurveToPoint( C4Point(30, 9.4), control2:C4Point(32.2, 7.2), point: C4Point(35, 7.2))
        bezier.addCurveToPoint( C4Point(37.8, 7.2), control2:C4Point(40, 9.4), point: C4Point(40, 12.2))
        bezier.addCurveToPoint( C4Point(40, 23.7), control2:C4Point(24.3, 31.5), point: C4Point(24.3, 31.5))

        bezier.moveToPoint(C4Point(10, 24.1))
        bezier.addLineToPoint(C4Point(10, 5))
        bezier.addCurveToPoint( C4Point(10, 2.2), control2:C4Point(7.8, 0), point: C4Point(5, 0))
        bezier.addCurveToPoint( C4Point(2.2, 0), control2:C4Point(0, 2.2), point: C4Point(0, 5))

        bezier.moveToPoint(C4Point(20, 24.1))
        bezier.addLineToPoint(C4Point(20, 5))
        bezier.addCurveToPoint( C4Point(20, 2.2), control2:C4Point(17.8, 0), point: C4Point(15, 0))
        bezier.addCurveToPoint( C4Point(12.2, 0), control2:C4Point(10, 2.2), point: C4Point(10, 5))

        bezier.moveToPoint(C4Point(39.1, 29.8))
        bezier.addCurveToPoint( C4Point(34.5, 29.8), control2:C4Point(30, 28), point: C4Point(30, 19.2))
        bezier.addLineToPoint(C4Point(30, 5))
        bezier.addCurveToPoint( C4Point(30, 2.2), control2:C4Point(27.8, 0), point: C4Point(25, 0))
        bezier.addCurveToPoint( C4Point(22.2, 0), control2:C4Point(20, 2.2), point: C4Point(20, 5))
        
        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
        shape.origin = C4Point(25,275)
        shapes["virgo"] = shape
    }

    func libra() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(37.5, 11.3))
        bezier.addLineToPoint(C4Point(30, 11.3))
        bezier.addCurveToPoint( C4Point(30, 5.1), control2:C4Point(24.9, 0), point: C4Point(18.7, 0))
        bezier.addCurveToPoint( C4Point(12.5, 0), control2:C4Point(7.4, 5.1), point: C4Point(7.4, 11.3))
        bezier.addLineToPoint(C4Point(0, 11.3))
        
        bezier.moveToPoint(C4Point(0, 20.2))
        bezier.addLineToPoint(C4Point(37.5, 20.2))

        
        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
        shape.origin = C4Point(75, 25)
        shapes["libra"] = shape
    }

    func pices() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(2.8, 0.1))
        bezier.addCurveToPoint( C4Point(2.8, 0.1), control2:C4Point(9.2, 1.9), point: C4Point(9.2, 13.1))
        bezier.addCurveToPoint( C4Point(9.2, 24.3), control2:C4Point(2.8, 26.1), point: C4Point(2.8, 26.1))

        bezier.moveToPoint(C4Point(25.4, 26))
        bezier.addCurveToPoint( C4Point(25.4, 26), control2:C4Point(19, 24.2), point: C4Point(19, 13))
        bezier.addCurveToPoint( C4Point(19, 1.8), control2:C4Point(25.4, 0), point: C4Point(25.4, 0))

        bezier.moveToPoint(C4Point(0, 13.1))
        bezier.addLineToPoint(C4Point(28.2, 13.1))

        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
        shape.origin = C4Point(75, 75)
        
        shapes["pices"] = shape
    }
    
    func aquarius() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(0, 5.4))
        bezier.addCurveToPoint( C4Point(4.5, 5.4), control2:C4Point(3.6, 0), point: C4Point(8.2, 0))
        bezier.addCurveToPoint( C4Point(12.7, 0), control2:C4Point(11.8, 5.4), point: C4Point(16.3, 5.4))
        bezier.addCurveToPoint( C4Point(20.8, 5.4), control2:C4Point(19.9, 0), point: C4Point(24.5, 0))
        bezier.addCurveToPoint( C4Point(29, 0), control2:C4Point(28.1, 5.4), point: C4Point(32.6, 5.4))
        bezier.addCurveToPoint( C4Point(37.1, 5.4), control2:C4Point(36.2, 0), point: C4Point(40.7, 0))
        
        bezier.moveToPoint(C4Point(40.7, 15.1))
        bezier.addCurveToPoint( C4Point(36.2, 15.1), control2:C4Point(37.1, 20.5), point: C4Point(32.6, 20.5))
        bezier.addCurveToPoint( C4Point(28.1, 20.5), control2:C4Point(29, 15.1), point: C4Point(24.5, 15.1))
        bezier.addCurveToPoint( C4Point(19.9, 15.1), control2:C4Point(20.8, 20.5), point: C4Point(16.3, 20.5))
        bezier.addCurveToPoint( C4Point(11.8, 20.5), control2:C4Point(12.7, 15.1), point: C4Point(8.2, 15.1))
        bezier.addCurveToPoint( C4Point(3.6, 15.1), control2:C4Point(4.5, 20.5), point: C4Point(0, 20.5))

        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
        shape.origin = C4Point(75,125)
        
        shapes["aquarius"] = shape
    }

    func sagittarius() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(30.4, 10.6))
        bezier.addLineToPoint(C4Point(30.4, 0))
        bezier.addLineToPoint(C4Point(19.8, 0))

        bezier.moveToPoint(C4Point(7.8, 10.5))
        bezier.addLineToPoint(C4Point(13.9, 16.5))
        bezier.addLineToPoint(C4Point(0, 30.4))

        bezier.moveToPoint(C4Point(30.3, 0.1))
        bezier.addLineToPoint(C4Point(13.9, 16.5))
        bezier.addLineToPoint(C4Point(20, 22.7))

        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
        shape.origin = C4Point(75, 175)
        
        shapes["sagittarius"] = shape
    }

    func capricorn() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(13, 22.3))
        bezier.addLineToPoint(C4Point(13, 6.5))
        bezier.addCurveToPoint( C4Point(13, 2.9), control2:C4Point(10.1, 0), point: C4Point(6.5, 0))
        bezier.addCurveToPoint( C4Point(2.9, 0), control2:C4Point(0, 2.9), point: C4Point(0, 6.5))
        
        bezier.moveToPoint(C4Point(13, 6.5))
        bezier.addCurveToPoint( C4Point(13, 2.9), control2:C4Point(15.9, 0), point: C4Point(19.5, 0))
        bezier.addCurveToPoint( C4Point(23.1, 0), control2:C4Point(26, 2.9), point: C4Point(26, 6.5))
        bezier.addCurveToPoint( C4Point(26, 16.3), control2:C4Point(27.6, 19.6), point: C4Point(29.9, 22.9))
        bezier.addCurveToPoint( C4Point(32.2, 26.3), control2:C4Point(35.2, 27.7), point: C4Point(37.7, 27.7))
        bezier.addCurveToPoint( C4Point(41.8, 27.7), control2:C4Point(45.2, 24.4), point: C4Point(45.2, 20.3))
        bezier.addCurveToPoint( C4Point(45.2, 16.2), control2:C4Point(41.9, 12.9), point: C4Point(37.8, 12.9))
        bezier.addCurveToPoint( C4Point(32.1, 12.9), control2:C4Point(30.7, 18.5), point: C4Point(29.9, 22.9))
        bezier.addCurveToPoint( C4Point(28.3, 31.7), control2:C4Point(22.4, 33.6), point: C4Point(17.1, 33.6))

        
        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear
        
        shape.origin = C4Point(75, 225)
        
        shapes["capricorn"] = shape
    }
    
    func scorpio() {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(10, 24.1))
        bezier.addLineToPoint(C4Point(10, 5))
        bezier.addCurveToPoint( C4Point(10, 2.2), control2:C4Point(7.8, 0), point: C4Point(5, 0))
        bezier.addCurveToPoint( C4Point(2.2, 0), control2:C4Point(0, 2.2), point: C4Point(0, 5))

        bezier.moveToPoint(C4Point(20, 24.1))
        bezier.addLineToPoint(C4Point(20, 5))
        bezier.addCurveToPoint( C4Point(20, 2.2), control2:C4Point(17.8, 0), point: C4Point(15, 0))
        bezier.addCurveToPoint( C4Point(12.2, 0), control2:C4Point(10, 2.2), point: C4Point(10, 5))

        bezier.moveToPoint(C4Point(39.1, 31.1))
        bezier.addCurveToPoint( C4Point(36, 28.1), control2:C4Point(30, 23.9), point: C4Point(30, 15.1))
        bezier.addLineToPoint(C4Point(30, 5))
        bezier.addCurveToPoint( C4Point(30, 2.2), control2:C4Point(27.8, 0), point: C4Point(25, 0))
        bezier.addCurveToPoint( C4Point(22.2, 0), control2:C4Point(20, 2.2), point: C4Point(20, 5))

        bezier.moveToPoint(C4Point(39.2, 20.5))
        bezier.addLineToPoint(C4Point(39.2, 31.1))
        bezier.addLineToPoint(C4Point(28.6, 31.1))

        var shape = C4Shape(bezier)
        shape.lineCap = .Round
        shape.lineJoin = .Round
        shape.lineWidth = 3
        shape.strokeColor = black
        shape.fillColor = clear

        shape.origin = C4Point(75, 275)
        
        shapes["scorpio"] = shape
    }

}