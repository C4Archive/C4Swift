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

    var container = C4View()
    
    override func viewDidLoad() {
        container.frame = C4Rect(view.frame)
        
        let text = C4TextShape(text: "hello there", font: C4Font(name: "menlo", size:20.0))
        let circ = C4Ellipse(frame: C4Rect(0,0,100,100))
        circ.origin = C4Point(100,100)
        text.origin = C4Point(100,200)
        
        container.add(circ)
        container.add(text)
        container.interactionEnabled = false
        view.add(container)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: NSSelectorFromString("animate")))
    }
    
    func animate() {
        let anim = C4ViewAnimation(duration: 0.25) {
            self.container.transform = C4Transform.makeScale(0.8, 0.8, 0)
        }
        anim.animate()
    }
    
    func appMenu() {
        view.backgroundColor = UIColor(lightGray)
        createMenu()
        createLogo()
        createAnimations()
    }

    var buttons = [MenuButton]()
    var tapView = C4View()
    var menu = C4View()
    func createMenu() {
        let menuHeight = 211.0
        let screenSize = C4Size(view.frame.size)
        let menuFrame = C4Rect(0.0,screenSize.height - menuHeight, screenSize.width, menuHeight)
        menu = C4View(frame: menuFrame)
        menu.backgroundColor = white
        
        var about = MenuButton("News")
        about.action = {
            println("-> news")
            self.toggleMenu()
        }
        
        var components = MenuButton("Story")
        components.action = {
            println("-> story")
            self.toggleMenu()
        }
        
        var tutorials = MenuButton("Components")
        tutorials.action = {
            println("-> components")
            self.toggleMenu()
        }

        var examples = MenuButton("Examples")
        examples.action = {
            println("-> other")
            self.toggleMenu()
        }
        
        var origin = C4Point(menu.width - 20 - components.width, 20)
        var buttonSize = components.size
        let gap = 9.0
        let dy = buttonSize.height + gap
        components.origin = origin
        origin.y += dy
        tutorials.origin = origin
        origin.y += dy
        examples.origin = origin
        origin.y += dy
        about.origin = origin
        
        menu.add(components)
        menu.add(tutorials)
        menu.add(examples)
        menu.add(about)
        
        buttons.append(components)
        buttons.append(tutorials)
        buttons.append(examples)
        buttons.append(about)
        
        view.add(menu)
    }
    
    var menuAnimation = C4ViewAnimation(){}
    var tapViewAnimation = C4ViewAnimation(){}
    var buttonAnimations = [C4ViewAnimation]()
    var cAnimation = C4ViewAnimation(){}
    var fAnimation = C4ViewAnimation(){}
    let dy = 118.0
    var isUp = true
    var up = C4ViewAnimation(){}
    var down = C4ViewAnimation(){}
    
    func createAnimations() {
        tapView = C4View(frame: C4Rect(0,Double(view.frame.size.height)-204,100,86))
        view.add(tapView)
        
        menuAnimation = C4ViewAnimation(duration: 0.25) {
            let y = self.isUp ? Double(self.view.frame.size.height) : Double(self.view.frame.size.height)-self.menu.height
            self.menu.origin = C4Point(0,y)
        }
        menuAnimation.curve = .EaseOut
        
        for i in 0...3 {
            var anim = C4ViewAnimation(duration: 0.25) {
                let dy = self.isUp ? self.dy : -self.dy
                var origin = self.buttons[i].origin
                origin.y += dy
                self.buttons[i].origin = origin
            }
            anim.curve = .EaseOut
            buttonAnimations.append(anim)
        }
        
        tapViewAnimation = C4ViewAnimation(duration: 0.25) {
            let dy = self.isUp ? self.dy : -self.dy
            self.tapView.origin = C4Point(self.tapView.origin.x,self.tapView.origin.y + dy)
        }
        
        cAnimation = C4ViewAnimation(duration: 0.25) {
            let dy = self.isUp ? self.dy : -self.dy
            self.c.origin = C4Point(self.c.origin.x,self.c.origin.y + dy)
            self.fmask.origin = C4Point(self.fmask.origin.x,self.fmask.origin.y + dy)
        }
        cAnimation.curve = .EaseOut
        
        fAnimation = C4ViewAnimation(duration: 0.25) {
            let dy = self.isUp ? self.dy : -self.dy
            self.f.origin = C4Point(self.f.origin.x,self.f.origin.y + dy)
            self.f2.origin = C4Point(self.f2.origin.x,self.f2.origin.y + dy)
            self.fmask.origin = C4Point(self.fmask.origin.x,self.fmask.origin.y - dy)
        }
        fAnimation.curve = .EaseOut
        
        
        tapView.addTapGestureRecognizer { (location, state) -> () in
            self.toggleMenu()
        }
    }
    
    func toggleMenu() {
        self.isUp = self.menu.origin.y < Double(self.view.frame.size.height) ? true : false
        
        delay(0.1) {
            self.menuAnimation.animate()
        }
        
        if(self.isUp) {
            self.buttonAnimations[3].animate()
            delay(0.05) {
                self.buttonAnimations[2].animate()
            }
            delay(0.1) {
                self.buttonAnimations[1].animate()
            }
            delay(0.15) {
                self.buttonAnimations[0].animate()
            }
        } else {
            self.buttonAnimations[0].animate()
            delay(0.05) {
                self.buttonAnimations[1].animate()
            }
            delay(0.1) {
                self.buttonAnimations[2].animate()
            }
            delay(0.15) {
                self.buttonAnimations[3].animate()
            }
        }
        
        self.tapViewAnimation.animate()
        self.cAnimation.animate()
        
        delay(0.1) {
            self.fAnimation.animate()
        }
    }
    
    var c = C4Shape()
    var f = C4Shape()
    var f2 = C4Shape()
    var fmask = C4Shape()

    func createLogo() {
        var t = C4Transform.makeScale(4.0, 4.0, 0.0)
        
        var cp = C4Path()
        
        cp.moveToPoint(C4Point(12.5, 10))
        cp.addLineToPoint(C4Point(7.5, 10))
        cp.addCurveToPoint(C4Point(6.12, 10), control2: C4Point(5, 8.88), point: C4Point(5, 7.5))
        cp.addCurveToPoint(C4Point(5, 6.12), control2: C4Point(6.12, 5), point: C4Point(7.5, 5))
        cp.addLineToPoint(C4Point(12.5, 5))
        cp.addCurveToPoint(C4Point(13.88, 5), control2: C4Point(15, 3.88), point: C4Point(15, 2.5))
        cp.addCurveToPoint(C4Point(15, 1.12), control2: C4Point(13.88, 0), point: C4Point(12.5, 0))
        cp.addLineToPoint(C4Point(7.5, 0))
        cp.addCurveToPoint(C4Point(3.36, 0), control2: C4Point(0, 3.36), point: C4Point(0, 7.5))
        cp.addCurveToPoint(C4Point(0, 11.64), control2: C4Point(3.36, 15), point: C4Point(7.5, 15))
        cp.addLineToPoint(C4Point(12.5, 15))
        cp.addCurveToPoint(C4Point(13.88, 15), control2: C4Point(15, 13.88), point: C4Point(15, 12.5))
        cp.addCurveToPoint(C4Point(15, 11.12), control2: C4Point(13.88, 10), point: C4Point(12.5, 10))
        cp.closeSubpath()
        cp.transform(t)
        
        c = C4Shape(cp)
        c.fillColor = C4Pink
        c.origin = C4Point(20.0, menu.origin.y + 20.0)
        c.interactionEnabled = false
        
        var fp = C4Path()
        fp.moveToPoint(C4Point(17.5, 5))
        fp.addLineToPoint(C4Point(15, 5))
        fp.addLineToPoint(C4Point(15, 2.5))
        fp.addCurveToPoint(C4Point(15, 1.12), control2: C4Point(13.88, 0), point: C4Point(12.5, 0))
        fp.addCurveToPoint(C4Point(11.81, 0), control2: C4Point(11.18, 0.28), point: C4Point(10.73, 0.73))
        fp.addLineToPoint(C4Point(5.74, 5.72))
        fp.addLineToPoint(C4Point(5.74, 5.72))
        fp.addCurveToPoint(C4Point(5.28, 6.18), control2: C4Point(5, 6.81), point: C4Point(5, 7.5))
        fp.addCurveToPoint(C4Point(5, 8.88), control2: C4Point(6.12, 10), point: C4Point(7.5, 10))
        fp.addLineToPoint(C4Point(10, 10))
        fp.addLineToPoint(C4Point(10, 12.5))
        fp.addCurveToPoint(C4Point(10, 13.88), control2: C4Point(11.12, 15), point: C4Point(12.5, 15))
        fp.addCurveToPoint(C4Point(13.88, 15), control2: C4Point(15, 13.88), point: C4Point(15, 12.5))
        fp.addLineToPoint(C4Point(15, 10))
        fp.addLineToPoint(C4Point(17.5, 10))
        fp.addCurveToPoint(C4Point(18.88, 10), control2: C4Point(20, 8.88), point: C4Point(20, 7.5))
        fp.addCurveToPoint(C4Point(20, 6.12), control2: C4Point(18.88, 5), point: C4Point(17.5, 5))
        fp.closeSubpath()
        fp.transform(t)
        
        f = C4Shape(fp)
        f.fillColor = C4Blue
        f.origin = C4Point(f.origin.x+20, c.origin.y)
        f.interactionEnabled = false
        f.interactionEnabled = false;
        
        f2 = C4Shape(fp)
        f2.fillColor = C4Purple
        f2.origin = f.origin
        f2.interactionEnabled = false
        
        fmask = C4Shape(cp)
        fmask.origin = C4Point(c.origin.x - f.origin.x, 0)
        fmask.lineWidth = 1.0
        f2.layer?.mask = fmask.layer
        
        view.add(c)
        view.add(f)
        view.add(f2)
    }
    
    var bg = C4Rectangle()
    var scrollview = UIScrollView()
    var logo = C4Image("logoTwitter")
    func twitterCellHeader() {
        scrollview.frame = view.frame
        var size = scrollview.frame.size
        size.height *= 2.0
        scrollview.contentSize = size
        view.add(scrollview)
        
        bg = C4Rectangle(frame: C4Rect(0,0,Double(view.frame.size.width),44))
        bg.origin = C4Point(0,Double(view.frame.size.height))
        bg.lineWidth = 0
        bg.fillColor = darkGray
        
        let retweets = C4TextShape(text: "Retweets", font: C4Font(name: "Helvetica-Light", size: 16))
        retweets.center = C4Point(bg.width - retweets.width/2.0 - 10.0, bg.height / 2.0)
        retweets.fillColor = white
        bg.add(retweets)
        
        let numRT = C4TextShape(text: "4", font: C4Font(name: "Helvetica-Bold", size: 16))
        numRT.origin = C4Point(retweets.origin.x - numRT.width - 6, retweets.origin.y)
        numRT.fillColor = white
        bg.add(numRT)
        
        let dot = C4Ellipse(frame: C4Rect(0,0,6,6))
        dot.lineWidth = 0
        dot.fillColor = C4Blue
        dot.center = C4Point(numRT.origin.x-dot.width-4, numRT.center.y)
        bg.add(dot)
        
        let date = C4TextShape(text: "January 14, 2014", font: C4Font(name: "Helvetica-Light", size: 16))
        date.origin = C4Point(dot.origin.x-6-date.width,numRT.origin.y)
        date.fillColor = white
        bg.add(date)
        
        let fg = C4Rectangle(frame: bg.bounds)
        fg.lineWidth = 0
        fg.fillColor = lightGray
        scrollview.add(bg)
        bg.add(fg)
        
        scrollview.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
        
        let circ = C4Ellipse(frame: logo.bounds)
        logo.layer?.mask = circ.layer
        circ.lineWidth = 0
        logo.center = C4Point(fg.width / 2.0, 0.0)
        fg.add(logo)
        fg.interactionEnabled = false
        
        let font = C4Font(name: "Helvetica", size: 16)
        let name = C4TextShape(text: "cocoafor", font: font)
        name.fillColor = white
        name.lineWidth = 0
        name.center = C4Point(name.width / 2 + 10, bg.height / 2)
        bg.add(name)
        
        let a = C4ViewAnimation(duration: 0.15) {
            fg.center = C4Point(self.bg.width / 2.0, self.bg.height / 2.0)
            self.logo.center = C4Point(fg.width / 2.0, self.logo.center.y)
            name.opacity = 1.0
        }
        
        bg.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            if(translation.x < 0 && translation.x >= -(self.bg.width - circ.width - 20) ) {
                fg.center = C4Point(self.bg.width/2 + translation.x, self.bg.height/2.0)
                name.opacity = (self.bg.width / 3.0 + translation.x)/(self.bg.width/3.0)
                self.logo.center = C4Point(fg.width / 2.0 - translation.x/2.0, self.logo.center.y)
            }
            
            if state == .Ended {
                a.animate()
            }
        }
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            let offset = self.scrollview.contentOffset.y / self.scrollview.frame.size.height
            if(offset >= 0 && offset <= 1.0) {
                logo.center = C4Point(logo.center.x, self.bg.height * Double(offset))
            }
        }
    }
    var anims = [C4ViewAnimation]()
    func delayedAnims() {
        for i in 0...3 {
            let shape = C4Ellipse(frame: C4Rect(0,0,44,44))
            shape.center = C4Point(view.center)
            view.add(shape)
            
            let anim = C4ViewAnimation(duration: 0.5) {
                var target = shape.center
                let displacement = shape.width
                switch i {
                case 0:
                    target.y -= displacement
                case 1:
                    target.x -= displacement
                case 2:
                    target.y += displacement
                case 3:
                    target.x += displacement
                default:
                    break
                }
                shape.center = target
            }
            anim.curve = .EaseOut
            anims.append(anim)
        }
        
        delay(1.0) {
            self.anims[3].animate()
        }
        delay(1.1) {
            self.anims[2].animate()
        }
        delay(1.2) {
            self.anims[1].animate()
        }
        delay(1.3) {
            self.anims[0].animate()
        }
    }
}

/*
Issues with C4Shape+Creation

addCurve: creates curve properly, but rendering of that curve doesn't work. specifically, original line isn't used for fill, removing moveToPoint() works.
lineWidth: changing line width results in strange rendering, only last element of line is rendered, and shape doesn't have fill color.
*/
