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

    var b: Bool = true
    var v = C4View(frame: C4Rect(100,100,100,100))
    var u = C4View(frame: C4Rect(50,50,25,25))
    
    override func viewDidLoad() {
        v.backgroundColor = C4Color(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        
        u.backgroundColor = C4Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        v.mask = u
        
        v.interactionEnabled = false
        self.view.add(v)
    }
}