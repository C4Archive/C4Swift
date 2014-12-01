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

//TODO: combine shapes as a set of lines

class Rule {
    var a: IsometricPoint
    var b: IsometricPoint
    lazy var targets = [[IsometricPoint]]()
    
    init(_ a: IsometricPoint, _ b: IsometricPoint) {
        self.a = a
        self.b = b
    }
    
    func addTarget(a: IsometricPoint, _ b: IsometricPoint) {
        targets.append([a,b])
    }
}

class IsometricLine {
    var dx: Double = 0.0
    var origin: C4Vector = C4Vector(0,0)
    var rules = [String : Rule]()
    internal var points: [IsometricPoint] {
        didSet {
            sort()
            updatePath()
        }
    }
    
    var a: IsometricPoint {
        get {
            return points[0]
        }
    }
    var b: IsometricPoint {
        get {
            return points[1]
        }
    }
    
    var line: C4Line
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    init(filePath: String, dx: Double, origin: C4Vector) {
        self.dx = dx
        self.origin = origin
        let nsd = NSDictionary(contentsOfFile: filePath)
        let lineRules = nsd as [String : [String]]
        
        for lineID in lineRules.keys {
            let ruleCoordinates = pointsFromLineID(lineID, dx, origin)
            var rule = Rule(ruleCoordinates.0,ruleCoordinates.1)
            if let targets = lineRules[lineID] {
                for index in 0..<targets.count {
                    let targetPoints = pointsFromLineID(targets[index], dx, origin)
                    rule.addTarget(targetPoints.0,targetPoints.1)
                }
                //TODO: figure out how you're not reading the rules properly
                rules[lineID] = rule
            }
        }
        
        let index = random(below: rules.count)
        let arr = [String](rules.keys)
        let randomKey = arr[index]
        let randomStartRule = rules[randomKey]!
        
        
        points = [IsometricPoint]()
        points.append(randomStartRule.a)
        points.append(randomStartRule.b)

        line = C4Line([points[0].screenCoordinate, points[1].screenCoordinate])
    }

    func updatePath() {
        line.points = [points[0].screenCoordinate, points[1].screenCoordinate]
    }

    var id: String {
        get {
            return "\(Int(a.x)),\(Int(a.y)).\(Int(b.x)),\(Int(b.y))"
        }
    }
    
    internal func sort() {
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
    
    func run() {
        if let rule = rules[self.id] {
        
            var r = 0

            if rule.targets.count > 1 {
                r = random() % rule.targets.count
            }

            self.points = rule.targets[r]
        }
        
        delay(0.5) {
            self.run()
        }
    }
}

func pointsFromLineID(lineID : String, dx: Double, origin: C4Vector) -> (IsometricPoint, IsometricPoint) {
    let pointDescriptions = lineID.componentsSeparatedByString(".")
    let pointA = pointDescriptions[0]
    let pointAComponents = pointA.componentsSeparatedByString(",")
    let pointB = pointDescriptions[1]
    let pointBComponents = pointB.componentsSeparatedByString(",")
    let x1 = pointAComponents[0].toInt()
    let y1 = pointAComponents[1].toInt()
    let x2 = pointBComponents[0].toInt()
    let y2 = pointBComponents[1].toInt()
    let a = IsometricPoint(x1!,y1!,dx,origin)
    let b = IsometricPoint(x2!,y2!,dx,origin)
    return (a,b)
}

class ViewController: UIViewController {
    var isoLines = [IsometricLine]()
    var t: NSTimer = NSTimer()
    var dl = DynamicLine()
    var dl2 = DynamicLine()
    var visibleLine = C4Line([C4Point(0,0),C4Point(1,1)])
    var dx = 16.0
    var wMod = 2.75/20.0
    var origin = C4Vector(0,0)
    var l = [String: C4Line]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        origin.x = Double(view.center.x)
        origin.y = 10.0
        loadDynamically()
    }
    
    func createLogoLines(fileName: String) {
        let nsd = NSArray(contentsOfFile: docsDir()+"/\(fileName).plist")
        let arr = nsd as [String]
        for lineID in arr {
            let points = pointsFromLineID(lineID, dx, origin)
            let line = C4Line([points.0.screenCoordinate,points.1.screenCoordinate])
            line.strokeColor = .blueColor()
            line.lineWidth = dx * wMod
            l[lineID] = line;
            view.add(line)
        }
    }
    
    func loadDynamically() {
        let fileManager = NSFileManager.defaultManager()
        if let enumerator = fileManager.enumeratorAtPath(docsDir()) {
            for url in enumerator.allObjects {
                let fileName : String = (url as String).componentsSeparatedByString(".")[0]
                if fileName.hasPrefix("lines") {
                    createLogoLines(fileName)
                }
                if fileName.hasPrefix("rules") {
                    createIsoline(fileName)
                }
            }
        }
    }
    
    func createIsoline(fileName: String) {
        let isoline = IsometricLine(filePath: docsDir()+"/\(fileName).plist", dx: dx, origin: origin)
        isoLines.append(isoline)
        self.view.add(isoline.line)
        isoline.run()
        isoline.line.strokeColor = .blueColor()
        isoline.line.lineWidth = dx * wMod
    }
    
