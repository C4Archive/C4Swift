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
    
    func printFunctions() {

        for key in signs.keys {
            
            if let closure = signs[key] {
                let big = closure().big
                let small = closure().small
                
                println("func "+key+"() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {")
                println("\tlet big = [")
                for i in 0..<big.count {
                    let pt = big[i]
                    println("\t\tC4Point(\(pt.x-canvas.center.x),\(pt.y-canvas.center.y)),")
                }
                println("\t]")
                println()
                println("\tlet small = [")
                for i in 0..<small.count {
                    let pt = small[i]
                    println("\t\tC4Point(\(pt.x-canvas.center.x),\(pt.y-canvas.center.y)),")
                }
                println("\t]")
                println()
                println("\tlet lines = [[big[0],big[0]]]")
                println()
                println("\treturn (big,small,lines)")
                println("}")
                println()
                println()
            }
        }
    }
    
    func layout() {
        canvas.backgroundColor = cosmosbkgd
        scrollviews.append(starsLayer(speeds[0],imageName: "03Star",starCount: 4))
        scrollviews.append(starsLayer(speeds[1],imageName: "04Star",starCount: 10))
        scrollviews.append(starsLayer(speeds[2],imageName: "05Star",starCount: 9))
        scrollviews.append(vignette())
        scrollviews.append(starsLayer(speeds[4],imageName: "07Star",starCount: 7))
        scrollviews.append(layer08())
        scrollviews.append(layer09())
        scrollviews.append(layer10())

        for scrollview in scrollviews {
            canvas.add(scrollview)
        }
        
//        for i in 0..<scrollviews.count-2 {
//            let scrollview = scrollviews[i]
//            if i != 0 { scrollview.hidden = true }
//            canvas.add(scrollview)
//        }
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
    
    func layer08() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let framesize = sv.frame.size.width * CGFloat(speeds[5])
        sv.contentSize = CGSizeMake(framesize * (signFrames * CGFloat(gap) + 2), 1.0)
        sv.hidden = true
        return sv
    }
    

    func layer09() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        
        let framesize = sv.frame.size.width * CGFloat(speeds[6])
        sv.contentSize = CGSizeMake(framesize * (signFrames * CGFloat(gap) + 2), 1.0)
        
        let closures = [SignClosure](signs.values)
        for i in 0..<closures.count {
            var dx = Double(i) * canvas.width * Double(speeds[6]) * gap
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            let closure = closures[i]
            for point in closure().small {
                let img = C4Image("09Star")
                var p = point
                p.transform(t)
                img.center = p
                sv.add(img)
            }
        }
        
        var dx = Double(12.0) * canvas.width * Double(speeds[6]) * gap
        let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
        let closure = closures[0]
        for point in closure().small {
            let img = C4Image("09Star")
            var p = point
            p.transform(t)
            img.center = p
            sv.add(img)
        }
        
        return sv
    }
    
    func layer10() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * signFrames * CGFloat(gap) + sv.frame.size.width, 1.0)
        
        let closures = [SignClosure](signs.values)
        for i in 0..<closures.count {
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + Double(i) * canvas.width * gap, y: canvas.center.y, z: 0))
            let closure = closures[i]
            for point in closure().big {
                let img = C4Image("10Star")
                var p = point
                p.transform(t)
                img.center = p
                sv.add(img)
            }
        }
        
        var dx = Double(12) * canvas.width * gap
        let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
        let closure = closures[0]
        for point in closure().big {
            let img = C4Image("10Star")
            var p = point
            p.transform(t)
            img.center = p
            sv.add(img)
        }

//        let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x, y: canvas.center.y, z: 0))
//        
//        for point in aquarius().big {
//            let img = C4Image("10Star")
//            var p = point
//            p.transform(t)
//            img.center = p
//            sv.add(img)
//        }
//        
//        for i in 1...11 {
//            let start = Double(i) * canvas.width
//            for j in 0...2 {
//                let pt = C4Point( start + random01() * canvas.width, random01() * canvas.height)
//                let img = C4Image("10Star")
//                img.center = pt
//                sv.add(img)
//            }
//        }
        
        sv.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: &myContext)
        
        return sv
    }
