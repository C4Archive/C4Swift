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
import SpriteKit

class ViewController: UIViewController {
    var container = C4View()
    var scrollview = UIScrollView()
    var scrollviewb = UIScrollView()
    var deltaX : CGFloat = 0.0
    var prevPos : CGFloat = 0.0
    private var myContext = 0
    
    override func viewDidLoad() {
        sv2()
        sv1()
//        scrollview.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &myContext)
//
//        scrollviewb = UIScrollView(frame: view.bounds)
//        scrollviewb.contentSize = CGSizeMake(1000, view.bounds.size.height)
//        
//        let skviewb = SKView(frame: CGRectMake(0, 0, 1000, scrollview.contentSize.height))
//        var particleb = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
//
//        skviewb.backgroundColor = .clearColor()
//        let sceneb = SKScene(size: CGSizeMake(1000, view.bounds.size.height))
//        sceneb.backgroundColor = .whiteColor()
//        sceneb.scaleMode = .Fill
//        particleb.particleColor = .redColor()
//        sceneb.addChild(particleb)
//        skviewb.asynchronous = true
//        skviewb.presentScene(scene)
//        scrollviewb.add(skview)
//        skviewb.userInteractionEnabled = false
//        canvas.add(scrollviewb)
        
    }

    func sv2() {
        scrollviewb = UIScrollView(frame: view.bounds)
        scrollviewb.contentSize = CGSizeMake(1000, view.bounds.size.height)
        let path = NSBundle.mainBundle().pathForResource("MyParticleB", ofType: "sks")
        var particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        
        let skview = SKView(frame: CGRectMake(0, 0, 1000, scrollviewb.contentSize.height))
        
        skview.backgroundColor = .whiteColor()
        let scene = SKScene(size: CGSizeMake(1000, view.bounds.size.height))
        scene.backgroundColor = .clearColor()
        scene.scaleMode = .Fill
        scene.addChild(particle)
        skview.asynchronous = true
        skview.presentScene(scene)
        skview.allowsTransparency = true
        skview.shouldCullNonVisibleNodes = true
        scrollviewb.add(skview)
        skview.userInteractionEnabled = false
        canvas.add(scrollviewb)
    }

    func sv1() {
        scrollview = UIScrollView(frame: view.bounds)
        scrollview.contentSize = CGSizeMake(1000, view.bounds.size.height)
        let path = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")
        var particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        
        let skview = SKView(frame: CGRectMake(0, 0, 1000, scrollview.contentSize.height))
        
        let scene = SKScene(size: CGSizeMake(1000, view.bounds.size.height))
        scene.scaleMode = .Fill
        scene.addChild(particle)
        skview.asynchronous = true
        skview.presentScene(scene)
        skview.allowsTransparency = true
        skview.shouldCullNonVisibleNodes = true
        scrollview.add(skview)
        scene.backgroundColor = .clearColor()
        skview.userInteractionEnabled = false
        canvas.add(scrollview)
        
        scrollview.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &myContext)
    }

    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            scrollviewb.contentOffset = CGPointMake(scrollview.contentOffset.x*0.8, 0)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    deinit {
        scrollview.removeObserver(self, forKeyPath: "contentOffset", context: &myContext)
    }
}