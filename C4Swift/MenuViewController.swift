//
//  MenuViewController.swift
//  C4Swift
//
//  Created by travis on 2015-04-14.
//  Copyright (c) 2015 C4. All rights reserved.
//

import Foundation

import UIKit
import C4UI
import C4Core
import C4Animation

let cosmosbkgd = C4Color(red:0.078, green:0.118, blue:0.306, alpha:1.0)
let cosmosblue = C4Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)

class MenuViewController: UIViewController {
    var circles = [C4Circle]()
    var wedge = C4Wedge()
    var out = true
    var animateOut = C4ViewAnimationSequence(animations: [C4ViewAnimation]())
    var animateIn = C4ViewAnimationSequence(animations: [C4ViewAnimation]())
    var frames = [C4Rect]()
    var outerCircle = C4Circle()
    var lines = [C4Line]()
    var linesOut = [C4ViewAnimation]()
    var linesIn = [C4ViewAnimation]()
    var menuVisible = false
    var shouldRevert = false
    var thickCircle = C4Circle()
    var thickCircleFrames = [C4Rect]()
    var logosOrder = ["aries", "taurus", "gemini", "cancer", "leo", "virgo", "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"]
    var currentSelection = 0
    var dashedCircles = [C4Circle]()
    
    /*
    Next steps:
    3) add longpress changed tracking to see which logo is selected
    */
    
    override func viewDidLoad() {
        canvas.backgroundColor = clear
        
        createCircles()
        addDashedCircles()
        createLines()
        createOutAnimations()
        createInAnimations()
        createGesture()
        
        layoutHighlight()
        
        createLogos()
        positionLogos()
    }
    
    var innerTargets = [C4Point]()
    var outerTargets = [C4Point]()
    
    func positionLogos() {
        var r = 10.5
        let dx = canvas.center.x
        let dy = canvas.center.y
        for i in 0..<logosOrder.count {
            var ϴ = M_PI/6 * Double(i)
            let name = logosOrder[i]
            if let sign = logos[name] {
                sign.center = C4Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy)
                canvas.add(sign)
                
                sign.anchorPoint = C4Point(0.5,0.5)
                innerTargets.append(sign.center)
            }
        }
        