/*
    func pisces() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(57.00,202.3),
            C4Point(280.50,115.8)]
        
        let small = [C4Point(32.50,122.8),
            C4Point(31.00,140.8),
            C4Point(48.00,147.8),
            C4Point(57.00,245.8),
            C4Point(52.50,295.3),
            C4Point(78.00,263.8),
            C4Point(94.00,251.3),
            C4Point(131.50,216.3),
            C4Point(152.00,205.3),
            C4Point(218.00,154.3),
            C4Point(244.50,136.3),
            C4Point(252.50,120.3),
            C4Point(266.00,153.8),
            C4Point(285.50,134.8),
            C4Point(289.50,95.8)]
        
        let lines = [
            [big[0],big[0]]]
        
        return (big,small,lines)
    }

    func aries() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(218.00,226.3),
            C4Point(285.50,266.3)]
        
        let small = [
            C4Point(25.50,188.8),
            C4Point(297.00,295.3)]
        
        let lines = [
            [big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    func taurus() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(106.75,75.8),
            C4Point(103.25,257.8)]
        
        let small = [
            C4Point(25.25,109.8),
            C4Point(135.75,251.8),
            C4Point(135.75,274.8),
            C4Point(127.25,294.8),
            C4Point(247.75,277.8),
            C4Point(144.25,351.3),
            C4Point(191.75,426.3)]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    func gemini() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(63.25,90.3),
            C4Point(26.75,141.8),
            C4Point(237.25,303.8)]

        let small = [
            C4Point(184.25,65.3),
            C4Point(130.25,116.3),
            C4Point(54.75,158.3),
            C4Point(25.25,191.3),
            C4Point(214.75,185.3),
            C4Point(280.75,217.8),
            C4Point(305.75,216.8),
            C4Point(263.75,249.8),
            C4Point(101.25,228.3),
            C4Point(150.75,246.8),
            C4Point(103.75,302.8),
            C4Point(213.75,351.8)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }

    func cancer() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(91.75,262.8),
            C4Point(206.25,425.8)]

        let small = [
            C4Point(93.25,74.8),
            C4Point(100.75,203.3),
            C4Point(33.25,374.8),
            C4Point(165.75,365.8)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }

    func leo() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(99.75,250.3),
            C4Point(228.75,233.8),
            C4Point(270.75,334.3)]

        let small = [
            C4Point(298.75,154.8),
            C4Point(278.75,126.8),
            C4Point(226.75,180.3),
            C4Point(128.25,249.8),
            C4Point(263.75,269.3),
            C4Point(104.25,324.8),
            C4Point(21.75,346.3)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }

    func virgo() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(131.25,35.8),
            C4Point(25.25,174.8),
            C4Point(253.75,227.3),
            C4Point(106.75,382.8)]

        let small = [
            C4Point(150.75,97.3),
            C4Point(157.75,139.3),
            C4Point(103.75,167.3),
            C4Point(199.25,197.3),
            C4Point(141.75,244.3),
            C4Point(115.75,294.3),
            C4Point(247.25,319.8),
            C4Point(193.75,326.3),
            C4Point(191.75,352.8),
            C4Point(184.25,378.8)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }

    func libra() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(133.75,162.3)]

        let small = [
            C4Point(18.75,246.3),
            C4Point(143.25,248.3),
            C4Point(256.75,244.8),
            C4Point(89.25,349.3),
            C4Point(95.25,386.3),
            C4Point(106.75,431.3),
            C4Point(280.75,376.3),
            C4Point(278.75,393.3),
            C4Point(301.25,401.8)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }

    func scorpio() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(74.25,316.3),
            C4Point(95.25,387.8),
            C4Point(198.75,147.8)]

        let small = [
            C4Point(89.25,318.8),
            C4Point(62.25,345.3),
            C4Point(59.25,360.8),
            C4Point(150.75,370.8),
            C4Point(188.75,353.8),
            C4Point(189.25,338.8),
            C4Point(179.75,299.3),
            C4Point(170.75,255.3),
            C4Point(184.75,175.3),
            C4Point(216.25,132.8),
            C4Point(263.75,86.3),
            C4Point(241.75,53.3),
            C4Point(221.75,53.3),
            C4Point(279.25,127.3),
            C4Point(290.25,166.8)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }
    
    func sagittarius() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(90.25,362.3),
            C4Point(61.75,185.8)]

        let small = [
            C4Point(160.75,365.8),
            C4Point(141.25,328.3),
            C4Point(57.75,306.3),
            C4Point(50.75,294.8),
            C4Point(17.75,233.8),
            C4Point(30.25,221.3),
            C4Point(132.25,190.3),
            C4Point(149.25,206.3),
            C4Point(153.75,171.3),
            C4Point(117.25,131.8),
            C4Point(102.25,124.3),
            C4Point(81.25,112.3),
            C4Point(66.75,105.3),
            C4Point(177.75,171.3),
            C4Point(212.75,143.3),
            C4Point(247.25,81.3),
            C4Point(236.75,183.8),
            C4Point(270.75,181.3),
            C4Point(302.25,151.3),
            C4Point(242.25,229.8),
            C4Point(261.25,250.3)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }
    
    func capricorn() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(296.25,242.8),
            C4Point(293.25,274.3),
            C4Point(161.25,334.3),
            C4Point(30.25,357.8)]

        let small = [
            C4Point(108.75,343.3),
            C4Point(54.25,356.8),
            C4Point(75.25,387.8),
            C4Point(109.25,406.8),
            C4Point(123.75,412.8),
            C4Point(187.75,428.8),
            C4Point(241.25,440.8),
            C4Point(251.25,417.3)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }
    
    func aquarius() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [C4Point(19.75,135.3),
            C4Point(149.25,80.3),
            C4Point(214.25,125.8),
            C4Point(300.25,156.3)]

        let small = [
            C4Point(31.25,266.3),
            C4Point(66.75,196.3),
            C4Point(62.25,148.3),
            C4Point(92.25,81.8),
            C4Point(106.25,77.8),
            C4Point(118.25,90.3),
            C4Point(125.75,147.8),
            C4Point(141.25,180.8),
            C4Point(150.25,198.3)]

        let lines = [[big[0],big[0]]]

        return (big,small,lines)
    }
    
*/
    
    func taurus() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-53.25,-208.2),
            C4Point(-56.75,-26.2),
        ]
        
        let small = [
            C4Point(-134.75,-174.2),
            C4Point(-24.25,-32.2),
            C4Point(-24.25,-9.19999999999999),
            C4Point(-32.75,10.8),
            C4Point(87.75,-6.19999999999999),
            C4Point(-15.75,67.3),
            C4Point(31.75,142.3),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func sagittarius() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-69.75,78.3),
            C4Point(-98.25,-98.2),
        ]
        
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
            C4Point(101.25,-33.7),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func cancer() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-68.25,-21.2),
            C4Point(46.25,141.8),
        ]
        
        let small = [
            C4Point(-66.75,-209.2),
            C4Point(-59.25,-80.7),
            C4Point(-126.75,90.8),
            C4Point(5.75,81.8),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func gemini() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-96.75,-193.7),
            C4Point(-133.25,-142.2),
            C4Point(77.25,19.8),
        ]
        
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
            C4Point(53.75,67.8),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func pisces() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-103.0,-81.7),
            C4Point(120.5,-168.2),
        ]
        
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
            C4Point(129.5,-188.2),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func leo() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-60.25,-33.7),
            C4Point(68.75,-50.2),
            C4Point(110.75,50.3),
        ]
        
        let small = [
            C4Point(138.75,-129.2),
            C4Point(118.75,-157.2),
            C4Point(66.75,-103.7),
            C4Point(-31.75,-34.2),
            C4Point(103.75,-14.7),
            C4Point(-55.75,40.8),
            C4Point(-138.25,62.3),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func virgo() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-28.75,-248.2),
            C4Point(-134.75,-109.2),
            C4Point(93.75,-56.7),
            C4Point(-53.25,98.8),
        ]
        
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
            C4Point(24.25,94.8),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func aries() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(58.0,-57.7),
            C4Point(125.5,-17.7),
        ]
        
        let small = [
            C4Point(-134.5,-95.2),
            C4Point(137.0,11.3),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func libra() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-26.25,-121.7),
        ]
        
        let small = [
            C4Point(-141.25,-37.7),
            C4Point(-16.75,-35.7),
            C4Point(96.75,-39.2),
            C4Point(-70.75,65.3),
            C4Point(-64.75,102.3),
            C4Point(-53.25,147.3),
            C4Point(120.75,92.3),
            C4Point(118.75,109.3),
            C4Point(141.25,117.8),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func aquarius() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-140.25,-148.7),
            C4Point(-10.75,-203.7),
            C4Point(54.25,-158.2),
            C4Point(140.25,-127.7),
        ]
        
        let small = [
            C4Point(-128.75,-17.7),
            C4Point(-93.25,-87.7),
            C4Point(-97.75,-135.7),
            C4Point(-67.75,-202.2),
            C4Point(-53.75,-206.2),
            C4Point(-41.75,-193.7),
            C4Point(-34.25,-136.2),
            C4Point(-18.75,-103.2),
            C4Point(-9.75,-85.7),
        ]
        
        let lines = [[big[0],big[0]]]
        
        return (big,small,lines)
    }
    
    
    func scorpio() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [
            C4Point(-85.75,32.3),
            C4Point(-64.75,103.8),
            C4Point(38.75,-136.2),
        ]
        
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
            C4Point(130.25,-117.2),
        ]
        
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
            C4Point(91.25,133.3),
        ]
        
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