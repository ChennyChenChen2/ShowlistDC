//
//  SLDCCalendarHeader.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 10/10/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import UIKit
import JTAppleCalendar

class SLDCCalendarHeader : JTAppleHeaderView {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    weak var delegate: SLDCCalendarHeaderDelegate?
    
    @IBAction func rightArrowPressed(_ sender: Any) {
        if let theDelegate = self.delegate {
            theDelegate.didPressRightArrow()
        }
    }
    
    @IBAction func leftArrowPressed(_ sender: Any) {
        if let theDelegate = self.delegate {
            theDelegate.didPressLeftArrow()
        }
    }
    
    @IBAction func refreshButtonPresed(_ sender: Any) {
        
        /*
         var popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("NewCategory") as UIViewController
         var nav = UINavigationController(rootViewController: popoverContent)
         nav.modalPresentationStyle = UIModalPresentationStyle.Popover
         var popover = nav.popoverPresentationController
         popoverContent.preferredContentSize = CGSizeMake(50,50)
         popover.delegate = self
         popover.sourceView = sender
         popover.sourceRect = sender.bounds
         
         self.presentViewController(nav, animated: true, completion: nil)
 */
    }
    
}

protocol SLDCCalendarHeaderDelegate: class {
    func didPressRightArrow()
    func didPressLeftArrow()
}
