//
//  BackgroundViewController.swift
//  C4Swift
//
//  Created by travis on 2015-04-14.
//  Copyright (c) 2015 C4. All rights reserved.
//

import Foundation

import UIKit
import C4UI
import C4Core
import C4Animation

typealias SignClosure = () -> (big:[C4Point],small:[C4Point],lines:[[C4Point]])

class BackgroundViewController: UIViewController, UIScrollViewDelegate {
    //MARK: Properties
    var scrollviewOffsetContext = 0

    let signProvider = AstrologicalSignProvider()
    
    var signLines = [[C4Line]]()
    var currentSignLines = [C4Line]()
    var scrollviews = [InfiniteScrollView]()
    
    var snapTargets = [CGFloat]()
    
    var gapBetweenSigns = 10.0
    var signCount : CGFloat = 12.0
    var speeds : [CGFloat] = [0.08,0.0,0.10,0.12,0.15,1.0,0.8,1.0]
    
    override func viewDidLoad() {
        canvas.backgroundColor = cosmosbkgd
        createScrollviews()
        createSnapTargets()
    }
    
    //MARK: Snap Targets
    func createSnapTargets() {
        snapTargets.removeAll(keepCapacity: false)
        for i in 0...12 {
            snapTargets.append(CGFloat(gapBetweenSigns * Double(i)*canvas.width))
        }
    }
    
    //MARK: Scrollviews
    func createScrollviews() {
        scrollviews.removeAll(keepCapacity: false)
        scrollviews.append(createBackgroundStars(speeds[0],imageName: "03Star",starCount: 20))
        scrollviews.append(createVignette())
        scrollviews.append(createBackgroundStars(speeds[2],imageName: "04Star",starCount: 20))
        scrollviews.append(createBackgroundStars(speeds[3],imageName: "05Star",starCount: 20))
        scrollviews.append(createBackgroundStars(speeds[4],imageName: "07Star",starCount: 20))
        scrollviews.append(createSignLines())
        scrollviews.append(createSmallStars())
        scrollviews.append(createBigStars())
        
        for scrollview in scrollviews {
            canvas.add(scrollview)
            
            if scrollview == scrollviews.last {
                scrollview.contentOffset = CGPointMake(view.frame.size.width * CGFloat(gapBetweenSigns / 2.0), 0)
            }
        }
    }
    
    //MARK: Go To
    func goto(selection: Int) {
        let target = canvas.width * gapBetweenSigns * Double(selection)

        let anim = C4ViewAnimation(duration: 3.0) { () -> Void in
            self.scrollviews.last?.contentOffset = CGPoint(x: CGFloat(target),y: 0)
        }
        anim.curve = .EaseOut
        anim.animate()
        
        delay(anim.duration) {
            self.currentSignLines = self.signLines[selection]
            self.revealCurrentSignLines()
        }
    }
    
