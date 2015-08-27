//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import C4

class MyTapGestureRecognizer : UITapGestureRecognizer {
    var touches = [UITouch]()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        self.touches = Array(touches)
    }
}

class MyPanGestureRecognizer : UIPanGestureRecognizer {
    var touches = [UITouch]()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        self.touches = Array(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        self.touches = Array(touches)
    }
}

struct Point {
    var x = 0.0
    var y = 0.0
    var z = 0.0
    
    var vz = 0.0
    var az = 0.0
    
    init() {}
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

class PointView : C4Circle {
    var point = Point()
    
    convenience init(point: Point) {
        let radius = 2.0
        let frame = C4Rect(point.x-radius, point.y-radius, radius * 2, radius * 2)
        self.init(frame: frame)
        self.point = point
        self.strokeColor = nil
        self.fillColor = C4Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    }
    
    func update() {
        center = C4Point(point.x, point.y)
        
        var v: Double
        if point.z > 0 {
            v = pow(point.z, 0.3) + 0.5
        } else {
            v = -pow(-point.z, 0.3) + 0.5
        }
        fillColor = C4Color(red: v, green: v, blue: v, alpha: 1)
    }
}

class ViewController: C4CanvasController {
    var touches = [C4Shape]()
    var lines = [C4Line]()

    struct Constants {
        static let rows = 20
        static let cols = 70
        static let spacing = 20.0
        static let springConstant = 500.0
        static let dampening = 0.1 * sqrt(springConstant)
        static let frameInterval = 1
        static let dt = Double(frameInterval) / 60.0
    }
    
    var views = [PointView]()
    var displayLink: CADisplayLink?
    var updateCount = 0
    
    func view(var col col: Int, var row: Int) -> PointView {
        if row < 0 { row += Constants.rows }
        if row >= Constants.rows { row -= Constants.rows }
        if col < 0 { col += Constants.cols }
        if col >= Constants.cols { col -= Constants.cols }
        return views[row * Constants.cols + col]
    }
    
    func step() {
        for r in 0..<Constants.rows {
            for c in 0..<Constants.cols {
                let left   = view(col: c - 1, row: r).point
                let right  = view(col: c + 1, row: r).point
                let top    = view(col: c, row: r - 1).point
                let bottom = view(col: c, row: r + 1).point
                
                let v = view(col: c, row: r)
                let center = v.point
                var force = (left.z - center.z) + (right.z - center.z) + (top.z - center.z) + (bottom.z - center.z)
                force *= Constants.springConstant
                force -= Constants.springConstant * center.z / 10.0
                if force > 0 && force - Constants.dampening * v.point.vz >= 0 {
                    force -= Constants.dampening * v.point.vz
                } else if force < 0 && force - Constants.dampening * v.point.vz <= 0 {
                    force -= Constants.dampening * v.point.vz
                }
                v.point.az += force
            }
        }
        for r in 0..<Constants.rows {
            for c in 0..<Constants.cols {
                let v = view(col: c, row: r)
                v.point.vz += v.point.az * Constants.dt
                v.point.z += v.point.vz * Constants.dt
                v.point.az = 0
                if v.point.z > 0.5 {
                    v.point.z = 0.5
                    if v.point.vz > 0 {
                        v.point.vz = 0
                    }
                }
                if v.point.z < -0.5 {
                    v.point.z = -0.5
                    if v.point.vz < 0 {
                        v.point.vz = 0
                    }
                }
            }
        }
        
        updateCount += 1
        if updateCount == 4 {
            for v in views {
                v.update()
            }
            updateCount = 0
        }
    }
    
    func neurotic() {
        let l = C4Line([C4Point(),C4Point(canvas.width,canvas.height)])
        l.lineWidth = 300.0
        l.strokeColor = C4Blue
        l.opacity = 0.5
        canvas.add(l)
        
        let lrot = C4ViewAnimation(duration: 1.0) {
            l.transform = C4Transform.makeRotation(M_PI)
        }
        lrot.repeats = true
        lrot.animate()
        
        let r = C4ViewAnimation(duration: random01()/3.0){
            self.canvas.backgroundColor = C4Pink
            delay(random01()/3.0) {
                C4ViewAnimation(duration: 0.0) {
                    l.strokeColor = C4Pink
                }.animate()
            }
        }
        r.curve = .EaseOut

        let w = C4ViewAnimation(duration: random01()/3.0){
            self.canvas.backgroundColor = C4Blue
            delay(random01()/3.0) {
                C4ViewAnimation(duration: 0.0) {
                    l.strokeColor = C4Blue
                    }.animate()
            }
        }
        w.curve = .EaseOut

        r.addCompletionObserver { () -> Void in
            delay(random01()/3.0) {
                w.animate()
            }
        }
        
        r.addCompletionObserver { () -> Void in
            delay(random01()/3.0) {
                r.animate()
            }
        }
        
        r.animate()
        
        
    }
    
