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

    override func viewDidLoad() {

        let sv1 = UIScrollView(frame: CGRect(canvas.frame))
        let sv2 = UIScrollView(frame: CGRect(canvas.frame))
        let sv3 = UIScrollView(frame: CGRect(canvas.frame))

        let size = C4Size(canvas.width*12,canvas.height)
        sv1.contentSize = CGSize(size)
        sv2.contentSize = CGSize(size)
        sv3.contentSize = CGSize(size)

        var pos1 = C4Point(157,8)
        var pos2 = C4Point(0,215)
        var pos3 = C4Point(171, 460)
        var pos4 = C4Point()
        for i in 0...11 {
            let img1 = C4Image("star3")
            let img2 = C4Image("star3")
            let img3 = C4Image("star3")

            img1.origin = C4Point(pos1.x + Double(i) * canvas.width, pos1.y)
            img2.origin = C4Point(pos2.x + Double(i) * canvas.width, pos2.y)
            img3.origin = C4Point(pos3.x + Double(i) * canvas.width, pos3.y)

            sv3.add(img1)
            sv3.add(img2)
            sv3.add(img3)
        }
        canvas.add(sv3)
        
        pos1.x = 62
        pos1.y = 51
        pos2.x = 248
        pos2.y = 208
        pos3.x = 27
        pos3.y = 270
        pos4.x = 90
        pos4.y = 541
        
        for i in 0...11 {
            let img1 = C4Image("star2")
            let img2 = C4Image("star2")
            let img3 = C4Image("star2")
            let img4 = C4Image("star2")
            
            img1.origin = C4Point(pos1.x + Double(i) * canvas.width, pos1.y)
            img2.origin = C4Point(pos2.x + Double(i) * canvas.width, pos2.y)
            img3.origin = C4Point(pos3.x + Double(i) * canvas.width, pos3.y)
            img4.origin = C4Point(pos4.x + Double(i) * canvas.width, pos4.y)

            sv2.add(img1)
            sv2.add(img2)
            sv2.add(img3)
            sv2.add(img4)
        }
        canvas.add(sv2)

        pos1.x = 23
        pos1.y = 50
        pos2.x = 215
        pos2.y = 11
        pos3.x = 184
        pos3.y = 556
        
        for i in 0...11 {
            let img1 = C4Image("star1")
            let img2 = C4Image("star1")
            let img3 = C4Image("star1")
            
            img1.origin = C4Point(pos1.x + Double(i) * canvas.width, pos1.y)
            img2.origin = C4Point(pos2.x + Double(i) * canvas.width, pos2.y)
            img3.origin = C4Point(pos3.x + Double(i) * canvas.width, pos3.y)
            
            sv1.add(img1)
            sv1.add(img2)
            sv1.add(img3)
        }
        canvas.add(sv1)

    }
}