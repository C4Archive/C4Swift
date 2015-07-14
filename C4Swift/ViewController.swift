 //
//  ViewController.swift
//  C4Swift
//
//  Created by travis on 2014-10-28.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit
import C4

class ViewController: C4CanvasController, SensorTagManagerDelegate {
    let bg = C4Image("statusBarBG1px")
    let alertBar = AlertBar()
    let needle = C4Image("needle")
    let staticContent = C4Image("staticContent")
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
    var gearsButton : UIBarButtonItem?

    let extTemp = C4Circle(frame: C4Rect(0,0,174,174))
    let intTemp = C4Circle(frame: C4Rect(0,0,199,199))

    let intTempLabel = UILabel(frame: CGRectMake(132, 334.5, 100, 25))
    let extTempLabel = UILabel(frame: CGRectMake(132, 306.5, 100, 25))

    let speedLabel = UILabel(frame: CGRectMake(392, 321, 100, 36))

    var sensorTagManager : SensorTagManager?

//    var storedSpeed = [(Double,Double)]()
//    var storedTemp = [(Float,Float)]()
    
    override func setup() {
        sensorTagManager = SensorTagManager(delegate: self)
        createInterface()

        delay(0.75) {
            self.intTemp.hidden = false
            self.extTemp.hidden = false
        }
        
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = Selector("toggleLive")
    }
    
    var live = true
    
    func toggleLive() {
        if live {
            sensorTagManager?.stopScan()
            sensorTagManager?.close()
            initiateSpeedTimer()
            initiateTempTimer()
            navigationItem.rightBarButtonItem?.tintColor = .blueColor()
            live = false
        } else {
            sensorTagManager = SensorTagManager(delegate: self)
            sensorTagManager?.startScan()
            speedTimer?.invalidate()
            tempTimer?.invalidate()
            speedIndex = 0
            tempIndex = 0
            navigationItem.rightBarButtonItem?.tintColor = .redColor()
            live = true
        }
    }
    
    var speedTimer : NSTimer?
    func initiateSpeedTimer() {
        println(recordedSpeeds.count)
        speedTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateSpeed"), userInfo: nil, repeats: true)
    }
    
    var speedIndex = 0
    func updateSpeed() {
        let speeds = recordedSpeeds[speedIndex]
        
        graph.updateAccelerometerData(speeds.0)
        graph.updateRawData(speeds.1)
        updateSpeed(speeds.0)
        
        speedIndex++
        if speedIndex >= recordedSpeeds.count {
            speedIndex = 0
        }
    }
    
    var tempTimer : NSTimer?
    func initiateTempTimer() {
        println(recordedTemps.count)
        tempTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTemp"), userInfo: nil, repeats: true)
    }
    
    var tempIndex = 0
    func updateTemp() {
        let temps = recordedTemps[tempIndex]
        
        let targetTemperature = temps.0
        let ambientTemperature = temps.1
        
        C4ViewAnimation(duration: 0.5) {
            self.intTemp.strokeEnd = clamp(Double(targetTemperature), 0.0, 30.0) * 0.025
            if targetTemperature >= 25.0 {
                self.intTemp.strokeColor = red
                self.intTempLabel.textColor = .redColor()
            } else {
                self.intTemp.strokeColor = white
                self.intTempLabel.textColor = .whiteColor()
            }
            self.intTempLabel.text = NSString(format: "%2.2f", targetTemperature) as String
            
            self.extTemp.strokeEnd = clamp(Double(ambientTemperature), 0.0, 30.0) * 0.025
            if ambientTemperature >= 25.0 {
                self.extTemp.strokeColor = red
                self.extTempLabel.textColor = .redColor()
            } else {
                self.extTemp.strokeColor = white
                self.extTempLabel.textColor = .whiteColor()
            }
            self.extTempLabel.text = NSString(format: "%2.2f", ambientTemperature) as String
            
            //            self.storedTemp.append((targetTemperature,ambientTemperature))
            }.animate()
        
        tempIndex++
        if tempIndex >= recordedTemps.count { tempIndex = 0 }
    }

