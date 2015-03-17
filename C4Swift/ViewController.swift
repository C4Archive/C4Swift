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

    public override func viewDidLoad() {
        
    }

}

/*
Issues with C4Shape+Creation

addCurve: creates curve properly, but rendering of that curve doesn't work. specifically, original line isn't used for fill, removing moveToPoint() works.
lineWidth: changing line width results in strange rendering, only last element of line is rendered, and shape doesn't have fill color.
*/
