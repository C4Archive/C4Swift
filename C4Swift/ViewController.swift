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
    var colors = [[C4Color]]()
    
    override func setup() {
        canvas.backgroundColor = white

        colors.append([C4Color(red: 0.354, green: 0.704, blue: 0.217, alpha: 1.0),C4Color(red: 0.105, green: 0.662, blue: 0.525, alpha: 1.0)])
        colors.append([C4Color(red: 0.746, green: 0.539, blue: 0.742, alpha: 1.0),C4Color(red: 0.428, green: 0.318, blue: 0.620, alpha: 1.0)])
        colors.append([C4Color(red: 0.991, green: 0.803, blue: 0.040, alpha: 1.0),C4Color(red: 0.914, green: 0.198, blue: 0.108, alpha: 1.0)])
        colors.append([C4Color(red: 0.199, green: 0.727, blue: 0.945, alpha: 1.0),C4Color(red: 0.303, green: 0.308, blue: 0.619, alpha: 1.0)])
        colors.append([C4Color(red: 0.904, green: 0.093, blue: 0.169, alpha: 1.0),C4Color(red: 0.915, green: 0.318, blue: 0.594, alpha: 1.0)])
        
        let circle = createCircle
        let tetris = createTetris
        let line = createLine
        let plus = createPlus

        let shapes = [circle, tetris, line, plus]
        canvas.addTapGestureRecognizer { (location, state) -> () in
            self.addShape(shapes, location: location)
        }
        
        self.addShapeAtRandomPoint(shapes)
    }
    
    func addShape(shapes: [()->C4Gradient], location: C4Point) {
        C4ShapeLayer.disableActions = true
        let index = random(below: shapes.count)
        let method = shapes[index]
        let newShape = method()
        newShape.center = location
        newShape.interactionEnabled = false
        self.canvas.add(newShape)
        C4ShapeLayer.disableActions = false
        
        delay(3.0) { () -> () in
            let anim = C4ViewAnimation(duration: 0.25, animations: { () -> Void in
                newShape.opacity = 0.0
            })
            anim.addCompletionObserver({ () -> Void in
                newShape.removeFromSuperview()
            })
            anim.animate()
        }
    }
    
    func addShapeAtRandomPoint(shapes: [()->C4Gradient]) {
        let x = random01() * canvas.width * 0.66 + canvas.width * 0.33/2.0
        let y = random01() * canvas.height * 0.66 + canvas.height * 0.33/2.0
        
        addShape(shapes, location: C4Point(x,y))
        delay(random01()*5.0+1.0) { () -> () in
            self.addShapeAtRandomPoint(shapes)
        }
   }
    
    func createCircle() -> C4Gradient {
        let gr = C4Gradient(frame: C4Rect(0,0,canvas.height/3.0+40.0,canvas.height/3.0+40.0), colors: colors[random(below: colors.count)], locations: [0,1])
        let c = C4Circle(center: gr.center, radius: gr.width/2.0-20.0)
        c.lineWidth = 40.0
        c.fillColor = clear
        c.lineCap = .Butt
        c.strokeEnd = 0.0
        gr.layer!.mask = c.layer
        
        delay(0.25) { () -> () in
            C4ViewAnimation(duration: 0.25, animations: { () -> Void in
                c.strokeEnd = 1.0
            }).animate()
        }
        return(gr)
    }
    
    func createTetris() -> C4Gradient {
        C4ShapeLayer.disableActions = true
        var gr : C4Gradient
        var t : C4Polygon
        
        if Bool(random(below: 2)) {
            gr = C4Gradient(frame: C4Rect(0,0,canvas.height/6.0,canvas.height/3.0), colors: colors[random(below: colors.count)], locations: [0,1])
            t = C4Polygon([C4Point(20.0,gr.height),C4Point(20,20),C4Point(gr.width,20.0)])
        } else {
            gr = C4Gradient(frame: C4Rect(0,0,canvas.height/3.0,canvas.height/6.0), colors: colors[random(below: colors.count)], locations: [0,1])
            t = C4Polygon([C4Point(gr.width-20.0,0),C4Point(gr.width-20,gr.height-20),C4Point(0,gr.height-20.0)])
        }
 
        t.lineCap = .Butt
        t.lineWidth = 40.0
        t.fillColor = clear
        t.lineJoin = .Miter
        t.strokeEnd = 0.0
        gr.layer!.mask = t.layer
        C4ShapeLayer.disableActions = false
        
        delay(0.25) { () -> () in
            C4ViewAnimation(duration: 0.25, animations: { () -> Void in
                t.strokeEnd = 1.0
            }).animate()
        }
        return(gr)
    }
    
    func createPlus() -> C4Gradient {
        let gr = C4Gradient(frame: C4Rect(0,0,canvas.height/6.0,canvas.height/6.0), colors: colors[random(below: colors.count)], locations: [0,1])
        let path = C4Path()
        path.moveToPoint(C4Point(0,gr.height/2.0))
        path.addLineToPoint(C4Point(gr.width,gr.height/2.0))
        path.moveToPoint(C4Point(gr.width/2.0,0))
        path.addLineToPoint(C4Point(gr.width/2.0,gr.height))
        let plus = C4Shape(path)
        
        plus.lineWidth = 40.0
        plus.lineCap = .Butt
        plus.strokeEnd = 0.0
        gr.layer?.mask = plus.layer
        
        if Bool(random(below: 2)) {
            let rotation = C4Transform.makeRotation(M_PI_4)
            gr.transform = rotation
        }
        
        delay(0.25) { () -> () in
            C4ViewAnimation(duration: 0.25, animations: { () -> Void in
                plus.strokeEnd = 1.0
            }).animate()
        }
        return gr
    }
    
    func createLine() -> C4Gradient {
        let gr = C4Gradient(frame: C4Rect(0,0,canvas.height/4.0,40.0), colors: colors[random(below: colors.count)], locations: [0,1])
        let line = C4Line([C4Point(0,gr.height/2.0),C4Point(gr.width,gr.height/2.0)])
        line.lineWidth = 40.0
        line.lineCap = .Butt
        line.strokeEnd = 0.0
        gr.layer?.mask = line.layer

        delay(0.25) { () -> () in
            C4ViewAnimation(duration: 0.25, animations: { () -> Void in
                line.strokeEnd = 1.0
            }).animate()
        }

        return gr
    }

}