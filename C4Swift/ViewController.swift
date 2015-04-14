//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    let background = BackgroundViewController()
    
    override func viewDidLoad() {
        canvas.add(background.canvas)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}