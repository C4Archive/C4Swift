//
//  InfoViewController.swift
//  C4Swift
//
//  Created by travis on 2015-05-21.
//  Copyright (c) 2015 C4. All rights reserved.
//

import Foundation

import UIKit
import C4UI
import C4Core
import C4Animation

class InfoViewController: UIViewController {
    //MARK: Properties
    lazy var link = C4TextShape(text: "www.c4ios.com", font: C4Font(name: "Menlo-Regular", size: 24))
    let logo = C4Image("logo")
    let textLabel = UILabel(frame: CGRectMake(0, 0, 240, 480))
    
    override func viewDidLoad() {
        applyStyles()
        applyPositions()
        createGestures()
        addElementsToCanvas()
    }
    
    //MARK: Methods
    func addElementsToCanvas() {
        canvas.add(textLabel)
        canvas.add(logo)
        canvas.add(link)
        createAddLinkLine()
    }
    
    func createAddLinkLine() {
        //create link line
        let a = C4Point(link.origin.x,link.origin.y+link.height+5)
        let b = C4Point(a.x + link.width + 1, a.y)
        
        let line = C4Line([a,b])
        line.lineWidth = 2.0
        line.strokeColor = C4Pink
        canvas.add(line)
    }
    
    func applyStyles() {
        canvas.backgroundColor = C4Color(red: 0, green: 0, blue: 0, alpha: 0.33)
        canvas.border.width = 4.0
        canvas.border.color = C4Color(red: 1, green: 1, blue: 1, alpha: 0.2)
        canvas.opacity = 0

        link.fillColor = white
        link.lineWidth = 0
        
        textLabel.font = UIFont(name: "Menlo-Regular", size: 18)
        textLabel.numberOfLines = 40
        textLabel.text = "C4SMOS is a lovingly\nbuilt app created\nby the C4 team.\n\nWe hope you enjoy\ncruising the C4SMOS.\n\n\n\n\n\nYou can learn how\nto build this app\n on our site at:"
        textLabel.textColor = .whiteColor()
        textLabel.textAlignment = .Center
        textLabel.sizeToFit()
    }
    
    func applyPositions() {
        var center = C4Point(canvas.center.x,logo.height)
        logo.center = center
        center.y += logo.height + Double(textLabel.frame.size.height/2.0)
        textLabel.center = CGPoint(center)
        center.y += Double(textLabel.frame.size.height / 2.0)
        center.y += (canvas.height - center.y - link.height) / 2.0
        link.center = center
    }
    
    func createGestures() {
        linkGesture()
        hideGesture()
    }
    
    func linkGesture() {
        let press = link.addLongPressGestureRecognizer { location, state in
            switch state {
            case .Began:
                self.link.fillColor = C4Pink
            case .Ended:
                if self.link.hitTest(location) {
                    UIApplication.sharedApplication().openURL(NSURL(string:"http://www.c4ios.com/tutorials")!)
                }
                self.link.fillColor = white
            default:
                let x = 0
            }
        }
        press.minimumPressDuration = 0.0
    }
    
    func hideGesture() {
        canvas.addTapGestureRecognizer { location, state in
            self.hide()
        }
    }
    
    func hide() {
        C4ViewAnimation(duration: 0.25) { () -> Void in
            self.canvas.opacity = 0.0
        }.animate()
    }
    
    func show() {
        C4ViewAnimation(duration: 0.25) { () -> Void in
            self.canvas.opacity = 1.0
        }.animate()
    }
}