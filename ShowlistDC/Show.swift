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

class Show: Object, SavableItem, NSCopying {
    
    dynamic var uniqueKey : String = ""
    private func compoundKeyValue() -> String {
        return "\(artist1), \(venue), \(start), \(getDateString())"
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
            venue.sanitizeEncodings()
            uniqueKey = compoundKeyValue()              // J
        }
    }
    dynamic var venuePlus : String = ""                 // K
        { didSet {
            venuePlus.sanitizeEncodings()
            uniqueKey = compoundKeyValue()
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
    
    dynamic var start : String = "9 PM"                // Default: 9 PM... see in Venue+ for details
        { didSet {
            start = start.trimmingCharacters(in: .whitespaces)
        }
        
    }
    dynamic var ticketfly : String? = nil               // X ... inject into URL with this format: https://www.ticketfly.com/purchase/event/1639796
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
        
        if self.isCancelledShow {
            result += "-- CANCELLED"
        } else if self.soldOut {
            result += "-- SOLD OUT"
        } else if self.recommended {
            result += "-- RECOMMENDED!"
        }
        
        return result
    }
    
    var isCancelledShow: Bool {
        if let theCancelledPostponed = self.cancelledPostponed {
            return theCancelledPostponed.contains("CANCELLED")
        } else {
            return false
        }
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
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Show()
        copy.artist1 = self.artist1
        copy.artist2 = self.artist2
        copy.artist3 = self.artist3
        copy.artist4 = self.artist4
        copy.start = self.start
        copy.recommended = self.recommended
        copy.soldOut = self.soldOut
        copy.cancelledPostponed = self.cancelledPostponed
        copy.addedChanged = self.addedChanged
        copy.comment = self.comment
        copy.date = self.date
        copy.venue = self.venue
        copy.venuePlus = self.venuePlus
        copy.ticketfly = self.ticketfly
        copy.fb = self.fb
        copy.twitter = self.twitter
        return copy
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
        if self.contains("<s>") {
            self = self.replacingOccurrences(of: "<s>", with: "")
        }
        if self.contains("</s>") {
            self = self.replacingOccurrences(of: "</s>", with: "")
        }
    }
    
    func getStrikethrough() -> NSAttributedString {
        let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributedString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    func matches(forRegex regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
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
