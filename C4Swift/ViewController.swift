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

typealias SignClosure = () -> (big:[C4Point],small:[C4Point],lines:[[C4Point]])

class ViewController: UIViewController {
    var myContext = 0
    let cosmosblue = C4Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)
    let cosmosbkgd = C4Color(red: 0.078, green: 0.118, blue: 0.306, alpha: 1.0)
    let cosmosprpl = C4Color(red:0.565, green: 0.075, blue: 0.996, alpha: 1.0)
    var scrollviews = [InfiniteScrollView]()
    var speeds : [CGFloat] = [0.08,0.10,0.12,0.0,0.15,1.0,0.8,1.0]
    var gap = 10.0
    var signFrames : CGFloat = 12.0
    var signs = [String : SignClosure]()
    var order = ["pisces", "aries", "taurus", "gemini", "cancer", "leo", "virgo", "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"]
    
    override func viewDidLoad() {
        signs["pisces"] = pisces
        signs["aries"] = aries
        signs["taurus"] = taurus
        signs["gemini"] = gemini
        signs["cancer"] = cancer
        signs["leo"] = leo
        signs["virgo"] = virgo
        signs["libra"] = libra
        signs["scorpio"] = scorpio
        signs["sagittarius"] = sagittarius
        signs["capricorn"] = capricorn
        signs["aquarius"] = aquarius

        layout()
    }
    
