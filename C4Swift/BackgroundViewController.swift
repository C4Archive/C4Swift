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
    let signProvider = AstrologicalSignProvider()
    var myContext = 0
    var scrollviews = [InfiniteScrollView]()
    var speeds : [CGFloat] = [0.08,0.10,0.12,0.0,0.15,1.0,0.8,1.0]
    var gap = 10.0
    var signFrames : CGFloat = 12.0
    var order = ["pisces", "aries", "taurus", "gemini", "cancer", "leo", "virgo", "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"]
    var snapTargets = [CGFloat]()
    var signLines = [[C4Line]]()
    var currentLines = [C4Line]()
    var currentLinesVisible = false
    
    override func viewDidLoad() {
        layout()
    }
    
    func layout() {
        canvas.backgroundColor = cosmosbkgd
        scrollviews.append(starsLayer(speeds[0],imageName: "03Star",starCount: 4))
        scrollviews.append(starsLayer(speeds[1],imageName: "04Star",starCount: 10))
        scrollviews.append(starsLayer(speeds[2],imageName: "05Star",starCount: 9))
        scrollviews.append(vignette())
        scrollviews.append(starsLayer(speeds[4],imageName: "07Star",starCount: 7))
        scrollviews.append(lines())
        scrollviews.append(smallSignStars())
        scrollviews.append(bigSignStars())
        
        for i in 0...12 {
            snapTargets.append(CGFloat(gap * Double(i)*canvas.width))
        }
        
        for scrollview in scrollviews {
            canvas.add(scrollview)
        }
        
        if let sv = scrollviews.last {
            sv.contentOffset = CGPointMake(view.frame.size.width * CGFloat(gap / 2.0), 0)
        }
    }
    
    func goto(selection: Int) {
        let top = scrollviews[scrollviews.count-1]
        
        let target = canvas.width * gap * Double(selection)
        
        let anim = C4ViewAnimation(duration: 3.0) { () -> Void in
            top.contentOffset = CGPoint(x: CGFloat(target),y: 0)
        }
        anim.curve = .EaseOut
        anim.animate()
        
        delay(3.0) {
            self.currentLines = self.signLines[selection]
            self.showCurrentLines()
        }
    }
    
    func vignette() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let img = C4Image("06Vignette")
        img.frame = canvas.frame
        sv.add(img)
        return sv
    }
    
    func starsLayer(speed: CGFloat, imageName: String, starCount: Int) -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let framesize = sv.frame.size.width * CGFloat(speed)
        
        let fullframe = Double(framesize) * gap
        sv.contentSize = CGSizeMake(framesize * CGFloat(gap) * signFrames  + CGFloat(canvas.width), 1.0)
        
        for frameCount in 0..<Int(signFrames-1) {
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
    
    func lines() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * signFrames * CGFloat(gap) + sv.frame.size.width, 1.0)

        for i in 0..<order.count {
            var dx = Double(i) * canvas.width * gap
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(order[i]) {
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
    
    func smallSignStars() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        
        let framesize = sv.frame.size.width * CGFloat(speeds[6])
        sv.contentSize = CGSizeMake(framesize * (signFrames * CGFloat(gap) + 2), 1.0)
        
        for i in 0..<order.count {
            var dx = Double(i) * canvas.width * Double(speeds[6]) * gap
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(order[i]) {
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
    
    func bigSignStars() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * signFrames * CGFloat(gap) + sv.frame.size.width, 1.0)
        
        for i in 0..<order.count {
            var dx = Double(i) * canvas.width * gap
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(order[i]) {
                for point in sign.big {
                    let img = C4Image("10Star")
                    var p = point
                    p.transform(t)
                    img.center = p
                    sv.add(img)
                }
            }
        }
        
        C4ViewAnimation(duration: 0.0) {
            let points = [C4Point(0,0),C4Point(Double(sv.contentSize.width),0)]
            let marker = C4Line(points)
            marker.lineDashPattern = [1.0,self.canvas.width * self.gap-1.0]
            marker.lineWidth = 40
            marker.strokeColor = white
            marker.lineDashPhase = -self.canvas.width/2
            marker.opacity = 0.33
            marker.origin = C4Point(0,self.canvas.height)
            
            let dw = (12.0 * self.canvas.width * self.gap / 600.0)
            
            let dashes = C4Line(points)
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
            sv.add(dashes)
            sv.add(marker)
        }.animate()
        
        sv.showsHorizontalScrollIndicator = false
        
        sv.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &myContext)
            
        let signNames = ["Pisces","Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"]
        
        let font = C4Font(name:"Menlo-Regular", size: 13.0)
        let dx = self.canvas.width*self.gap
        let offset = self.canvas.width / 2.0
        var y = self.canvas.height - 86.0

        C4ViewAnimation(duration: 0.0) {
            for i in 0..<signNames.count {
                let name = signNames[i]
                var point = C4Point(offset+dx*Double(i),y)

                if let sign = self.signProvider.get(name)?.shape {
                    sign.lineWidth = 1
                    sign.strokeColor = white
                    sign.fillColor = clear
                    sign.opacity = 0.33
                    sign.transform = C4Transform.makeScale(0.66, 0.66, 0)
                    sign.center = point
                    sv.add(sign)
                }
                
                point.y += 26.0
                
                let text = C4TextShape(text:name, font:font)
                text.fillColor = white
                text.lineWidth = 0
                text.opacity = 0.33
                text.center = point
                point.y+=22.0
                
                var value = i * 30
                if value > 330 { value = 0 }
                let degree = C4TextShape(text:"\(value)", font:font)
                degree.fillColor = white
                degree.lineWidth = 0
                degree.opacity = 0.33
                degree.center = point
                
                sv.add(text)
                sv.add(degree)
            }
        }.animate()
        
        sv.delegate = self
        return sv
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
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
                    var index = Int(Double(target) / (self.canvas.width * self.gap))
                    if index == 12 { index = 0 }
                    self.currentLines = self.signLines[index]
                    self.showCurrentLines()
                }
                return
            }
        }
    }
    
    func showCurrentLines() {
        C4ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 1.0
            }
        }.animate()
    }
    
    func hideCurrentLines() {
        C4ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 0.0
            }
        }.animate()
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let x = scrollView.contentOffset.x
            snapIfNeeded(x, scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.hideCurrentLines()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            let sv = object as! InfiniteScrollView
            let offset = sv.contentOffset
            
            for i in 0...6 {
                let layer = scrollviews[i]
                layer.contentOffset = CGPointMake(offset.x * speeds[i], 0.0)
            }
        }
    }
}