//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import C4iOS
import C4Core
import C4Animation

//class ViewController: UIViewController {
//    var s: C4Line = C4Line([C4Point(),C4Point(100,100)])
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.view.add(s)
//        test(s)
//        
//        let tg = UITapGestureRecognizer(target: self, action: "handleTap:")
//        self.view.addGestureRecognizer(tg)
//        
//        let cube = IsometricCube()
//        cube.view.frame = self.view.frame
//        self.view.add(cube.view)
//    }
//
//    func test(s: C4Shape) {
//        let v = s.strokeColor
//        view.backgroundColor = v
//        s.strokeColor = .redColor()
//    }
//    
//    func handleTap(sender: UITapGestureRecognizer) {
//        s.points = [C4Point(random(below: 100),random(below: 100)),C4Point(random(below: 100),random(below: 100))]
//    }
//    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
//}

class ViewController: UIViewController {
    
    var dynamicLine: C4Line = C4Line([C4Point(),C4Point(100,100)])

    let dx = 100.0
    var fill = UIColor.orangeColor()
    var offset = C4Vector()
    var points = [IsometricPoint]()
    
    override func viewDidLoad() {
            offset = C4Vector(x:Double(view.center.x),y:Double(view.center.y)-74.5) //hacking the 74.5
            points.append(IsometricPoint(0,0,dx,offset))
            points.append(IsometricPoint(0,1,dx,offset))
            points.append(IsometricPoint(1,0,dx,offset))
            points.append(IsometricPoint(1,1,dx,offset))
            points.append(IsometricPoint(1,2,dx,offset))
            points.append(IsometricPoint(2,2,dx,offset))
            points.append(IsometricPoint(2,1,dx,offset))
            
            addLine(from: points[0], to: points[1])
            addLine(from: points[0], to: points[2])
            addLine(from: points[1], to: points[3])
            addLine(from: points[2], to: points[3])
            addLine(from: points[1], to: points[4])
            addLine(from: points[3], to: points[5])
            addLine(from: points[2], to: points[6])
            addLine(from: points[4], to: points[5])
            addLine(from: points[5], to: points[6])
            
            for p in points {
                addEllipse(p.screenCoordinate)
            }

        let tg = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.view.addGestureRecognizer(tg)
        
        self.view.add(dynamicLine)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        dynamicLine.points = [C4Point(random(below: 100),random(below: 100)),C4Point(random(below: 100),random(below: 100))]
    }
    
    func addEllipse(at: C4Point) {
        var e = Ellipse(C4Rect(0,0,4,4))
        e.center = CGPoint(at)
        e.fillColor = fill
        self.view.add(e)
    }
    
