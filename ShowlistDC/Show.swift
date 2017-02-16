//
//  Show.swift
//  ShowListDC
//
//  Created by Jonathan Chen on 5/4/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import CoreData

class Show {
                                        // COLUMN INDECIES:
    var recommended : Bool?             // A
    var soldOut : Bool?                 // B
    var cancelledPostponed : String?    // C
    var addedChanged : NSDate?          // D
    var comment : String?               // E
    
    var date : NSDate?                  // G
    
    // TODO: MAKE A VENUE POJO
    var venue : String?                 // J
    var venuePlus : String?             // K
    
    var artist1 : String?               // O
    var artist2 : String?               // P
    var artist3 : String?               // Q
    var artist4 : String?               // R
    
    var start : String?                 // Default: 7 PM... see in Venue+ for details
    var end : String?                   // Should we even have this?
    var ticketfly : String?             // X
    var fb : String?                    // Y
    var twitter : String?               // ???
    
//    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//        super.init(entity: entity, insertIntoManagedObjectContext: context)
////        commonInit()
//    }
    
//    init() {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//
//        let entity =  NSEntityDescription.entityForName("Show",
//                                                        inManagedObjectContext:managedContext)
//
//        super.init(entity:entity!, insertIntoManagedObjectContext:nil)
//        commonInit()
//    }
    
    init() {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//        
//        let entity =  NSEntityDescription.entityForName("Show",
//                                                        inManagedObjectContext:managedContext)
//        
//        self = NSManagedObject(entity:entity!, insertIntoManagedObjectContext:managedContext)
        self.recommended = false
        self.soldOut = false
        self.cancelledPostponed = ""
        self.addedChanged = nil
        self.comment = ""
        self.venue = ""
        self.artist1 = ""
        self.artist2 = ""
        self.artist3 = ""
        self.artist4 = ""
        self.date = nil
        self.venuePlus = ""
        self.start = ""
        self.end = ""
        self.ticketfly = ""
        self.fb = ""
        self.twitter = ""
    }
    
    init(recommended: Bool, soldOut: Bool, cancelledPostponed: String?, addedChanged: NSDate?, comment: String?, venue: String, artist1: String, artist2: String?, artist3: String?, artist4: String?, date: NSDate, venuePlus: String?, start: String, end: String, ticketfly: String?, fb: String?, twitter: String?) {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//        let entity =  NSEntityDescription.entityForName("Show",
//                                                        inManagedObjectContext:managedContext)
//        super.init(entity:entity!, insertIntoManagedObjectContext:managedContext)
        self.recommended = recommended
        self.soldOut = soldOut
        self.cancelledPostponed = cancelledPostponed!
        self.addedChanged = addedChanged!
        self.comment = comment!
        self.venue = venue
        self.artist1 = artist1
        self.artist2 = artist2!
        self.artist3 = artist3!
        self.artist4 = artist4!
        self.date = date
        self.venuePlus = venuePlus!
        self.start = start
        self.end = end
        self.ticketfly = ticketfly!
        self.fb = fb!
        self.twitter = twitter!
    }
    
}