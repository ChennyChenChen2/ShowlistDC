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
import QuartzCore
import RealmSwift

 class SLDCShowlistViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource, SLDCCalendarHeaderDelegate, UIPopoverPresentationControllerDelegate {
    
    /// Asks the data source to return the start and end boundary dates
    /// as well as the calendar to use. You should properly configure
    /// your calendar at this point.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    /// - returns:
    ///     - ConfigurationParameters instance:
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = Date()
        let secondsInYear = 60*60*24*365
        let endDate = Date().addingTimeInterval(TimeInterval(Int(secondsInYear)))
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: numberOfRows, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)
        return parameters
    }
    
    let kRefreshPopoverId = "refresh-popover"
    let kCalendarHeaderHeight : CGFloat = 60.0
    let kIsNotFirstLaunchKey = "kIsNotFirstLaunch"
    
    var token: NotificationToken?
    
    var firstDayOfShownMonth : Date = Date().calculateFirstDayOfMonth()
    
    var datesWithShows = [Date]()
    var _tableShows = [Show]()
    var tableShows : [Show] {
        get {
            return _tableShows
        } set {
            _tableShows = newValue
            var datesArray = [Date]()
            for show in _tableShows {
                let date = show.date
                datesArray.append(date as Date)
            }
            datesWithShows = datesArray
        }
    }
    
    var numberOfRows : Int {
        get {
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.year, .month, .day], from: firstDayOfShownMonth)
            (components as NSDateComponents).setValue(1, forComponent: .day)
            if let firstDayOfMonth = calendar.date(from: components) {
                let dayOfWeek = (calendar as NSCalendar).component(.weekday, from:firstDayOfMonth)
                let days = (calendar as NSCalendar).range(of: .day, in: .month, for: firstDayOfMonth)
                
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
    var shouldHighlightSelectedRow = false
    var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: "SLDCCalendarCell")
        self.calendarView.registerHeaderView(xibFileNames: ["SLDCCalendarHeader"])
        self.calendarView.itemSize = ((self.view.frame.size.height / 2) - kCalendarHeaderHeight) / CGFloat(numberOfRows)
        self.calendarHeightConstraint.constant = self.calendarView.itemSize! * CGFloat(numberOfRows) + kCalendarHeaderHeight
        self.calendarView.cellInset = CGPoint(x: 1, y: 1)
        self.calendarView.scrollEnabled = true
        self.calendarView.scrollingMode = .stopAtEachSection
        self.calendarView.scrollDirection = .vertical
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector:#selector(reloadShows), name:ReloadConstants.kReloadCompleteNoteName, object:nil)
        
        let realm = try! Realm()
        self.token = realm.observe { notification, realm in
            DispatchQueue.main.async {
                self.reloadShows()
            }
        }
        
        self.tableShows = Showlist.getShowsForMonth(firstDayOfShownMonth)
        self.tableView.reloadData()
        
        if !UserDefaults.standard.bool(forKey: kIsNotFirstLaunchKey) {
            let blurVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: SLDCFirstTimeBlurView.kStoryboardId)
            self.present(blurVC, animated: true, completion: nil)
            SpreadsheetReader.shared.generateData(shouldRestart: true)
            UserDefaults.standard.set(true, forKey: kIsNotFirstLaunchKey)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if let theToken = self.token {
            theToken.invalidate()
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        // Add border between table and calendar
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 2)
        
        border.borderWidth = width
        self.tableView.layer.addSublayer(border)
        self.tableView.layer.masksToBounds = true
    }
    
    @objc fileprivate func reloadShows() {
        self.tableShows = Showlist.getShowsForMonth(firstDayOfShownMonth)
        self.calendarView.reloadData()
        self.tableView.reloadData()
    }
    
    func dateIsShowDate(_ date: Date) -> Bool {
        for showDate in datesWithShows {
            if showDate.isOnSameDayAsDate(date) {
                return true
            }
        }
        return false
    }
    
    // MARK -- JTAppleCalendarViewDataSource
    func configureCalendar(_ calendar: JTAppleCalendarView) -> (startDate: Date, endDate: Date, numberOfRows: Int, calendar: Calendar) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let firstDate = Date()
        let secondsInYear = 60*60*24*365
        let secondDate = Date().addingTimeInterval(TimeInterval(Int(secondsInYear)))
        let aCalendar = Calendar.current // Properly configure your calendar to your time zone here
        
        return (startDate: firstDate, endDate: secondDate, numberOfRows: numberOfRows, calendar: aCalendar)
    }
    
    // MARK -- JTAppleCalendarViewDelegate
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        let oldSelectedDate = self.selectedDate
        self.selectedDate = date
        self.calendarView.reloadDates([oldSelectedDate, self.selectedDate])
        self.scrollToDate(date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let theCell = cell as! SLDCCalendarCell
        
        // Setup Cell text
        theCell.dayLabel.text = cellState.text
        theCell.dayHasEventsView.isHidden = !dateIsShowDate(date)
        
        // Make round dayHasEventsView
        theCell.dayHasEventsView.layer.cornerRadius = theCell.dayHasEventsView.frame.size.width/2
        theCell.dayHasEventsView.clipsToBounds = true
        
        theCell.dayHasEventsView.layer.borderColor = UIColor.white.cgColor
        theCell.dayHasEventsView.layer.borderWidth = 1.0
        
        if date.isOnSameDayAsDate(self.selectedDate) {
            theCell.selectionView.isHidden = false
            theCell.selectionView.layer.cornerRadius = theCell.selectionView.frame.size.height / 2
        } else {
            theCell.selectionView.isHidden = true
        }
        
        // Setup text color
        if cellState.dateBelongsTo == .thisMonth {
            theCell.dayLabel.textColor = UIColor.black
        } else {
            theCell.dayLabel.textColor = UIColor.gray
        }
    }
 
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        firstDayOfShownMonth = visibleDates.monthDates[0]
        self.calendarHeightConstraint.constant = CGFloat(self.numberOfRows * Int(self.calendarView.itemSize!)) + kCalendarHeaderHeight
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        })
        self.tableShows = Showlist.getShowsForMonth(firstDayOfShownMonth)
        self.tableView.reloadData()
        self.calendarView.reloadData()
    }
    
    func scrollToShowInTable(date: Date) {
        if self.shouldHighlightSelectedRow {
            let showsOnDate = Showlist.getShowsForDate(date)
            if showsOnDate.count > 0 {
                let showToScrollTo = showsOnDate[0]
                if let index = self.tableShows.index(of: showToScrollTo), self.tableView.numberOfRows(inSection: 1) > index {
                    UIView.animate(withDuration: 3.0, animations: {
                        self.tableView.selectRow(at: IndexPath(row:index, section: 0), animated: true, scrollPosition: .top)
                    }, completion: { (success) in
                        self.tableView.deselectRow(at: IndexPath(row:index, section: 0), animated: true)
                    })
                }
            }
            self.shouldHighlightSelectedRow = false
        } else {
            if self.tableView.visibleCells.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: true)
            }
        }
    }

    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderSizeFor range: (start: Date, end: Date), belongingTo month: Int) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: kCalendarHeaderHeight)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplaySectionHeader header: JTAppleHeaderView, range: (start: Date, end: Date), identifier: String) {
        let headerCell = header as! SLDCCalendarHeader
        headerCell.delegate = self
        headerCell.monthLabel.text = getMonthNameFromDate(range.start)
    }
    
    func getMonthNameFromDate(_ startDate: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        let monthVal = (calendar as NSCalendar).component(.month, from:startDate)
        let monthName = formatter.monthSymbols[monthVal - 1]
        let yearVal = (calendar as NSCalendar).component(.year, from:startDate)
        return "\(monthName) \(yearVal)"
    }
    
    // MARK -- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableShows.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayListCell")!
        let show = self.tableShows[indexPath.row]
        
        if show.isCancelledShow {
            cell.textLabel!.attributedText = show.artist1.getStrikethrough()
            cell.detailTextLabel!.attributedText = show.venue.getStrikethrough()
        } else {
            cell.textLabel!.text = show.artist1
            cell.detailTextLabel!.text = show.venue
        }
        
        return cell
    }
    
    // MARK -- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let show = self.tableShows[indexPath.row]
        let showDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ShowDetailViewController.storyboardId) as! ShowDetailViewController
        showDetailVC.show = show
        if let navController = self.navigationController {
            navController.show(showDetailVC, sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollToDate(_ date: Date) {
        self.shouldHighlightSelectedRow = true
        self.calendarView.scrollToDate(date)
        self.scrollToShowInTable(date: self.selectedDate)
    }
    
    // MARK -- SLDCCalendarHeaderDelegate
    func didPressRightArrow() {
        let date = getConsecutiveMonthDate(backwards: false)
        self.calendarView.scrollToDate(date, triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: UICollectionViewScrollPosition.centeredVertically, completionHandler: nil)
    }
    
    func didPressLeftArrow() {
        let date = getConsecutiveMonthDate(backwards: true)
        self.calendarView.scrollToDate(date, triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: UICollectionViewScrollPosition.centeredVertically, completionHandler: nil)
    }
    
    func didPressRefreshButton(_ button: UIButton) {
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: kRefreshPopoverId) as! RefreshPopoverViewController
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = .any
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = button
        popController.popoverPresentationController?.sourceRect = button.bounds
        
        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
    
    func didPressTodayButton() {
        self.selectedDate = Date()
        self.scrollToDate(Date())
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    fileprivate func getConsecutiveMonthDate(backwards:Bool) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = backwards ? -1 : 1
        let calendar = NSCalendar(identifier: .gregorian)!
        return calendar.date(byAdding: dateComponents, to: firstDayOfShownMonth, options:.searchBackwards)!
    }
}

extension Date {
    func calculateFirstDayOfMonth() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: self) as NSDateComponents
        components.setValue(1, forComponent: .day)
        return calendar.date(from: components as DateComponents) ?? self
    }
    
    func isOnSameDayAsDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: self)
        let otherDateComponents = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        return components.day == otherDateComponents.day &&
        components.month == otherDateComponents.month &&
        components.year == otherDateComponents.year
    }
}
