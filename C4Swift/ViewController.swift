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

class ViewController: C4CanvasController, UIAlertViewDelegate {
    let productionPlanningRed = C4Image("productionPlanningRed")
    let productionPlanningBlue = C4Image("productionPlanningBlue")
    let productionPlanningPopup = C4Image("productionPlanningPopup")
    let primaryEngineAssembly = C4Image("primaryEngineAssembly")
    let cylinderHeadPopup = C4Image("cylinderHeadPopup")
    let cylinderHeadPopupLines = C4Image("cylinderHeadPopupLines")
    var cylinderHeadPopupLinesMask = C4Rectangle()
    let primaryEngineAssemblySourcePopup = C4Image("primaryEngineAssemblySourcePopup")
    let primaryEngineAssemblySourcePopupLine = C4Image("primaryEngineAssemblySourcePopupLine")
    var primaryEngineAssemblySourcePopupLineMask = C4Rectangle()
    let datePopup = C4Image("datePopup")
    let alternativeSuppliers = C4Image("alternativeSuppliers")
    let alternativeSuppliersList = C4Image("alternativeSuppliersList")
    let alternativeSuppliersScrollview = UIScrollView()
    let densoLine = C4Line([C4Point(),C4Point(367,0)])
    let monarkLine = C4Line([C4Point(),C4Point(349,0)])
    let densoMark = C4Image("checkMark")
    let monarkMark = C4Image("checkMark")
    let monarkDay = C4Image("monarkDay")
    let densoDays = C4Image("densoDays")
    
    override func setup() {
        self.setupProductionPlanning()
        self.setupPrimaryEngineAssembly()
        self.setupAlternativeSuppliers()
    }
    
    func setupAlternativeSuppliers() {
        alternativeSuppliers.interactionEnabled = true
        alternativeSuppliers.origin = C4Point(canvas.width,0)
        canvas.add(alternativeSuppliers)
        
        alternativeSuppliersScrollview.frame = CGRectMake(0, 100, CGFloat(canvas.width), CGFloat(alternativeSuppliersList.height))
        alternativeSuppliersScrollview.contentSize = CGSizeMake(CGFloat(alternativeSuppliersList.width),1)
        alternativeSuppliersScrollview.add(alternativeSuppliersList)
        alternativeSuppliersScrollview.showsHorizontalScrollIndicator = false
        alternativeSuppliers.add(alternativeSuppliersScrollview)

        monarkLine.origin = C4Point(373,562)
        monarkLine.strokeColor = C4Color(red: 0.47, green: 0.71, blue: 0.13, alpha: 1.0)
        monarkLine.lineWidth = 10
        monarkLine.lineCap = .Round
        alternativeSuppliers.add(monarkLine)
    
        densoLine.origin = C4Point(411,520)
        densoLine.opacity = 0.0
        densoLine.strokeColor = monarkLine.strokeColor
        densoLine.lineWidth = 10
        densoLine.lineCap = .Round
        alternativeSuppliers.add(densoLine)

        let monarkButton = C4Rectangle(frame: C4Rect(0,0,293,alternativeSuppliersList.height))
        monarkButton.fillColor = clear
        monarkButton.strokeColor = clear
        alternativeSuppliersScrollview.add(monarkButton)

        let densoButton = C4Rectangle(frame: C4Rect(293,0,296,alternativeSuppliersList.height))
        densoButton.fillColor = clear
        densoButton.strokeColor = clear
        alternativeSuppliersScrollview.add(densoButton)
        
        monarkMark.center = C4Point(273,9.5)
        alternativeSuppliersScrollview.add(monarkMark)
        densoMark.center = C4Point(570,9.5)
        densoMark.hidden = true
        alternativeSuppliersScrollview.add(densoMark)
        
        monarkDay.origin = C4Point(28,440)
        alternativeSuppliers.add(monarkDay)
        
        densoDays.origin = C4Point(28,440)
        densoDays.opacity = 0.0
        alternativeSuppliers.add(densoDays)

        let createRequisitionButton = C4Rectangle(frame: C4Rect(alternativeSuppliers.width-192,alternativeSuppliers.height-44,192,44))
        createRequisitionButton.fillColor = clear
        createRequisitionButton.strokeColor = clear
        alternativeSuppliers.add(createRequisitionButton)
        
        createRequisitionButton.addTapGestureRecognizer { (location, state) -> () in
            let alert = UIAlertView(title: "Requisition has been created.", message: "", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "ok")
            alert.show()
            alert.delegate = self
        }
        
        densoButton.addTapGestureRecognizer { (location, state) -> () in
            C4ViewAnimation(duration: 0) {
                self.monarkMark.hidden = true
                self.densoMark.hidden = false
            }.animate()
            
            C4ViewAnimation(duration: 0.25) {
                self.densoLine.opacity = 1.0
                self.densoDays.opacity = 1.0
                self.monarkLine.opacity = 0.0
                self.monarkDay.opacity = 0.0
            }.animate()
        }

        monarkButton.addTapGestureRecognizer { (location, state) -> () in
            C4ViewAnimation(duration: 0) {
                self.monarkMark.hidden = false
                self.densoMark.hidden = true
            }.animate()
            
            C4ViewAnimation(duration: 0.25) {
                self.densoLine.opacity = 0.0
                self.densoDays.opacity = 0.0
                self.monarkLine.opacity = 1.0
                self.monarkDay.opacity = 1.0
            }.animate()
        }

    }
    
