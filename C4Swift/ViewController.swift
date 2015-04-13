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
    var myContext = 0
    let cosmosblue = C4Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)
    let cosmosbkgd = C4Color(red: 0.078, green: 0.118, blue: 0.306, alpha: 1.0)
    let cosmosprpl = C4Color(red:0.565, green: 0.075, blue: 0.996, alpha: 1.0)
    var scrollviews = [InfiniteScrollView]()
    var speeds : [CGFloat] = [0.05,0.08,0.10,0.0,0.15,1.0,0.8,1.0]
    
    override func viewDidLoad() {
        
        canvas.backgroundColor = cosmosbkgd
        scrollviews.append(layer03())
        scrollviews.append(layer04())
        scrollviews.append(layer05())
        scrollviews.append(layer06())
        scrollviews.append(layer07())
        scrollviews.append(layer08())
        scrollviews.append(layer09())
        scrollviews.append(layer10())
        
        for scrollview in scrollviews {
            canvas.add(scrollview)
        }
    }
    
    func layer03() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * 12.0, 1.0)
        
        for i in 0...11 {
            let start = Double(i) * canvas.width
            for j in 0...14 {
                let pt = C4Point( start + random01() * canvas.width, random01() * canvas.height)
                let img = C4Image("03Star")
                img.center = pt
                sv.add(img)
            }
        }
        
        return sv
    }
    
    func layer04() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * 12.0, 1.0)
        
        for i in 0...11 {
            let start = Double(i) * canvas.width
            for j in 0...24 {
                let pt = C4Point( start + random01() * canvas.width, random01() * canvas.height)
                let img = C4Image("04Star")
                img.center = pt
                sv.add(img)
            }
        }
        
        return sv
    }

    
    func layer05() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * 12.0, 1.0)
        
        for i in 0...11 {
            let start = Double(i) * canvas.width
            for j in 0...19 {
                let pt = C4Point( start + random01() * canvas.width, random01() * canvas.height)
                let img = C4Image("05Star")
                img.center = pt
                sv.add(img)
            }
        }
        
        return sv
    }
    
    func layer06() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let img = C4Image("06Vignette")
        img.frame = canvas.frame
        sv.add(img)
        return sv
    }

    func layer07() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * 12.0, 1.0)
        
        for i in 0...11 {
            let start = Double(i) * canvas.width
            for j in 0...19 {
                let pt = C4Point( start + random01() * canvas.width, random01() * canvas.height)
                let img = C4Image("07Star")
                img.center = pt
                sv.add(img)
            }
        }
        
        return sv
    }

    func layer08() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * 12.0, 1.0)
        
        for points in taurus().lines {
            let line = C4Line(points)
            line.strokeColor = cosmosprpl
            line.lineWidth = 1.0
            line.opacity = 0.4
            sv.add(line)
        }

        for i in 1...11 {
            let start = Double(i) * canvas.width
            for j in 0...3 {
                let bgn = C4Point( start + random01() * canvas.width, random01() * canvas.height)
                let end = C4Point( start + random01() * canvas.width, random01() * canvas.height)
                
                let line = C4Line([bgn,end])
                line.strokeColor = cosmosprpl
                line.lineWidth = 1.0
                line.opacity = 0.4
                sv.add(line)
            }
        }
        
        return sv
    }

    func layer09() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * 12.0, 1.0)
        
        for point in taurus().small {
            let img = C4Image("09Star")
            img.center = point
            sv.add(img)
        }
        
        for i in 1...11 {
            let start = Double(i) * canvas.width
            for j in 0...6 {
                let pt = C4Point( start + random01() * canvas.width, random01() * canvas.height)
                let img = C4Image("09Star")
                img.center = pt
                sv.add(img)
            }
        }
        
        return sv
    }

    func layer10() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * 12.0, 1.0)
        
        for point in taurus().big {
            let img = C4Image("10Star")
            img.center = point
            sv.add(img)
        }
        
        for i in 1...11 {
            let start = Double(i) * canvas.width
            for j in 0...2 {
                let pt = C4Point( start + random01() * canvas.width, random01() * canvas.height)
                let img = C4Image("10Star")
                img.center = pt
                sv.add(img)
            }
        }
        
        sv.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: &myContext)
        
        return sv
    }
    
    func taurus() -> (big:[C4Point],small:[C4Point],lines:[[C4Point]]) {
        let big = [C4Point(126,165),C4Point(123,338)]
        let small = [C4Point(45,199),C4Point(156,342),C4Point(156,361),C4Point(267,364),C4Point(147,384),C4Point(164,441),C4Point(211,516)]
        let lines = [
            [big[0],small[1]],
            [small[0],big[1]],
            [small[1],small[2]],
            [big[1],small[4]],
            [small[1],small[3]],
            [small[2],small[4]],
            [small[4],small[5]],
            [small[5],small[6]]]
        
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