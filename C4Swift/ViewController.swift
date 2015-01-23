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
    
    override func viewDidLoad() {
        var about = MenuButton("About C4")
        about.center = C4Point(view.center)
        view.backgroundColor = UIColor(lightGray)
        about.action = {
            println("run")
        }
        
        var components = MenuButton("Components")
        components.center = C4Point(view.center)
        view.backgroundColor = UIColor(lightGray)
        components.action = {
            println("run")
        }
        
        var tutorials = MenuButton("Tutorials")
        tutorials.center = C4Point(view.center)
        view.backgroundColor = UIColor(lightGray)
        tutorials.action = {
            println("run")
        }
        var examples = MenuButton("Examples")
        examples.center = C4Point(view.center)
        view.backgroundColor = UIColor(lightGray)
        examples.action = {
            println("run")
        }
        
        var menu = C4View(frame: C4Rect(0,0,Double(view.frame.size.width),276))
        menu.backgroundColor = white

        var origin = C4Point(menu.width-20-components.width, 20)
        components.origin = origin
        origin.y += components.height + 20
        tutorials.origin = origin
        origin.y += components.height + 20
        examples.origin = origin
        origin.y += components.height + 20
        about.origin = origin
        
        menu.add(components)
        menu.add(tutorials)
        menu.add(examples)
        menu.add(about)
        
        view.add(menu)
    }
    
    func logo() {
        var t = C4Transform.makeScale(2.0, 2.0, 0.0)
        
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
        
        var c = C4Shape(cp)
        c.fillColor = C4Pink
        c.origin = C4Point(c.origin.x, c.origin.y + 100)
        view.add(c)
        
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
        
        var f = C4Shape(fp)
        f.fillColor = C4Blue
        f.origin = C4Point(f.origin.x, f.origin.y + 100)
        view.add(f)
        
        var f2 = C4Shape(fp)
        f2.fillColor = C4Purple
        f2.origin = f.origin
        view.add(f2)
        
        let fmask = C4Shape(cp)
        fmask.origin = C4Point(c.origin.x - f.origin.x-0.5, 0)
        fmask.lineWidth = 1.0
        f2.layer?.mask = fmask.layer
        
        var canim = C4ViewAnimation(duration: 0.25) {
            c.origin = C4Point(c.origin.x,c.origin.y - 50)
            fmask.origin = C4Point(fmask.origin.x,fmask.origin.y - 50)
        }
        canim.curve = .EaseOut
        
        var fanim = C4ViewAnimation(duration: 0.25) {
            f.origin = C4Point(f.origin.x,f.origin.y - 50)
            f2.origin = C4Point(f2.origin.x,f2.origin.y - 50)
            fmask.origin = C4Point(fmask.origin.x,fmask.origin.y + 50)
        }
        
        fanim.curve = .EaseOut
        
        delay(1) {
            canim.animate()
        }
        
        delay(1.1) {
            fanim.animate()
        }
        
    }
}

/*
Issues with C4Shape+Creation

addCurve: creates curve properly, but rendering of that curve doesn't work. specifically, original line isn't used for fill, removing moveToPoint() works.
lineWidth: changing line width results in strange rendering, only last element of line is rendered, and shape doesn't have fill color.
*/
