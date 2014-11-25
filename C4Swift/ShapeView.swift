//
//  ShapeView.swift
//  C4Swift
//
//  Created by travis on 2014-11-24.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit

/*
lazy var shapeView: ShapeView = ShapeView([CGPointMake(0,0),CGPointMake(100,100)])
override func viewDidLoad() {
shapeView.shapeLayer.strokeColor = UIColor.redColor().CGColor
self.view.addSubview(shapeView)

var tap = UITapGestureRecognizer(target:self, action:"handleTap:")
view.addGestureRecognizer(tap)
}

func handleTap(sender: UITapGestureRecognizer) {
shapeView.updatePoints([CGPointMake(rand(100)+100,rand(100)+100),CGPointMake(rand(100)+100,rand(100)+100)])
}

func rand(val: Int) -> CGFloat {
return CGFloat(arc4random_uniform(UInt32(val)))
}
*/
class ShapeView: UIView {
    lazy internal var linePoints = [CGPoint]()
    convenience init(_ points: [CGPoint]) {
        self.init(frame: CGRectMakeFromPoints(points))
        for i in 0..<points.count {
            linePoints.append(points[i])
        }
        
        self.clipsToBounds = false
        
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, linePoints[0].x, linePoints[0].y)
        
        for i in 1..<linePoints.count {
            CGPathAddLineToPoint(path, nil, linePoints[i].x, linePoints[i].y)
        }
        var transform = CGAffineTransformMakeTranslation(-frame.origin.x,-frame.origin.y)
        shapeLayer.path = path
        
    }
    
    func updatePoints(points:[CGPoint]) {
        linePoints.removeAll()
        for i in 0..<points.count {
            linePoints.append(points[i])
        }
        updatePath()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    func updatePath() {
        if linePoints.count > 1 {
            var path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, linePoints[0].x, linePoints[0].y)
            
            for i in 1..<linePoints.count {
                CGPathAddLineToPoint(path, nil, linePoints[i].x, linePoints[i].y)
            }
            animateKeyPath("path", toValue: path)
        }
    }
    
    var shapeLayer: CAShapeLayer {
        get {
            return layer as CAShapeLayer
        }
    }
    
    func animation() -> CABasicAnimation {
        var anim = CABasicAnimation()
        anim.duration = 0.25
        anim.beginTime = CACurrentMediaTime()
        anim.autoreverses = false
        anim.repeatCount = 0
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeBoth
        return anim
    }
    
    func animateKeyPath(keyPath: String, toValue: AnyObject) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.shapeLayer.path = toValue as CGPath
            self.adjustToFitPath()
        })
        var anim = animation()
        anim.keyPath = "path"
        anim.fromValue = self.layer.presentationLayer().valueForKeyPath("path")
        anim.toValue = toValue
        self.layer.addAnimation(anim, forKey:"animatepath")
        CATransaction.commit()
    }
    
    func adjustToFitPath() {
        if shapeLayer.path == nil {
            return
        }
        var f = CGPathGetPathBoundingBox(shapeLayer.path)
        var t = CGAffineTransformMakeTranslation(0,0)
        let p = CGPathCreateCopyByTransformingPath(shapeLayer.path, &t)
        
        self.shapeLayer.path = p
        bounds = CGPathGetPathBoundingBox(shapeLayer.path)
        frame = f
    }
}

public func CGRectMakeFromPoints(points: [CGPoint]) -> CGRect {
    var path = CGPathCreateMutable()
    CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
    for i in 1..<points.count {
        CGPathAddLineToPoint(path, nil, points[i].x, points[i].y)
    }
    return CGPathGetBoundingBox(path)
}