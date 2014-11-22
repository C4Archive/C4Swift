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

class ViewController: UIViewController {
    lazy var dx: Double = 0.0
    lazy var dy: Double = 0.0
    lazy var ox: Double = 0.0
    lazy var oy: Double = 0.0
    lazy var c: UIColor = .lightGrayColor()
    lazy var edges: [Line] = [Line]()
    lazy var hiddenEdges: [Int] = [Int]()
    
    override func viewDidLoad() {
        dx = 8.0
        dy = dx / 1.9
        ox = Double(self.view.frame.size.width) / 2.0 + dx * 3.0
        oy = 10.0
        
//        createGrid()
        createLogo()
        hideSomeEdges()
        dispatch_after(1, dispatch_get_main_queue(), {self.revealRandomEdge(0)})
    }
    
    func hideSomeEdges() {
        for i in 0...10 {
            hideRandomEdge()
        }
    }
    
    func hideRandomEdge() {
        var index = 0
        do {
            index = random(below: edges.count)
        } while edges[index].alpha == 0.0
        edges[index].alpha = 0.0
    }
    
    func revealRandomEdge(previousEdge: Int) {
        var index = 0
        do {
            index = random(below: edges.count)
        } while edges[index].alpha > 0.0 && index != previousEdge
        
        let l = edges[index]
        UIView.animateWithDuration(
            0.75,
            animations: {
                l.alpha = 1.0
            },
            completion: { c in
                if c { self.fadeRandomEdge(index) }
        })
    }
    
    func fadeRandomEdge(previousEdge: Int) {
        var index = 0
        do {
            index = random(below: edges.count)
        } while edges[index].alpha == 0.0 && index != previousEdge

        let l = edges[index]
        UIView.animateWithDuration(
            0.75,
            animations: { l.alpha = 0.0 },
            completion: { c in if c { self.revealRandomEdge(index) }
        })
    }
    
    func createGrid() {
        for x in 0...120 {
            for y in 0...120 {
                let p = convertCoordinate(C4Point(x,y))
                if C4Rect(self.view.frame).contains(p) {
                    let e = createPoint(p)
                    self.view.add(e)
                }
            }
        }
    }
    
    func createLogo() {
        
        c = .blueColor()
        ln(0, 10, 0, 20)
        ln(0, 20, 16, 36)
        ln(0, 10, 2, 12)
        ln(2,12,2,22)
        ln(2,12,12,12)
        ln(4,10,6,12)
        ln(0,10,10,10)
        ln(8,8,10,8)
        ln(8,8,8,10)
        ln(10,10,10,8)
        ln(10,8,18,16)
        ln(10,10,22,22)
        ln(4, 22, 4, 12)
        ln(4,22,16,34)
        ln(16,34,24,34)
        ln(24,34,26,36)
        ln(26,36,16,36)
        ln(26,36,26,26)
        ln(26,34,24,32)
        ln(24,32,24,24)
        ln(24,24,24,16)
        ln(24,32,16,32)
        ln(16,32,6,22)
        ln(6,22,6,12)
        ln(6,20,16,30)
        ln(16,30,20,30)
        ln(20,30,20,24)
        ln(20,24,12,16)
        ln(12,16,6,16)
        ln(6,14,12,14)
        ln(12,14,24,26)
        ln(12,14,12,16)
        ln(14,18,12,18)
        ln(12,18,10,16)
        ln(22,32,22,26)
        ln(22,26,24,26)
        ln(20,24,22,26)
        ln(22,22,22,14)
        ln(22,14,10,2)
        ln(26,26,24,24)
        ln(24,18,32,26)
        ln(32,26,32,24)
        ln(32,24,24,16)
        ln(22,14,20,14)
        ln(20,14,20,18)
        ln(20,18,18,16)
        ln(18,16,18,12)
        ln(20,14,10,4)
        ln(10,4,10,0)
        ln(10,0,12,0)
        ln(12,0,20,8)
        ln(20,6,22,8)
        ln(20,6,20,8)
        ln(18,6,20,6)
        ln(22,8,22,10)
        ln(22,10,34,22)
        ln(34,22,34,26)
        ln(34,26,32,26)
        ln(34,24,12,2)
        ln(12,2,10,2)
        ln(12,30,14,30)
        
        var points = [C4Point]()
        points.append(convertCoordinate(C4Point(3,0)))
        points.append(convertCoordinate(C4Point(3,1)))
        points.append(convertCoordinate(C4Point(4,2)))
        points.append(convertCoordinate(C4Point(5,2)))
        points.append(convertCoordinate(C4Point(5,1)))
        points.append(convertCoordinate(C4Point(4,0)))
        points.append(convertCoordinate(C4Point(3,0)))
    }
    
    func ln(x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
        let a = convertCoordinate(C4Point(x1,y1))
        let b = convertCoordinate(C4Point(x2,y2))
        let l = Line([a,b])
        l.lineCap = .Round
        l.strokeColor = c
        l.lineWidth = 2.0
        edges.append(l)
        self.view.add(l)
    }
    
    func pt(x: Int, _ y: Int) {
        let p = convertCoordinate(C4Point(x,y))
        let e = createEllipse(p)
        e.fillColor = c
        self.view.add(e)
    }
    
    func convertCoordinate(point: C4Point) -> C4Point {
        var pt = C4Point(point.x * dx + ox - dx * point.y, point.y * dy + oy + dy * point.x)
        //        var pt = C4Point(point.x * 4, point.y * 4)
        return pt
    }
    
    func createEllipse(point: C4Point) -> Ellipse {
        let e = Ellipse(C4Rect(0,0,8,8))
        e.center = CGPoint(point)
        
        e.strokeColor = .redColor()
        e.lineWidth = 1.0
        e.fillColor = .clearColor()
        return e
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createPoint(point: C4Point) -> Ellipse {
        let e = Ellipse(C4Rect(0,0,3,3))
        e.fillColor = c
        e.center = CGPoint(point)
        return e
    }
    
    func createGrid2() {
        var y = 0.0
        do {
            var x = 0.0
            do {
                var pt = C4Point(x,y)
                let e = Ellipse(C4Rect(0,0,4,4))
                if(Int(y) % Int(dx/2.0) == 0) {
                    pt.x += dx/2.0
                    e.fillColor = .redColor()
                }
                e.center = CGPoint(pt)
                self.view.add(e)
                x += dx
            } while x <= Double(self.view.frame.size.width)
            y += dy
        } while y <= Double(self.view.frame.size.height)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}