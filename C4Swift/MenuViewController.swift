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

typealias MenuAction = (selection: Int) -> Void

class MenuViewController: UIViewController {
    let menuOutSound = C4AudioPlayer("menuOpen.mp3")
    let menuInSound = C4AudioPlayer("menuClose.mp3")
    let tick = C4AudioPlayer("tick4.mp3")
    var introTextStage = 0
    
    var longpress = UILongPressGestureRecognizer()

    var signProvider = AstrologicalSignProvider()
    
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
    var logosOrder = ["pisces","aries", "taurus", "gemini", "cancer", "leo", "virgo", "libra", "scorpio", "sagittarius", "capricorn", "aquarius"]
    var currentSelection = 0
    var dashedCircles = [C4Circle]()
    var titleLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 160, height: 22))
    var instructionLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 320, height: 44))
    var infoLogo = C4Image("infoLight")
    var infoView = C4View(frame: C4Rect(0,0,44,44))
    var action : MenuAction?
    
    var timer = NSTimer()
    
    var shadow = C4Shape()
    
    override func viewDidLoad() {
        
        menuInSound.volume = 0.66
        menuOutSound.volume = 0.66
        tick.volume = 0.4
        
        shadow = C4Rectangle(frame: canvas.frame)

        canvas.backgroundColor = clear
        canvas.frame = C4Rect(0,0,80,80)
        
        shadow.fillColor = black
        shadow.lineWidth = 0
        shadow.opacity = 0.0
        shadow.center = canvas.center
        canvas.add(shadow)
        
        createCircles()
        addDashedCircles()
        createLines()
        createOutAnimations()
        createInAnimations()
        createGesture()
        
        layoutHighlight()
        
        createLogos()
        positionLogos()
        
        titleLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        titleLabel.textAlignment = .Center
        titleLabel.textColor = .whiteColor()
        titleLabel.userInteractionEnabled = false
        titleLabel.center = view.center
        titleLabel.text = ""
        
        canvas.add(titleLabel)
        
        instructionLabel.text = "press and hold to open menu\nthen drag to choose a sign"
        instructionLabel.font = titleLabel.font
        instructionLabel.textAlignment = .Center
        instructionLabel.textColor = .whiteColor()
        instructionLabel.userInteractionEnabled = false
        instructionLabel.center = CGPointMake(view.center.x,view.center.y - 128)
        instructionLabel.numberOfLines = 2
        instructionLabel.alpha = 0.0
        canvas.add(instructionLabel)
        
        infoView.add(infoLogo)
        infoLogo.center = infoView.center
        infoView.center = C4Point(canvas.center.x,canvas.center.y + 190)
        infoView.opacity = 0.0
        canvas.add(infoView)
    
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("showInstruction"), userInfo: nil, repeats: true)
    }
    
    func showInstruction() {
        let show = C4ViewAnimation(duration: 2.5) {
            self.instructionLabel.alpha = 1.0
        }
        show.animate()
    }
    
    func hideInstruction() {
        timer.invalidate()
        let hide = C4ViewAnimation(duration: 0.25) {
            self.instructionLabel.alpha = 0.0
        }
        hide.animate()
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
        longpress = canvas.addLongPressGestureRecognizer { (location, state) -> () in
            switch state {
            case .Began:
                self.menuOut()
            case .Cancelled, .Ended, .Failed:
                self.canvas.interactionEnabled = false
                if !self.wedge.hidden {
                    if let a = self.action {
                        a(selection: self.currentSelection)
                    }
                    self.wedge.hidden = true
                }
                if self.menuVisible {
                    self.menuIn()
                } else {
                    self.shouldRevert = true
                }
    
                if self.infoView.hitTest(location) {
                    self.showInfo()
                }
                self.titleLabel.text = ""
            case .Changed:
                self.moveWedge(location)
            default:
                let i = 0
            }
        }
    }
    
    func showInfo() {
        println(__FUNCTION__)
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
        menuOutSound.play()
        hideInstruction()
        C4ViewAnimation(duration:0.25) {
            self.shadow.opacity = 0.44
        }.animate()
        
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
            C4ViewAnimation(duration:0.25) {
                self.infoView.opacity = 1.0
            }.animate()
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
        menuInSound.play()
        
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
        
        C4ViewAnimation(duration:0.25) {
            self.infoView.opacity = 0.0
        }.animate()

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
        
            C4ViewAnimation(duration:0.25) {
                self.shadow.opacity = 0.0
            }.animate()
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
        wedge.opacity = 0.8
        wedge.interactionEnabled = false
        wedge.layer?.mask = donut.layer
        wedge.layer?.anchorPoint = CGPointZero
        wedge.center = canvas.center
        wedge.hidden = true
        canvas.add(wedge)
    }
    
    func moveWedge(location: C4Point) {
        
        let a = C4Vector(x:self.canvas.width / 2.0+1.0, y:self.canvas.height/2.0)
        let b = C4Vector(x:self.canvas.width / 2.0, y:self.canvas.height/2.0)
        let c = C4Vector(x:location.x, y:location.y)
        
        let dist = distance(location, self.canvas.bounds.center)
        
        if dist > 102.0 && dist < 156 {
            wedge.hidden = false
            var angle = c.angleTo(a, basedOn: b)
            
            if c.y < a.y {
                angle = 2*M_PI - angle
            }
            
            var newSelection = Int(radToDeg(angle)) / 30
            
            titleLabel.text = logosOrder[newSelection].capitalizedString
            
            if self.currentSelection != newSelection {
                tick.stop()
                tick.play()
                self.currentSelection = newSelection
                var rotation = C4Transform()
                rotation.rotate(degToRad(Double(self.currentSelection) * 30.0), axis: C4Vector(x:0,y:0,z:-1))
                self.wedge.transform = rotation
            }
        } else if self.infoView.hitTest(location) {
            wedge.hidden = true
            titleLabel.text = "Info"
        } else {
            wedge.hidden = true
            titleLabel.text = ""
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
        logos["pisces"] = pisces()
        
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

        var shape = signProvider.taurus().shape
        
        shape.anchorPoint = C4Point()
        
        return shape
    }
    
    func aries() -> C4Shape {
 
        var shape = signProvider.aries().shape
        
        shape.anchorPoint = C4Point(0.076,0.535)
        
        return shape
    }
    
    func gemini() -> C4Shape {

        var shape = signProvider.gemini().shape
        
        shape.anchorPoint = C4Point(1,0)
        
        return shape
    }
    
    func cancer() -> C4Shape {

        var shape = signProvider.cancer().shape
        
        shape.anchorPoint = C4Point(0,0.27)
        
        return shape
    }
    
    func leo() -> C4Shape {

        var shape = signProvider.leo().shape
        
        shape.anchorPoint = C4Point(0.375,0.632)
        
        return shape
    }
    
    func virgo() -> C4Shape {
        
        var shape = signProvider.virgo().shape
        
        shape.anchorPoint = C4Point(0.75,0.385)
        
        return shape
    }
    
    func libra() -> C4Shape {

        var shape = signProvider.libra().shape
        
        shape.anchorPoint = C4Point(1,0.565)
        
        return shape
    }
    
    func pisces() -> C4Shape {

        var shape = signProvider.pisces().shape
        
        shape.anchorPoint = C4Point(0.1,0.005)
        
        return shape
    }
    
    func aquarius() -> C4Shape {
        var shape = signProvider.aquarius().shape
        
        shape.anchorPoint = C4Point(0,0.26)
        
        return shape
    }
    
    func sagittarius() -> C4Shape {
        
        var shape = signProvider.sagittarius().shape
        
        shape.anchorPoint = C4Point(1,0.35)
        
        return shape
    }
    
    func capricorn() -> C4Shape {
        var shape = signProvider.capricorn().shape
        
        shape.anchorPoint = C4Point(0.285,0.66)
        
        return shape
    }
    
    func scorpio() -> C4Shape {
        
        var shape = signProvider.scorpio().shape
        
        shape.anchorPoint = C4Point(0.26,0.775)
        
        return shape
    }
}