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
    
    static let shared = Showlist()
    fileprivate init() {}
    
    static let kShowAddedNotification = Notification.Name("showAdded")
    
    func add(_ show: Show) {
        let realm = try! Realm()
        print("\(realm.configuration.fileURL!.absoluteString)")
        
        try! realm.write {
            realm.add(show, update: true)
        }
    }
    
    func getShowsForMonth(_ date: Date) -> [Show] {
        let result : [Show] = []
        
        
        
        return result
    }
    
    func getShowsWithSearchQuery(_ query: String) -> [Show] {
        let predicate = NSPredicate(format: "uniqueKey contains[cd] %@", query)
        
        let realm = try! Realm()
        realm.refresh()
        let result = realm.objects(Show.self).filter(predicate)
        
        return Array(result)
    }

    func getShowsForDay(_ date: Date) -> [Show] {
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
    
    func getShowCount() -> Int {
        
        let realm = try! Realm()
        realm.refresh()
        return realm.objects(Show.self).count
        
    }
}
