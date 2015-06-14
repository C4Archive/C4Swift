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

class ViewController: C4CanvasController, SensorTagManagerDelegate {
    let bg = C4Image("statusBarBG1px")
    let alertBar = AlertBar()
    let needle = C4Image("needle")
    let screen1 = C4Image("screen1")
    let rotationScale = -1.495*M_PI
    let brakeImageContainer = C4View()
    let brakeTemp01 = C4Image("brakeTemp01")
    let brakeTemp02 = C4Image("brakeTemp02")
    let brakeTempOverlay = C4Image("brakeTempOverlay")
    var popup = C4Rectangle(frame: C4Rect())
    var popupImage = C4Image("popup")
    var yesButton = C4Circle(center: C4Point(269,305), radius: 8)
    var noButton = C4Circle(center: C4Point(355,305), radius: 8)
    let lines = C4Image("lines")
    var linesMask = C4Rectangle(frame: C4Rect())
    let barsRed = C4Image("barsRed")
    var barsRedMask = C4Rectangle(frame: C4Rect())
    let barsGrey = C4Image("barsGrey")
    var barsGreyMask = C4Rectangle(frame: C4Rect())
    var graph = Graph()

    var sensorTagManager : SensorTagManager?

    override func setup() {
        sensorTagManager = SensorTagManager(delegate: self)
        createInterface()
    }

//    Next step: link graph with sensor data...

    //MARK: SensorTag
    func bluetoothStateChanged(on: Bool) {
        if on {
            self.sensorTagManager?.startScan()
        }
    }

    func didDiscoverSensorTag(sensorTag: SensorTag!) {
        self.sensorTagManager?.stopScan()
        self.sensorTagManager?.connectSensorTag(sensorTag)
    }

    func didConnectSensorTag(sensorTag: SensorTag!) {
        sensorTag.setMovementEnabled(true)
        sensorTag.setMovementNotify(true)
        sensorTag.setMovementPeriod(100)

        delay(1.0) {
            sensorTag.setTemperatureEnabled(false)
            sensorTag.setLuxometerEnabled(false)
            sensorTag.setHumidityEnabled(false)
            sensorTag.setBarometerEnabled(false)
        }
    }

    func sensorTag(sensorTag: SensorTag!, didUpdateAmbientTemperature ambientTemperature: Float, targetTemperature: Float) {
        println(ambientTemperature)
    }

    func sensorTag(sensorTag: SensorTag!, didUpdateBarometer barometer: Float, temperature: Float) {
    }

    func sensorTag(sensorTag: SensorTag!, didUpdateHumidity humidity: Float, temperature: Float) {
    }

    func sensorTag(sensorTag: SensorTag!, didUpdateLuxometer lux: Float) {
    }

    func sensorTag(sensorTag: SensorTag!, didUpdateRSSI rssi: NSNumber!) {

    }

    var px = 0.0
    func sensorTag(sensorTag: SensorTag!, didUpdateAccelerometer accelerometer: Point3D, gyroscope: Point3D, magnetometer: Point3D) {
        var x = Double(px * 0.9 + Double(accelerometer.x) * 0.1)
        graph.updateAccelerometerData(x)
        px = x
        updateSpeed(x)
    }

    var velocities = [0.0,0.0,0.0,0.0,0.0]
    var accels = [0.0,0.0,0.0,0.0,0.0]
    var pv = 0.0
    var pa = 0.0
    var start = NSDate(timeIntervalSinceNow: 0)
    var pt = NSDate.timeIntervalSinceReferenceDate()

    func updateSpeed(val: Double) {
        accels.removeAtIndex(0)
        accels.append(val)
        var avg = 0.0
        for v in accels {
            avg += v
        }
        avg /= Double(accels.count)

        var y = avg * 100
        if y < 0 {
            y = ceil(y)
        } else {
            y = floor(y)
        }

        println(y)

        if abs(y) < 2 { y = 0 }


        let t = C4Transform.makeRotation(abs(y)/30.0*rotationScale, axis: C4Vector(x: 0, y: 0, z: 1))
        needle.transform = t
    }

    func didDisconnectSensorTag(sensorTag: SensorTag!) {
        self.sensorTagManager?.startScan()
    }

    //MARK: Interface
    func createInterface() {
        view.backgroundColor = UIColor(patternImage: bg.uiimage)
        styleNavigationBar()
        addScreenContents()
        positionSpeedNeedle()
        createFlippableBreakTemperatureWithBehaviours()
        createPopup()
        createDataGraph()
    }

    func createDataGraph() {
        canvas.add(graph.canvas)
    }

    func addScreenContents() {
        screen1.origin = C4Point(0,64)
        canvas.add(screen1)
    }

    func styleNavigationBar() {
        var neutech = UIImage(named: "neutech")
        neutech = neutech?.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: neutech, landscapeImagePhone: neutech, style: .Plain, target: self, action:NSSelectorFromString("reset"))

        var driveOnTitleLogo = UIImage(named: "driveOnTitleLogo")
        self.navigationItem.titleView = UIImageView(image: driveOnTitleLogo)

