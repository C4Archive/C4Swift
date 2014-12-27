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
        let line = C4Line([C4Point(100,100),C4Point(200,200)])
        view.add(line)
    }
}

