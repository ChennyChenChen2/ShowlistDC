//
//  SpreadsheetReader.swift
//  ShowListDC
//
//  Created by Jonathan Chen on 4/7/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import CoreData

class SpreadsheetReader {
    
    var spreadsheet: BRAWorksheet?
    var showlist : Showlist
    
    let concurrentQueue = DispatchQueue(label: "concurrentShowQueue", attributes: .concurrent)
    
    init() {
        let documentPath = Bundle.main.path(forResource: "SLDC_For_Jon", ofType: "xlsx")!
        
        let package = BRAOfficeDocumentPackage.open(documentPath)
        
        //First worksheet in the workbook
        self.spreadsheet = package!.workbook.worksheets[0] as? BRAWorksheet
        self.showlist = Showlist.shared
        generateShows()
        print("HERE!");
    }
    
    func generateShows() {
        let rows = self.spreadsheet!.rows;
        rowLoop: for r in rows! {
            let row = r as! BRARow
            if (row.rowIndex == 1) {
                continue
            }

            let checkCellID : String = "G\(row.rowIndex)"
            
            if let checkCell = self.spreadsheet?.cell(forCellReference: checkCellID) {
                if !checkCell.stringValue().isEmpty {
                    //let concurrentQueue = DispatchQueue(label: "com.sldc.concurrentQueue", qos: .utility, attributes: .concurrent)
                    //concurrentQueue.async {
                        generateShow(with: row);
                    //}
                }
            }
        }
    }
    
    func generateShow(with row: BRARow) {
//        concurrentQueue.async {
//            let managedObjectContext = (UIApplication.shared.delegate
//                as! AppDelegate).managedObjectContext
//            
//            let entityDescription = NSEntityDescription.entity(forEntityName: "Show",
//                                                               in: managedObjectContext)
//            
//            let show = Show(entity: entityDescription!,
//                            insertInto: managedObjectContext)
            let show = Show()
            let cells = NSArray.init(array: row.cells)
            for c in cells {
                let cell = c as! BRACell
                self.populate(show:show, with:cell);
            }
            self.showlist.add(show)
//        }
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
                testDateString.replaceSubrange(dateString.index(dateString.endIndex, offsetBy: -2)..<dateString.endIndex, with: "17")

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