        var gears = UIImage(named: "gears")
        gears = gears?.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: gears, landscapeImagePhone: gears, style: .Plain, target: nil, action: nil)

        self.navigationController?.view.add(alertBar.canvas)
    }

    func positionSpeedNeedle() {
        needle.anchorPoint = C4Point(0.88,0.12)
        needle.center = C4Point(477,236)
        canvas.add(needle)
    }

    func createFlippableBreakTemperatureWithBehaviours() {
        addBehaviourToBreakTemp01()
        addBehaviourToBreakTemp02()
        createBreakTemperatureContainer()
    }

    func createBreakTemperatureContainer() {
        brakeImageContainer.frame = brakeTemp01.bounds
        brakeImageContainer.origin = C4Point(461,572)
        brakeImageContainer.add(brakeTemp01)

        canvas.add(brakeImageContainer)
    }

    func addBehaviourToBreakTemp01() {
        brakeTemp01.interactionEnabled = true

        brakeTemp01.addTapGestureRecognizer { (location, state) -> () in
            delay(2.0) {
                self.flip01()
                self.alertBar.reveal()
            }
        }
    }

    func addBehaviourToBreakTemp02() {
        brakeTemp02.interactionEnabled = true
        brakeTemp02.addTapGestureRecognizer { (location, state) -> () in
            self.flip02()
        }
        brakeTempOverlay.addTapGestureRecognizer { (location, state) -> () in
            self.revealPopup()
        }
        brakeTempOverlay.interactionEnabled = true
        brakeTemp02.add(brakeTempOverlay)
    }

    func createPopup() {
        createBackgroundAndImageForPopup()
        createAnimatedDataForPopup()
        createYesNoButtonsForPopup()
        createScheduleServiceButton()
    }

    func createBackgroundAndImageForPopup() {
        popup.interactionEnabled = false

        popup.frame = screen1.bounds
        popupImage.interactionEnabled = true
        popupImage.center = popup.center
        popup.add(popupImage)
        popup.origin = screen1.origin
        popup.backgroundColor = C4Color(red: 0, green: 0, blue: 0, alpha: 0.4)
        popup.opacity = 0.0
        canvas.add(popup)
    }

    func createYesNoButtonsForPopup() {
        yesButton.fillColor = clear
        yesButton.strokeColor = clear
        popupImage.add(yesButton)

        yesButton.addTapGestureRecognizer { (location, state) -> () in
            self.yesButton.fillColor = green
            self.noButton.fillColor = clear
        }

        noButton.fillColor = red
        noButton.strokeColor = clear
        popupImage.add(noButton)

        noButton.addTapGestureRecognizer { (location, state) -> () in
            self.yesButton.fillColor = clear
            self.noButton.fillColor = red
        }
    }

    func createAnimatedDataForPopup() {
        lines.origin = C4Point(82,470)
        linesMask = C4Rectangle(frame: lines.bounds)
        linesMask.origin = C4Point(-linesMask.width,0)
        lines.layer?.mask = linesMask.layer
        popupImage.add(lines)

        barsGrey.origin = C4Point(496,460)
        barsGreyMask = C4Rectangle(frame: barsRed.bounds)
        barsGreyMask.origin = C4Point(-barsGreyMask.width,0)
        barsGrey.layer?.mask = barsGreyMask.layer
        popupImage.add(barsGrey)

        barsRed.origin = barsGrey.origin
        barsRedMask = C4Rectangle(frame: barsRed.bounds)
        barsRedMask.fillColor = red
        barsRedMask.origin = C4Point(-barsRedMask.width,0)
        barsRed.add(barsRedMask)
        barsRed.layer?.mask = barsRedMask.layer
        popupImage.add(barsRed)
    }

    func createScheduleServiceButton() {
        let button = C4Rectangle(frame: C4Rect(popupImage.width-204,popupImage.height-44,194,40))
        button.fillColor = clear
        button.strokeColor = clear
        button.addTapGestureRecognizer { (location, state) -> () in
            self.brakeImageContainer.interactionEnabled = false
            self.hidePopup()
            delay(0.25){
                self.alertBar.blue()
            }
            delay(0.5){
                C4ViewAnimation(duration: 0.25) {
                    self.brakeTempOverlay.opacity = 0.0
                    }.animate()
            }
            delay(2.0) {
                self.alertBar.hide()
            }
        }
        popupImage.add(button)
    }
    
    func reset() {
        brakeImageContainer.interactionEnabled = true
        alertBar.hide()
        alertBar.red()
        flip02()
        brakeTempOverlay.opacity = 1.0
        barsRedMask.origin = C4Point(-barsRedMask.width,0)
        barsGreyMask.origin = C4Point(-barsGreyMask.width,0)
        linesMask.origin = C4Point(-linesMask.width,0)
        self.yesButton.fillColor = clear
        self.noButton.fillColor = red
    }

    func flip01() {
        UIView.transitionFromView(brakeTemp01.view, toView: brakeTemp02.view, duration: 0.25, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
    }
    
    func flip02() {
        UIView.transitionFromView(brakeTemp02.view, toView: brakeTemp01.view, duration: 0.25, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
    }
    
    func revealPopup() {
        popup.interactionEnabled = true
        C4ViewAnimation(duration: 0.5) {
            self.popup.opacity = 1.0
        }.animate()
        delay(0.25) {
            C4ViewAnimation(duration: 0.25) {
                self.popupImage.opacity = 1.0
            }.animate()
       }
        delay(0.5) {
            C4ViewAnimation(duration: 0.66) {
                self.linesMask.origin = C4Point()
            }.animate()
        }
        delay(0.75) {
            C4ViewAnimation(duration: 0.66) {
                self.barsGreyMask.origin = C4Point()
            }.animate()
        }
        delay(1.0) {
            C4ViewAnimation(duration: 0.66) {
                self.barsRedMask.origin = C4Point()
            }.animate()
        }
    }

    func hidePopup() {
        popup.interactionEnabled = false
        C4ViewAnimation(duration: 0.5) {
            self.popup.opacity = 0.0
        }.animate()
    }
}