    func createVerticalLine() {
        canvas.addTapGestureRecognizer { (location, state) -> () in
            
            let points = [C4Point(),C4Point(0,self.canvas.height)]
            var origin = C4Point(-self.canvas.width*0.2,self.canvas.center.y)
            var target = C4Point(self.canvas.width * 1.2,self.canvas.center.y)
            
            if false {
                origin = C4Point(self.canvas.width*1.2,self.canvas.center.y)
                target = C4Point(-self.canvas.width*0.2,self.canvas.center.y)
            }
            
            let l = C4Line(points)
            l.center = origin
            l.lineWidth = 229
            l.strokeColor = black
            l.border.radius = 10
            l.border.width = 1.0
            l.border.color = white
            l.interactionEnabled = false
            self.canvas.add(l)
            
            let anim = C4ViewAnimation(duration: random01()+1.0) {
                l.center = target
                l.transform = C4Transform.makeRotation(M_PI/30.0)
            }
            anim.curve = .EaseInOut
            anim.autoreverses = true
            anim.repeats = true
            anim.animate()
        }
    }
    
    func createLine() {
        canvas.addTapGestureRecognizer { (location, state) -> () in
        
            var points = [C4Point(),C4Point(self.canvas.width,self.canvas.height)]
            var origin = C4Point(-self.canvas.width*0.1,self.canvas.height * 1.1)
            var target = C4Point(self.canvas.width * 1.1,-self.canvas.height*0.1)

            if false {
                points = [C4Point(0,self.canvas.height),C4Point(self.canvas.width,0)]
                origin = C4Point(self.canvas.width*1.1,self.canvas.height * 1.1)
                target = C4Point(-self.canvas.width*0.1,-self.canvas.height*0.1)
            }
            
            let l = C4Line(points)
            l.center = origin
            l.lineWidth = 100
            l.interactionEnabled = false
            self.canvas.add(l)
            
            let anim = C4ViewAnimation(duration: 2.0) {
                l.center = target
            }
            anim.curve = .EaseInOut
            anim.repeats = true
            anim.animate()

        }
    }
    
    
    override func setup() {
        for r in 0..<Constants.rows {
            for c in 0..<Constants.cols {
                let point = Point(x: Double(c) * Constants.spacing, y: Double(r) * Constants.spacing)
                let view = PointView(point: point)
                canvas.add(view)
                views.append(view)
            }
        }
        
        canvas.addTapGestureRecognizer({ location, state in
            let effectRadius = 3.0
            let col = Int(round(location.x / Constants.spacing))
            let row = Int(round(location.y / Constants.spacing))
            for c in col-Int(effectRadius)...col+Int(effectRadius) {
                for r in row-Int(effectRadius)...row+Int(effectRadius) {
                    let view = self.view(col: c, row: r)
                    let dc = Double(c - col)
                    let dr = Double(r - row)
                    let d = sqrt(dc*dc + dr*dr)
                    if d <= effectRadius {
                        view.point.z = 0.2 * (effectRadius - d) / effectRadius
                    }
                }
            }
        })
        
        displayLink = CADisplayLink(target: self, selector: Selector("step"))
        displayLink?.frameInterval = 4
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
//        let resetPress = canvas.addLongPressGestureRecognizer { (location, state) -> () in
//            for s in self.canvas.view.subviews {
//                s.removeFromSuperview()
//            }
//        }
//        resetPress.numberOfTouchesRequired = 2
//        canvas.backgroundColor = C4Blue
//        self.neurotic()
        
//        let l = C4Line([C4Point(0,100),C4Point(100,0)])
//        canvas.add(l)
//        
//        canvas.backgroundColor = black
//        
//        let c = C4Circle(center: C4Point(0,100), radius: 20)
//        canvas.add(c)
//
//        let p = C4Polygon([C4Point(0,50),l.b,c.origin])
//        p.strokeColor = orange
//        canvas.add(p)
//        
//        canvas.add(poly)
//        poly.border.color = green
//        poly.border.width = 1.0
        
//        createWake()
//        createRipple()
//        createMyRipple()
//        createLine()
//        createVerticalLine()
        
//        for i in 1...5 {
//            let g = MyTapGestureRecognizer(target: self, action: Selector("handleMyTap:"))
//            g.numberOfTouchesRequired = i
//            view.addGestureRecognizer(g)
//        }
//        repeat {
////            let c = C4Circle(center: C4Point(-100,-100), radius: 60)
//            let c = C4Rectangle(frame: C4Rect(-229,0,44,canvas.height))
//            c.border.radius = 5
//            let col = C4Pink
//            col.alpha = 0.8
//            c.fillColor = col
//            c.lineWidth = 0
//            c.interactionEnabled = false
//            c.border.width = 5.0
//            c.border.color = orange
//            touches.append(c)
//            canvas.add(c)
//        } while touches.count < 5
//       
//        let g = MyPanGestureRecognizer(target: self, action: Selector("handleMyPan:"))
//        view.addGestureRecognizer(g)
    }
    