//    func printFunctions() {
//
//        for key in signs.keys {
//            
//            if let closure = signs[key] {
//                let big = closure().big
//                let small = closure().small
//                
//                println("func "+key+"() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {")
//                println("\tlet big = [")
//                for i in 0..<big.count {
//                    let pt = big[i]
//                    println("\t\tC4Point(\(pt.x-canvas.center.x),\(pt.y-canvas.center.y)),")
//                }
//                println("\t]")
//                println()
//                println("\tlet small = [")
//                for i in 0..<small.count {
//                    let pt = small[i]
//                    println("\t\tC4Point(\(pt.x-canvas.center.x),\(pt.y-canvas.center.y)),")
//                }
//                println("\t]")
//                println()
//                println("\tlet lines = [[big[0],big[0]]]")
//                println()
//                println("\treturn (big,small,lines)")
//                println("}")
//                println()
//                println()
//            }
//        }
//    }
    
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

        for scrollview in scrollviews {
            canvas.add(scrollview)
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
        let framesize = sv.frame.size.width * CGFloat(speeds[5])
        sv.contentSize = CGSizeMake(framesize * (signFrames * CGFloat(gap) + 2), 1.0)
        sv.hidden = true
        return sv
    }

    func smallSignStars() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        
        let framesize = sv.frame.size.width * CGFloat(speeds[6])
        sv.contentSize = CGSizeMake(framesize * (signFrames * CGFloat(gap) + 2), 1.0)
        
        for i in 0..<order.count {
            var dx = Double(i) * canvas.width * Double(speeds[6]) * gap
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let closure = signs[order[i]] {
                for point in closure().small {
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
            if let closure = signs[order[i]] {
                for point in closure().big {
                    let img = C4Image("10Star")
                    var p = point
                    p.transform(t)
                    img.center = p
                    sv.add(img)
                }
            }
        }
        
        sv.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: &myContext)
        
        return sv
    }
    
    func taurus() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-53.25,-208.2),
            C4Point(-56.75,-26.2)]
        
        let small = [
            C4Point(-134.75,-174.2),
            C4Point(-24.25,-32.2),
            C4Point(-24.25,-9.2),
            C4Point(-32.75,10.8),
            C4Point(87.75,-6.2),
            C4Point(-15.75,67.3),
            C4Point(31.75,142.3)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func sagittarius() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-69.75,78.3),
            C4Point(-98.25,-98.2)]
        
        let small = [
            C4Point(0.75,81.8),
            C4Point(-18.75,44.3),
            C4Point(-102.25,22.3),
            C4Point(-109.25,10.8),
            C4Point(-142.25,-50.2),
            C4Point(-129.75,-62.7),
            C4Point(-27.75,-93.7),
            C4Point(-10.75,-77.7),
            C4Point(-6.25,-112.7),
            C4Point(-42.75,-152.2),
            C4Point(-57.75,-159.7),
            C4Point(-78.75,-171.7),
            C4Point(-93.25,-178.7),
            C4Point(17.75,-112.7),
            C4Point(52.75,-140.7),
            C4Point(87.25,-202.7),
            C4Point(76.75,-100.2),
            C4Point(110.75,-102.7),
            C4Point(142.25,-132.7),
            C4Point(82.25,-54.2),
            C4Point(101.25,-33.7)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func cancer() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-68.25,-21.2),
            C4Point(46.25,141.8)]
        
        let small = [
            C4Point(-66.75,-209.2),
            C4Point(-59.25,-80.7),
            C4Point(-126.75,90.8),
            C4Point(5.75,81.8)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func gemini() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-96.75,-193.7),
            C4Point(-133.25,-142.2),
            C4Point(77.25,19.8)]
        
        let small = [
            C4Point(24.25,-218.7),
            C4Point(-29.75,-167.7),
            C4Point(-105.25,-125.7),
            C4Point(-134.75,-92.7),
            C4Point(54.75,-98.7),
            C4Point(120.75,-66.2),
            C4Point(145.75,-67.2),
            C4Point(103.75,-34.2),
            C4Point(-58.75,-55.7),
            C4Point(-9.25,-37.2),
            C4Point(-56.25,18.8),
            C4Point(53.75,67.8)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func pisces() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-103.0,-81.7),
            C4Point(120.5,-168.2)]
        
        let small = [
            C4Point(-127.5,-161.2),
            C4Point(-129.0,-143.2),
            C4Point(-112.0,-136.2),
            C4Point(-103.0,-38.2),
            C4Point(-107.5,11.3),
            C4Point(-82.0,-20.2),
            C4Point(-66.0,-32.7),
            C4Point(-28.5,-67.7),
            C4Point(-8.0,-78.7),
            C4Point(58.0,-129.7),
            C4Point(84.5,-147.7),
            C4Point(92.5,-163.7),
            C4Point(106.0,-130.2),
            C4Point(125.5,-149.2),
            C4Point(129.5,-188.2)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func leo() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-60.25,-33.7),
            C4Point(68.75,-50.2),
            C4Point(110.75,50.3)]
        
        let small = [
            C4Point(138.75,-129.2),
            C4Point(118.75,-157.2),
            C4Point(66.75,-103.7),
            C4Point(-31.75,-34.2),
            C4Point(103.75,-14.7),
            C4Point(-55.75,40.8),
            C4Point(-138.25,62.3)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func virgo() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-28.75,-248.2),
            C4Point(-134.75,-109.2),
            C4Point(93.75,-56.7),
            C4Point(-53.25,98.8)]
        
        let small = [
            C4Point(-9.25,-186.7),
            C4Point(-2.25,-144.7),
            C4Point(-56.25,-116.7),
            C4Point(39.25,-86.7),
            C4Point(-18.25,-39.7),
            C4Point(-44.25,10.3),
            C4Point(87.25,35.8),
            C4Point(33.75,42.3),
            C4Point(31.75,68.8),
            C4Point(24.25,94.8)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func aries() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(58.0,-57.7),
            C4Point(125.5,-17.7)]
        
        let small = [
            C4Point(-134.5,-95.2),
            C4Point(137.0,11.3)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func libra() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-26.25,-121.7)]
        
        let small = [
            C4Point(-141.25,-37.7),
            C4Point(-16.75,-35.7),
            C4Point(96.75,-39.2),
            C4Point(-70.75,65.3),
            C4Point(-64.75,102.3),
            C4Point(-53.25,147.3),
            C4Point(120.75,92.3),
            C4Point(118.75,109.3),
            C4Point(141.25,117.8)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func aquarius() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-140.25,-148.7),
            C4Point(-10.75,-203.7),
            C4Point(54.25,-158.2),
            C4Point(140.25,-127.7)]
        
        let small = [
            C4Point(-128.75,-17.7),
            C4Point(-93.25,-87.7),
            C4Point(-97.75,-135.7),
            C4Point(-67.75,-202.2),
            C4Point(-53.75,-206.2),
            C4Point(-41.75,-193.7),
            C4Point(-34.25,-136.2),
            C4Point(-18.75,-103.2),
            C4Point(-9.75,-85.7)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func scorpio() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-85.75,32.3),
            C4Point(-64.75,103.8),
            C4Point(38.75,-136.2)]
        
        let small = [
            C4Point(-70.75,34.8),
            C4Point(-97.75,61.3),
            C4Point(-100.75,76.8),
            C4Point(-9.25,86.8),
            C4Point(28.75,69.8),
            C4Point(29.25,54.8),
            C4Point(19.75,15.3),
            C4Point(10.75,-28.7),
            C4Point(24.75,-108.7),
            C4Point(56.25,-151.2),
            C4Point(103.75,-197.7),
            C4Point(81.75,-230.7),
            C4Point(61.75,-230.7),
            C4Point(119.25,-156.7),
            C4Point(130.25,-117.2)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func capricorn() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(136.25,-41.2),
            C4Point(133.25,-9.69999999999999),
            C4Point(1.25,50.3),
            C4Point(-129.75,73.8),
        ]
        
        let small = [
            C4Point(-51.25,59.3),
            C4Point(-105.75,72.8),
            C4Point(-84.75,103.8),
            C4Point(-50.75,122.8),
            C4Point(-36.25,128.8),
            C4Point(27.75,144.8),
            C4Point(81.25,156.8),
            C4Point(91.25,133.3)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
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