    //MARK: SensorTag
    func bluetoothStateChanged(on: Bool) {
        if on {
            self.sensorTagManager?.startScan()
        }
    }
    
    func didDiscoverSensorTag(sensorTag: SensorTag!) {
        self.sensorTagManager?.stopScan()
        self.sensorTagManager?.connectSensorTag(sensorTag)
        self.navigationItem.rightBarButtonItem?.tintColor = .yellowColor()
    }

    func didConnectSensorTag(sensorTag: SensorTag!) {
        sensorTag.setMovementEnabled(true)
        sensorTag.setMovementNotify(true)
        sensorTag.setMovementPeriod(100)
        navigationItem.rightBarButtonItem?.tintColor = .whiteColor()

        sensorTag.setTemperatureEnabled(true)
        sensorTag.setTemperaturePeriod(100)
        sensorTag.setTemperatureNotify(true)

        delay(1.0) {
            sensorTag.setLuxometerEnabled(false)
            sensorTag.setHumidityEnabled(false)
            sensorTag.setBarometerEnabled(false)
        }
    }

    func sensorTag(sensorTag: SensorTag!, didUpdateAmbientTemperature ambientTemperature: Float, targetTemperature: Float) {
        C4ViewAnimation(duration: 0.5) {
            self.intTemp.strokeEnd = clamp(Double(targetTemperature), 0.0, 30.0) * 0.025
            if targetTemperature >= 25.0 {
                self.intTemp.strokeColor = red
                self.intTempLabel.textColor = .redColor()
            } else {
                self.intTemp.strokeColor = white
                self.intTempLabel.textColor = .whiteColor()
            }
            self.intTempLabel.text = NSString(format: "%2.2f", targetTemperature) as String

            self.extTemp.strokeEnd = clamp(Double(ambientTemperature), 0.0, 30.0) * 0.025
            if ambientTemperature >= 25.0 {
                self.extTemp.strokeColor = red
                self.extTempLabel.textColor = .redColor()
            } else {
                self.extTemp.strokeColor = white
                self.extTempLabel.textColor = .whiteColor()
            }
            self.extTempLabel.text = NSString(format: "%2.2f", ambientTemperature) as String

//            self.storedTemp.append((targetTemperature,ambientTemperature))
        }.animate()
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
        graph.updateRawData(Double(accelerometer.x))
        px = x
        updateSpeed(x)
//        storedSpeed.append((x,Double(accelerometer.x)))
    }

    var velocities = [0.0,0.0,0.0,0.0,0.0]
    var accels = [0.0,0.0,0.0]
    var pv = 0.0
    var pa = 0.0
    var start = NSDate(timeIntervalSinceNow: 0)
    var pt = NSDate.timeIntervalSinceReferenceDate()

    func updateSpeed(var val: Double) {
        
        if abs(val) < 0.015 {
            val = 0.0
        }
        val /= 0.3

        val = clamp(val, -1.0, 1.0)
        val = abs(val)
        let t = C4Transform.makeRotation(val*rotationScale, axis: C4Vector(x: 0, y: 0, z: 1))
        needle.transform = t

        let speed = val*30.0

        speedLabel.text = NSString(format: "%2.1f", speed) as String
    }

    func didDisconnectSensorTag(sensorTag: SensorTag!) {
        self.sensorTagManager?.startScan()
        navigationItem.rightBarButtonItem?.tintColor = .redColor()
    }

    //MARK: Interface
    func createInterface() {
        view.backgroundColor = UIColor(patternImage: bg.uiimage)
        styleNavigationBar()
        addScreenContents()
        positionSpeedNeedle()
        createFlippableBreakTemperatureWithBehaviours()
        createTemperatureAndSpeedVisuals()
        createPopup()
    }
    
