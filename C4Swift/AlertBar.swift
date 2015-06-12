//
//  AlertBar.swift
//  C4Swift
//
//  Created by travis on 2015-06-12.
//  Copyright (c) 2015 C4. All rights reserved.
//

import Foundation
import C4UI
import C4Core
import C4Animation

public class AlertBar : C4CanvasController {
    let redAlertMessage = C4Image("redAlertMessage")
    let blueAlertMessage = C4Image("blueAlertMessage")
    var isRed = true

    override public func setup() {
        canvas.frame = C4Rect(0,0,canvas.width,66)
        canvas.backgroundColor = C4Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        var center = canvas.center
        center.y += 6
        
        redAlertMessage.center = center
        canvas.add(redAlertMessage)

        center.y -= 3
        blueAlertMessage.center = center
        blueAlertMessage.opacity = 0.0
        canvas.add(blueAlertMessage)
        
        canvas.shadow.offset = C4Size(0,2)
        canvas.shadow.opacity = 0.33
    }
    
    public func red() {
        C4ViewAnimation(duration: 0.25) {
            self.canvas.backgroundColor = C4Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            self.blueAlertMessage.opacity = 0.0
            self.redAlertMessage.opacity = 1.0
        }.animate()
        self.isRed = true
    }

    public func blue() {
        C4ViewAnimation(duration: 0.25) {
            self.canvas.backgroundColor = C4Color(red: 0.11, green: 0.71, blue: 0.98, alpha: 1.0)
            self.blueAlertMessage.opacity = 1.0
            self.redAlertMessage.opacity = 0.0
        }.animate()
        self.isRed = false
    }

    public func toggleVisible() {
        if canvas.origin == C4Point() {
            C4ViewAnimation(duration: 0.25) {
                self.canvas.origin = C4Point(0,-self.canvas.height)
                self.canvas.shadow.opacity = 0.0
            }.animate()
        } else {
            C4ViewAnimation(duration: 0.25) {
                self.canvas.origin = C4Point()
                self.canvas.shadow.opacity = 0.33
            }.animate()
        }
    }
}