    var poly = C4Polygon([C4Point(),C4Point(),C4Point()])
    
    func handleMyPan(gesture: MyPanGestureRecognizer) {
        print("\(gestureState(gesture.state)) \(gesture.touches.count)")
        if gesture.state == .Ended {
            for t in touches {
                t.center = C4Point(-300,canvas.center.y)
            }
            for l in lines {
                l.hidden = true
            }
        } else {
            if gesture.touches.count > 2 {
                var points = [C4Point]()
                for t in gesture.touches {
                    points.append(C4Point(t.locationInView(canvas.view)))
                }
                C4ShapeLayer.disableActions = true
                poly.points = points
                C4ShapeLayer.disableActions = false
            }
        }
    }
    
    func gestureState(state: UIGestureRecognizerState) -> String {
        var string = "Unknown"
        switch state {
            case .Possible:
                string = "Possible"
            case .Began:
                string = "Began"
            case .Changed:
                string = "Changed"
            case .Ended:
                string = "Ended"
            case .Cancelled:
                string = "Cancelled"
            case .Failed:
                string = "Failed"
        }
        return string
    }
    
    func handleMyTap(gesture: MyTapGestureRecognizer) {
        print(gesture.touches.count)
    }
    
    func createMyRipple() {
        
    }
    
    var pan : UIPanGestureRecognizer?
    var first = true
    var tap : UITapGestureRecognizer?
    var ppts = [C4Point]()
    var mytap : MyTapGestureRecognizer?
    
    func createRipple() {
        tap = canvas.addTapGestureRecognizer { (location, state) -> () in
            
//            self.addCircleRipple(location)
//            self.addHexagonRipple(location)
            for i in 0...2 {
                delay(Double(i)*0.08) {
                    self.addHexagonRipple(location, duration: 1.0+0.2*Double(i))
                }
            }
        }
    }

    func createWake() {
        pan = canvas.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            if state == .Began {
                self.first = true
            }
            else if state == .Changed {
                if self.first {
                    self.first = false
                    return
                }
                self.addWake(location, translation: translation, velocity: velocity)
                self.pan?.setTranslation(CGPointZero, inView: self.canvas.view)
            }
        }
    }

   
    func addWake(location: C4Point, translation: C4Vector, velocity: C4Vector) {
        let curr = C4Vector(x: translation.x, y: -translation.y)
        let angle = curr.heading
        
        let c = C4Polygon([C4Point(10,0), C4Point(0,5),C4Point(10,10)])
        c.fillColor = clear
        c.transform = C4Transform.makeRotation(angle - M_PI)
        c.center = location
        self.canvas.add(c)
        
        let anim = C4ViewAnimation(duration: 1.0) {
            var t = c.transform
            let s = sqrt(velocity.x*velocity.x + velocity.y*velocity.y)/500.0 + 1.0
            t.scale(s,s)
            c.transform = t
            c.opacity = 0.5
        }
        anim.curve = .EaseOut
        let fade = C4ViewAnimation(duration: 0.66) {
            c.opacity = 0.0
        }
        fade.addCompletionObserver({ () -> Void in
            c.removeFromSuperview()
        })
        fade.curve = .EaseIn
        
        let seq = C4ViewAnimationSequence(animations: [anim,fade])
        seq.animate()
    }