    func addLine(from a:IsometricPoint, to b:IsometricPoint) {
        let line = C4Line([a.screenCoordinate,b.screenCoordinate])
        line.lineWidth = 2.0
        line.strokeColor = .blueColor()
        self.view.add(line)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

struct IsometricPoint {
    var x: Int = 0
    var y: Int = 0
    var dx: Double = 1.0
    var dy: Double = 1.0
    var offset: C4Vector = C4Vector(1,1)
    
    init(_ x: Int, _ y: Int, _ dx: Double, _ off: C4Vector) {
        self.x = x
        self.y = y
        self.dx = dx
        self.dy = dx / 1.9
        self.offset = off
    }
    
    var screenCoordinate: C4Point {
        get {
            let s = sin(45.0 * M_PI / 180.0)
            let c = cos(45.0 * M_PI / 180.0)
            var point = C4Point()
            
            point.x = c * Double(x) - s * Double(y) //normalized translate
            point.x *= dx                           //scaled
            
            point.y = s * Double(x) + c * Double(y) //normalize translate
            point.y *= dy                           //scaled
            
            return point + offset                   //offset
        }
    }
}
//
//struct Logo {
//    var offset: C4Vector = C4Vector(1,1)
//    var dx = 1.0
//    var dy = 1.0
//    var scale: Int
//}
//
//class GridLayout: UIViewController {
//    let dx = 8.0
//    let dy = 8.0 / 1.9
//
//    override func viewDidLoad() {
//        for x in 0...200 {
//            for y in 0...200 {
//                let p = isometric(C4Point(Double(x),Double(y)))
//                if C4Rect(self.view.frame).contains(p) {
//                    addEllipse(p)
//                }
//
//                if y > Int(self.view.frame.size.height) {
//                    break
//                }
//            }
//        }
//    }
//
//    func isometric(var point: C4Point) -> C4Point {
//        point = rotate(point, 45)
//        point = C4Point(point.x * dx, point.y*dy)
//        point = point + C4Vector(x: Double(self.view.center.x), y:10)
//        return point
//    }
//
//    func rotate(point: C4Point, _ degrees: Double) -> C4Point {
//        let s = sin(degrees * M_PI / 180.0)
//        let c = cos(degrees * M_PI / 180.0)
//        return C4Point(c * point.x - s * point.y, s * point.x + c * point.y);
//    }
//
//    func addEllipse(at: C4Point) {
//            var e = Ellipse(C4Rect(0,0,4,4))
//            e.center = CGPoint(at)
//            self.view.add(e)
//    }
//
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
//}
//
//class ShapeView: UIView {
//    lazy internal var linePoints = [CGPoint]()
//    lazy internal var start = C4Point()
//    lazy internal var end = C4Point()
//    lazy internal var duration = 1.0
//    
//    convenience init(_ points: [CGPoint]) {
//        self.init(frame: CGRectMakeFromPoints(points))
//        let p = CGPathCreateMutable()
//        CGPathMoveToPoint(p, nil, 0,0)
//        CGPathAddLineToPoint(p, nil, 1, 1)
//        shapeLayer.path = p
//        updatePoints(points)
//    }
//    
//    func updatePoints(points:[CGPoint]) {
//        linePoints.removeAll()
//        for i in 0..<points.count {
//            linePoints.append(points[i])
//        }
//        updatePath()
//    }
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//    
//    override class func layerClass() -> AnyClass {
//        return CAShapeLayer.self
//    }
//    
//    func updatePath() {
//        if linePoints.count > 1 {
//            var path = CGPathCreateMutable()
//            CGPathMoveToPoint(path, nil, linePoints[0].x, linePoints[0].y)
//            
//            for i in 1..<linePoints.count {
//                CGPathAddLineToPoint(path, nil, linePoints[i].x, linePoints[i].y)
//            }
//            animateKeyPath("path", toValue: path)
//        }
//    }
//    
//    var shapeLayer: CAShapeLayer {
//        get {
//            return layer as CAShapeLayer
//        }
//    }
//    
//    func animation() -> CABasicAnimation {
//        var anim = CABasicAnimation()
//        anim.duration = 0.25
//        anim.beginTime = CACurrentMediaTime()
//        anim.autoreverses = false
//        anim.repeatCount = 0
//        anim.removedOnCompletion = false
//        anim.fillMode = kCAFillModeBoth
//        return anim
//    }
//    
//    func animateKeyPath(keyPath: String, toValue: AnyObject) {
//        CATransaction.begin()
//        CATransaction.setCompletionBlock({
//            self.shapeLayer.path = toValue as CGPath
//            self.adjustToFitPath()
//        })
//        var anim = animation()
//        anim.keyPath = "path"
//        anim.fromValue = self.layer.presentationLayer()?.valueForKeyPath("path")
//        anim.toValue = toValue
//        self.layer.addAnimation(anim, forKey:"animatepath")
//        CATransaction.commit()
//    }
//    
//    func adjustToFitPath() {
//        if shapeLayer.path == nil {
//            return
//        }
//        var f = CGPathGetPathBoundingBox(shapeLayer.path)
//        var t = CGAffineTransformMakeTranslation(0,0)
//        let p = CGPathCreateCopyByTransformingPath(shapeLayer.path, &t)
//        
//        self.shapeLayer.path = p
//        bounds = CGPathGetPathBoundingBox(shapeLayer.path)
//        frame = f
//    }
//}


