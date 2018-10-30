//
//  SpreadsheetReader.swift
//  ShowListDC
//
//  Created by Jonathan Chen on 4/7/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import CoreData


struct ReloadConstants {
    static let kReloadDidBeginNoteName: NSNotification.Name = NSNotification.Name(rawValue: "refreshDidBegin")
    static let kReloadCompleteNoteName: NSNotification.Name = NSNotification.Name(rawValue: "refreshDidFinish")
    static let kUpdatedRowsNoteName   : NSNotification.Name = NSNotification.Name(rawValue: "didUpdateRows")
}

@objc class SpreadsheetReader: NSObject {
    
    var showSpreadsheet: BRAWorksheet?
    var venueSpreadsheet: BRAWorksheet?
    
    fileprivate var _totalRows = -1
    var totalRows : Int {
        return _totalRows
    }
    
    fileprivate var _processedRows = -1 {
        didSet {
            NotificationCenter.default.post(name: ReloadConstants.kUpdatedRowsNoteName, object:nil)
        }
    }
    
    var processedRows : Int {
        return _processedRows
    }
    
    var downloadStatusString : String {
        let downloadPercent = Int((Float(processedRows) / Float(totalRows)) * 100.0)
        if isLoadingSpreadsheet { return "Extracting data from spreadsheet..." }
        else if isLoadingData { return "\(downloadPercent)% updated" }
        else { return "Ready to reload shows" }
    }
    
    var isLoadingSpreadsheet = false
    var isLoadingData = false
    
    static let shared = SpreadsheetReader()
    fileprivate override init() {}
    
    func loadSpreadsheet() {
        let documentPath = Bundle.main.path(forResource: "ShowlistDC", ofType: "xlsx")!

        let package = BRAOfficeDocumentPackage.open(documentPath)
        
        if self.showSpreadsheet == nil {
            
            //First worksheet in the workbook has shows, second has venues
            guard let theShowSpreadsheet = package?.workbook.worksheets[0] as? BRAWorksheet
                else {
                    return
            }
            
            self.showSpreadsheet = theShowSpreadsheet
        }
        
        if self.venueSpreadsheet == nil {
            guard let theVenueSpreadsheet = package?.workbook.worksheets[1] as? BRAWorksheet
                else {
                    return
            }
            
            self.venueSpreadsheet = theVenueSpreadsheet
        }
        
        self.isLoadingSpreadsheet = false
        
        guard let showRows = self.showSpreadsheet?.rows, let venueRows = self.venueSpreadsheet?.rows else { return }
        _totalRows = showRows.count + venueRows.count
        print("Start of download. Shows spreadsheet has \(self.totalRows) rows.")
        _processedRows = 0
    }
    
    func loadData(startDate: Date, endDate: Date, shouldRestart: Bool) {
        self.loadSpreadsheet()
        guard let showRows = self.showSpreadsheet?.rows as? [BRARow] else { return }
        
//        let testResult = !spreadsheetIsConsistent(rowArray: showRows)
//        if !testResult {
//            return
//        }
//        determineValidRowStart(from: showRows)
        let startDateCell = binarySearchDate(startDate, rowArray: showRows, pivot: showRows.count / 2)
        let endDateCell = binarySearchDate(endDate, rowArray: showRows, pivot: showRows.count / 2)
        generateData(shouldRestart: shouldRestart, showRowStart: startDateCell, showRowEnd: endDateCell)
    }
    
    private func spreadsheetIsConsistent(rowArray: [BRARow]) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = formatter.defaultDateFormat()
        