    func createTemperatureAndSpeedVisuals() {
        extTemp.hidden = true
        extTemp.fillColor = clear
        extTemp.strokeColor = C4Color(red: 0.93,green: 0.87,blue: 0.85,alpha: 1.0)
        extTemp.lineWidth = 13.0
        extTemp.center = C4Point(210.5,234.5)
        extTemp.strokeEnd = 0
        extTemp.transform = C4Transform.makeRotation(-3*M_PI_4, axis: C4Vector(x: 0, y: 0, z: 1))
        canvas.add(extTemp)
        
        intTemp.hidden = true
        intTemp.fillColor = clear
        intTemp.strokeColor = C4Color(red: 0.89,green: 0.87,blue: 0.85,alpha: 1.0)
        intTemp.lineWidth = 13.0
        intTemp.center = C4Point(210.5,234.5)
        intTemp.strokeEnd = 0.0
        intTemp.transform = C4Transform.makeRotation(-3*M_PI_4, axis: C4Vector(x: 0, y: 0, z: 1))
        canvas.add(intTemp)
        
        extTempLabel.text = "--"
        extTempLabel.textAlignment = .Right
        extTempLabel.textColor = .whiteColor()
        extTempLabel.font = UIFont(name: "Arial", size: 24)
        canvas.add(extTempLabel)

        intTempLabel.text = "--"
        intTempLabel.textAlignment = .Right
        intTempLabel.textColor = .whiteColor()
        intTempLabel.font = UIFont(name: "Arial", size: 24)
        canvas.add(intTempLabel)
        
        speedLabel.text = "--"
        speedLabel.textColor = .whiteColor()
        speedLabel.textAlignment = .Right
        speedLabel.font = UIFont(name: "Arial", size: 36)
        canvas.add(speedLabel)
        
        canvas.add(graph.canvas)
    }

    func addScreenContents() {
        staticContent.origin = C4Point(0,64)
        canvas.add(staticContent)
    }

    func styleNavigationBar() {
        var neutech = UIImage(named: "neutech")
        neutech = neutech?.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: neutech, landscapeImagePhone: neutech, style: .Plain, target: self, action:NSSelectorFromString("reset"))

        var driveOnTitleLogo = UIImage(named: "driveOnTitleLogo")
        self.navigationItem.titleView = UIImageView(image: driveOnTitleLogo)

        var gears = UIImage(named: "gears")
        gearsButton = UIBarButtonItem(image: gears, landscapeImagePhone: gears, style: .Plain, target: nil, action: nil)

        self.navigationItem.rightBarButtonItem = gearsButton
        self.navigationController?.view.add(alertBar.canvas)
        self.navigationItem.rightBarButtonItem?.tintColor = .redColor()
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

        popup.frame = staticContent.bounds
        popupImage.interactionEnabled = true
        popupImage.center = popup.center
        popup.add(popupImage)
        popup.origin = staticContent.origin
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
//        println("storedSpeed")
//        println(storedSpeed)
//        println()
//        
//        println("storedTemp")
//        println(storedTemp)
//        println()
        
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
    
