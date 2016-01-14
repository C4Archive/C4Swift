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
    var gradients = [C4Gradient]()
    var points = [C4Point]()

    override func setup() {
//        let g = C4Gradient(frame: C4Rect(0,0,200,200), locations: [0,1])
//        canvas.add(g)
        setupPan()
//        setupDisperse()
//        setupRain()
    }
    
    func setupDisperse() {
        canvas.addLongPressGestureRecognizer { (location, state) -> () in
            if state == .Began {
                self.gradients.removeAll()
                self.createGradients()
            }
        }
        
        canvas.addTapGestureRecognizer { (location, state) -> () in
            self.disperseGradients()
        }
    }
    
    func disperseGradients() {
        for g in gradients {
            let mod = (random01()*2.0-1.0)*500
            var center = g.center
            center.x += mod
            
            let move = C4ViewAnimation(duration: 0.75) {
                g.center = center
                g.opacity = 0.5
            }
            move.curve = .EaseOut
            
            let fade = C4ViewAnimation(duration: 0.25) {
                g.opacity = 0.0
            }
            fade.curve = .EaseOut
            fade.addCompletionObserver({ () -> Void in
                g.removeFromSuperview()
            })
            
            let seq = C4ViewAnimationSequence(animations: [move,fade])
            seq.animate()
        }
    }
    
    func createGradients() {
        for _ in 0...50 {
            let g = C4Gradient(frame: C4Rect(0,0,3,random01()*100+100), colors: [C4Pink, C4Blue])
            let mod = (random01()*2.0-1.0)*10
            g.center = C4Point(self.canvas.center.x + mod, self.canvas.center.y)
            self.canvas.add(g)
            self.gradients.append(g)
            let anim = C4ViewAnimation(duration: random01()*3+1) {
                g.transform = C4Transform.makeScale(1.0,random01()*2+1.0)
            }
            anim.autoreverses = true
            anim.repeats = true
            anim.curve = .EaseInOut
            anim.animate()
        }
    }

    func setupRain() {
        canvas.addTapGestureRecognizer { (location, state) -> () in
            if location.y < 100 {
                for _ in 0...10 {
                    let g = C4Gradient(frame: C4Rect((random01()*2.0-1.0)*40+location.x,location.y,2,2), colors: [C4Pink, C4Blue])
                    self.canvas.add(g)
                    self.canvas.sendToBack(g)
                    let anim = C4ViewAnimation(duration: random01()/2.0 + 0.5) {
                        g.transform = C4Transform.makeScale(random01()*4+4,random01()*400+100)
                        g.origin = C4Point(g.origin.x + random01() * 200.0, (random01()+1.0) + self.canvas.height)
                    }
                    anim.autoreverses = false
                    anim.repeatCount = 0
                    anim.curve = .EaseIn
                    anim.animate()
                }
            }
            
            else {
                let c = C4Circle(center: location, radius: 100)
                c.interactionEnabled = false
                c.fillColor = C4Grey
                c.lineWidth = 0.0
                self.canvas.add(c)
                let anim = C4ViewAnimation(duration: 10.0) {
                    c.transform = C4Transform.makeScale(0.01, 0.01)
                }
                anim.addCompletionObserver({ () -> Void in
                    c.removeFromSuperview()
                })
                anim.curve = .EaseOut
                anim.animate()
            }
        }
        
        canvas.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            if location.y < 100 {
                    let g = C4Gradient(frame: C4Rect((random01()*2.0-1.0)*40+location.x,location.y,2,2), colors: [C4Pink, C4Blue])
                    self.canvas.add(g)
                    self.canvas.sendToBack(g)
                    let anim = C4ViewAnimation(duration: random01()/2.0 + 0.5) {
                        g.transform = C4Transform.makeScale(random01()*4+4,random01()*400+100)
                        g.origin = C4Point(g.origin.x,(random01()+1.0) + self.canvas.height)
                    }
                    anim.autoreverses = false
                    anim.repeatCount = 0
                    anim.curve = .EaseIn
                    anim.animate()
                }
        }
    }
    
    func setupPan() {
        canvas.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            self.createBar(location)
        }
       
        canvas.addLongPressGestureRecognizer { (location, state) -> () in
            if state == .Began {
                for g in self.gradients {
                    g.removeFromSuperview()
                }
                self.gradients.removeAll()
            }
        }

        canvas.backgroundColor = black
    }
    
    func animateAllGradients() {
        for gradient in gradients {
            createAnim(gradient)
        }
        
        delay(4.0) {
            print(__FUNCTION__)
            self.animateAllGradients()
        }
    }

    func createBar(point: C4Point) {
        let width = random(below: 5)+1
        let g = C4Gradient(frame: C4Rect(0,0,width,random(below: 250)+50), locations: [0,1])
        g.center = point
        g.endPoint = C4Point(0,1.0)
        g.border.radius = Double(width)/4.0
        switch random(below: 2) {
        case 0:
            g.colors = [C4Blue,C4Pink]
        default:
            g.colors = [C4Pink,C4Blue]
        }
        canvas.add(g)
        createAnim(g)
        gradients.append(g)

        if gradients.count > 100 {
            let fade = gradients[0]
            fade.removeFromSuperview()
            self.gradients.removeAtIndex(0)
        }
    }
    
    func createAnim(g: C4Gradient) {
        let c = g.center
        let anim = C4ViewAnimation(duration: 3.0) {
            let t = C4Transform.makeScale(1, random01() + 0.5)
            g.transform = t
            g.center = c
        }
        anim.autoreverses = true
        anim.repeats = true
        anim.curve = .EaseInOut
        
        delay(random01()*1.0 + 0.25) {
            anim.animate()
        }
    }
}