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

typealias SelectionAction = (selection: Int) -> Void
typealias InfoAction = () -> Void

class MenuViewController: UIViewController {
    //MARK: Properties
    lazy var signProvider = AstrologicalSignProvider()

    let tick = C4AudioPlayer("tick4.mp3")
    let hideMenuSound = C4AudioPlayer("menuClose.mp3")
    let revealMenuSound = C4AudioPlayer("menuOpen.mp3")
    
    lazy var menuVisible = false
    lazy var menuHighlight = C4Wedge()
    lazy var menuDividingLines = [C4Line]()
    var menuRingsOut : C4ViewAnimationSequence?
    var menuRingsIn : C4ViewAnimationSequence?
    
    lazy var shouldRevert = false
    lazy var currentSelection = 0

    lazy var rings = [C4Circle]()
    lazy var ringFrames = [C4Rect]()

    lazy var thickRing = C4Circle()
    lazy var thickRingFrames = [C4Rect]()

    lazy var dashedRings = [C4Circle]()
    
    lazy var infoLogo = C4Image("infoLight")
    lazy var infoButtonView = C4View(frame: C4Rect(0,0,44,44))
    lazy var titleLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 160, height: 22))
    lazy var instructionLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 320, height: 44))

    var infoAction : InfoAction?
    var selectionAction : SelectionAction?
    
    var timer : NSTimer?
    var shadow : C4Shape?
    
    override func viewDidLoad() {
        canvas.backgroundColor = clear
        canvas.frame = C4Rect(0,0,80,80)
        
        adjustVolumes()
        
        createShadow()
        createMenuRingsLines()
        createMenuAnimations()
        createMenuHighlight()
        createGesture()
        createSignIcons()
        createTitleLabel()
        createInstructionLabel()
        createInfoViewButton()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("showInstruction"), userInfo: nil, repeats: true)
    }
    
    //MARK: Volume
    func adjustVolumes() {
        hideMenuSound.volume = 0.66
        revealMenuSound.volume = 0.66
        tick.volume = 0.4
    }
    
    //MARK: Visual Elements
    func createShadow() {
        shadow = C4Rectangle(frame: C4Rect(UIScreen.mainScreen().bounds))
        shadow?.fillColor = black
        shadow?.lineWidth = 0
        shadow?.opacity = 0.0
        shadow?.center = C4Point(canvas.width/2,canvas.height/2)
        canvas.add(shadow)
    }
    
    func createTitleLabel() {
        titleLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        titleLabel.textAlignment = .Center
        titleLabel.textColor = .whiteColor()
        titleLabel.userInteractionEnabled = false
        titleLabel.center = view.center
        titleLabel.text = ""
        canvas.add(titleLabel)
    }
    
    func createInstructionLabel() {
        instructionLabel.text = "press and hold to open menu\nthen drag to choose a sign"
        instructionLabel.font = titleLabel.font
        instructionLabel.textAlignment = .Center
        instructionLabel.textColor = .whiteColor()
        instructionLabel.userInteractionEnabled = false
        instructionLabel.center = CGPointMake(view.center.x,view.center.y - 128)
        instructionLabel.numberOfLines = 2
        instructionLabel.alpha = 0.0
        canvas.add(instructionLabel)
    }
    
    func createInfoViewButton() {
        infoButtonView.add(infoLogo)
        infoLogo.center = infoButtonView.center
        infoButtonView.center = C4Point(canvas.center.x,canvas.center.y + 190)
        infoButtonView.opacity = 0.0
        canvas.add(infoButtonView)
    }
    
    //MARK: Gesture
    func createGesture() {
        canvas.addLongPressGestureRecognizer { (location, state) -> () in
            switch state {
            case .Began:
                self.revealMenu()
            case .Cancelled, .Ended, .Failed:
                self.canvas.interactionEnabled = false
                if !self.menuHighlight.hidden {
                    self.selectionAction!(selection: self.currentSelection)
                    self.menuHighlight.hidden = true
                }
                if self.menuVisible {
                    self.hideMenu()
                } else {
                    self.shouldRevert = true
                }
    
                if self.infoButtonView.hitTest(location, from: self.canvas) {
                    delay(0.75) {
                        self.infoAction!()
                    }
                }
                self.titleLabel.text = ""
            case .Changed:
                self.updateMenuHighlight(location)
                if self.infoButtonView.hitTest(location, from: self.canvas) {
                    self.titleLabel.text = "Info"
                }
            default:
                let i = 0
            }
        }
    }
    
    //MARK: Menu Animations
    func createMenuAnimations() {
        createSignIconAnimations()
        createThickRingAnimations()
        createDashedRingAnimations()
        createInfoButtonAnimations()
        createShadowAnimations()
        createMenuRingsOutAnimations()
        createMenuRingsInAnimations()
    }
    
    func showInstruction() {
        C4ViewAnimation(duration: 2.5) {
            self.instructionLabel.alpha = 1.0
        }.animate()
    }
    
    func hideInstruction() {
        timer?.invalidate()
        C4ViewAnimation(duration: 0.25) {
            self.instructionLabel.alpha = 0.0
        }.animate()
    }
    
    func revealDividingLines() {
        revealHideDividingLines(1.0)
    }
    
    func hideDividingLines() {
        revealHideDividingLines(0.0)
    }

    func revealHideDividingLines(target: Double) {
        var indices = [0,1,2,3,4,5,6,7,8,9,10,11]
        
        for i in 0...11 {
            delay(0.05*Double(i)) {
                let randomIndex = random(below: indices.count)
                let index = indices[randomIndex]
                
                C4ViewAnimation(duration: 0.1) {
                    self.menuDividingLines[index].strokeEnd = target
                }.animate()
                
                indices.removeAtIndex(randomIndex)
            }
        }
    }
    
    var signIconsOut : C4ViewAnimation?
    var signIconsIn : C4ViewAnimation?
    var revealSignIcons : C4ViewAnimation?
    var hideSignIcons : C4ViewAnimation?
    
    func createSignIconAnimations() {
        signIconsOut = C4ViewAnimation(duration: 0.33) {
            for i in 0..<self.signProvider.order.count {
                let name = self.signProvider.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.outerTargets[i]
                }
            }
        }
        
        signIconsOut?.curve = .EaseOut
        
        revealSignIcons = C4ViewAnimation(duration: 0.5) {
            for sign in [C4Shape](self.signIcons.values) {
                sign.strokeEnd = 1.0
            }
        }
        revealSignIcons?.curve = .EaseOut
        
        signIconsIn = C4ViewAnimation(duration: 0.33) {
            for i in 0..<self.signProvider.order.count {
                let name = self.signProvider.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.innerTargets[i]
                }
            }
        }
        signIconsIn?.curve = .EaseOut
        
        hideSignIcons = C4ViewAnimation(duration: 0.5) {
            for sign in [C4Shape](self.signIcons.values) {
                sign.strokeEnd = 0.001
            }
        }
        hideSignIcons?.curve = .EaseOut
    }
    
    var thickRingOut : C4ViewAnimation?
    var thickRingIn : C4ViewAnimation?
    
    func createThickRingAnimations() {
        thickRingOut = C4ViewAnimation(duration: 0.5) {
            self.thickRing.frame = self.thickRingFrames[1]
            self.thickRing.updatePath()
        }
        thickRingOut?.curve = .EaseOut
        
        thickRingIn = C4ViewAnimation(duration: 0.5) {
            self.thickRing.frame = self.thickRingFrames[0]
            self.thickRing.updatePath()
        }
        thickRingIn?.curve = .EaseOut
    }
    
    var revealDashedRings : C4ViewAnimation?
    var hideDashedRings : C4ViewAnimation?
    
    func createDashedRingAnimations() {
        revealDashedRings = C4ViewAnimation(duration: 0.25) {
            self.dashedRings[0].lineWidth = 4
            self.dashedRings[1].lineWidth = 12
        }
        revealDashedRings?.curve = .EaseOut
        
        hideDashedRings = C4ViewAnimation(duration: 0.25) {
            self.dashedRings[0].lineWidth = 0
            self.dashedRings[1].lineWidth = 0
        }
        hideDashedRings?.curve = .EaseOut
    }
    
    var revealInfoButton : C4ViewAnimation?
    var hideInfoButton : C4ViewAnimation?
    
    func createInfoButtonAnimations() {
        revealInfoButton = C4ViewAnimation(duration:0.25) {
            self.infoButtonView.opacity = 1.0
        }
        revealInfoButton?.curve = .EaseOut
        
        hideInfoButton = C4ViewAnimation(duration:0.25) {
            self.infoButtonView.opacity = 0.0
        }
        hideInfoButton?.curve = .EaseOut
    }

    var revealShadow : C4ViewAnimation?
    var hideShadow : C4ViewAnimation?
    
    func createShadowAnimations() {
        revealShadow = C4ViewAnimation(duration:0.25) {
            self.shadow?.opacity = 0.44
        }
        revealShadow?.curve = .EaseOut
        
        hideShadow = C4ViewAnimation(duration:0.25) {
            self.shadow?.opacity = 0.0
        }
        hideShadow?.curve = .EaseOut
    }

    func revealMenu() {
        menuVisible = false

        hideInstruction()
        revealMenuSound.play()
        revealShadow?.animate()
        thickRingOut?.animate()
        menuRingsOut?.animate()
        signIconsOut?.animate()
        
        delay(0.33) {
            self.revealDividingLines()
            self.revealSignIcons?.animate()
        }
        delay(0.66) {
            self.revealDashedRings?.animate()
            self.revealInfoButton?.animate()
        }
        delay(1.0) {
            self.menuVisible = true
            if self.shouldRevert {
                self.hideMenu()
                self.shouldRevert = false
            }
        }
    }
    
    func hideMenu() {
        menuVisible = false
        
        hideMenuSound.play()
        hideDividingLines()
        hideDashedRings?.animate()
        hideInfoButton?.animate()

        delay(0.16) {
            self.hideSignIcons?.animate()
        }
        delay(0.57) {
            self.menuRingsIn?.animate()
        }
        delay(0.66) {
            self.signIconsIn?.animate()
            self.thickRingIn?.animate()
            self.hideShadow?.animate()
            self.canvas.interactionEnabled = true
        }
    }
    
    func createMenuRingsOutAnimations() {
        var animationArray = [C4ViewAnimation]()
        for i in 0..<self.rings.count-1 {
            let anim = C4ViewAnimation(duration: 0.075 + Double(i) * 0.01) {
                var circle = self.rings[i]

                if (i > 0) {
                    C4ViewAnimation(duration: 0.0375) {
                        circle.opacity = 1.0
                    }.animate()
                }
                
                circle.frame = self.ringFrames[i+1]
                circle.updatePath()
            }
            anim.curve = .EaseOut
            animationArray.append(anim)
        }
        menuRingsOut = C4ViewAnimationSequence(animations: animationArray)
    }

    func createMenuRingsInAnimations() {
        var animationArray = [C4ViewAnimation]()
        for i in 1...self.rings.count {
            let anim = C4ViewAnimation(duration: 0.075 + Double(i) * 0.01, animations: { () -> Void in
                var circle = self.rings[self.rings.count - i]
                if self.rings.count - i > 0 {
                    C4ViewAnimation(duration: 0.0375) {
                        circle.opacity = 0.0
                    }.animate()
                }
                circle.frame = self.ringFrames[self.rings.count - i]
                circle.updatePath()
            })
            anim.curve = .EaseOut
            animationArray.append(anim)
        }
        menuRingsIn = C4ViewAnimationSequence(animations: animationArray)
    }
    
    func createMenuHighlight() {
        menuHighlight = C4Wedge(center: canvas.center, radius: 156, start: 0.0, end: M_PI/6.0)
        menuHighlight.fillColor = cosmosblue
        menuHighlight.lineWidth = 0.0
        menuHighlight.opacity = 0.8
        menuHighlight.interactionEnabled = false
        menuHighlight.layer?.anchorPoint = CGPointZero
        menuHighlight.center = canvas.center
        menuHighlight.hidden = true

        var path = C4Path()
        path.addEllipse(C4Rect(-156,-156,312,312))
        path.addEllipse(C4Rect((312-204)/2-156,(312-204)/2-156,204,204))
        
        var donut = C4Shape(path)
        donut.fillRule = .EvenOdd
        menuHighlight.layer?.mask = donut.layer

        canvas.add(menuHighlight)
    }
    
    func updateMenuHighlight(location: C4Point) {
        
        let a = C4Vector(x:self.canvas.width / 2.0+1.0, y:self.canvas.height/2.0)
        let b = C4Vector(x:self.canvas.width / 2.0, y:self.canvas.height/2.0)
        let c = C4Vector(x:location.x, y:location.y)
        
        let dist = distance(location, self.canvas.bounds.center)
        
        if dist > 102.0 && dist < 156 {
            menuHighlight.hidden = false
            var angle = c.angleTo(a, basedOn: b)
            
            if c.y < a.y {
                angle = 2*M_PI - angle
            }
            
            var newSelection = Int(radToDeg(angle)) / 30
            if currentSelection != newSelection {
                titleLabel.text = signProvider.order[newSelection].capitalizedString
                tick.stop()
                tick.play()
                self.currentSelection = newSelection
                var rotation = C4Transform()
                rotation.rotate(degToRad(Double(self.currentSelection) * 30.0), axis: C4Vector(x:0,y:0,z:-1))
                self.menuHighlight.transform = rotation
            }
        } else if self.infoButtonView.hitTest(location) {
            menuHighlight.hidden = true
            titleLabel.text = "Info"
        } else {
            menuHighlight.hidden = true
            titleLabel.text = ""
        }
    }
    
    //MARK: Rings
    func createMenuRingsLines() {
        createThickRing()
        createThinRings()
        createDashedRings()
        createMenuDividingLines()
    }
    
    func createThickRing() {
        thickRing = C4Circle(center: canvas.center, radius: 14)
        let inner = C4Circle(center: canvas.center, radius: 14)
        let outer = C4Circle(center: canvas.center, radius: 225)
        thickRingFrames = [inner.frame,outer.frame]

        C4ViewAnimation(duration: 0.0) {
            self.thickRing.fillColor = clear
            self.thickRing.lineWidth = 3
            self.thickRing.strokeColor = cosmosblue
            self.thickRing.interactionEnabled = false
        }.animate()

        canvas.add(thickRing)
    }
    
    func createThinRings() {
        rings.append(C4Circle(center: canvas.center, radius: 8))
        rings.append(C4Circle(center: canvas.center, radius: 56))
        rings.append(C4Circle(center: canvas.center, radius: 78))
        rings.append(C4Circle(center: canvas.center, radius: 98))
        rings.append(C4Circle(center: canvas.center, radius: 102))
        rings.append(C4Circle(center: canvas.center, radius: 156))
        
        C4ViewAnimation(duration: 0.0) {
            for i in 0..<self.rings.count {
                var ring = self.rings[i]
                ring.fillColor = clear
                ring.lineWidth = 1
                ring.strokeColor = cosmosblue
                ring.interactionEnabled = false
                if i > 0 {
                    ring.opacity = 0.0
                }
                self.ringFrames.append(ring.frame)
            }
            }.animate()
        
        for ring in rings {
            canvas.add(ring)
        }
    }
    
    func createMenuDividingLines() {
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
            menuDividingLines.append(line)
        }
    }
    
    func createShortDashedRing() {
        let shortDashedRing = C4Circle(center: canvas.center, radius: 82+2)
        C4ViewAnimation(duration: 0.0) {
            let pattern = [1.465,1.465,1.465,1.465,1.465,1.465,1.465,1.465*3.0] as [NSNumber]
            shortDashedRing.lineDashPattern = pattern
            shortDashedRing.strokeEnd = 0.995

            var rotation = C4Transform()
            rotation.rotate(-3.0*M_PI/360.0, axis: C4Vector(x: 0, y: 0, z: 1.0))
            shortDashedRing.transform = rotation
            
            shortDashedRing.lineWidth = 0
        }.animate()
        dashedRings.append(shortDashedRing)
    }
    
    func createLongDashedRing() {
        let longDashedRing = C4Circle(center: canvas.center, radius: 82+2)
        
        C4ViewAnimation(duration: 0.0) {
            longDashedRing.lineWidth = 0
            
            let pattern = [1.465,1.465*9.0] as [NSNumber]
            longDashedRing.lineDashPattern = pattern
            longDashedRing.strokeEnd = 0.995
            
            var rotation = C4Transform()
            rotation.rotate(M_PI/360.0, axis: C4Vector(x: 0, y: 0, z: 1.0))
            longDashedRing.transform = rotation

            var mask = C4Circle(center: C4Point(longDashedRing.width/2.0,longDashedRing.height/2.0), radius: 82+4)
            mask.fillColor = clear
            mask.strokeColor = red
            mask.lineWidth = 8
            longDashedRing.layer?.mask = mask.layer
        }.animate()

        dashedRings.append(longDashedRing)
    }
    
    func createDashedRings() {
        createShortDashedRing()
        createLongDashedRing()

        C4ViewAnimation(duration: 0.0) {
            for ring in self.dashedRings {
                ring.strokeColor = cosmosblue
                ring.fillColor = clear
                ring.interactionEnabled = false
                self.canvas.add(ring)
            }
        }.animate()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Sign Icons
    var signIcons = [String:C4Shape]()
    
    func createSignIcons() {
        signIcons["aries"] = aries()
        signIcons["taurus"] = taurus()
        signIcons["gemini"] = gemini()
        signIcons["cancer"] = cancer()
        signIcons["leo"] = leo()
        signIcons["virgo"] = virgo()
        signIcons["libra"] = libra()
        signIcons["scorpio"] = scorpio()
        signIcons["sagittarius"] = sagittarius()
        signIcons["capricorn"] = capricorn()
        signIcons["aquarius"] = aquarius()
        signIcons["pisces"] = pisces()
        
        C4ViewAnimation(duration: 0) {
            for shape in [C4Shape](self.signIcons.values) {
                shape.strokeEnd = 0.001
                shape.transform = C4Transform.makeScale(0.64, 0.64, 1.0)
                shape.lineCap = .Round
                shape.lineJoin = .Round
                shape.lineWidth = 2
                shape.strokeColor = white
                shape.fillColor = clear
            }
        }.animate()
        
        positionSignIcons()
    }

    var innerTargets = [C4Point]()
    var outerTargets = [C4Point]()

    func positionSignIcons() {
        var r = 10.5
        let dx = canvas.center.x
        let dy = canvas.center.y
        for i in 0..<signProvider.order.count {
            var ϴ = M_PI/6 * Double(i)
            let name = signProvider.order[i]
            if let sign = signIcons[name] {
                sign.center = C4Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy)
                canvas.add(sign)
                sign.anchorPoint = C4Point(0.5,0.5)
                innerTargets.append(sign.center)
            }
        }
        
        for i in 0..<signProvider.order.count {
            let r = 129.0
            let ϴ = M_PI/6 * Double(i) + M_PI/12.0
            outerTargets.append(C4Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy))
        }
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