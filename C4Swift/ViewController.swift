//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import C4iOS

class ViewController: UIViewController {
    var currentCircle = UIView ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:86.0/255.0, green:0.0, blue:135.0/255.0, alpha: 1.0)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "drag:")
        longPress.minimumPressDuration = 0.1
        self.view.addGestureRecognizer(longPress)
    }
    
    func drag(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .Began:
            self.currentCircle = createCircle()
            self.currentCircle.center = gesture.locationInView(self.view)
            self.currentCircle.userInteractionEnabled = false
            self.view.addSubview(self.currentCircle)
        case .Changed:
            self.currentCircle.center = gesture.locationInView(self.view)
        default:
            self.currentCircle.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createCircle() -> UIView {
        let view = UIView(frame: CGRectMake(0,0,230,230))
        for var i: Int = 0; i < 10; i++ {
            var mod: Double = Double(i) * 10.0
            var frame = CGRectMake(CGFloat(0.0), CGFloat(0.0), CGFloat(140.0 + mod), CGFloat(140.0 + mod))
            var shape = Ellipse(frame: frame)
            shape.fillColor = UIColor.clearColor()
            shape.lineWidth = 20
            shape.strokeColor = UIColor(red:40.0/255.0, green:210.0/255.0, blue:172.0/255.0, alpha: 1)
            shape.alpha = 0.33
            shape.center = view.center
            view.addSubview(shape)
            let delay = 0.15 * Double(i)
            let time = dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            )
            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                CATransaction.begin()
                var anim = CABasicAnimation()
                anim.duration = 0.40
                anim.repeatCount = 100
                anim.autoreverses = true
                anim.fromValue = shape.alpha
                anim.toValue = 0.0
                shape.layer.addAnimation(anim, forKey: "alpha")
                
                anim.fromValue = shape.lineWidth
                anim.toValue = 0.0
                shape.layer.addAnimation(anim, forKey: "lineWidth")
                CATransaction.commit()
            })
        }
        return view
    }
}

