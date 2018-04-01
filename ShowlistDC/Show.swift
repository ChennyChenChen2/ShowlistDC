//
//  Show.swift
//  ShowListDC
//
//  Created by Jonathan Chen on 5/4/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

protocol SavableItem {
    func savedItemType() -> AnyClass
    func savedItemDisplay() -> String
    func detailVCClass() -> AnyClass
}

class Show: Object, SavableItem {
    
    dynamic var uniqueKey : String = ""
    private func compoundKeyValue() -> String {
        var theKey = ""
        if let theVenuePlus = venuePlus {
            theKey = "\(artist1), \(venue) \(theVenuePlus) \(getDateString())"
        }
        return theKey
    }
                                                  // COLUMN INDECIES:
    dynamic var recommended : Bool = false              // A
    dynamic var soldOut : Bool = false                  // B
    dynamic var cancelledPostponed : String? = nil      // C
    dynamic var addedChanged : String? = nil            // D
    dynamic var comment : String? = nil                 // E
    
    dynamic var date : NSDate = NSDate() {
        didSet {
            uniqueKey = compoundKeyValue()
        }
    }                                                   // G
    
    // TODO: MAKE A VENUE POJO?
    dynamic var venue : String = "" {
        didSet {
//            uniqueKey = compoundKey()
        }
    }                                                   // J
    dynamic var venuePlus : String? = nil               // K
        { didSet {
               uniqueKey = compoundKeyValue()
            // TODO: use regex to find h:mm pattern in string and add it to start var, iff start has been set
        }
    }
    
    dynamic var artist1 : String = ""                   // O
        { didSet {
            artist1.sanitizeEncodings()
            uniqueKey = compoundKeyValue()
        }
    }
    
    dynamic var artist2 : String? = nil                 // P
        { didSet {
            artist2?.sanitizeEncodings()
        }
    }
    
    dynamic var artist3 : String? = nil                 // Q
        { didSet {
            artist3?.sanitizeEncodings()
        }
    }
    
    dynamic var artist4 : String? = nil                 // R
        { didSet {
            artist4?.sanitizeEncodings()
        }
    }
    
    dynamic var start : String = "7 PM"                 // Default: 7 PM... see in Venue+ for details
        { didSet {
            // TODO: use regex to find h:mm pattern in venuePlus and add it to start var, iff venuePlus has been set
        }
    }
    dynamic var end : String   = ""                     // Should we even have this?
    dynamic var ticketfly : String? = nil               // X
    dynamic var fb : String? = nil                      // Y
    dynamic var twitter : String? = nil                 // ???
    
    override static func primaryKey() -> String? {
        return "uniqueKey"
    }
    
    func getArtistLabelText() -> String {
        var result = artist1
        
        if let theArtist2 = artist2, theArtist2 != "" {
            result += ", \(theArtist2)"
        }
        
        if let theArtist3 = artist3, theArtist3 != "" {
            result += ", \(theArtist3)"
        }
        
        if let theArtist4 = artist4, theArtist4 != "" {
            result += ", \(theArtist4)"
        }
        
        return result
    }

    func getDateString() -> String {
        return (date as Date).getStringFromSLDCFormat()
    }
    
    func getWhenText() -> String {
        return "\(self.getDateString()) at \(self.start)"
    }
    
    func savedItemType() -> AnyClass {
        return SavedShow.self
    }
    
    func savedItemDisplay() -> String {
        return self.uniqueKey
    }
    
    func detailVCClass() -> AnyClass {
        return ShowDetailViewController.self
    }
    
    func getSavedShow() -> SavedShow {
        let savedShow = SavedShow()
        savedShow.artist1 = self.artist1
        savedShow.artist2 = self.artist2
        savedShow.artist3 = self.artist3
        savedShow.artist4 = self.artist4
        savedShow.start = self.start
        savedShow.end = self.end
        savedShow.recommended = self.recommended
        savedShow.soldOut = self.soldOut
        savedShow.cancelledPostponed = self.cancelledPostponed
        savedShow.addedChanged = self.addedChanged
        savedShow.comment = self.comment
        savedShow.date = self.date
        savedShow.venue = self.venue
        savedShow.venuePlus = self.venuePlus
        savedShow.ticketfly = self.ticketfly
        savedShow.fb = self.fb
        savedShow.twitter = self.twitter
        return savedShow
    }
    
    /*
     func getSavedVenue() -> SavedVenue {
     let savedVenue = SavedVenue()
     savedVenue.name = self.name
     savedVenue.address = self.address
     savedVenue.phone = self.phone
     savedVenue.mapLink = self.mapLink
     savedVenue.fb = self.fb
     savedVenue.twitter = self.twitter
     savedVenue.instagram = self.instagram
     return savedVenue
     }
 */
}

class SavedShow: Show {}

extension String {
    mutating func sanitizeEncodings() {
        if self.contains("&amp;") {
            self = self.replacingOccurrences(of: "&amp;", with: "&")
        }
        if self.contains("<em>") {
            self = self.replacingOccurrences(of: "<em>", with: "")
        }
        if self.contains("</em>") {
            self = self.replacingOccurrences(of: "</em>", with: "")
        }
        if self.contains("<b>") {
            self = self.replacingOccurrences(of: "<b>", with: "")
        }
        if self.contains("</b>") {
            self = self.replacingOccurrences(of: "</b>", with: "")
        }
    }
}

extension Date {
    func getStringFromSLDCFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: self)
    }
}