    func load() {
        createLogoLines("lines")
        createLogoLines("lines3")
        
    }
    
//    func createVisibleLine(rules: String) {
//        let nsd = NSDictionary(contentsOfFile: docsDir()+"/\(rules).plist")
//        interpretRules(nsd as Dictionary)
//        visibleLine.points = [dl.a.screenCoordinate,dl.b.screenCoordinate]
//        visibleLine.strokeColor = .blueColor()
//        visibleLine.lineWidth = dx * wMod
//        view.add(visibleLine)
//        logic(visibleLine)
//    }
//    
//    func interpretRules(rules: [String: [String: [String]]]) {
//        
//        for lineID in rules.keys {
//            if let lineDict = rules[lineID] {
//                if let arr = lineDict["targets"] {
//                    for lineDescription: String in arr {
//                        let points = pointsFromLineID(lineDescription, dx, origin)
////                        slide.append([points.0,points.1])
//                    }
//                }
//                let points = pointsFromLineID(lineID, 16.0, C4Vector(0,0))
////                d[lineID] = line
//            }
//        }
//        
//        dl = DynamicLine(IsometricPoint(2,6,dx,origin),IsometricPoint(3,7,dx,origin))
//    }

    

    func logic() {
//        if let line = d[dl.id]? {
//            var options = [String]()
//            //            if line.canShift { options.append("shift") }
//            if line.canSlide { options.append("slides") }
//            
//            var r = 0
//            
//            if options.count > 1 {
//                r = random() % options.count
//            }
//            
//            if(options[r] == "slides") {
//                let arr = line.slides.targets
//                r = random() % arr.count
//                let nl = line.slides.targets[r]
//                //println("line({\(dl.a.x),\(dl.a.y)},{\(dl.b.x),\(dl.b.y)}) should slide to ({\(nl[0].x),\(nl[0].y)},{\(nl[1].x),\(nl[1].y)})")
//                dl = DynamicLine(nl[0],nl[1])
//            }
//            visibleLine.points = [dl.a.screenCoordinate,dl.b.screenCoordinate]
//        }
//        
//        delay(0.5, closure: {
//            self.logic()
//        })
    }
    
    func logic(vLine: C4Line) {
//        if let line = d[dl.id]? {
//            
//                let arr = line.slides.targets
//                let r = random() % arr.count
//                let nl = line.slides.targets[r]
//                //println("line({\(dl.a.x),\(dl.a.y)},{\(dl.b.x),\(dl.b.y)}) should slide to ({\(nl[0].x),\(nl[0].y)},{\(nl[1].x),\(nl[1].y)})")
//                dl = DynamicLine(nl[0],nl[1])
//
//                vLine.points = [dl.a.screenCoordinate,dl.b.screenCoordinate]
//        }
//        
//        delay(0.5, closure: {
//            self.logic(vLine)
//        })
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
//        let keys = d.keys
//        for k in keys {
////            printOptions(k)
//        }
    }
    
    func exportOptions() {
//        let keys = d.keys
//        var allLines = [String: [String:[String]]]()
//        for k in keys {
//            allLines[k] = exportOptions(k)
//        }
//        
//        let nsd : NSDictionary = allLines
//        nsd.writeToFile(docsDir()+"/rules.plist", atomically: true)
    }
    
    func reveal() {
//        for k in d.keys {
//            let logoline: LogoLine = d[k]!
//            let line = C4Line([logoline.a.screenCoordinate,logoline.b.screenCoordinate])
//            line.strokeColor = .lightGrayColor()
//            view.add(line)
//        }
    }
    
    func exportOptions(id:String)-> [String:[String]] {
//        let l = d[id]
        var dict = [String:[String]]()
        
        var lineDict = [String: [String]]()
//        if let line = l? {
//            if line.canSlide {
//                var slideArr = [String]()
//                for i in 0..<line.slides.targets.count {
//                    let points = line.slides.targets[i]
//                    slideArr.append("\(points[0].x),\(points[0].y).\(points[1].x),\(points[1].y)")
//                }
//                lineDict["slide"] = slideArr
//            }
//            if line.canShift {
//                if line.shifts.a.targets.count > 0 {
//                    var shiftA = [String]()
//                    for i in 0..<line.shifts.a.targets.count {
//                        let target = line.shifts.a.targets[i]
//                        shiftA.append("\(target.x),\(target.y)")
//                    }
//                    lineDict["shiftA"] = shiftA
//                }
//                if line.shifts.b.targets.count > 0 {
//                    var shiftB = [String]()
//                    for i in 0..<line.shifts.b.targets.count {
//                        let target = line.shifts.b.targets[i]
//                        shiftB.append("\(target.x),\(target.y)")
//                    }
//                    lineDict["shiftB"] = shiftB
//                }
//            }
//        }
        return lineDict
    }
 
    func docsDir()-> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)
        return paths[0] as String
    }
    
    func saveRules() {
        let url = NSURL(string: docsDir()+"/rules.plist")
        println("\(url)")
//        let nsd: NSDictionary = d
//        nsd.writeToFile(docsDir()+"/rules.plist", atomically: true)
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

//class LogoLine: NSObject {
//    let a: IsometricPoint
//    let b: IsometricPoint
////    let slides: Slides
////    let shifts: Shifts
//    
//    var id: String {
//        get {
//            return "\(Int(a.x)),\(Int(a.y)).\(Int(b.x)),\(Int(b.y))"
//        }
//    }
//    
//    init(a: IsometricPoint, b: IsometricPoint, slides: Slides, shifts: Shifts) {
//        self.a = a
//        self.b = b
//        self.slides = slides
//        self.shifts = shifts
//    }
//    
//    var canShift: Bool {
//        get {
////            return shifts.a.targets.count > 0 || shifts.b.targets.count > 0
//        }
//    }
//    
//    var canSlide: Bool {
//        get {
//            return slides.targets.count > 0
//        }
//    }
//}

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