    let recordedSpeeds : [(Double,Double)] = [(0.0015380859375, 0.015380859375), (0.00306884765625, 0.016845703125), (0.004153564453125, 0.013916015625), (0.0052274658203125, 0.014892578125), (0.00619397705078125, 0.014892578125), (0.00747887622070313, 0.01904296875), (0.00826907453613281, 0.015380859375), (0.00880935458251953, 0.013671875), (0.00941767693676758, 0.014892578125), (0.0101604795555908, 0.016845703125), (0.0107557597250317, 0.01611328125), (0.0113159259400286, 0.016357421875), (0.0115271067835257, 0.013427734375), (0.0120833804801731, 0.01708984375), (0.0124131283696558, 0.015380859375), (0.0125145889701902, 0.013427734375), (0.0127523878856712, 0.014892578125), (0.0131617194096041, 0.016845703125), (0.0133836334061437, 0.015380859375), (0.0136321841280293, 0.015869140625), (0.0138558797777264, 0.015869140625), (0.0140572058624538, 0.015869140625), (0.0143116415262084, 0.0166015625), (0.0140279383110875, 0.011474609375), (0.0140899882299788, 0.0146484375), (0.0139993487819809, 0.01318359375), (0.0142595701537828, 0.0166015625), (0.0142008006384045, 0.013671875), (0.0144164627620641, 0.016357421875), (0.0147082149233577, 0.017333984375), (0.0150928621810219, 0.0185546875), (0.0151704900254197, 0.015869140625), (0.0149473863353777, 0.012939453125), (0.01481983520184, 0.013671875), (0.014949179806656, 0.01611328125), (0.0154073868259904, 0.01953125), (0.0155268043933913, 0.0166015625), (0.0153901395790522, 0.01416015625), (0.015486867808647, 0.016357421875), (-0.0271751002222177, -0.4111328125), (-0.0380806370749959, -0.13623046875), (-0.0396680811799963, -0.053955078125), (-0.0635821324369967, -0.27880859375), (-0.056882122318297, 0.00341796875), (-0.0706763319614673, -0.19482421875), (-0.0596047925153206, 0.0400390625), (-0.0522282976387885, 0.01416015625), (-0.0573570303749097, -0.103515625), (-0.0313576554624187, 0.20263671875), (-0.00808028835367685, 0.201416015625), (0.0341339904816908, 0.4140625), (0.0504471539335218, 0.197265625), (0.0576094697901696, 0.1220703125), (0.0384940306236526, -0.133544921875), (0.0262217759987874, -0.084228515625), (0.0287997937114086, 0.052001953125), (-0.00413389659723223, -0.300537109375), (0.020669141499991, 0.243896484375), (0.00705437578749189, -0.115478515625), (-0.0277086789787573, -0.340576171875), (-0.0314563657683816, -0.065185546875), (-0.0365382682540434, -0.082275390625), (-0.00280631642863907, 0.30078125), (0.0151256824017248, 0.176513671875), (-0.0588234092759476, -0.724365234375), (-0.00311196678585288, 0.498291015625), (-0.0468925669822676, -0.44091796875), (-0.0452306540340408, -0.0302734375), (-0.0422700886306368, -0.015625), (-0.0443174938300731, -0.062744140625), (-0.0410576194470658, -0.01171875), (0.0340686503101408, 0.710205078125), (0.0425758477791267, 0.119140625), (-0.00137900262378596, -0.39697265625), (-0.0128621961114074, -0.1162109375), (-0.00693730462526663, 0.04638671875), (-0.04047208978774, -0.34228515625), (-0.078710037058966, -0.4228515625), (-0.146351728665569, -0.755126953125), (-0.137063235486512, -0.053466796875), (-0.184050271312861, -0.60693359375), (-0.184419658244075, -0.187744140625), (-0.150767731482168, 0.152099609375), (-0.138693888021451, -0.030029296875), (-0.104804967969306, 0.2001953125), (-0.118323494609875, -0.239990234375), (-0.0723358717113877, 0.341552734375), (-0.0663962298527489, -0.012939453125), (-0.044375747492474, 0.15380859375), (0.0157747178817734, 0.55712890625), (0.0331913867185961, 0.18994140625), (0.126576349609236, 0.967041015625), (0.134963636523313, 0.21044921875), (0.158381335370982, 0.369140625), (0.200355701833883, 0.578125), (0.173581850400495, -0.0673828125), (0.154368196610446, -0.0185546875), (0.153018291011901, 0.140869140625), (0.171920563473211, 0.342041015625), (0.13588085087589, -0.1884765625), (0.139358195475801, 0.170654296875), (0.146809094678221, 0.2138671875), (0.145946544585399, 0.13818359375), (0.111527671376859, -0.1982421875), (0.083431544864173, -0.16943359375), (0.0886137810027557, 0.13525390625), (0.0959877544649801, 0.162353515625), (0.0530637837059821, -0.333251953125), (0.0438755693978839, -0.038818359375), (0.0364362546455955, -0.030517578125), (0.010893215118536, -0.218994140625), (0.00365154985668236, -0.0615234375), (-0.0107761051289859, -0.140625), (-0.00278931492858729, 0.069091796875), (-0.0161822584357286, -0.13671875), (-0.0163706732171557, -0.01806640625), (-0.00413790277044013, 0.10595703125), (-6.20031183961177e-05, 0.03662109375), (0.0216727128184435, 0.21728515625), (0.0524155977865991, 0.3291015625), (0.0825011864454392, 0.353271484375), (0.0973711849883953, 0.231201171875), (0.0842893399270558, -0.033447265625), (0.12522564030935, 0.49365234375), (0.139900341903415, 0.27197265625), (0.156134917088074, 0.30224609375), (0.176678651941766, 0.361572265625), (0.16838578674759, 0.09375), (0.155917325260331, 0.043701171875), (0.142522858359298, 0.02197265625), (0.121312564710868, -0.069580078125), (0.0730240816772811, -0.361572265625), (0.047215814134553, -0.18505859375), (0.0196670842835977, -0.228271484375), (0.00202654773023793, -0.15673828125), (-0.0117747398552859, -0.135986328125), (-0.00576328149475727, 0.04833984375), (-0.0162709377202815, -0.11083984375), (-0.0156448205107534, -0.010009765625), (-0.0340266275221781, -0.199462890625), (-0.0492030663324603, -0.185791015625), (-0.0456987753242142, -0.01416015625), (-0.0589999915417928, -0.1787109375), (-0.0414056564501135, 0.116943359375), (-0.0601166533051022, -0.228515625), (-0.036331550474592, 0.177734375), (-0.0113605048021328, 0.21337890625), (0.0111866784905805, 0.214111328125), (0.0287691825165225, 0.18701171875), (0.0489147252023702, 0.230224609375), (0.0594773542446332, 0.154541015625), (0.0652727828826699, 0.117431640625), (0.0699759733444029, 0.1123046875), (0.0546043525724626, -0.083740234375), (0.0446029016902163, -0.04541015625), (0.0309873380836947, -0.091552734375), (0.00830852615032524, -0.19580078125), (-0.00685338115220729, -0.143310546875), (-0.0152256602244866, -0.090576171875), (-0.0196357113895379, -0.059326171875), (-0.0250451871255841, -0.07373046875), (-0.0301578559130257, -0.076171875), (-0.0418881640717231, -0.1474609375), (-0.0531534492270508, -0.154541015625), (-0.0613879089918457, -0.135498046875), (-0.0451416962176612, 0.10107421875), (-0.0236353390958951, 0.169921875), (0.0102223354386945, 0.31494140625), (0.025704008144825, 0.1650390625), (0.0614636854553425, 0.38330078125), (0.0780468090973083, 0.227294921875), (0.0774198625625774, 0.07177734375), (0.0765138138063197, 0.068359375), (0.0981837214881877, 0.293212890625), (0.115855583714369, 0.27490234375), (0.150778814405432, 0.465087890625), (0.163679448589889, 0.27978515625), (0.1472870896684, -0.000244140625), (0.13756326351406, 0.050048828125), (0.103836234037654, -0.19970703125), (0.0557328840713886, -0.377197265625), (0.0138802987892497, -0.36279296875), (-0.00567179358967525, -0.181640625), (-0.0239522704807077, -0.1884765625), (-0.0273675903076369, -0.05810546875), (-0.0462861047143732, -0.216552734375), (-0.0366281973679359, 0.05029296875), (-0.0714419401311423, -0.384765625), (-0.0807772383055281, -0.164794921875), (-0.0680120144749753, 0.046875), (-0.0747606177149778, -0.135498046875), (-0.06118104031848, 0.06103515625), (-0.082260201911632, -0.27197265625), (-0.0758164082829688, -0.017822265625), (-0.0821996112046719, -0.1396484375), (-0.0426319938342047, 0.3134765625), (-0.0390035600757843, -0.00634765625), (0.0230510928067942, 0.58154296875), (0.0187928585261148, -0.01953125), (0.0840278304860033, 0.671142578125), (0.083486375562403, 0.07861328125), (0.132754925506163, 0.576171875), (0.150436464205546, 0.3095703125), (0.140983638097492, 0.055908203125), (0.158257344600243, 0.313720703125), (0.139697235140218, -0.02734375), (0.142719699126197, 0.169921875), (0.114800268276077, -0.136474609375), (0.124877858635969, 0.215576171875), (0.133825619647372, 0.21435546875), (0.101082706120135, -0.193603515625), (0.108479318320622, 0.175048828125), (0.0981196677385594, 0.0048828125), (0.110451255652203, 0.221435546875), (0.143693239461983, 0.44287109375), (0.176784853015785, 0.474609375), (0.171386641151706, 0.122802734375), (0.173974539536536, 0.197265625), (0.189291929332882, 0.3271484375), (0.134937931712094, -0.354248046875), (0.110848435415885, -0.10595703125), (0.0879227715617961, -0.118408203125), (0.0656783459681165, -0.134521484375), (0.0315226207463048, -0.27587890625), (0.0625500461716744, 0.341796875), (0.0710411353045069, 0.1474609375), (0.0793667092740562, 0.154296875), (0.0695501555341506, -0.018798828125), (0.0616185774807356, -0.009765625), (0.049328790045162, -0.061279296875), (0.0503529422906458, 0.0595703125), (0.0514699918115812, 0.0615234375), (0.0665866645054231, 0.20263671875), (0.0805090527423808, 0.205810546875), (0.0856173271556427, 0.131591796875), (0.0893602819400784, 0.123046875), (0.0878949568710706, 0.07470703125), (0.0868691330589636, 0.07763671875), (0.0892417900655672, 0.110595703125), (0.0833937829340105, 0.03076171875), (0.0721247171406094, -0.029296875), (0.0675733782390485, 0.026611328125), (0.0616705326026436, 0.008544921875), (0.0566753543423793, 0.01171875), (0.0530830142206414, 0.020751953125), (0.0488001034235772, 0.01025390625), (0.0448722415187195, 0.009521484375), (0.0422404861168475, 0.0185546875), (0.0136756171926628, -0.243408203125), (-0.00702788202660349, -0.193359375), (0.0436016639885569, 0.499267578125), (0.0562580991522012, 0.170166015625), (0.0760717423619811, 0.25439453125), (0.096125700938283, 0.276611328125), (0.134975044906955, 0.484619140625), (0.105803712291259, -0.15673828125), (0.101912794187133, 0.06689453125), (0.14470003039342, 0.52978515625), (0.131157761729078, 0.00927734375), (0.12678221993117, 0.08740234375), (0.115129388563053, 0.01025390625), (0.154641840331748, 0.51025390625), (0.134368085986073, -0.048095703125), (0.171590457074966, 0.506591796875), (0.175281020742469, 0.20849609375), (0.168666004605722, 0.109130859375), (0.15712166977015, 0.05322265625), (0.088186846543135, -0.5322265625), (0.0425029275138215, -0.36865234375), (0.00236396288743937, -0.35888671875), (-0.0229945037138046, -0.251220703125), (-0.0351481783424241, -0.14453125), (-0.0583667589456817, -0.267333984375), (-0.0649324268011135, -0.1240234375), (-0.0602946528710022, -0.0185546875), (-0.058049367271402, -0.037841796875), (-0.0720930633567618, -0.198486328125), (-0.0475253585835856, 0.173583984375), (-0.043773799287727, -0.010009765625), (-0.0274335287339543, 0.11962890625), (-0.0138991602355589, 0.10791015625), (0.000772005787996998, 0.1328125), (-0.0262583197908027, -0.26953125), (-0.0417721362492224, -0.181396484375), (-0.0253146491868002, 0.122802734375), (0.0133984563568798, 0.36181640625), (0.0337871263461919, 0.21728515625), (0.0429328277740727, 0.125244140625), (0.0579510684341654, 0.193115234375), (0.0898268600282489, 0.376708984375), (0.094345150587924, 0.135009765625), (0.0636459870916316, -0.212646484375), (0.0643614665074684, 0.07080078125), (0.0781401636067216, 0.2021484375), (0.0949843503710495, 0.24658203125), (0.124719313771445, 0.392333984375), (0.1237708198943, 0.115234375), (0.11393280040487, 0.025390625), (0.125024871926883, 0.224853515625), (0.123240158171695, 0.107177734375), (0.119631962667025, 0.087158203125), (0.100027164837823, -0.076416015625), (0.0779150733540405, -0.12109375), (0.0515200503936364, -0.18603515625), (0.0215633578542728, -0.248046875), (-0.0105734466811545, -0.2998046875), (-0.00429149263803905, 0.05224609375), (-0.00574222618673514, -0.018798828125), (-0.00592483950556163, -0.007568359375), (0.00135709756999454, 0.06689453125), (0.000781934687995082, -0.00439453125), (-0.0215618837808044, -0.22265625), (-0.021895929777724, -0.02490234375), (-0.0569866102374516, -0.372802734375), (-0.0613465429637064, -0.1005859375), (-0.0504511464798358, 0.047607421875), (-0.0194538833943522, 0.259521484375), (-0.00935419817991699, 0.08154296875), (-0.000386551799425296, 0.080322265625), (0.0108581580680172, 0.112060546875), (-0.00761047023878449, -0.173828125), (-0.014661923214906, -0.078125), (-0.0143676058934154, -0.01171875), (-0.0103673687415739, 0.025634765625), (-0.00803668655491651, 0.012939453125), (-0.0168277444619249, -0.095947265625), (0.0414224127967676, 0.565673828125), (0.0836668902670909, 0.4638671875), (0.0674632871778818, -0.078369140625), (-0.0123787446649064, -0.73095703125), (-0.0215412608234158, -0.10400390625), (0.00143806057142581, 0.208251953125), (0.0402102701392832, 0.38916015625), (0.0299392431253549, -0.0625), (0.0405195375628194, 0.1357421875), (0.0265310603690375, -0.099365234375), (0.0551035402696337, 0.312255859375), (0.0421713112426704, -0.07421875), (0.0394922660559033, 0.015380859375), (0.045821359762813, 0.102783203125), (0.0570107081615317, 0.15771484375), (0.0239170592203785, -0.27392578125), (-0.0329180060766593, -0.54443359375), (0.0203737945310066, 0.5), (-0.000779795859594052, -0.191162109375), (0.0505921290388654, 0.512939453125), (0.0807624083224788, 0.352294921875), (0.0988580424902309, 0.26171875), (0.0633863007412079, -0.255859375), (0.0905925925420871, 0.33544921875), (0.112661262975378, 0.311279296875), (0.138138300740341, 0.367431640625), (0.146907478478806, 0.225830078125), (0.155312433755926, 0.23095703125), (0.165782166942833, 0.260009765625), (0.13926742681105, -0.099365234375), (0.117039902879945, -0.0830078125), (0.0965956782169504, -0.08740234375), (0.0885962666452554, 0.0166015625), (0.0811282415432299, 0.013916015625), (0.0731619017639069, 0.00146484375), (0.0677500084625162, 0.01904296875), (0.0617562576162646, 0.0078125), (0.0570698896671381, 0.014892578125), (0.0517535257004243, 0.00390625), (0.0480430168803819, 0.0146484375), (0.0440932073798437, 0.008544921875), (0.0408801757043593, 0.011962890625), (0.0382814159464234, 0.014892578125), (0.0357472196642811, 0.012939453125), (0.0329049195728529, 0.00732421875), (0.0305421619905677, 0.00927734375), (0.0283912661040109, 0.009033203125), (0.0264066316811098, 0.008544921875), (0.0249378435129988, 0.01171875), (0.0235182779116989, 0.0107421875), (0.021996528245529, 0.00830078125), (0.0208222660459761, 0.01025390625), (0.0193992191288785, 0.006591796875), (0.0182649612784907, 0.008056640625), (0.0175370979631416, 0.010986328125), (0.0167599506668274, 0.009765625), (0.0163290727876447, 0.012451171875), (0.0158924545713802, 0.011962890625), (0.0156215684892422, 0.01318359375), (0.015035974140318, 0.009765625), (0.0148751501637862, 0.013427734375), (0.0145595101474076, 0.01171875), (0.0145684028826668, 0.0146484375), (0.0143810938444001, 0.0126953125), (0.0143101719599601, 0.013671875), (0.0138068891389641, 0.00927734375), (0.0129144814750677, 0.0048828125), (0.0125507677025609, 0.00927734375), (0.0123454956198048, 0.010498046875), (0.0121851648078244, 0.0107421875), (0.0120896952020419, 0.01123046875), (0.0119305303693377, 0.010498046875), (0.011884938269904, 0.011474609375), (0.0119171475679136, 0.01220703125), (0.0119705499986222, 0.012451171875), (0.01155474499876, 0.0078125), (0.010618997061384, 0.002197265625), (0.0109242848552456, 0.013671875), (0.010784004807221, 0.009521484375), (0.0109263074514989, 0.01220703125), (0.010785825143849, 0.009521484375), (0.0107814613794641, 0.0107421875), (0.0106310496165177, 0.00927734375), (0.0108130618423659, 0.012451171875), (0.0109524587831294, 0.01220703125), (0.0112244004048164, 0.013671875), (0.0112494213018348, 0.011474609375), (0.0112719401091513, 0.011474609375), (0.0112922070357362, 0.011474609375), (0.0112127910196626, 0.010498046875), (0.0107995197301963, 0.007080078125), (0.0109402708821767, 0.01220703125), (0.010676321918959, 0.00830078125), (0.0112688459770631, 0.0166015625), (0.0111673520043568, 0.01025390625), (0.0110271793039211, 0.009765625), (0.010998680123529, 0.0107421875), (0.0111439292986761, 0.012451171875), (0.0103713332438085, 0.00341796875), (0.0102131061694276, 0.0087890625), (0.0102416002399849, 0.010498046875), (0.0106334558409864, 0.01416015625), (0.0103025321318878, 0.00732421875), (0.010615052356199, 0.013427734375), (0.0103592111830791, 0.008056640625), (0.0102510244397712, 0.00927734375), (0.0103733829332941, 0.011474609375), (0.0104102633899646, 0.0107421875), (0.0101993151759682, 0.00830078125), (0.0104733289708714, 0.012939453125), (0.0108420116987842, 0.01416015625), (0.0111005839664058, 0.013427734375), (0.0109182599447652, 0.00927734375), (0.0109250667627887, 0.010986328125), (0.0105161538365098, 0.0068359375), (0.0101237181403589, 0.006591796875), (0.010112322888823, 0.010009765625), (0.0102729655999407, 0.01171875), (0.0105152002899466, 0.0126953125), (0.0103670005734519, 0.009033203125), (0.0104045192661068, 0.0107421875), (0.0108777392144961, 0.01513671875), (0.0108397699805465, 0.010498046875), (0.0104638007949918, 0.007080078125), (0.0102963269654926, 0.0087890625), (0.0103409130189434, 0.0107421875), (0.010332212342049, 0.01025390625), (0.0107882489203441, 0.014892578125), (0.0103441896533097, 0.00634765625), (0.0107257863129788, 0.01416015625), (0.0106785983066809, 0.01025390625), (0.0107826134760128, 0.01171875), (0.0109006411909115, 0.011962890625), (0.0106406551968204, 0.00830078125), (0.0103578396771383, 0.0078125)]
    
