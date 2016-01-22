// Copyright © 2016 C4
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import UIKit
import C4

class WorkSpace: C4CanvasController {
    var gradients = [C4Gradient]()
    var timer: C4Timer!

    override func setup() {
        var x = 1.0
        repeat {
            gradients.append(createGradient(C4Point(x,canvas.center.y)))
            x += 2.0
        } while x < canvas.width

        timer = C4Timer(interval: 0.02, count: gradients.count) { () -> () in
            let g = self.gradients[self.timer.step]
            self.createAnimation(g)
        }
        timer.start()
    }

    func createGradient(point: C4Point) -> C4Gradient {
        var colors = [C4Blue,C4Pink]

        if random(below: 2) == 1 {
            colors = [C4Pink,C4Blue]
        }

        let g = C4Gradient(frame: C4Rect(0,0,1,1), colors: colors)
        g.center = point
        g.transform.rotate(M_PI_4)
        canvas.add(g)
        return g
    }

    func createAnimation(g: C4Gradient) {
        let anim = C4ViewAnimation(duration: 2.0) {
            var f = g.frame
            let c = g.center
            f.height = 100
            f.center = c
            g.frame = f
        }
        anim.curve = .EaseInOut
        anim.autoreverses = true
        anim.repeats = true
        anim.animate()
    }
}