        for i in 0..<rowArray.count {
            if i == 0 { continue }
            
            let row = rowArray[i]
            if let dateCell = row.cells[3] as? BRACell, let dateString = dateCell.stringValue() {
                if formatter.date(from: dateString) == nil {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func determineValidRowStart(from rowArray: [BRARow]) -> Int {
        var returnValue = 0
        let formatter = DateFormatter()
        formatter.dateFormat = formatter.defaultDateFormat()
        
        let testCell = rowArray[965]
        
        for row in rowArray {
            
        }
        
        
        return returnValue
    }
    
    func generateData(shouldRestart: Bool, showRowStart: Int = 0, showRowEnd: Int = -1) {
        self.isLoadingData = true
        self.isLoadingSpreadsheet = true
        var showRowEnd = showRowEnd
        
        if shouldRestart {
            self._processedRows = -1
        }
        
        DispatchQueue(label: "show-queue").async {
            NotificationCenter.default.post(name: ReloadConstants.kUpdatedRowsNoteName, object:nil)
            self.loadSpreadsheet()
            
            if showRowEnd - showRowStart > 0 {
                self._totalRows = showRowEnd - showRowStart
            }
            
            // TODO: Request spreadsheet from server via downloadManager class of some kind
            
            if let showRows = self.showSpreadsheet?.rows, let venueRows = self.venueSpreadsheet?.rows {
                
                // Load venues first, very quick
                venueLoop: for v in venueRows {
                    guard let row = v as? BRARow else { return }
                    if (row.rowIndex == 1) {
                        continue
                    }
                    guard let cell = row.cells[0] as? BRACell else { return }
                    if cell.stringValue() == "Other Listing Sites" ||
                        cell.stringValue() == "DEFUNCT VENUES" ||
                        cell.stringValue() == "" {
                        break venueLoop
                    } else {
                        self.generateVenue(with: row)
                    }
                }
                
                // Load shows, starting from where download left off if app was suspended
                var startIndex = 0
                if self.processedRows > -1 {
                    startIndex = self.processedRows
                }
                
                if showRowEnd == -1 {
                    showRowEnd = showRows.count
                }
                
                for r in startIndex..<showRowEnd {
                    
                    guard let row = showRows[r] as? BRARow else { return }
                    if (row.rowIndex == 1) {
                        continue
                    }

                    let checkCellID : String = "G\(row.rowIndex)"

                    if let checkCell = self.showSpreadsheet?.cell(forCellReference: checkCellID) {
                        if !checkCell.stringValue().isEmpty {
                            self.generateShow(with: row)
                            print("Processed show \(row.rowIndex)")
                        }
                    }
                    self._processedRows = self._processedRows + 1
                }
                
                print("DONE LOADING SHOWS!!!!!!")
                DispatchQueue.main.async {
                    self.isLoadingData = false
                    NotificationCenter.default.post(name: ReloadConstants.kReloadCompleteNoteName, object: NSNumber(booleanLiteral: true))
                }
            } else {
                // TODO: show alert saying there are no shows/temporary outage/something like that
            }
        }
    }
    
    // Binary search for start index for given date
    fileprivate func binarySearchDate(_ date: Date, rowArray: [BRARow], pivot: Int) -> Int {
        if let pivotRowCells = rowArray[pivot].cells, let dateCell = pivotRowCells[3] as? BRACell {
            
            let dateString = dateCell.stringValue() ?? ""
            let formatter = DateFormatter()
            formatter.dateFormat = formatter.defaultDateFormat()
            
            // TESTING!!!!! Make dates this year for testing
//            var testDateString = dateString
//            testDateString.replaceSubrange(testDateString.index(testDateString.endIndex, offsetBy: -2)..<testDateString.endIndex, with: "18")
            
//            if let theDate = formatter.date(from: testDateString) {
            if let theDate = formatter.date(from: dateString) {
                if theDate.isOnSameDayAsDate(date) {
                    return pivot
                } else {
                    var theArray: [BRARow]
                    if theDate.compare(date) == .orderedDescending {
                        theArray = Array(rowArray.prefix(upTo: pivot))
                        return binarySearchDate(date, rowArray: theArray, pivot: theArray.count / 2)
                    } else {
                        theArray = Array(rowArray.suffix(from: pivot))
                        return binarySearchDate(date, rowArray: theArray, pivot: theArray.count / 2)
                    }
                }
            } else {
                return binarySearchDate(date, rowArray: rowArray, pivot: pivot + 1)
            }
        }

        return 0
    }
    
    fileprivate func generateVenue(with row: BRARow) {
        let venue = Venue()
        let cells = NSArray.init(array: row.cells)
        for c in cells {
            guard let cell = c as? BRACell else { return }
            self.populate(venue: venue, with: cell)
            print("HERE!")
        }
        Showlist.add(venue)
        print(self.downloadStatusString)
    }
    
    /*
    Column labels:
     1. Venue
     2. More
     3. Address
     4. Phone
     5. Map
     6. FB
     7. Twitter
     8. Instagram
     9. Last Updated
     10. Web Site
     11. More link
     12. Venues page
     13. Individual page
     14. TODAY
     15. 3/2/16
     16. 24
     17. 0
     18. For \"Venue Info\" page
     19. 1
     20. January
     */
    fileprivate func populate(venue: Venue, with cell: BRACell) {
        switch cell.columnIndex() {
        case 1:
            venue.name = cell.stringValue()
        case 3:
            venue.address = cell.stringValue()
        case 4:
            venue.phone = cell.stringValue()
        case 5:
            venue.mapLink = cell.stringValue()
        case 6:
            if cell.stringValue() != "" && cell.stringValue() != "NONE" {
                venue.fb = cell.stringValue()
            }
        case 7:
            if cell.stringValue() != "" && cell.stringValue() != "NONE" {
                venue.twitter = cell.stringValue()
            }
        case 8:
            if cell.stringValue() != "" && cell.stringValue() != "NONE" {
                venue.instagram = cell.stringValue()
            }
        default:
            break
        }
    }
    
    fileprivate func generateShow(with row: BRARow) {
        let show = Show()
        let cells = NSArray.init(array: row.cells)
        var processedShows = [show]
    
        for c in cells {
            let cell = c as! BRACell
            var nextProcessedShows = processedShows
            
            for processShow in processedShows {
                self.populate(show:processShow, processingShows:&nextProcessedShows, with:cell)
            }
            
            processedShows = nextProcessedShows
        }
        
        for resultShow in processedShows {
            Showlist.add(resultShow)
        }
        
        print(self.downloadStatusString)
    }
    
    fileprivate func populate(show: Show, processingShows: inout [Show], with cell: BRACell) {
        switch cell.columnIndex() {
        case 1:
            show.recommended = cell.boolValue()
        case 2:
            show.soldOut = cell.boolValue()
        case 3:
            show.cancelledPostponed = cell.stringValue()
        case 4:
            show.addedChanged = cell.stringValue()
        case 5:
            show.comment = cell.stringValue()
        case 7:
            if let dateString = cell.stringValue() {
                let formatter = DateFormatter()
                formatter.dateFormat = formatter.defaultDateFormat()
                
                // TESTING!!!!! Make dates this year for testing
                var testDateString = dateString
                testDateString.replaceSubrange(dateString.index(dateString.endIndex, offsetBy: -2)..<dateString.endIndex, with: "18")

//                show.date = formatter.date(from: dateString)
                
                if let theDate = formatter.date(from: testDateString) {
                    let castedDate = theDate as NSDate
                    show.date = castedDate
                }
            }
        case 10:
            show.venue = cell.stringValue()
        case 11:
/* Venue+ special cases:
    1) Late show/early show, need to edit show start time
    2) One row represents two shows, need to generate two shows
*/
            guard let cellValue = cell.stringValue() else { return }
            
            // Case 1)
            if cellValue.lowercased().contains("late show") || cellValue.lowercased().contains("early show") {
                show.venuePlus = cellValue
                show.start = getLateEarlyTimeFromVenuePlus(show: show)
            } else if cellValue.lowercased().contains("two shows") { // Case 2)
                show.venuePlus = cellValue
                let timeMatches = getTwoShowTimesFromVenuePlus(show: show)
                if timeMatches.count > 0 {
                    var isCopyShow = false
                    for time in timeMatches {
                        if isCopyShow {
                            let showCopy = show.copy() as! Show
                            showCopy.start = time
                            showCopy.venuePlus = cellValue
                            processingShows.append(showCopy)
                        } else {
                            show.start = time
                            show.venuePlus = cellValue
                            isCopyShow = true
                        }
                    }
                }
            } else {
                show.venuePlus = cellValue
            }
        case 15:
            show.artist1 = cell.stringValue()
        case 16:
            show.artist2 = cell.stringValue()
        case 17:
            show.artist3 = cell.stringValue()
        case 18:
            show.artist4 = cell.stringValue()
        case 24:
            show.ticketfly = cell.stringValue()
        case 25:
            show.fb = cell.stringValue()
        default:
            break
        }
    }
    
    private func getTwoShowTimesFromVenuePlus(show: Show) -> [String] {
        let regexMatch = show.venuePlus.matches(forRegex: "\\s*[0-9]*:*[0-9]+\\s[AP]M")
        
        return regexMatch
    }
    
    private func getLateEarlyTimeFromVenuePlus(show: Show) -> String {
        var start = "9 PM"

        let regexMatch = show.venuePlus.matches(forRegex: "\\s*[0-9]*:*[0-9]+\\s[AP]M") // Late show - 9 PM
        if regexMatch.count > 0 {
            start = regexMatch[0]
        }
        
        return start
    }
    
}

extension DateFormatter {
    func defaultDateFormat() -> String {
        return "M/dd/yy"
    }
}
