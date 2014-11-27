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
    var d = [String: LogoLine]()
    var t: NSTimer = NSTimer()
    var dl = DynamicLine()
    var visibleLine = C4Line([C4Point(0,0),C4Point(1,1)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
        reveal()
        visibleLine.points = [dl.a.screenCoordinate,dl.b.screenCoordinate]
        visibleLine.strokeColor = .redColor()
        visibleLine.lineWidth = 2.0
        view.add(visibleLine)
        logic()
    }
    
    func logic() {
        if let line = d[dl.id]? {
            var options = [String]()
            if line.canShift { options.append("shift") }
            if line.canSlide { options.append("slides") }
            
            var r = 0
            
            if options.count > 1 {
                r = random() % options.count
            }
            
            if(options[r] == "slides") {
                let arr = line.slides.targets
                r = random() % arr.count
                let nl = line.slides.targets[r]
                //println("line({\(dl.a.x),\(dl.a.y)},{\(dl.b.x),\(dl.b.y)}) should slide to ({\(nl[0].x),\(nl[0].y)},{\(nl[1].x),\(nl[1].y)})")
                dl = DynamicLine(nl[0],nl[1])
            } else {
                options = [String]()
                if line.shifts.a.targets.count > 0 { options.append("a") }
                if line.shifts.b.targets.count > 0 { options.append("b") }
                
                r = 0
                
                if options.count > 1 {
                    r = random() % options.count
                }
                
                if(options[r] == "a") {
                    let arr = line.shifts.a.targets
                    r = random() % arr.count
                    //println("line({\(dl.a.x),\(dl.a.y)},{\(dl.b.x),\(dl.b.y)}) should shift to ({\(arr[r].x),\(arr[r].y)},{\(dl.b.x),\(dl.b.y)})")
                    dl.a = arr[r]
                } else {
                    let arr = line.shifts.b.targets
                    r = random() % arr.count
                    //println("line({\(dl.a.x),\(dl.a.y)},{\(dl.b.x),\(dl.b.y)}) should shift to ({\(dl.a.x),\(dl.a.y)},{\(arr[r].x),\(arr[r].y)})")
                    dl.b = arr[r]
                }
            }
            visibleLine.points = [dl.a.screenCoordinate,dl.b.screenCoordinate]
        }
        
        delay(0.5, closure: {
            self.logic()
        })
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func printAllOptions() {
        let keys = d.keys
        for k in keys {
            printOptions(k)
        }
    }
    
    func reveal() {
        for k in d.keys {
            let logoline: LogoLine = d[k]!
            let line = C4Line([logoline.a.screenCoordinate,logoline.b.screenCoordinate])
            line.strokeColor = .lightGrayColor()
            view.add(line)
        }
    }
    
    func printOptions(id:String) {
        let l = d[id]
        
        if let line = l? {
            println("The line running from (\(line.a.x),\(line.a.y)) to (\(line.b.x),\(line.b.y))")
            if line.canSlide {
                println("\tCan slide to:")
                for i in 0..<line.slides.targets.count {
                    let points = line.slides.targets[i]
                    println("\t\t(\(points[0].x),\(points[0].y)) to (\(points[1].x),\(points[1].y))")
                }
            } else {
                println("\tCan NOT slide")
            }
            if line.canShift {
                println("\tCan shift:")
                if line.shifts.a.targets.count > 0 {
                    println("\t\t A to:")
                    for i in 0..<line.shifts.a.targets.count {
                        let target = line.shifts.a.targets[i]
                        println("\t\t\t(\(target.x),\(target.y))")
                    }
                }
                if line.shifts.b.targets.count > 0 {
                    println("\t\t B to:")
                    for i in 0..<line.shifts.b.targets.count {
                        let target = line.shifts.b.targets[i]
                        println("\t\t\t(\(target.x),\(target.y))")
                    }
                }
            } else {
                println("\tCan NOT shift")
            }
        }
    }
    
    func build() {
        
        func run0() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(1,1,dx,offset))
            b.append(IsometricPoint(1,0,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(0,1,dx,offset),IsometricPoint(1,1,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(0,0,dx,offset), b: IsometricPoint(0,1,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        func run1() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(0,1,dx,offset))
            b.append(IsometricPoint(2,1,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(0,0,dx,offset),IsometricPoint(0,1,dx,offset)])
            slides.append([IsometricPoint(2,1,dx,offset),IsometricPoint(2,2,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(1,0,dx,offset), b: IsometricPoint(1,1,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        func run2() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(1,1,dx,offset))
            b.append(IsometricPoint(0,1,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(0,1,dx,offset),IsometricPoint(1,1,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(0,0,dx,offset), b: IsometricPoint(1,0,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        func run3() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(1,0,dx,offset))
            a.append(IsometricPoint(2,2,dx,offset))
            b.append(IsometricPoint(0,0,dx,offset))
            b.append(IsometricPoint(1,2,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(0,0,dx,offset),IsometricPoint(1,0,dx,offset)])
            slides.append([IsometricPoint(1,2,dx,offset),IsometricPoint(2,2,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(0,1,dx,offset), b: IsometricPoint(1,1,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        func run4() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(2,2,dx,offset))
            b.append(IsometricPoint(1,1,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(1,1,dx,offset),IsometricPoint(2,2,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(0,1,dx,offset), b: IsometricPoint(1,2,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        func run5() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(2,2,dx,offset))
            b.append(IsometricPoint(1,1,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(1,1,dx,offset),IsometricPoint(2,2,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(1,0,dx,offset), b: IsometricPoint(2,1,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        func run6() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(1,2,dx,offset))
            a.append(IsometricPoint(2,1,dx,offset))
            b.append(IsometricPoint(1,0,dx,offset))
            b.append(IsometricPoint(0,1,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(0,1,dx,offset),IsometricPoint(1,2,dx,offset)])
            slides.append([IsometricPoint(1,0,dx,offset),IsometricPoint(2,1,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(1,1,dx,offset), b: IsometricPoint(2,2,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        func run7() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(1,1,dx,offset))
            b.append(IsometricPoint(0,1,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(0,1,dx,offset),IsometricPoint(1,1,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(1,2,dx,offset), b: IsometricPoint(2,2,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        func run8() {
            let dx = 100.0
            var offset = C4Vector(x:Double(view.center.x),y:Double(20))
            var a = Shift()
            var b = Shift()
            
            a.append(IsometricPoint(1,1,dx,offset))
            b.append(IsometricPoint(1,0,dx,offset))
            
            var shifts = Shifts(a,b)
            
            var slides = Slides()
            slides.append([IsometricPoint(1,0,dx,offset),IsometricPoint(1,1,dx,offset)])
            
            let l = LogoLine(a: IsometricPoint(2,1,dx,offset), b: IsometricPoint(2,2,dx,offset), slides: slides, shifts: shifts)
            d[l.id] = l
        }
        
        run0()
        run1()
        run2()
        run3()
        run4()
        run5()
        run6()
        run7()
        run8()
    }
 
//    var dynamicLine: C4Line = C4Line([C4Point(),C4Point(100,100)])
//
//    let dx = 100.0
//    var fill = UIColor.orangeColor()
//    var offset = C4Vector()
//    var points = [IsometricPoint]()
//    
//    override func viewDidLoad() {
//            offset = C4Vector(x:Double(view.center.x),y:Double(view.center.y)-74.5) //hacking the 74.5
//            points.append(IsometricPoint(0,0,dx,offset))
//            points.append(IsometricPoint(0,1,dx,offset))
//            points.append(IsometricPoint(1,0,dx,offset))
//            points.append(IsometricPoint(1,1,dx,offset))
//            points.append(IsometricPoint(1,2,dx,offset))
//            points.append(IsometricPoint(2,2,dx,offset))
//            points.append(IsometricPoint(2,1,dx,offset))
//            
//            addLine(from: points[0], to: points[1])
//            addLine(from: points[0], to: points[2])
//            addLine(from: points[1], to: points[3])
//            addLine(from: points[2], to: points[3])
//            addLine(from: points[1], to: points[4])
//            addLine(from: points[3], to: points[5])
//            addLine(from: points[2], to: points[6])
//            addLine(from: points[4], to: points[5])
//            addLine(from: points[5], to: points[6])
//            
//            for p in points {
//                addEllipse(p.screenCoordinate)
//            }
//
//        let tg = UITapGestureRecognizer(target: self, action: "handleTap:")
//        self.view.addGestureRecognizer(tg)
//        
//        self.view.add(dynamicLine)
//    }
//    
//    func handleTap(sender: UITapGestureRecognizer) {
//        dynamicLine.points = [C4Point(random(below: 100),random(below: 100)),C4Point(random(below: 100),random(below: 100))]
//    }
//    
//    func addEllipse(at: C4Point) {
//        var e = Ellipse(C4Rect(0,0,4,4))
//        e.center = CGPoint(at)
//        e.fillColor = fill
//        self.view.add(e)
//    }
//    
//    func addLine(from a:IsometricPoint, to b:IsometricPoint) {
//        let line = C4Line([a.screenCoordinate,b.screenCoordinate])
//        line.lineWidth = 2.0
//        line.strokeColor = .blueColor()
//        self.view.add(line)
//    }
//    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
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

struct DynamicLine {
    internal var points: [IsometricPoint]
    var a: IsometricPoint {
        get {
            return points[0]
        } set(val) {
            points[0] = val
            sort()
        }
    }
    var b: IsometricPoint {
        get {
            return points[1]
        } set(val) {
            points[1] = val
            sort()
        }
    }
    var id: String {
        get {
            return "\(Int(a.x)),\(Int(a.y)).\(Int(b.x)),\(Int(b.y))"
        }
    }
    
    init(_ a: IsometricPoint, _ b:IsometricPoint) {
        points = [IsometricPoint]()
        points.append(a)
        points.append(b)
        sort()
    }
    
    init() {
        self.init(IsometricPoint(0,0,100,C4Vector(x:160.0,y:Double(20))), IsometricPoint(0,1,100,C4Vector(x:160.0,y:Double(20))))
    }
    
    mutating internal func sort() {
        let tmpa = a
        let tmpb = b
        if(tmpa.y > tmpb.y) {
            points[0] = tmpb
            points[1] = tmpa
        } else if tmpa.y == tmpb.y {
            if tmpa.x > tmpb.x {
                points[0] = tmpb
                points[1] = tmpa
            }
        }
    }
}

struct LogoLine {
    let a: IsometricPoint
    let b: IsometricPoint
    let slides: Slides
    let shifts: Shifts
    
    var id: String {
        get {
            return "\(Int(a.x)),\(Int(a.y)).\(Int(b.x)),\(Int(b.y))"
        }
    }
    
    init(a: IsometricPoint, b: IsometricPoint, slides: Slides, shifts: Shifts) {
        self.a = a
        self.b = b
        self.slides = slides
        self.shifts = shifts
    }
    
    var canShift: Bool {
        get {
            return slides.targets.count > 0
        }
    }
    
    var canSlide: Bool {
        get {
            return shifts.a.targets.count > 0 || shifts.b.targets.count > 0
        }
    }
}

public struct Slides {
    var targets: [[IsometricPoint]] = [[IsometricPoint]]()
    mutating func append(points: [IsometricPoint]) {
        targets.append(points)
    }
}

public struct Shifts {
    var a: Shift
    var b: Shift
    init(_ a: Shift, _ b: Shift) {
        self.a = a
        self.b = b
    }
}

public struct Shift {
    var targets: [IsometricPoint] = [IsometricPoint]()
    
    mutating func append(point: IsometricPoint) {
        targets.append(point)
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