    func setupPrimaryEngineAssembly() {
        self.primaryEngineAssembly.interactionEnabled = true
        self.primaryEngineAssembly.origin = C4Point(canvas.width,0)
        canvas.add(primaryEngineAssembly)
        
        setupCylinderHeadPopup()
        setupPrimaryEngineAssemblyPopup()
        setupDatePopup()
        
        self.primaryEngineAssembly.addTapGestureRecognizer { location, state in
            if self.datePopup.opacity > 0.0 {
                self.hide(self.datePopup)
            }
            if self.primaryEngineAssemblySourcePopup.opacity > 0.0 {
                self.hide(self.primaryEngineAssemblySourcePopup)
                delay(0.5) {
                    C4ViewAnimation(duration: 0.0) {
                        self.primaryEngineAssemblySourcePopupLineMask.origin = C4Point(-self.primaryEngineAssemblySourcePopupLine.width,0)
                        }.animate()
                }
            }
            if self.cylinderHeadPopup.opacity > 0.0 {
                self.hide(self.cylinderHeadPopup)
                delay(0.5) {
                    C4ViewAnimation(duration: 0.0) {
                        self.cylinderHeadPopupLinesMask.origin = C4Point(-self.cylinderHeadPopupLinesMask.width,0)
                    }.animate()
                }
            }
        }
    }
    
    func setupDatePopup() {
        datePopup.interactionEnabled = true
        datePopup.origin = C4Point(462,334)
        datePopup.opacity = 0.0
        datePopup.shadow.opacity = 0.25
        datePopup.shadow.offset = C4Size(2,2)

        let datePopupButton = C4Rectangle(frame: C4Rect(750,370,274,66))
        datePopupButton.fillColor = clear
        datePopupButton.strokeColor = clear
        datePopupButton.addTapGestureRecognizer { (location, state) -> () in
            self.reveal(self.datePopup)
        }
        
        let datePopupDetailsButton = C4Rectangle(frame: C4Rect(datePopup.width-180,datePopup.height-40,166,40))
        datePopup.add(datePopupDetailsButton)
        datePopupDetailsButton.fillColor = clear
        datePopupDetailsButton.strokeColor = clear
        datePopupDetailsButton.addTapGestureRecognizer { location, state in
            self.push(self.alternativeSuppliers)
            delay(0.5) {
                self.pop(self.primaryEngineAssembly)
                self.hide(self.datePopup)
                self.hide(self.cylinderHeadPopup)
                self.hide(self.primaryEngineAssemblySourcePopup)
            }
        }
        
        primaryEngineAssembly.add(datePopupButton)
        primaryEngineAssembly.add(datePopup)
    }
    
    func setupCylinderHeadPopup() {
        let cylinderHeadButton = C4Rectangle(frame: C4Rect(0,107,346,66))
        cylinderHeadButton.fillColor = clear
        cylinderHeadButton.strokeColor = clear
        
        cylinderHeadButton.addTapGestureRecognizer { location, state in
            self.reveal(self.cylinderHeadPopup)
            delay(0.5) {
                C4ViewAnimation(duration: 0.66) {
                    self.cylinderHeadPopupLinesMask.origin = C4Point()
                    }.animate()
            }
        }
        
        primaryEngineAssembly.add(cylinderHeadButton)
        
        cylinderHeadPopup.origin = C4Point(554,70)
        cylinderHeadPopup.opacity = 0.0
        cylinderHeadPopup.shadow.opacity = 0.25
        cylinderHeadPopup.shadow.offset = C4Size(2,2)
        primaryEngineAssembly.add(cylinderHeadPopup)
        
        cylinderHeadPopupLines.origin = C4Point(60,110)
        cylinderHeadPopup.add(cylinderHeadPopupLines)
        
        cylinderHeadPopupLinesMask = C4Rectangle(frame: cylinderHeadPopupLines.bounds)
        cylinderHeadPopupLinesMask.origin = C4Point(-cylinderHeadPopupLinesMask.width,0)
        cylinderHeadPopupLines.layer?.mask = cylinderHeadPopupLinesMask.layer
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.productionPlanningBlue.hidden = false
        delay(0.25) {
            self.pop(self.alternativeSuppliers)
        }
        delay(0.75) {
            self.monarkMark.hidden = false
            self.densoMark.hidden = true
            self.densoLine.opacity = 0.0
            self.densoDays.opacity = 0.0
            self.monarkLine.opacity = 1.0
            self.monarkDay.opacity = 1.0
            self.alternativeSuppliersScrollview.contentOffset = CGPointZero
        }
    }
    