        for i in 0..<logosOrder.count {
            let r = 129.0
            let ϴ = M_PI/6 * Double(i) + M_PI/12.0
            outerTargets.append(C4Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy))
        }
    }
    
    func createCircles() {
        thickCircle = C4Circle(center: canvas.center, radius: 14)
        circles.append(C4Circle(center: canvas.center, radius: 8))
        circles.append(C4Circle(center: canvas.center, radius: 56))
        circles.append(C4Circle(center: canvas.center, radius: 78))
        circles.append(C4Circle(center: canvas.center, radius: 98))
        circles.append(C4Circle(center: canvas.center, radius: 102))
        circles.append(C4Circle(center: canvas.center, radius: 156))
        
        let inner = C4Circle(center: canvas.center, radius: 14)
        let outer = C4Circle(center: canvas.center, radius: 225)
        
        thickCircleFrames.append(inner.frame)
        thickCircleFrames.append(outer.frame)
        
        C4ViewAnimation(duration: 0.0) {
            self.thickCircle.fillColor = clear
            self.thickCircle.lineWidth = 3
            self.thickCircle.strokeColor = cosmosblue
            self.thickCircle.interactionEnabled = false
            
            for i in 0..<self.circles.count {
                var circle = self.circles[i]
                circle.fillColor = clear
                circle.lineWidth = 1
                circle.strokeColor = cosmosblue
                circle.interactionEnabled = false
                if i > 0 {
                    circle.opacity = 0.0
                }
                self.frames.append(circle.frame)
            }
        }.animate()

        
        canvas.add(thickCircle)
        for circle in circles {
            canvas.add(circle)
        }
    }
    
    func createGesture() {
        canvas.addLongPressGestureRecognizer { (location, state) -> () in
            switch state {
            case .Began:
                self.menuOut()
            case .Cancelled, .Ended, .Failed:
                self.canvas.interactionEnabled = false
                if !self.wedge.hidden {
                    println("\(self.logosOrder[self.currentSelection])")
                    self.wedge.hidden = true
                } else {
                    println("no selection")
                }
                if self.menuVisible {
                    self.menuIn()
                } else {
                    self.shouldRevert = true
                }
            case .Changed:
                self.moveWedge(location)
            default:
                let i = 0
            }
        }
    }
    
    func randomOut() {
        var indices = [0,1,2,3,4,5,6,7,8,9,10,11]
        
        for i in 0...11 {
            delay(0.05*Double(i)) {
                let randomIndex = random(below: indices.count)
                let index = indices[randomIndex]
                let a = C4ViewAnimation(duration: 0.1) {
                    self.lines[index].strokeEnd = 1.0
                }
                a.animate()
                indices.removeAtIndex(randomIndex)
            }
        }
    }
    
    func randomIn() {
        var indices = [0,1,2,3,4,5,6,7,8,9,10,11]
        
        for i in 0...11 {
            delay(0.05*Double(i)) {
                let randomIndex = random(below: indices.count)
                let index = indices[randomIndex]
                
                let a = C4ViewAnimation(duration: 0.1) {
                    self.lines[index].strokeEnd = 0.0
                }
                a.animate()
                indices.removeAtIndex(randomIndex)
            }
        }
    }
    
    func menuOut() {
        self.out = false
        self.menuVisible = false
        var thickCircleOut = C4ViewAnimation(duration: 0.5) {
            self.thickCircle.frame = self.thickCircleFrames[1]
            self.thickCircle.updatePath()
        }
        thickCircleOut.curve = .EaseOut
        thickCircleOut.animate()
        
        self.animateOut.animate()
        
        let logosOut = C4ViewAnimation(duration: 0.33) {
            for i in 0..<self.logosOrder.count {
                let name = self.logosOrder[i]
                if let sign = self.logos[name] {
                    sign.center = self.outerTargets[i]
                }
            }
        }
        
        logosOut.curve = .EaseOut
        logosOut.animate()
        
        let logosReveal = C4ViewAnimation(duration: 0.5) {
            for sign in [C4Shape](self.logos.values) {
                sign.strokeEnd = 1.0
            }
        }
        logosReveal.curve = .EaseOut
        
        let dashedCirclesReveal = C4ViewAnimation(duration: 0.25) {
            self.dashedCircles[0].lineWidth = 4
            self.dashedCircles[1].lineWidth = 12
        }
        dashedCirclesReveal.curve = .EaseOut
        
        
        delay(0.33) {
            self.randomOut()
            logosReveal.animate()
        }
        delay(0.66) {
            dashedCirclesReveal.animate()
        }
        delay(1.0) {
            self.menuVisible = true
            if self.shouldRevert {
                self.menuIn()
                self.shouldRevert = false
            }
        }
    }
    
    func menuIn() {
        self.out = true
        self.randomIn()
        
        let logosIn = C4ViewAnimation(duration: 0.33) {
            for i in 0..<self.logosOrder.count {
                let name = self.logosOrder[i]
                if let sign = self.logos[name] {
                    sign.center = self.innerTargets[i]
                }
            }
        }
        logosIn.curve = .EaseOut
        
        let logosHide = C4ViewAnimation(duration: 0.5) {
            for sign in [C4Shape](self.logos.values) {
                sign.strokeEnd = 0.001
            }
        }
        logosHide.curve = .EaseOut
        
        let dashedCirclesHide = C4ViewAnimation(duration: 0.25) {
            self.dashedCircles[0].lineWidth = 0
            self.dashedCircles[1].lineWidth = 0
        }
        dashedCirclesHide.curve = .EaseOut
        
        dashedCirclesHide.animate()
        
        delay(0.16) {
            logosHide.animate()
        }
        delay(0.33) {
            self.animateIn.animate()
        }
        delay(0.66) {
            logosIn.animate()
            var thickCircleIn = C4ViewAnimation(duration: 0.5) {
                self.thickCircle.frame = self.thickCircleFrames[0]
                self.thickCircle.updatePath()
            }
            thickCircleIn.curve = .EaseOut
            thickCircleIn.animate()
            self.canvas.interactionEnabled = true
        }
    }
    
    func animateMenu(lines: [C4ViewAnimation]) {
        let dt = 0.05
        
        for i in 0..<lines.count {
            delay(dt*Double(i)){
                lines[i].animate()
            }
        }
    }
    
    func createMenuAnimations() {
        for i in 0...self.lines.count-1 {
            let anim = C4ViewAnimation(duration: 0.05) {
                let line = self.lines[i]
                line.strokeEnd = 1.0
            }
            anim.curve = .EaseOut
            linesOut.append(anim)
        }
        
        for i in 1...self.lines.count {
            let anim = C4ViewAnimation(duration: 0.05) {
                let line = self.lines[self.lines.count - i]
                line.strokeEnd = 0.0
            }
            anim.curve = .EaseOut
            linesIn.append(anim)
        }
    }
    
    func createLines() {
        for i in 0...11 {
            var line = C4Line([C4Point(),C4Point(54,0)])
            C4ViewAnimation(duration: 0) {
                line.layer?.anchorPoint = CGPointMake(-1.88888,0)
                line.center = self.canvas.center
                var rot = C4Transform()
                rot.rotate(M_PI / 6.0 * Double(i) , axis: C4Vector(x: 0, y: 0, z: -1))
                line.transform = rot
                line.strokeColor = cosmosblue
                line.lineWidth = 1.0
                line.strokeEnd = 0.0
                }.animate()
            canvas.add(line)
            lines.append(line)
        }
    }
    
    func createOutAnimations() {
        var animationsOut = [C4ViewAnimation]()
        for i in 0..<self.circles.count-1 {
            
            let anim = C4ViewAnimation(duration: 0.075 + Double(i) * 0.01, animations: { () -> Void in
                var circle = self.circles[i]
                if ( i > 0) {
                    let opacity = C4ViewAnimation(duration: 0.0375, animations: { () -> Void in
                        circle.opacity = 1.0
                    })
                    opacity.animate()
                }
                
                circle.frame = self.frames[i+1]
                circle.updatePath()
            })
            anim.curve = .EaseOut
            animationsOut.append(anim)
        }
        
        animateOut = C4ViewAnimationSequence(animations: animationsOut)
    }
    
    func createInAnimations() {
        var animations = [C4ViewAnimation]()
        
        let outerCircleIn = C4ViewAnimation(duration: 0.25) { () -> Void in
            //            self.outerCircle.strokeEnd = 0.0
            
            var reverseAnims = [C4ViewAnimation]()
            for i in 1...self.circles.count {
                let anim = C4ViewAnimation(duration: 0.075 + Double(i) * 0.01, animations: { () -> Void in
                    var circle = self.circles[self.circles.count - i]
                    if self.circles.count - i > 0 {
                        let opacity = C4ViewAnimation(duration: 0.0375, animations: { () -> Void in
                            circle.opacity = 0.0
                        })
                        opacity.animate()
                    }
                    circle.frame = self.frames[self.circles.count - i]
                    circle.updatePath()
                })
                anim.curve = .EaseOut
                reverseAnims.append(anim)
            }
            
            let reverseSequence = C4ViewAnimationSequence(animations: reverseAnims)
            delay(0.25, { () -> () in
                reverseSequence.animate()
            })
        }
        outerCircleIn.curve = .EaseOut
        animations.append(outerCircleIn)
        
        animateIn = C4ViewAnimationSequence(animations: animations)
    }
    
    func layoutHighlight() {
        var path = C4Path()
        path.addEllipse(C4Rect(-156,-156,312,312))
        path.addEllipse(C4Rect((312-204)/2-156,(312-204)/2-156,204,204))
        
        var donut = C4Shape(path)
        donut.fillRule = .EvenOdd
        
        wedge = C4Wedge(center: canvas.center, radius: 156, start: 0.0, end: M_PI/6.0)
        wedge.fillColor = cosmosblue
        wedge.lineWidth = 0.0
        wedge.interactionEnabled = false
        wedge.layer?.mask = donut.layer
        wedge.layer?.anchorPoint = CGPointZero
        wedge.center = canvas.center
        wedge.hidden = true
        canvas.add(wedge)
    }
    
    func moveWedge(location: C4Point) {
        
        let a = C4Vector(x:self.canvas.center.x+1.0, y:self.canvas.center.y)
        let b = C4Vector(x:self.canvas.center.x, y:self.canvas.center.y)
        let c = C4Vector(x:location.x, y:location.y)
        
        let dist = distance(location, self.canvas.center)
        
        if dist > 102.0 && dist < 156 {
            wedge.hidden = false
            var angle = c.angleTo(a, basedOn: b)
            
            if c.y < a.y {
                angle = 2*M_PI - angle
            }
            
            var newSelection = Int(radToDeg(angle)) / 30
            
            if self.currentSelection != newSelection {
                self.currentSelection = newSelection
                var rotation = C4Transform()
                rotation.rotate(degToRad(Double(self.currentSelection) * 30.0), axis: C4Vector(x:0,y:0,z:-1))
                self.wedge.transform = rotation
            }
        } else {
            wedge.hidden = true
        }
        
    }
    
    func addDashedCircles() {
        dashedCircles.append(C4Circle(center: canvas.center, radius: 82+2))
        dashedCircles.append(C4Circle(center: canvas.center, radius: 82+2))
        
        C4ViewAnimation(duration: 0.0) {
            let c = self.dashedCircles[0]
            c.lineWidth = 0
            var pattern = [1.465,1.465,1.465,1.465,1.465,1.465,1.465,1.465*3.0] as [NSNumber]
            c.lineDashPattern = pattern
            var rotation = C4Transform()
            c.strokeEnd = 0.995
            rotation.rotate(-3.0*M_PI/360.0, axis: C4Vector(x: 0, y: 0, z: 1.0))
            c.transform = rotation
            
            let d = self.dashedCircles[1]
            d.lineWidth = 0
            
            pattern = [1.465,1.465*9.0] as [NSNumber]
            d.lineDashPattern = pattern
            d.strokeEnd = 0.995
            
            rotation = C4Transform()
            rotation.rotate(M_PI/360.0, axis: C4Vector(x: 0, y: 0, z: 1.0))
            d.transform = rotation
            var mask = C4Circle(center: C4Point(d.width/2.0,d.height/2.0), radius: 82+4)
            mask.fillColor = clear
            mask.strokeColor = red
            mask.lineWidth = 8
            d.layer?.mask = mask.layer
            
            for circle in self.dashedCircles {
                circle.strokeColor = cosmosblue
                circle.fillColor = clear
                circle.interactionEnabled = false
                self.canvas.add(circle)
            }
        }.animate()
    }
    
    func addCircles() {
        circles.append(C4Circle(center: canvas.center, radius: 8))
        circles.append(C4Circle(center: canvas.center, radius: 14))
        circles.append(C4Circle(center: canvas.center, radius: 56))
        circles.append(C4Circle(center: canvas.center, radius: 78))
        circles.append(C4Circle(center: canvas.center, radius: 82+2))
        circles.append(C4Circle(center: canvas.center, radius: 82+2))
        circles.append(C4Circle(center: canvas.center, radius: 98))
        circles.append(C4Circle(center: canvas.center, radius: 102))
        circles.append(C4Circle(center: canvas.center, radius: 156))
        circles.append(C4Circle(center: canvas.center, radius: 225))
        
        for i in 0..<circles.count {
            var circle = circles[i]
            circle.lineWidth = 1
            if i == 1 || i == 2 {
                circle.lineWidth = 3
            }
            
            if i == 4 {
                circle.lineWidth = 4
                var pattern = [1.465,1.465,1.465,1.465,1.465,1.465,1.465,1.465*3.0] as [NSNumber]
                circle.lineDashPattern = pattern
                var rotation = C4Transform()
                circle.strokeEnd = 0.995
                rotation.rotate(-3.0*M_PI/360.0, axis: C4Vector(x: 0, y: 0, z: 1.0))
                circle.transform = rotation
            }
            
            if i == 5 {
                circle.lineWidth = 12
                
                var pattern = [1.465,1.465*9.0] as [NSNumber]
                circle.lineDashPattern = pattern
                circle.strokeEnd = 0.995
                
                var rotation = C4Transform()
                rotation.rotate(M_PI/360.0, axis: C4Vector(x: 0, y: 0, z: 1.0))
                circle.transform = rotation
                var mask = C4Circle(center: C4Point(circle.width/2.0,circle.height/2.0), radius: 82+4)
                mask.fillColor = clear
                mask.strokeColor = red
                mask.lineWidth = 8
                circle.layer?.mask = mask.layer
            }
            
            circle.strokeColor = cosmosblue
            circle.fillColor = clear
            circle.interactionEnabled = false
            canvas.add(circle)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Logos
    var logos = [String:C4Shape]()
    var logosAnimation = C4ViewAnimation(duration:0.25) {}
    
    func createLogoAnimation() {
        logosAnimation = C4ViewAnimation(duration: 1.0) {
            for shape in [C4Shape](self.logos.values) {
                if(shape.strokeEnd < 1.0) { shape.strokeEnd = 1.0 }
                else { shape.strokeEnd = 0.001 }
            }
        }
    }
    
    func createLogos() {
        
        var logosOrder = ["aries", "taurus", "gemini", "cancer", "leo", "virgo", "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"]
        
        logos["aries"] = aries()
        logos["taurus"] = taurus()
        logos["gemini"] = gemini()
        logos["cancer"] = cancer()
        logos["leo"] = leo()
        logos["virgo"] = virgo()
        logos["libra"] = libra()
        logos["scorpio"] = scorpio()
        logos["sagittarius"] = sagittarius()
        logos["capricorn"] = capricorn()
        logos["aquarius"] = aquarius()
        logos["pisces"] = pices()
        
        C4ViewAnimation(duration: 0) {
            for shape in [C4Shape](self.logos.values) {
                shape.strokeEnd = 0.001
                shape.transform = C4Transform.makeScale(0.64, 0.64, 1.0)
                shape.lineCap = .Round
                shape.lineJoin = .Round
                shape.lineWidth = 2
                shape.strokeColor = white
                shape.fillColor = clear
            }
            }.animate()
    }
    
    func taurus() -> C4Shape {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(0, 0))
        bezier.addCurveToPoint( C4Point(6.3, 0), control2:C4Point(6.4, 10.2), point: C4Point(15.2, 10.2))
        bezier.addCurveToPoint( C4Point(20.8, 10.2), control2:C4Point(25.4, 14.8), point: C4Point(25.4, 20.4))
        bezier.addCurveToPoint( C4Point(25.4, 26), control2:C4Point(20.8, 30.6), point: C4Point(15.2, 30.6))
        bezier.addCurveToPoint( C4Point(9.6, 30.6), control2:C4Point(5, 26), point: C4Point(5, 20.4))
        bezier.addCurveToPoint( C4Point(5, 14.8), control2:C4Point(9.6, 10.2), point: C4Point(15.2, 10.2))
        bezier.addCurveToPoint( C4Point(24, 10.2), control2:C4Point(24.1, 0), point: C4Point(30.4, 0))
        
        var shape = C4Shape(bezier)
        
        shape.anchorPoint = C4Point()
        
        return shape
    }
    
    func aries() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(0.076,0.535)
        
        return shape
    }
    
    func gemini() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(1,0)
        
        return shape
    }
    
    func cancer() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(0,0.27)
        
        return shape
    }
    
    func leo() -> C4Shape {
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
        
        
        shape.anchorPoint = C4Point(0.375,0.632)
        
        return shape
    }
    
    func virgo() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(0.75,0.385)
        return shape
    }
    
    func libra() -> C4Shape {
        var bezier = C4Path()
        
        bezier.moveToPoint(C4Point(37.5, 11.3))
        bezier.addLineToPoint(C4Point(30, 11.3))
        bezier.addCurveToPoint( C4Point(30, 5.1), control2:C4Point(24.9, 0), point: C4Point(18.7, 0))
        bezier.addCurveToPoint( C4Point(12.5, 0), control2:C4Point(7.4, 5.1), point: C4Point(7.4, 11.3))
        bezier.addLineToPoint(C4Point(0, 11.3))
        
        bezier.moveToPoint(C4Point(0, 20.2))
        bezier.addLineToPoint(C4Point(37.5, 20.2))
        
        
        var shape = C4Shape(bezier)
        
        shape.anchorPoint = C4Point(1,0.565)
        
        return shape
    }
    
    func pices() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(0.1,0.005)
        
        return shape
    }
    
    func aquarius() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(0,0.26)
        
        return shape
    }
    
    func sagittarius() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(1,0.35)
        
        return shape
    }
    
    func capricorn() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(0.285,0.66)
        
        return shape
    }
    
    func scorpio() -> C4Shape {
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
        
        shape.anchorPoint = C4Point(0.26,0.775)
        
        return shape
    }
}