    let recordedTemps : [(Float,Float)] = [(19.0, 25.5), (18.9375, 25.5), (19.0938, 25.5), (18.8438, 25.5), (18.7812, 25.5), (18.7812, 25.5), (19.125, 25.5312), (18.0, 25.5312), (19.8125, 25.5312), (20.0312, 25.5312), (19.6875, 25.5312), (19.5312, 25.5312), (19.4688, 25.5312), (19.5312, 25.5312), (19.875, 25.5312), (19.6562, 25.5312), (19.4688, 25.5312), (19.5938, 25.5312), (19.5, 25.5312), (17.9062, 25.5312), (18.3125, 25.5312), (18.9375, 25.5312), (19.5, 25.5312), (19.5938, 25.5625), (19.4688, 25.5312), (18.9062, 25.5312), (19.2188, 25.5625), (19.25, 25.5625), (19.1875, 25.5625), (19.5625, 25.5625), (19.2812, 25.5625), (18.4375, 25.5625), (19.5938, 25.5625), (19.5312, 25.5625), (19.75, 25.5625), (19.5, 25.5625), (19.5625, 25.5625), (19.5938, 25.5625), (19.5312, 25.5625), (19.5938, 25.5625), (19.4688, 25.5625), (19.5312, 25.5625), (19.4688, 25.5625), (19.5312, 25.5625), (19.4688, 25.5625)]
 }