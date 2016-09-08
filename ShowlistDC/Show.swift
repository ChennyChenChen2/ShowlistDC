//
//  Show.swift
//  ShowListDC
//
//  Created by Jonathan Chen on 5/4/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation

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
    
    init() {
        self.recommended = nil
        self.soldOut = nil
        self.cancelledPostponed = nil
        self.addedChanged = nil
        self.comment = nil
        self.venue = nil
        self.artist1 = nil
        self.artist2 = nil
        self.artist3 = nil
        self.artist4 = nil
        self.date = nil
        self.venuePlus = nil
        self.start = nil
        self.end = nil
        self.ticketfly = nil
        self.fb = nil
        self.twitter = nil
    }
    
    init(recommended: Bool, soldOut: Bool, cancelledPostponed: String?, addedChanged: NSDate?, comment: String?, venue: String, artist1: String, artist2: String?, artist3: String?, artist4: String?, date: NSDate, venuePlus: String?, start: String, end: String, ticketfly: String?, fb: String?, twitter: String?) {
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