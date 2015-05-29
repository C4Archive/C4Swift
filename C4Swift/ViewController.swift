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
    var rpmContext = 0
    var slider = UISlider(frame: CGRectMake(0, 0, 300, 44))
    var rpmLink : CADisplayLink?
    var circle = C4Circle(center: C4Point(100,100), radius: 50)
    var label = UILabel(frame: UIScreen.mainScreen().bounds)
    override func viewDidLoad() {
        canvas.add(circle)
        
        rpmLink = CADisplayLink(target: self, selector: "update")
        rpmLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        let f = UIFont(name: "PreloCondensed-Bold", size: 20)
        label.text = "1024"
        label.font = f
        canvas.add(label)
        canvas.backgroundColor = darkGray
        
        slider.continuous = true
        canvas.add(slider)

        canvas.addTapGestureRecognizer { location, state in
            C4ViewAnimation(duration: 1.25) {
                let r = random01()
                self.circle.strokeEnd = r
            }.animate()
        }
    }
    
    func update() {
        if let layer = self.circle.layer?.presentationLayer() as? CAShapeLayer {
            label.text = String(format: "%.2f", layer.strokeEnd*10)
        }
    }
}