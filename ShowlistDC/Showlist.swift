//
//  Showlist.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 11/27/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import CoreData
import RealmSwift

class Showlist {
    
    static let kShowAddedNotification = Notification.Name("showAdded")
    
    class func getAllVenues() -> [Venue] {
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(Venue.self)
        return Array(result)
    }
    
    class func getAllSavedVenues() -> [SavedVenue] {
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(SavedVenue.self)
        return Array(result)
    }
    
    class func getAllSavedShows() -> [SavedShow] {
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(SavedShow.self)
        return Array(result)
    }
    
    class func getVenuesWithSearchQuery(_ query: String) -> [Venue] {
        let predicate = NSPredicate(format: "name contains[cd] %@ OR address contains[cd] %@", query, query)
        
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(Venue.self).filter(predicate)
        
        return Array(result)
    }
    
    class func getSavedVenuesWithName(_ query: String) -> [SavedVenue] {
        let predicate = NSPredicate(format: "name == %@", query)
        
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(SavedVenue.self).filter(predicate)
        
        return Array(result)
    }
    
    class func unsaveVenue(venue: Venue) {
        let predicate = NSPredicate(format: "name == %@", venue.name as CVarArg)
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(SavedVenue.self).filter(predicate)
        try! realm.write {
            realm.delete(result)
        }
    }
    
    class func unsaveAllVenues() {
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(SavedVenue.self)
        try! realm.write {
            realm.delete(result)
        }
    }
    
    class func unsaveAllShows() {
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(SavedShow.self)
        try! realm.write {
            realm.delete(result)
        }
    }
    
    class func unsaveShow(show: Show) {
        let predicate = NSPredicate(format: "uniqueKey == %@", show.uniqueKey as CVarArg)
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(SavedShow.self).filter(predicate)
        try! realm.write {
            realm.delete(result)
        }
    }
    
    class func getSavedShowWithUniqueKey(_ query: String) -> [SavedShow] {
        let predicate = NSPredicate(format: "uniqueKey == %@", query)
        
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(SavedShow.self).filter(predicate)
        
        return Array(result)
    }
    
    class func save(_ show: Show) {
        let savedShow = show.getSavedShow()
        let realm = try! Realm()
        //        print("\(realm.configuration.fileURL!.absoluteString)")
        
        try! realm.write {
            realm.add(savedShow, update: true)
        }
    }
    
    class func save(_ venue: Venue) {
        let savedVenue = venue.getSavedVenue()
        let realm = try! Realm()
//        print("\(realm.configuration.fileURL!.absoluteString)")
        
        try! realm.write {
            realm.add(savedVenue, update: true)
        }
    }
    
    class func add(_ show: Show) {
        let realm = try! Realm()
//        print("\(realm.configuration.fileURL!.absoluteString)")
        
        try! realm.write {
            realm.add(show, update: true)
        }
    }
    
    class func add(_ venue: Venue) {
        let realm = try! Realm()
//        print("\(realm.configuration.fileURL!.absoluteString)")
        
        try! realm.write {
            realm.add(venue, update: true)
        }
    }
    
    class func getShowsWithSearchQuery(_ query: String) -> [Show] {
        let predicate = NSPredicate(format: "uniqueKey contains[cd] %@", query)
        
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(Show.self).filter(predicate)
        
        return Array(result)
    }

    class func getShowsForMonth(_ date: Date) -> [Show] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var dateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
        guard let monthRange = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }

        dateComponents.month = dateComponents.month
        dateComponents.day = monthRange.upperBound
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        
        let startDate = (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: date, options: NSCalendar.Options())!
        guard let endDate = (calendar as NSCalendar).date(from: dateComponents) else {
            return []
        }

        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as CVarArg, endDate as CVarArg)
        
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(Show.self).filter(predicate).sorted(byKeyPath: "date")
        
        return Array(result)
    }
    
    class func getShowsForDate(_ date: Date) -> [Show] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let startDate = (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: date, options: NSCalendar.Options())!
        
        let predicate = NSPredicate(format: "date >= %@", startDate as CVarArg)
        
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(Show.self).filter(predicate).sorted(byKeyPath: "date")
        
        return Array(result)
    }
    
    class func getShowCount() -> Int {
        let realm = try! Realm()
        realm.refresh()
        return realm.objects(Show.self).count
    }
    
    class func deleteOldVenues() {
        
    }
    
    class func deleteShowsBeforeToday() {
        let today = Date()
        let predicate = NSPredicate(format: "date < %@", today as CVarArg)
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(Show.self).filter(predicate)
        try! realm.write {
            realm.delete(result)
        }
    }
}
