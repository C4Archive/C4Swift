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
    let brakeImageContainer = C4View()
    let brakeTemp01 = C4Image("brakeTemp01")
    let brakeTemp02 = C4Image("brakeTemp02")
    let brakeTempOverlay = C4Image("brakeTempOverlay")
    
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
        
        brakeTemp01.interactionEnabled = true
        
        brakeTemp01.addTapGestureRecognizer { (location, state) -> () in
            self.flip01()
        }
        
        brakeTemp02.addTapGestureRecognizer { (location, state) -> () in
            self.flip02()
        }
        
        brakeTempOverlay.addTapGestureRecognizer { (location, state) -> () in
            self.revealPopup()
        }
        
        brakeTemp02.interactionEnabled = true
        brakeTempOverlay.interactionEnabled = true
        brakeTemp02.add(brakeTempOverlay)
        
        brakeImageContainer.frame = brakeTemp01.bounds
        brakeImageContainer.origin = C4Point(461,572)
        brakeImageContainer.add(brakeTemp01)
        canvas.add(brakeImageContainer)
    }
    
    func reset() {
        
    }
    
    func flip01() {
        UIView.transitionFromView(brakeTemp01.view, toView: brakeTemp02.view, duration: 0.25, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
    }
    
    func flip02() {
        UIView.transitionFromView(brakeTemp02.view, toView: brakeTemp01.view, duration: 0.25, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
    }
    
    func revealPopup() {
        
    }
}