 //
//  SLDCShowlistViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 9/11/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import UIKit
import Foundation
import JTAppleCalendar
import CoreData

class SLDCShowlistViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let kCalendarHeaderHeight : CGFloat = 60.0
    
    var firstDayOfShownMonth : NSDate = NSDate()
    
    var tableShows = [Show]()
    
    var numberOfRows : Int {
        get {
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Year, .Month, .Day], fromDate: firstDayOfShownMonth)
            components.setValue(1, forComponent: .Day)
            if let firstDayOfMonth = calendar.dateFromComponents(components) {
                let dayOfWeek = calendar.component(.Weekday, fromDate:firstDayOfMonth)
                let days = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: firstDayOfMonth)
                
                var roundedResult = Int(round(Double((dayOfWeek + days.length - 1) / 7)))
                if ((dayOfWeek + days.length - 1) % 7 != 0) {
                    roundedResult += 1;
                }
                return roundedResult
            } else {
                return 6
            }
        }
    }
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var tableView: SLDCDayListingsTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(fileName: "SLDCCalendarCell")
        self.calendarView.registerHeaderViewXibs(fileNames: ["SLDCCalendarHeader"])
        
        self.calendarView.cellInset = CGPoint(x: 1, y: 1)
        self.calendarView.itemSize = (self.calendarView.frame.size.height - kCalendarHeaderHeight) / CGFloat(numberOfRows)
        self.calendarHeightConstraint.constant = self.calendarView.itemSize! * CGFloat(numberOfRows) + kCalendarHeaderHeight
        self.calendarView.scrollEnabled = true
        self.calendarView.scrollingMode = .StopAtEachSection
        self.calendarView.direction = .Vertical
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableShows = Showlist.sharedInstance.getShowsForDay(NSDate.init()).map({ (obj) -> Show in
            NSManagedObject().getShowFromManagedObject(obj)
        })
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK -- JTAppleCalendarViewDataSource
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let firstDate = NSDate()
        let secondsInYear = 60*60*24*365
        let secondDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(Int(secondsInYear)))
        let aCalendar = NSCalendar.currentCalendar() // Properly configure your calendar to your time zone here
        
        return (startDate: firstDate, endDate: secondDate, numberOfRows: numberOfRows, calendar: aCalendar)
    }
    
    // MARK -- JTAppleCalendarViewDelegate
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        (cell as! SLDCCalendarCell).setupCellBeforeDisplay(cellState, date: date)
    }
    
    func calendar(calendar : JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        firstDayOfShownMonth = startDate
        self.calendarHeightConstraint.constant = CGFloat(self.numberOfRows * Int(self.calendarView.itemSize!)) + kCalendarHeaderHeight
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func calendar(calendar : JTAppleCalendarView, sectionHeaderSizeForDate dateRange: (start: NSDate, end: NSDate), belongingTo month: Int) -> CGSize {
        return CGSizeMake(self.view.frame.size.width, 60)
    }
    
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, dateRange: (start: NSDate, end: NSDate), identifier: String) {
        let headerCell = header as! SLDCCalendarHeader
        headerCell.monthLabel.text = getMonthNameFromDate(dateRange.start)
    }
    
    func getMonthNameFromDate(startDate: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let formatter = NSDateFormatter()
        let monthVal = calendar.component(.Month, fromDate:startDate)
        let monthName = formatter.monthSymbols[monthVal - 1]
        let yearVal = calendar.component(.Year, fromDate:startDate)
        return "\(monthName) \(yearVal)"
    }

    // MARK -- UITableViewDelegate

    
    // MARK -- UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableShows.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DayListCell")!
        let show = self.tableShows[indexPath.row]
        cell.textLabel!.text = show.artist1
        cell.detailTextLabel!.text = show.venue
        
        return cell
    }
}