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
    
    fileprivate var _totalRows = 0
    var totalRows : Int {
        return _totalRows
    }
    
    fileprivate var _processedRows = 0 {
        didSet {
            NotificationCenter.default.post(name: ReloadConstants.kUpdatedRowsNoteName, object:nil)
        }
    }
    
    var processedRows : Int {
        return _processedRows
    }
    
    
    var downloadStatusString : String {
        let downloadPercent = Int((Float(processedRows) / Float(totalRows)) * 100.0)
        return "\(downloadPercent)% updated"
    }
    
    var isLoadingData = false
    
    static let shared = SpreadsheetReader()
    fileprivate override init() {
        let documentPath = Bundle.main.path(forResource: "SLDC_For_Jon", ofType: "xlsx")!
        
        let package = BRAOfficeDocumentPackage.open(documentPath)
        
        //First worksheet in the workbook
        guard let theShowSpreadsheet = package?.workbook.worksheets[0] as? BRAWorksheet
        else {
            return
        }
        self.showSpreadsheet = theShowSpreadsheet
        
        // TODO: Use second worksheet in workbook for venues list
        guard let theVenueSpreadsheet = package?.workbook.worksheets[1] as? BRAWorksheet
        else {
            return
        }
        self.venueSpreadsheet = theVenueSpreadsheet
    }
    
    func generateData() {
        // TODO: Request spreadsheet from server via downloadManager class of some kind
        
        if let showRows = self.showSpreadsheet?.rows, let venueRows = self.venueSpreadsheet?.rows {
            _totalRows = showRows.count + venueRows.count
            print("Start of download. Shows spreadsheet has \(_totalRows) rows.")
            _processedRows = 0
            self.isLoadingData = true

            DispatchQueue(label: "show-queue").async {
                autoreleasepool {
                    for r in showRows {
                        guard let row = r as? BRARow else { return }
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
                    
                    print("DONE LOADING SHOWS!!!!!!")
                    DispatchQueue.main.async {
                        self.isLoadingData = false
                        NotificationCenter.default.post(name: ReloadConstants.kReloadCompleteNoteName, object: NSNumber(booleanLiteral: true))
                    }
                }
            }
        } else {
            // TODO: show alert saying there are no shows/temporary outage/something like that
        }
    }
    
    
    
    func generateVenue(with row: BRARow) {
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
    func populate(venue: Venue, with cell: BRACell) {
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
    
    func generateShow(with row: BRARow) {
            let show = Show()
            let cells = NSArray.init(array: row.cells)
            for c in cells {
                let cell = c as! BRACell
                self.populate(show:show, with:cell)
            }
            Showlist.add(show)
            print(self.downloadStatusString)
    }
    
    func populate(show: Show, with cell: BRACell) {
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
            // Make today for testing
//            show.date = cell.stringValue
        case 10:
            show.venue = cell.stringValue()
        case 11:
            // TODO: populate start time here
            show.venuePlus = cell.stringValue()
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
    
}

extension DateFormatter {
    func defaultDateFormat() -> String {
        return "M/dd/yy"
    }
}
