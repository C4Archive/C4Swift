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

let cosmosprpl = C4Color(red:0.565, green: 0.075, blue: 0.996, alpha: 1.0)
let cosmosblue = C4Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)
let cosmosbkgd = C4Color(red: 0.078, green: 0.118, blue: 0.306, alpha: 1.0)

class ViewController: UIViewController {
    let menu = MenuViewController()
    let background = BackgroundViewController()
    
    override func viewDidLoad() {
        canvas.add(background.canvas)
        canvas.add(menu.canvas)
        menu.canvas.center = canvas.center
        menu.action = self.grabSelection
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func grabSelection(selection: Int) {
        background.goto(selection)
    }
}