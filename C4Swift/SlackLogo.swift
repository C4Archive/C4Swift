//
//  SlackLogo.swift
//  C4Swift
//
//  Created by travis on 2016-01-04.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
class SlackLogo: C4View {
    var slackLines = [SlackLine]()

    var isSquares = false {
        didSet {
            for slackLine in self.slackLines {
                slackLine.isSquares = isSquares
            }
        }
    }

    override init() {
        super.init()
        frame = C4Rect(0,0,106,106)
        setup()
    }

    func animate() {
        for line in slackLines {
            line.animate()
        }
    }

    func setup() {

        var colors = [C4Color(red: 166, green: 217, blue: 227, alpha: 1.0), C4Color(red: 233, green: 188, blue: 33, alpha: 1.0), C4Color(red: 213, green: 58, blue: 102, alpha: 1.0), C4Color(red: 129, green: 194, blue: 168, alpha: 1.0)]
        var smallSquareColors = [C4Color(red: 124, green: 210, blue: 190, alpha: 1.0), C4Color(red: 165, green: 178, blue: 107, alpha: 1.0), C4Color(red: 207, green: 85, blue: 85, alpha: 1.0), C4Color(red: 120, green: 77, blue: 103, alpha: 1.0)]

        slackLines.append(SlackLine())
        slackLines[0].center = C4Point(center.x,30)
        slackLines[0].strokeColor = colors[0]
        slackLines[0].squareColor = smallSquareColors[0]

        slackLines.append(SlackLine())
        slackLines[1].center = C4Point(width-30,center.y)
        slackLines[1].transform = C4Transform.makeRotation(-M_PI/2)
        slackLines[1].strokeColor = colors[1]
        slackLines[1].squareColor = smallSquareColors[1]


        slackLines.append(SlackLine())
        slackLines[2].center = C4Point(center.x,height - 30)
        slackLines[2].transform = C4Transform.makeRotation(M_PI)
        slackLines[2].strokeColor = colors[2]
        slackLines[2].squareColor = smallSquareColors[2]

        slackLines.append(SlackLine())
        slackLines[3].center = C4Point(30,center.y)
        slackLines[3].transform = C4Transform.makeRotation(-M_PI * 3 / 2)
        slackLines[3].strokeColor = colors[3]
        slackLines[3].squareColor = smallSquareColors[3]

        for slackline in self.slackLines {
            add(slackline)
        }
    }
}