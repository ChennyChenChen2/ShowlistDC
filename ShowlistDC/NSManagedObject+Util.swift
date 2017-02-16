//
//  NSManagedObject+Util.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 12/24/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    func getShowFromManagedObject(obj: NSManagedObject) -> Show {
        
        let recommended = (obj.valueForKey("recommended") as! NSNumber).boolValue
        
        let soldOut = (obj.valueForKey("sold_out") as! NSNumber).boolValue
        
        let cancelledPostponed = obj.valueForKey("cancelled_postponed") as! String
        
        let addedChanged = obj.valueForKey("added_changed") as! NSDate
        
        let comment = obj.valueForKey("comment") as! String
        
        let venue = obj.valueForKey("venue_id") as! String
        
        let artist1 = obj.valueForKey("artist1") as! String
        
        let artist2 = obj.valueForKey("artist2") as! String
        
        let artist3 = obj.valueForKey("artist3") as! String
        
        let artist4 = obj.valueForKey("artist4") as! String
        
        let date = obj.valueForKey("date") as! NSDate
        
        let venuePlus = obj.valueForKey("venuePlus") as! String
        
        let start = obj.valueForKey("start") as! String
        
        let end = obj.valueForKey("end") as! String
        
        let ticketfly = obj.valueForKey("ticketfly") as! String
        
        let fb = obj.valueForKey("fb") as! String
        
        let twitter = obj.valueForKey("twitter") as! String
        
        return Show.init(recommended: recommended, soldOut: soldOut, cancelledPostponed: cancelledPostponed, addedChanged: addedChanged, comment: comment, venue: venue, artist1: artist1, artist2: artist2, artist3: artist3, artist4: artist4, date: date, venuePlus: venuePlus, start: start, end: end, ticketfly: ticketfly, fb: fb, twitter: twitter)
    }
    
}