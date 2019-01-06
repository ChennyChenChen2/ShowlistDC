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
    
    fileprivate dynamic var _totalRows = -1
    var totalRows : Int {
        return max(_totalRows, 1)
    }
    
    fileprivate dynamic var _processedRows = -1
    
    dynamic var processedRows : Int {
        return _processedRows
    }
    
    var downloadStatusString : String {
        if isLoadingSpreadsheet { return "Extracting data..." }
        else if isLoadingData { return "\(processedRows) shows updated" }
        else { return "Ready to reload shows" }
    }
    
    class func keyPathsForValuesAffectingProcessedRows() -> Set<String> {
        return [ "_processedRows" ]
    }
    
    class func keyPathsForValuesAffectingProgress() -> Set<String> {
        return [ "_processedRows", "_totalRows" ]
    }
    
    dynamic var progress : Float {
        return (Float(processedRows) / Float(totalRows))
    }
    
    var isLoadingSpreadsheet = false
    dynamic var isLoadingData = false
    
    let kLastShowCellIndex = "lastShowCellIndexKey"
    var lastShowCellIndex: Int {
        get {
            let index = UserDefaults.standard.integer(forKey: kLastShowCellIndex)
            return index > 0 ? index : Int.max
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kLastShowCellIndex)
        }
    }
    
    static let shared = SpreadsheetReader()
    fileprivate override init() {}
    
    func loadSpreadsheet() {
        self.isLoadingSpreadsheet = true
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
        
        let showQueue = DispatchQueue(label: "show-queue")
        self.isLoadingData = true
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue(label: "spreadsheet-queue").async { [weak self] in
            if let weakSelf = self {
                if weakSelf.showSpreadsheet == nil || weakSelf.venueSpreadsheet == nil {
                    weakSelf.loadSpreadsheet()
                }
            }
        }
        
        group.leave()
        group.notify(qos: .background, queue: showQueue) { [weak self] in
            if let weakSelf = self {
                weakSelf.loadSpreadsheet()
                guard let showRows = weakSelf.showSpreadsheet?.rows as? [BRARow] else { return }
                
                let sampleSize = min(weakSelf.lastShowCellIndex, showRows.count)
                let startDateCellIndex = weakSelf.binarySearchDate(startDate, pivot: sampleSize / 2, sampleSize: sampleSize / 2)
                let endDateCellIndex = weakSelf.binarySearchDate(endDate, pivot: sampleSize / 2, sampleSize: sampleSize / 2)
                
                weakSelf._processedRows = 0
                weakSelf._totalRows = endDateCellIndex - startDateCellIndex
                weakSelf.generateData(shouldRestart: shouldRestart, showRowStart: startDateCellIndex, showRowEnd: endDateCellIndex)
            }
        }
    }
    
    
    // TODO: What does this do???
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
    
    func generateData(shouldRestart: Bool, showRowStart: Int = 0, showRowEnd: Int = -1) {
        self.isLoadingData = true
        var showRowEnd = showRowEnd
        
        // TODO: do we need the shouldRestart variable?
        if shouldRestart {
            self._processedRows = -1
        }
        
        let showQueue = DispatchQueue(label: "show-queue")

        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue(label: "spreadsheet-queue").async { [weak self] in
            if let weakSelf = self {
                if weakSelf.showSpreadsheet == nil || weakSelf.venueSpreadsheet == nil {
                    weakSelf.loadSpreadsheet()
                }
            }
        }
        
        group.leave()
        group.notify(qos: .background, queue: showQueue) {
//        showQueue.async {
            if showRowEnd - showRowStart >= 0 {
                self._totalRows = showRowEnd - showRowStart
            }
        
            // TODO: Request spreadsheet from server via downloadManager class of some kind
            // When we do, reset the "lastRowInSpreadsheet" variable
            
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
                        } else {
                            self.lastShowCellIndex = row.rowIndex - 1
                            break
                        }
                    }
                    self._processedRows = self._processedRows + 1
                }
                
                print("DONE LOADING SHOWS!!!!!!")
                
                self.isLoadingData = false
                self._processedRows = 0
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: ReloadConstants.kReloadCompleteNoteName, object: NSNumber(booleanLiteral: true))
                }
            } else {
                // TODO: show alert saying there are no shows/temporary outage/something like that
            }
        }
    }
    
    // Binary search for start index for given date
    // THIS METHOD RELIES ON "COMPLETE" CELLS AT THE BEGINNING OF THE SPREADSHEET
    fileprivate func binarySearchDate(_ date: Date, pivot: Int, sampleSize: Int) -> Int {
        let checkCellID : String = "G\(pivot)"
        
        if let showSpreadsheet = self.showSpreadsheet, let dateCell = showSpreadsheet.cell(forCellReference: checkCellID), let theValue = dateCell.stringValue(), theValue.isDate() {

            if pivot == 2 || pivot == self.lastShowCellIndex {
                return pivot
            }
            
            let dateString = dateCell.stringValue()!
            let formatter = DateFormatter()
            formatter.dateFormat = formatter.defaultDateFormat()
            
            // TESTING!!!!! Make dates this year for testing
            var testDateString = dateString
            testDateString.replaceSubrange(testDateString.index(testDateString.endIndex, offsetBy: -2)..<testDateString.endIndex, with: "19")
            
            if let theDate = formatter.date(from: testDateString) {
//            if let theDate = formatter.date(from: dateString) {
                
                if theDate.compare(date) == .orderedDescending {
                    if sampleSize == 0 {
                        return fineTuneSearch(date, pivot: pivot, previousResult: .orderedDescending)
                    }
                    else {
                        return binarySearchDate(date, pivot: pivot - (sampleSize / 2), sampleSize: sampleSize / 2)
                    }
                } else {
                    if sampleSize == 0 {
                        return fineTuneSearch(date, pivot: pivot, previousResult: .orderedAscending)
                    } else {
                        return binarySearchDate(date, pivot: pivot + (sampleSize / 2), sampleSize: sampleSize / 2)
                    }
                }
            } else {
                return binarySearchDate(date, pivot: pivot - 1, sampleSize: sampleSize - 1)
            }
        }

        return 0
    }
    
    fileprivate func fineTuneSearch(_ date: Date, pivot: Int, previousResult: ComparisonResult) -> Int {
        let checkCellID : String = "G\(pivot)"
        
        if let showSpreadsheet = self.showSpreadsheet, let dateCell = showSpreadsheet.cell(forCellReference: checkCellID), let theValue = dateCell.stringValue(), theValue.isDate() {
            
            let dateString = dateCell.stringValue()!
            let formatter = DateFormatter()
            formatter.dateFormat = formatter.defaultDateFormat()
            
            // TESTING!!!!! Make dates this year for testing
            var testDateString = dateString
            testDateString.replaceSubrange(testDateString.index(testDateString.endIndex, offsetBy: -2)..<testDateString.endIndex, with: "19")
            
            if let theDate = formatter.date(from: testDateString) {
                if pivot == 2 || pivot == self.lastShowCellIndex {
                    return pivot
                }
                
                let currentResult = theDate.compare(date)
                
                if previousResult != currentResult {
                    return pivot
                } else {
                    if currentResult == .orderedDescending {
                        return fineTuneSearch(date, pivot: pivot - 1, previousResult: currentResult)
                    } else {
                        return fineTuneSearch(date, pivot: pivot + 1, previousResult: currentResult)
                    }
                }
            }
        } else {
            return fineTuneSearch(date, pivot: pivot - 1, previousResult: previousResult)
        }
        return 0
    }
    
    fileprivate func generateVenue(with row: BRARow) {
        let venue = Venue()
        let cells = NSArray.init(array: row.cells)
        for c in cells {
            guard let cell = c as? BRACell else { return }
            self.populate(venue: venue, with: cell)
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
                testDateString.replaceSubrange(dateString.index(dateString.endIndex, offsetBy: -2)..<dateString.endIndex, with: "19")

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

extension String {
    func isDate() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = formatter.defaultDateFormat()
        return formatter.date(from: self) != nil
    }
}