    func setupPrimaryEngineAssemblyPopup() {
        primaryEngineAssemblySourcePopup.origin = C4Point(436,278)
        primaryEngineAssemblySourcePopup.opacity = 0.0
        primaryEngineAssemblySourcePopup.shadow.opacity = 0.25
        primaryEngineAssemblySourcePopup.shadow.offset = C4Size(2,2)
        
        primaryEngineAssemblySourcePopup.add(primaryEngineAssemblySourcePopupLine)
        primaryEngineAssemblySourcePopupLine.origin = C4Point(182,132)
        
        primaryEngineAssemblySourcePopupLineMask = C4Rectangle(frame: primaryEngineAssemblySourcePopupLine.bounds)
        primaryEngineAssemblySourcePopupLineMask.origin = C4Point(-primaryEngineAssemblySourcePopupLineMask.width,0)
        primaryEngineAssemblySourcePopupLine.layer?.mask = primaryEngineAssemblySourcePopupLineMask.layer
        
        let primaryEngineAssemblySourceButton = C4Rectangle(frame: C4Rect(346,372,134,66))
        primaryEngineAssemblySourceButton.fillColor = clear
        primaryEngineAssemblySourceButton.strokeColor = clear
        
        primaryEngineAssemblySourceButton.addTapGestureRecognizer { location, state in
            self.reveal(self.primaryEngineAssemblySourcePopup)
            delay(0.5) {
                C4ViewAnimation(duration: 0.66) {
                    self.primaryEngineAssemblySourcePopupLineMask.origin = C4Point()
                }.animate()
            }
        }
        
        primaryEngineAssembly.add(primaryEngineAssemblySourceButton)
        primaryEngineAssembly.add(primaryEngineAssemblySourcePopup)

    }
    
    func setupProductionPlanning() {
        productionPlanningRed.interactionEnabled = true
        self.productionPlanningPopup.opacity = 0.0
        self.productionPlanningPopup.shadow.opacity = 0.25
        self.productionPlanningPopup.shadow.offset = C4Size(2,2)
        self.productionPlanningPopup.origin = C4Point(706,110)
        
        self.productionPlanningPopup.interactionEnabled = true
        
        self.title = "Plan It"
        let img = UIImage(named: "backButton")
        let orig = img?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: orig, landscapeImagePhone: orig, style: UIBarButtonItemStyle.Plain, target: self, action:NSSelectorFromString("reset"))
        self.canvas.backgroundColor = white
        
        self.canvas.add(productionPlanningRed)
        
        let productionPlanningRedButton = C4Rectangle(frame: C4Rect(615,224,100,24))
        productionPlanningRedButton.fillColor = clear
        productionPlanningRedButton.strokeColor = clear
        
        productionPlanningRed.add(productionPlanningRedButton)
        productionPlanningRedButton.addTapGestureRecognizer { location, state in
            self.reveal(self.productionPlanningPopup)
        }
        
        self.productionPlanningRed.addTapGestureRecognizer { location, state in
            if self.productionPlanningPopup.opacity > 0.0 {
                self.hide(self.productionPlanningPopup)
            }
        }
        
        productionPlanningRed.add(productionPlanningPopup)
        
        let productionPlanningPopupButton = C4Rectangle(frame: C4Rect(productionPlanningPopup.width-137,productionPlanningPopup.height-40,137,40))
        productionPlanningPopupButton.fillColor = clear
        productionPlanningPopupButton.strokeColor = clear
        productionPlanningPopup.add(productionPlanningPopupButton)
        productionPlanningPopupButton.addTapGestureRecognizer { location, state in
            self.push(self.primaryEngineAssembly)
            delay(0.5) {
                self.productionPlanningPopup.opacity = 0.0
            }
        }
        
        productionPlanningBlue.interactionEnabled = true
        productionPlanningBlue.origin = C4Point(613,220)
        productionPlanningBlue.hidden = true
        productionPlanningRed.add(productionPlanningBlue)
    }
    
    func hide(img: C4Image) {
        C4ViewAnimation(duration: 0.25, animations: { () -> Void in
           img.opacity = 0.0
        }).animate()
    }
    
    func reveal(img: C4Image) {
        C4ViewAnimation(duration: 0.25, animations: { () -> Void in
            img.opacity = 1.0
        }).animate()
    }
    
    func push(img: C4Image) {
        C4ViewAnimation(duration: 0.25, animations: { () -> Void in
            img.origin = C4Point()
        }).animate()
    }
    
    func pop(img: C4Image) {
        C4ViewAnimation(duration: 0.25, animations: { () -> Void in
            img.origin = C4Point(self.canvas.width,0)
        }).animate()
    }
    
    func reset() {
        self.pop(self.primaryEngineAssembly)
        self.pop(self.alternativeSuppliers)
        self.productionPlanningBlue.hidden = true
        self.hide(self.datePopup)
        self.hide(self.primaryEngineAssemblySourcePopup)
        self.hide(self.cylinderHeadPopup)
        self.hide(self.productionPlanningPopup)
        self.monarkMark.hidden = false
        self.densoMark.hidden = true
        self.densoLine.opacity = 0.0
        self.densoDays.opacity = 0.0
        self.monarkLine.opacity = 1.0
        self.monarkDay.opacity = 1.0
        self.alternativeSuppliersScrollview.contentOffset = CGPointZero
    }
}