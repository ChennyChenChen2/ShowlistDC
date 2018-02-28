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
    
    var spreadsheet: BRAWorksheet?
    var showlist : Showlist
    
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
        return "\(processedRows) of \(totalRows) updated"
    }
    
    var isLoadingData = false
    
    static let shared = SpreadsheetReader()
    fileprivate override init() {
        let documentPath = Bundle.main.path(forResource: "SLDC_For_Jon", ofType: "xlsx")!
        
        let package = BRAOfficeDocumentPackage.open(documentPath)
        
        //First worksheet in the workbook
        self.spreadsheet = package!.workbook.worksheets[0] as? BRAWorksheet
        
        // TODO: Use second worksheet in workbook for venues list
        
        self.showlist = Showlist.shared
    }
    
    func generateShows() {
        // TODO: Request spreadsheet from server via downloadManager class of some kind
        
        let rows = self.spreadsheet!.rows!
        
        print("Start of download. Spreadsheet has \(rows.count) rows.")
        _totalRows = rows.count
        _processedRows = 0
        self.isLoadingData = true

        DispatchQueue(label: "show-queue").async {
            autoreleasepool {

            rowLoop: for r in rows {
                    let row = r as! BRARow
                    if (row.rowIndex == 1) {
                        continue
                    }

                    let checkCellID : String = "G\(row.rowIndex)"
                    
                    if let checkCell = self.spreadsheet?.cell(forCellReference: checkCellID) {
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
            }
        }
    }
    
    func generateShow(with row: BRARow) {
            let show = Show()
            let cells = NSArray.init(array: row.cells)
            for c in cells {
                let cell = c as! BRACell
                self.populate(show:show, with:cell);
            }
            self.showlist.add(show)
//            DispatchQueue.main.async {
            print(self.downloadStatusString)
//            }
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