    //MARK: Vignette
    func createVignette() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let img = C4Image("06Vignette")
        img.frame = canvas.frame
        sv.add(img)
        return sv
    }
    
    //MARK: Background Star Layers
    func createBackgroundStars(speed: CGFloat, imageName: String, starCount: Int) -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let framesize = sv.frame.size.width * CGFloat(speed)
        
        let fullframe = Double(framesize) * gapBetweenSigns
        sv.contentSize = CGSizeMake(framesize * CGFloat(gapBetweenSigns) * signCount  + CGFloat(canvas.width), 1.0)
        for frameCount in 0..<Int(signCount) {
            for i in 0..<starCount {
                var dx = fullframe * Double(frameCount)
                var pt = C4Point(dx + random01() * fullframe, random01() * canvas.height)
                let img = C4Image(imageName)
                img.center = pt
                sv.add(img)
                if pt.x < canvas.width {
                    pt.x += 12 * fullframe
                    let img = C4Image(imageName)
                    img.center = pt
                    sv.add(img)
                }
            }
        }
        
        return sv
    }
    
    //MARK: Small Stars
    func createSmallStars() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        
        let framesize = sv.frame.size.width * CGFloat(speeds[6])
        sv.contentSize = CGSizeMake(framesize * (signCount * CGFloat(gapBetweenSigns) + 2), 1.0)
        
        var signOrder = signProvider.order
        signOrder.append(signOrder[0])
        
        for i in 0..<signOrder.count {
            var dx = Double(i) * canvas.width * Double(speeds[6]) * gapBetweenSigns
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(signOrder[i]) {
                for point in sign.small {
                    let img = C4Image("09Star")
                    var p = point
                    p.transform(t)
                    img.center = p
                    sv.add(img)
                }
            }
        }
        return sv
    }
    
    //MARK: Big Stars
    func createBigStars() -> InfiniteScrollView {
        let bigStars = InfiniteScrollView(frame: view.frame)
        bigStars.contentSize = CGSizeMake(bigStars.frame.size.width * (1.0 + signCount * CGFloat(gapBetweenSigns)), 1.0)
        
        bigStars.showsHorizontalScrollIndicator = false
        bigStars.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &scrollviewOffsetContext)
        addBigStars(bigStars)
        addDashesMarker(bigStars)
        addSignNames(bigStars)
        
        bigStars.delegate = self
        return bigStars
    }
    
    func addBigStars(sv: InfiniteScrollView) {
        var signOrder = signProvider.order
        signOrder.append(signOrder[0])
        
        for i in 0..<signOrder.count {
            var dx = Double(i) * canvas.width * gapBetweenSigns
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(signOrder[i]) {
                for point in sign.big {
                    let img = C4Image("10Star")
                    var p = point
                    p.transform(t)
                    img.center = p
                    sv.add(img)
                }
            }
        }
    }
    
    func addSignNames(sv: InfiniteScrollView) {
        var signNames = signProvider.order
        signNames.append(signNames[0])
        
        var y = self.canvas.height - 86.0
        let dx = self.canvas.width*self.gapBetweenSigns
        let offset = self.canvas.width / 2.0
        let font = C4Font(name:"Menlo-Regular", size: 13.0)
        
        for i in 0..<signNames.count {
            let name = signNames[i]
            var point = C4Point(offset+dx*Double(i),y)
            
            if let sign = self.createSmallSign(name) {
                sign.center = point
                sv.add(sign)
            }
            
            point.y += 26.0
            
            let title = self.createSmallSignTitle(name, font: font)
            title.center = point
            
            point.y+=22.0
            
            var value = i * 30
            if value > 330 { value = 0 }
            let degree = self.createSmallSignDegree(value, font: font)
            degree.center = point
            
            sv.add(title)
            sv.add(degree)
        }
    }
    
    func addDashesMarker(sv: InfiniteScrollView) {
        let points = [C4Point(0,0),C4Point(Double(sv.contentSize.width),0)]
        let marker = C4Line(points)
        let dashes = C4Line(points)
        
        C4ViewAnimation(duration: 0.0) {
            marker.lineDashPattern = [1.0,self.canvas.width * self.gapBetweenSigns-1.0]
            marker.lineWidth = 40
            marker.strokeColor = white
            marker.lineDashPhase = -self.canvas.width/2
            marker.opacity = 0.33
            marker.origin = C4Point(0,self.canvas.height)
            
            let dw = (12.0 * self.canvas.width * self.gapBetweenSigns / 600.0)
            
            dashes.lineDashPattern = [0.75,3.25]
            dashes.lineWidth = 10
            dashes.strokeColor = cosmosblue
            dashes.opacity = 0.33
            
            let highdashes = C4Line(points)
            highdashes.lineDashPattern = [1,31]
            highdashes.lineWidth = 20
            highdashes.strokeColor = cosmosblue
            dashes.add(highdashes)
            
            dashes.origin = marker.origin
        }.animate()
        sv.add(dashes)
        sv.add(marker)
    }
    
    func createSmallSign(name: String) -> C4Shape? {
        var smallSign : C4Shape?
        
        if let sign = self.signProvider.get(name)?.shape {
            sign.lineWidth = 2
            sign.strokeColor = white
            sign.fillColor = clear
            sign.opacity = 0.33
            sign.transform = C4Transform.makeScale(0.66, 0.66, 0)
            smallSign = sign
        }
        return smallSign
    }
    
    func createSmallSignTitle(name: String, font: C4Font) -> C4TextShape {
        let text = C4TextShape(text:name, font:font)
        text.fillColor = white
        text.lineWidth = 0
        text.opacity = 0.33
        return text
    }
    
    func createSmallSignDegree(degree: Int, font: C4Font) -> C4TextShape {
        let degree = C4TextShape(text:"\(degree)°", font:font)
        degree.fillColor = white
        degree.lineWidth = 0
        degree.opacity = 0.33
        return degree
    }
    
    //MARK: Sign Lines
    func createSignLines() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * signCount * CGFloat(gapBetweenSigns) + sv.frame.size.width, 1.0)
        
        var signOrder = signProvider.order
        signOrder.append(signOrder[0])
        
        for i in 0..<signOrder.count {
            var dx = Double(i) * canvas.width * gapBetweenSigns
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(signOrder[i]) {
                let connections = sign.lines
                
                var currentLineSet = [C4Line]()
                for points in connections {
                    var begin = points[0]
                    begin.transform(t)
                    
                    var end = points[1]
                    end.transform(t)
                    
                    C4ViewAnimation(duration: 0.0) {
                        let line = C4Line([begin,end])
                        line.strokeEnd = 0.0
                        line.lineWidth = 1.0
                        line.strokeColor = cosmosprpl
                        line.opacity = 0.4
                        sv.add(line)
                        currentLineSet.append(line)
                        }.animate()
                }
                signLines.append(currentLineSet)
            }
        }
        return sv
    }

    func revealCurrentSignLines() {
        C4ViewAnimation(duration: 0.25) {
            for line in self.currentSignLines {
                line.strokeEnd = 1.0
            }
        }.animate()
    }
    
    func hideCurrentSignLines() {
        C4ViewAnimation(duration: 0.25) {
            for line in self.currentSignLines {
                line.strokeEnd = 0.0
            }
        }.animate()
    }

    //MARK: Scrollview Behaviours
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        snapIfNeeded(x, scrollView)
    }
    
    func snapIfNeeded(x: CGFloat, _ scrollView: UIScrollView) {
        for target in snapTargets {
            let dist = abs(CGFloat(target) - x)
            if dist <= CGFloat(canvas.width/2.0) {
                scrollView.setContentOffset(CGPointMake(target,0), animated: true)
                delay(0.25) {
                    var index = Int(Double(target) / (self.canvas.width * self.gapBetweenSigns))
                    if index == 12 { index = 0 }
                    self.currentSignLines = self.signLines[index]
                    self.revealCurrentSignLines()
                }
                return
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let x = scrollView.contentOffset.x
            snapIfNeeded(x, scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.hideCurrentSignLines()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &scrollviewOffsetContext {
            let sv = object as! InfiniteScrollView
            let offset = sv.contentOffset
            
            for i in 0...6 {
                let layer = scrollviews[i]
                layer.contentOffset = CGPointMake(offset.x * speeds[i], 0.0)
            }
        }
    }
}