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
        
    }
    
    func createCircle() -> C4Gradient {
        let gr = C4Gradient(frame: C4Rect(0,0,canvas.height/3.0+40.0,canvas.height/3.0+40.0), colors: colors[random(below: colors.count)], locations: [0,1])
        let c = C4Circle(center: gr.center, radius: gr.width/2.0-20.0)
        c.lineWidth = 40.0
        c.fillColor = clear
        gr.layer!.mask = c.layer
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
        gr.layer!.mask = t.layer
        C4ShapeLayer.disableActions = false
        return(gr)
    }
    
    func createPlus() -> C4Gradient {
        let gr = C4Gradient(frame: C4Rect(0,0,canvas.height/6.0,canvas.height/6.0), colors: colors[random(below: colors.count)], locations: [0,1])
        let line1 = C4Line([C4Point(0,gr.height/2.0),C4Point(gr.width,gr.height/2.0)])
        line1.lineWidth = 40.0
        line1.lineCap = .Butt
        let line2 = C4Line([C4Point(gr.width/2.0,0),C4Point(gr.width/2.0,gr.height)])
        line2.lineWidth = 40.0
        line2.lineCap = .Butt
        if let l2l = line2.layer {
            line1.layer?.addSublayer(l2l)
        }
        gr.layer?.mask = line1.layer
        
        if Bool(random(below: 2)) {
            let rotation = C4Transform.makeRotation(M_PI_4)
            gr.transform = rotation
        }
        
        return gr
    }
    
    func createLine() -> C4Gradient {
        let gr = C4Gradient(frame: C4Rect(0,0,canvas.height/4.0,40.0), colors: colors[random(below: colors.count)], locations: [0,1])
        let line = C4Line([C4Point(0,gr.height/2.0),C4Point(gr.width,gr.height/2.0)])
        line.lineWidth = 40.0
        line.lineCap = .Butt
        gr.layer?.mask = line.layer
        return gr
    }

}