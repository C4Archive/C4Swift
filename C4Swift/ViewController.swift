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
    
    override func viewDidLoad() {
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
            circle.lineWidth = 1.25
            if i == 1 || i == 2 {
                circle.lineWidth = 4.25
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