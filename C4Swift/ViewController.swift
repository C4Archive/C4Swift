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

//TODO: combine shapes as a set of lines

class ViewController: UIViewController {
    override func viewDidLoad() {
        let m = C4Movie("halo.m4v")
        view.add(m)
        m.play()
    }
}
