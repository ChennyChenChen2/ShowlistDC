//
//  SLDCCalendarCell.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 9/11/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import UIKit
import JTAppleCalendar

class SLDCCalendarCell: JTAppleDayCellView {

    @IBOutlet weak var dayLabel: UILabel!
    
//    @IBOutlet weak var dayHighlightView: UIView?
    
    @IBOutlet weak var dayHasEventsView: UIView!
    
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