    func addCircleRipple(location: C4Point) {
        let c = C4Circle(center: location, radius: 10)
        c.lineWidth = 0.6
        c.fillColor = clear
        c.interactionEnabled = false
        self.canvas.add(c)
        let mod = random(min: 1, max:5)
        let scale = Double(60 + 20 * mod)
        let anim = C4ViewAnimation(duration: 1.0) {
            c.transform = C4Transform.makeScale(scale,scale)
            c.center = location
            c.fillColor = clear
        }
        anim.curve = .EaseOut
        
        let fade = C4ViewAnimation(duration: anim.duration*0.75) {
            c.opacity = 0.0
        }
        fade.addCompletionObserver({ () -> Void in
            c.removeFromSuperview()
        })
        fade.curve = .EaseIn
        
        let g = C4ViewAnimationGroup(animations: [anim,fade])
        g.animate()
    }
  
    func addHexagonRipple(location: C4Point, duration: Double) {
        let c = C4RegularPolygon(frame: C4Rect(0,0,10,10))
        c.center = location
        C4ShapeLayer.disableActions = true
        c.sides = 6
        c.fillColor = clear
        c.lineWidth = 1.0
        c.opacity = 0.75
        C4ShapeLayer.disableActions = false
        c.interactionEnabled = false
        self.canvas.add(c)
        let anim = C4ViewAnimation(duration: duration) {
            c.transform = C4Transform.makeScale(150, 150)
            c.center = location
            c.fillColor = clear
            c.lineWidth = 0.1
        }
        anim.curve = .EaseOut
        
        let fade = C4ViewAnimation(duration: duration*0.75) {
            c.opacity = 0.0
        }
        fade.addCompletionObserver({ () -> Void in
            c.removeFromSuperview()
        })
        fade.curve = .EaseIn
        
        let g = C4ViewAnimationGroup(animations: [anim,fade])
        g.animate()
//        let seq = C4ViewAnimationSequence(animations: [anim,fade])
//        seq.animate()
    }
    
//    override func setup() {
//        let emitter = C4Emitter()
//        emitter.center = C4Point(0,0)
//        canvas.add(emitter)
//        
//        let emitterB = C4Emitter()
//        emitterB.center = C4Point(-canvas.width-114.5,0)
//        canvas.add(emitterB)
//
//        let emitterC = C4Emitter()
//        emitterC.center = C4Point(emitterB.center.x*2,0)
//        canvas.add(emitterC)
//
//        canvas.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
//            let xacc = CGFloat((location.x/self.canvas.width - 0.5) * 100.0)
//            print(xacc)
//            emitter.cell.xAcceleration = xacc
//            emitterB.cell.xAcceleration = xacc
//            emitterC.cell.xAcceleration = xacc
//            emitter.update()
//            emitterB.update()
//            emitterC.update()
//        }
//    }
}

class C4Emitter : C4View {
    let cell = CAEmitterCell()

    internal class EmitterView : UIView {
        var emitterLayer: CAEmitterLayer {
            get {
                return self.layer as! CAEmitterLayer
            }
        }
        
        override class func layerClass() -> AnyClass {
            return CAEmitterLayer.self
        }
    }
    
    var emitterLayer: CAEmitterLayer {
        get {
            return self.emitterView.emitterLayer
        }
    }
    
    internal var emitterView: EmitterView {
        return self.view as! EmitterView
    }
    
    override init() {
        super.init()
        self.view = EmitterView(frame: CGRectMake(0,0,1,1))
        
        cell.birthRate = 15
        cell.lifetime = 15
        cell.velocity = 100
        cell.velocityRange = 20
        cell.emissionRange = CGFloat(M_PI/80.0)
        cell.emissionLongitude = CGFloat(M_PI_2)
        cell.spin = -0.05
        cell.xAcceleration = 40
        cell.name = "cell"
        
        let img = C4Image("C4EmitterLogo")
        cell.contents = img.cgimage
        
        self.emitterLayer.emitterPosition = CGPointZero
        self.emitterLayer.emitterShape = kCAEmitterLayerPoint
        self.emitterLayer.emitterMode = kCAEmitterLayerPoints
        self.emitterLayer.emitterCells = [cell]
        update()
    }
    
    func update() {
        self.emitterLayer.setValue(self.cell.xAcceleration, forKeyPath: "emitterCells.cell.xAcceleration")
    }
}