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

class ViewController: C4CanvasController {
    let bg = C4Image("statusBarBG1px")
    let alertBar = AlertBar()
    let needle = C4Image("needle")
    let screen1 = C4Image("screen1")
    let rotationScale = -1.495*M_PI
    
    override func setup() {
        view.backgroundColor = UIColor(patternImage: bg.uiimage)
        var neutech = UIImage(named: "neutech")
        neutech = neutech?.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: neutech, landscapeImagePhone: neutech, style: .Plain, target: self, action:NSSelectorFromString("reset"))
        
        var driveOnTitleLogo = UIImage(named: "driveOnTitleLogo")
        self.navigationItem.titleView = UIImageView(image: driveOnTitleLogo)
        
        var gears = UIImage(named: "gears")
        gears = gears?.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: gears, landscapeImagePhone: gears, style: .Plain, target: nil, action: nil)

        self.navigationController?.view.add(alertBar.canvas)
        
        screen1.origin = C4Point(0,64)
        canvas.add(screen1)

        needle.anchorPoint = C4Point(0.88,0.12)
        needle.center = C4Point(477,236)
        canvas.add(needle)
    }
    
    func reset() {
        
    }
}