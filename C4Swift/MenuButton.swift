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

class MenuButton: C4View {
    var action: () -> Void = {}
    
    var on = C4ViewAnimation(){}
    var off = C4ViewAnimation(){}
    
    var str : C4TextShape?
    
    convenience init(_ title: String) {
        self.init(frame: C4Rect(0,0,180,36))
        self.border.radius = self.height / 2.0
        self.border.width = 1
        self.border.color = C4Blue
        
        backgroundColor = white
        let font = C4Font(name: "MercuryBold-Regular", size: 20.0)
        C4ViewAnimation(duration: 0.0) {
            self.str = C4TextShape(text: title, font: font)
            if let s = self.str {
                s.fillColor = C4Blue
                s.interactionEnabled = false
                s.center = self.center
                s.lineWidth = 0
                self.add(s)
            }
        }.animate()
        
        on = C4ViewAnimation(duration: 0.1) {
            self.backgroundColor = C4Blue
            self.str!.fillColor = white
        }
        
        off = C4ViewAnimation(duration: 0.1) {
            self.backgroundColor = white
            self.str!.fillColor = C4Blue
        }
        
        let lp = addLongPressGestureRecognizer { location, state in
            switch state {
            case .Changed, .Possible:
                break
            case .Began:
                self.on.animate()
            case .Ended:
                if self.hitTest(location) { self.action() }
                self.off.animate()
            default:
                self.off.animate()
            }
        }
        
        lp.minimumPressDuration = 0.0
    }
}
