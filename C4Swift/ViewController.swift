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

    let infoPanel = UIScrollView(frame: UIScreen.mainScreen().bounds)
    var link = C4TextShape(text: "www.c4ios.com", font: C4Font(name: "Menlo-Regular", size: 24))
    
    override func viewDidLoad() {
        canvas.add(C4Image("bg"))
        
        infoPanel.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.66)
        
        infoPanel.layer.borderWidth = 2.0
        infoPanel.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.2).CGColor
        canvas.add(infoPanel)
        
        let logo = C4Image("logo")
        var center = C4Point(canvas.center.x,logo.height)
        logo.center = center
        infoPanel.add(logo)
        
        let body = UILabel(frame: CGRectMake(0, 0, 240, 480))
        body.font = UIFont(name: "Menlo-Regular", size: 18)
        body.numberOfLines = 40
        body.text = "C4SMOS is a lovingly\nbuilt app created\nby the C4 team.\n\nWe hope you enjoy\ncruising the C4SMOS.\n\n\n\n\n\nYou can learn how\nto build this app\n on our site at:"
        body.textColor = .whiteColor()
        body.textAlignment = .Center
        body.sizeToFit()
        
        center.y += logo.height
        center.y += Double(body.frame.size.height/2.0)
        body.center = CGPoint(center)
        infoPanel.add(body)
        
        center.y += Double(body.frame.size.height / 2.0)
        center.y += (canvas.height - center.y - link.height) / 2.0
        link.center = center
        
        link.fillColor = white
        link.lineWidth = 0
        
        let press = link.addLongPressGestureRecognizer { location, state in
            switch state {
            case .Began:
                self.link.fillColor = C4Pink
            case .Ended:
                if self.link.hitTest(self.canvas.convert(location, from:self.link)) {
                    UIApplication.sharedApplication().openURL(NSURL(string:"http://www.c4ios.com/tutorials")!)
                }
                self.link.fillColor = white
            default:
                let x = 0
            }
        }
        press.minimumPressDuration = 0.0
        
        let a = C4Point(link.origin.x,link.origin.y+link.height+5)
        let b = C4Point(a.x + link.width + 1, a.y)
        
        let line = C4Line([a,b])
        line.lineWidth = 2.0
        line.strokeColor = C4Pink
        infoPanel.add(line)
        
        infoPanel.add(link)
    }
}