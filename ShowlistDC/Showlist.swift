//
//  Showlist.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 11/27/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import CoreData

class Showlist {

    //   [November 2016 : [5 : [Guy Fawkes Band Show Obj, Natalie Portman Band Show Obj]]]
    private var shows = [String:[String:Show]]()
    private let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    static let sharedInstance = Showlist()
    private init() {}
    
    func add(show: Show) {
//        if let date = show.date {
//            let calendar = NSCalendar.currentCalendar()
//            let formatter = NSDateFormatter()
//            let monthVal = calendar.component(.Month, fromDate:date)
//            let monthName = formatter.monthSymbols[monthVal - 1]
//            let yearVal = calendar.component(.Year, fromDate:date)
//            let monthYearString = "\(monthName) \(yearVal)"
//            let dayVal = calendar.component(.Day, fromDate: date)
//            if let monthDict = shows[monthYearString] {
//                if let dayArray = monthDict["\(dayVal)"] {
//                    
//                } else {
//                 
//                    
//                }
//            }
//        
//        }
        do {
            let _ = getManagedObjectFromShow(show)
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }        
        
//        let fetchRequest = NSFetchRequest(entityName: "Show")
        
//        //3
//        do {
//            let results =
//                try managedContext.executeFetchRequest(fetchRequest)
//            let shows = results as! [Show]
//            print("HERE!!!")
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
//        
    }
    
    func getShowsForMonth(date: NSDate) -> [Show] {
        var result = []
        
        
        
        return result as! [Show]
    }

    func getShowsForDay(date: NSDate) -> [NSManagedObject] {
        var result = []
        
        let calendar = NSCalendar.currentCalendar()
        let startDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
        let endDate = calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: date, options: NSCalendarOptions())!
        
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, endDate)
        
        let fetchRequest = NSFetchRequest(entityName: "Show")
        //fetchRequest.predicate = predicate
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            result = results
            print("HERE!!!")
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return []
        }
        
        return result as! [NSManagedObject]
    }
    
    private func getManagedObjectFromShow(show: Show) -> NSManagedObject {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Show",
                                                        inManagedObjectContext:managedContext)
        
        let managedObject = NSManagedObject(entity:entity!, insertIntoManagedObjectContext:managedContext)
        
        managedObject.setValue(show.recommended, forKey: "recommended")
        managedObject.setValue(show.soldOut, forKey: "sold_out")
        managedObject.setValue(show.cancelledPostponed, forKey: "cancelled_postponed")
        managedObject.setValue(show.addedChanged, forKey: "added_changed")
        managedObject.setValue(show.comment, forKey: "comment")
        
        if let val = Int(show.venue!) {
            managedObject.setValue(NSNumber(integer:val), forKey: "venue_id")
        }
        managedObject.setValue(show.artist1, forKey: "artist1")
        managedObject.setValue(show.artist2, forKey: "artist2")
        managedObject.setValue(show.artist3, forKey: "artist3")
        managedObject.setValue(show.artist4, forKey: "artist4")
        managedObject.setValue(show.date, forKey: "date")
        managedObject.setValue(show.venuePlus, forKey: "venuePlus")
        managedObject.setValue(show.start, forKey: "start")
        managedObject.setValue(show.end, forKey: "end")
        managedObject.setValue(show.ticketfly, forKey: "ticketfly")
        managedObject.setValue(show.fb, forKey: "fb")
        managedObject.setValue(show.twitter, forKey: "twitter")
        
        return managedObject
    }
}