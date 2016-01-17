//
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import C4

class ViewController: C4CanvasController {
    var petris = [C4Circle]()

    override func setup() {
        createPetris()
        canvas.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            C4ShapeLayer.disableActions = true
            let petri = self.petris[random(below: self.petris.count)]
            let bit = self.createBit(petri)
            bit.center = location
            self.canvas.add(bit)
            C4ShapeLayer.disableActions = false
            self.moveToCenter(bit, then: petri)
        }
    }

    func moveToCenter(bit: C4Circle, then petri: C4Circle) {
        let a = C4ViewAnimation(duration: random01() * 0.5 + 0.5) { () -> Void in
            bit.center = self.canvas.center
        }
        a.addCompletionObserver { () -> Void in
            bit.removeFromSuperview()
            bit.center = petri.bounds.center
            petri.add(bit)
            self.randomMove(bit, inPetri: petri)
            delay(0.5) {
                self.kill(bit)
            }
        }
        a.animate()
    }

    func createPetris() {
        let r = (canvas.width < canvas.height ? canvas.width : canvas.height) * 0.45
        for _ in 0...5 {
            let petri = C4Circle(center: canvas.center, radius: r)
            petri.fillColor = clear
            petri.strokeColor = clear
            petri.interactionEnabled = false
            randomRotate(petri)
            petris.append(petri)
            canvas.add(petri)
        }
    }

    func createBit(petri: C4Circle) -> C4Circle {
        let θ = random01() * 2 * M_PI
        let r = petri.width/2.0 * random01()
        let c = C4Point(r * sin(θ), r * cos(θ)) + C4Vector(petri.bounds.center)
        let bit = C4Circle(center: c, radius: 2)
        bit.lineWidth = 0
        bit.fillColor = C4Pink
        return bit
    }

    func createBits(petri: C4Circle) {
        for _ in 0...20 {
            petri.add(createBit(petri))
        }
    }

    func randomMove(bit: C4Circle, inPetri petri: C4Circle) {
        let anim = C4ViewAnimation(duration: random01() * 5 + 2.0) { () -> Void in
            let θ = random01() * 2 * M_PI
            let r = petri.width/2.0 * random01()
            let c = C4Point(r * sin(θ), r * cos(θ)) + C4Vector(petri.bounds.center)
            bit.center = c
        }
        anim.delay = random01() * 1.0
        anim.addCompletionObserver { () -> Void in
            self.randomMove(bit, inPetri: petri)
        }
        anim.animate()
    }

    func randomRotate(petri: C4Circle) {
        let anim = C4ViewAnimation(duration: random01() * 5 + 2.0) { () -> Void in
            let θ = random01() * M_PI
            let d = round(random01()) == 0 ? -1.0 : 1.0
            petri.transform.rotate(θ * d)
        }
        anim.delay = random01() * 1.0
        anim.addCompletionObserver { () -> Void in
            self.randomRotate(petri)
        }
        anim.animate()
    }

    func kill(bit: C4Circle) {
        let a = C4ViewAnimation(duration: 0.25) {
            bit.opacity = 0.0
        }
        a.addCompletionObserver { () -> Void in
            bit.removeFromSuperview()
        }
        a.delay = random01() * 5 + 5
        a.animate()
    }
}