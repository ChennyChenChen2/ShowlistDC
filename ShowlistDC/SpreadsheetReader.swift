//
//  SpreadsheetReader.swift
//  ShowListDC
//
//  Created by Jonathan Chen on 4/7/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
//import XlsxReaderWriter

class SpreadsheetReader {
    
    static let sharedInstance = SpreadsheetReader()
    var spreadsheet: BRAWorksheet?
    var shows : [Show]
    
    init() {
        let documentPath = NSBundle.mainBundle().pathForResource("SLDC_For_Jon", ofType: "xlsx")!
        let package = BRAOfficeDocumentPackage.open(documentPath)
        
        //First worksheet in the workbook
        self.spreadsheet = package!.workbook.worksheets[0] as? BRAWorksheet
        self.shows = [Show]()
        generateShows()
        print("HERE!");
    }
    
    func generateShows() {
        let rows = self.spreadsheet!.rows;
        rowLoop: for r in rows {
            let row = r as! BRARow
            if (row.rowIndex == 1) {
                continue
            }

            let checkCellID : String = "G\(row.rowIndex)"
            
            if let checkCell = self.spreadsheet?.cellForCellReference(checkCellID) {
                if !checkCell.stringValue().isEmpty {
                    generateShow(with: row);
                }
            }
        }
        print("HERE!")
    }
    
    func generateShow(with row: BRARow) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            let show = Show.init()
            let cells = NSArray.init(array: row.cells)
            for c in cells {
                let cell = c as! BRACell
                self.populate(show:show, with:cell);
            }
            self.shows.append(show)
        }
    }
    
    func populate(show show: Show, with cell: BRACell) {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "US_en")
        formatter.dateFormat = "m/dd/yy"
        switch cell.columnIndex() {
        case 1:
            show.recommended = cell.boolValue()
        case 2:
            show.soldOut = cell.boolValue()
        case 3:
            show.cancelledPostponed = cell.stringValue()
        case 4:
            if let dateString = cell.stringValue() {
                show.addedChanged = formatter.dateFromString(dateString)
            }
        case 5:
            show.comment = cell.stringValue()
        case 7:
            if let dateString = cell.stringValue() {
                show.date = formatter.dateFromString(dateString)
            }
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