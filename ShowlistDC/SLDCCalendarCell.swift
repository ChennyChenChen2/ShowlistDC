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
    
    var normalDayColor = UIColor(colorWithHexValue: 0x574865)
    var weekendDayColor = UIColor(colorWithHexValue: 0xECEAED)
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate) {
        // Setup Cell text
        dayLabel.text =  cellState.text
        
        dayHasEventsView.layer.cornerRadius = dayHasEventsView.frame.size.width/2
        dayHasEventsView.clipsToBounds = true
        
        dayHasEventsView.layer.borderColor = UIColor.whiteColor().CGColor
        dayHasEventsView.layer.borderWidth = 5.0
        
        // Setup text color
        configureTextColor(cellState)
    }
    
    func configureTextColor(cellState: CellState) {
        if cellState.dateBelongsTo == .ThisMonth {
            dayLabel.textColor = normalDayColor
        } else {
            dayLabel.textColor = weekendDayColor
        }
    }
    
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