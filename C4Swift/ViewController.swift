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

    override func viewDidLoad() {
        dx = 11.0
        dy = dx / M_PI_2
        ox = Double(88) / 2.0
        oy = 10.0

        createGrid()
        createLogo()
    }
    
    func createGrid() {
        for x in 0...50 {
            for y in 0...50 {
                let p = convertCoordinate(C4Point(x,y))
                if C4Rect(self.view.frame).contains(p) {
                    let e = createPoint(p)
                    self.view.add(e)
                }
            }
        }
    }
    
    func createLogo() {
        
//        pt(0,0)
//        pt(0,1)
//        pt(1,0)
//        pt(1,1)
        
        c = .blackColor()
        ln(0, 0, 0, 1)
        ln(0, 0, 3, 0)
        ln(3, 1, 0, 1)
        ln(2, 2, 4, 2)
        ln(2, 2, 4, 4)
        ln(4, 4, 6, 4)
        ln(6, 4, 7, 5)
        ln(0, 1, 4, 5)
        ln(4, 5, 7, 5)
        ln(3, 2, 4, 3)
        ln(4, 3, 5, 3)
        ln(7,5, 7,4)
        ln(4,4,4,3)
        
        c = .redColor()
        ln(3,0,3,1)
        ln(3,1,4,2)
        ln(3,0,4,0)
        ln(4,0,4,1)
        ln(4,1,3,1)
        ln(4,1,5,2)
        ln(5,2, 5,1)
        ln(5,1,4,0)
        ln(5,2, 4,2)
        
        c = .blueColor()
        ln(4, 2, 6, 4)
        ln(6,4, 8,4)
        ln(8, 4, 9, 5)
        ln(9,5,10,5)
        ln(10,5,9,4)
        ln(9,4,10,4)
        ln(10,4,10,3)
        ln(10,3,9,2)
        ln(9,2,8,2)
        ln(8,2,6,0)
        ln(6,0,5,0)
        ln(5,0,5,1)
        ln(5,1,7,3)
        ln(7, 3, 6, 3)
        ln(6,3,5,2)
        ln(5,1,6,1)
        ln(6,1,6,0)
        ln(6,1,8,3)
        ln(8,3,9,3)
        ln(9,3,9,2)
        ln(10,4,10,5)
        ln(6,2,6,3)
        ln(8,2,8,3)
        
        var points = [C4Point]()
        points.append(convertCoordinate(C4Point(3,0)))
        points.append(convertCoordinate(C4Point(3,1)))
        points.append(convertCoordinate(C4Point(4,2)))
        points.append(convertCoordinate(C4Point(5,2)))
        points.append(convertCoordinate(C4Point(5,1)))
        points.append(convertCoordinate(C4Point(4,0)))
        points.append(convertCoordinate(C4Point(3,0)))
        
        var poly = Polygon(points: points)
        poly.fillColor = UIColor.redColor().colorWithAlphaComponent(0.33)
        self.view.add(poly)
        
        points.removeAll()
        points.append(convertCoordinate(C4Point(6,2)))
        points.append(convertCoordinate(C4Point(6,3)))
        points.append(convertCoordinate(C4Point(7,3)))
        poly = Polygon(points: points)
        poly.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.33)
        self.view.add(poly)

        points.removeAll()
        points.append(convertCoordinate(C4Point(6,4)))
        points.append(convertCoordinate(C4Point(7,5)))
        points.append(convertCoordinate(C4Point(7,4)))
        poly = Polygon(points: points)
        poly.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.33)
        self.view.add(poly)
    }

    func ln(x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
        let a = convertCoordinate(C4Point(x1,y1))
        let b = convertCoordinate(C4Point(x2,y2))
        let l = Line([a,b])
        l.strokeColor = c
        l.lineWidth = 1.0
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
        let e = Ellipse(C4Rect(0,0,4,4))
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