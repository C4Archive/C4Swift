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
    
    convenience init(_ title: String) {
        self.init(frame: C4Rect(0,0,180,36))
        self.border.radius = self.height / 2.0
        self.border.width = 1
        self.border.color = C4Blue
        
        backgroundColor = white
        let font = C4Font(name: "MercuryBold-Regular", size: 20.0)
        let str = C4TextShape(text: title, font: font)
        str.fillColor = C4Blue
        str.interactionEnabled = false
        str.center = center
        add(str)
        
        on = C4ViewAnimation(duration: 0.1) {
            self.backgroundColor = C4Blue
            str.fillColor = white
        }
        
        off = C4ViewAnimation(duration: 0.1) {
            self.backgroundColor = white
            str.fillColor = C4Blue
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
