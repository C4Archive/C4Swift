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
    let cosmosblue = C4Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)
    var circles = [C4Circle]()
    var wedge = C4Wedge()
    var intAngle = 0
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
    
    override func viewDidLoad() {
        circles.append(C4Circle(center: canvas.center, radius: 102))
        circles.append(C4Circle(center: canvas.center, radius: 156))
        
        for i in 0..<circles.count {
            var circle = circles[i]
            circle.fillColor = clear
            circle.lineWidth = 1
            circle.strokeColor = cosmosblue
            circle.interactionEnabled = false
            canvas.add(circle)
        }
        
        createLines()
        
        out = false
        
        
        
        canvas.addTapGestureRecognizer { (location, state) -> () in
            if self.out {
                self.out = false
//                self.staggeredOut()
                self.randomOut()
                            } else {
                self.out = true
//                self.staggeredIn()
                self.randomIn()
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
    
    func staggeredOut() {
        self.lines[9].strokeEnd = 1.0
        self.lines[3].strokeEnd = 1.0
        
        delay(0.1) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[0].strokeEnd = 1.0
                self.lines[6].strokeEnd = 1.0
            }
            a.animate()
        }
        
        delay(0.2) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[5].strokeEnd = 1.0
                self.lines[11].strokeEnd = 1.0
            }
            a.animate()
        }
        
        delay(0.3) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[1].strokeEnd = 1.0
                self.lines[7].strokeEnd = 1.0
            }
            a.animate()
        }
        
        delay(0.4) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[4].strokeEnd = 1.0
                self.lines[10].strokeEnd = 1.0
            }
            a.animate()
        }
        
        delay(0.5) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[2].strokeEnd = 1.0
                self.lines[8].strokeEnd = 1.0
            }
            a.animate()
        }
    }
    
    func staggeredIn() {
        self.lines[9].strokeEnd = 0.0
        self.lines[3].strokeEnd = 0.0
        
        delay(0.1) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[0].strokeEnd = 0.0
                self.lines[6].strokeEnd = 0.0
            }
            a.animate()
        }
        
        delay(0.2) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[5].strokeEnd = 0.0
                self.lines[11].strokeEnd = 0.0
            }
            a.animate()
        }
        
        delay(0.3) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[1].strokeEnd = 0.0
                self.lines[7].strokeEnd = 0.0
            }
            a.animate()
        }
        
        delay(0.4) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[4].strokeEnd = 0.0
                self.lines[10].strokeEnd = 0.0
            }
            a.animate()
        }
        
        delay(0.5) {
            let a = C4ViewAnimation(duration: 0.1) {
                self.lines[2].strokeEnd = 0.0
                self.lines[8].strokeEnd = 0.0
            }
            a.animate()
        }
    }
    
    func miewDidLoad() {
        thickCircle = C4Circle(center: canvas.center, radius: 14)
        thickCircle.fillColor = clear
        thickCircle.lineWidth = 3
        thickCircle.strokeColor = cosmosblue
        thickCircle.interactionEnabled = false
        canvas.add(thickCircle)
        
        outerCircle = C4Circle(center: self.canvas.center, radius: 156)
        outerCircle.strokeEnd = 0.0
        outerCircle.fillColor = clear
        outerCircle.lineWidth = 1
        outerCircle.strokeColor = cosmosblue
        outerCircle.interactionEnabled = false
        canvas.add(outerCircle)
        
        createLines()
        
        circles.append(C4Circle(center: canvas.center, radius: 8))
        circles.append(C4Circle(center: canvas.center, radius: 56))
        circles.append(C4Circle(center: canvas.center, radius: 78))
        circles.append(C4Circle(center: canvas.center, radius: 98))
        circles.append(C4Circle(center: canvas.center, radius: 102))
        
        for i in 0..<circles.count {
            var circle = circles[i]
            circle.fillColor = clear
            circle.lineWidth = 1
            circle.strokeColor = cosmosblue
            circle.interactionEnabled = false
            if i > 0 {
                circle.opacity = 0.0
            }
            canvas.add(circle)
            frames.append(circle.frame)
        }
        
        let inner = C4Circle(center: canvas.center, radius: 14)
        let outer = C4Circle(center: canvas.center, radius: 225)
        
        thickCircleFrames.append(inner.frame)
        thickCircleFrames.append(outer.frame)
        
        createOutAnimations()
        createInAnimations()
        createMenuAnimations()
        
        canvas.addLongPressGestureRecognizer { (location, state) -> () in
            switch state {
            case .Began:
                self.menuOut()
            case .Cancelled, .Ended, .Failed:
                self.canvas.interactionEnabled = false
                if self.menuVisible {
                    self.menuIn()
                } else {
                    self.shouldRevert = true
                }
            default:
                let i = 0
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
        delay(0.6) {
            self.animateMenu(self.linesOut)
        }
        delay(1.2) {
            self.menuVisible = true
            if self.shouldRevert {
                self.menuIn()
                self.shouldRevert = false
            }
        }
    }
    
    func menuIn() {
        self.out = true
        self.animateMenu(self.linesIn)
        delay(0.6) {
            self.animateIn.animate()
        }
        delay(1.0 ) {
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
        
        if self.outerCircle.strokeEnd < 1.0 { //animate out
            delay(dt) {
                let anim = C4ViewAnimation(duration: 12.0 * dt) {
                    self.outerCircle.strokeEnd = 1.0
                }
                anim.animate()
            }
        } else { //animate in
            let anim = C4ViewAnimation(duration: 12.0 * dt) {
                self.outerCircle.strokeEnd = 0.0
            }
            anim.animate()
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
            line.layer?.anchorPoint = CGPointMake(-1.88888,0)
            line.center = canvas.center
            var rot = C4Transform()
            rot.rotate(M_PI / 6.0 * Double(i) , axis: C4Vector(x: 0, y: 0, z: -1))
            line.transform = rot
            line.strokeColor = cosmosblue
            line.lineWidth = 1.0
            line.strokeEnd = 0.0
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
    
    func layoutMenu() {
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
        canvas.add(wedge)
        
        canvas.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            let a = C4Vector(x:self.canvas.center.x+1.0, y:self.canvas.center.y)
            let b = C4Vector(x:self.canvas.center.x, y:self.canvas.center.y)
            let c = C4Vector(x:location.x, y:location.y)
            
            let dist = distance(location, self.canvas.center)
            
            if dist > 102.0 && dist < 156 {
                var angle = c.angleTo(a, basedOn: b)
                
                if c.y < a.y {
                    angle = 2*M_PI - angle
                }
                
                var newAngle = Int(radToDeg(angle)) / 30
                
                if self.intAngle != newAngle {
                    self.intAngle = newAngle
                    
                    var rotation = C4Transform()
                    rotation.rotate(degToRad(Double(self.intAngle) * 30.0), axis: C4Vector(x:0,y:0,z:-1))
                    self.wedge.transform = rotation
                }
            }
        }
        
        addCircles()
        
        for i in 0...11 {
            donut = C4Shape(path)
            donut.fillRule = .EvenOdd
            
            let shape = C4Line([C4Point(),C4Point(156,0)])
            shape.layer?.anchorPoint = CGPointZero
            shape.center = canvas.center
            var rotation = C4Transform()
            rotation.rotate(degToRad(Double(i) * 30.0), axis: C4Vector(x:0,y:0,z:-1))
            shape.transform = rotation
            shape.lineWidth = 1.25
            shape.strokeColor = cosmosblue
            shape.layer?.mask = donut.layer
            canvas.add(shape)
        }
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
}