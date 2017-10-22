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
}

protocol SLDCCalendarHeaderDelegate: class {
    func didPressRightArrow()
    func didPressLeftArrow()
}
