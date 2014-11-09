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

class ViewController: UIViewController {
    var currentCircle = UIView ()
    var object = Obj()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1,target:self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(10)
        
        CATransaction.commit()
    }
    
    func update() {
        C4Log("\(object.value)")
    }
}

class Obj: NSObject {
    var value: Double = 0.0
}