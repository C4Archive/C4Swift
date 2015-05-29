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

class ViewController: C4CanvasController {
    
    let audio1 = C4AudioPlayer("audio1.mp3")
    let audio2 = C4AudioPlayer("audio2.mp3")
    
    let menu = MenuViewController()
    let info = InfoViewController()
    let background = BackgroundViewController()
    
    override func setup() {
        canvas.add(background.canvas)
        canvas.add(menu.canvas)
        menu.canvas.center = canvas.center
        menu.selectionAction = self.grabSelection
        
        menu.infoAction = info.show
        
        canvas.add(info.canvas)
        
        audio1.loops = true
        audio1.play()
        audio2.loops = true
        audio2.play()
    }
    
    func grabSelection(selection: Int) {
        background.goto(selection)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}