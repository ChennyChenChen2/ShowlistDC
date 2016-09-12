//
//  SLDCShowlistViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 9/11/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import JTAppleCalendar

class SLDCShowlistViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    
// MARK -- JTAppleCalendarViewDataSource
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        
        return (NSDate(), NSDate(), 0, NSCalendar.currentCalendar())
    }

    
    
// MARK -- JTAppleCalendarViewDelegate
    
    
    
    
    
    
    
}