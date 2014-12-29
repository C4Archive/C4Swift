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

class ViewController: UIViewController {
    override func viewDidLoad() {
        let r = C4View(frame: C4Rect(100,100,100,100))
        r.border.width = 1
        view.add(r)
        
        let poly = C4RegularPolygon(frame:C4Rect(100,100,100,100))
        view.add(poly)
    }
}
