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
    
    let menu = MenuViewController()
    
    override func viewDidLoad() {
        canvas.backgroundColor = cosmosbkgd
        canvas.add(menu.canvas)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}