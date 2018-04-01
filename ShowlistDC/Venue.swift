//
//  Venue.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 11/30/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Venue: Object, SavableItem {
    
    dynamic var name: String = "" {
        didSet {
            name.sanitizeEncodings()
        }
    }
    dynamic var address: String = "" {
        didSet {
            address.sanitizeEncodings()
        }
    }
    dynamic var phone: String = "" {
        didSet {
            phone.sanitizeEncodings()
        }
    }
    dynamic var mapLink: String = "" { // TODO: Make into URL!
        didSet {
            mapLink.sanitizeEncodings()
        }
    }
    dynamic var fb: String? = nil { // TODO: Make into URL!
        didSet {
            fb?.sanitizeEncodings()
        }
    }
    dynamic var twitter: String? = nil { // TODO: Make into URL!
        didSet {
            twitter?.sanitizeEncodings()
        }
    }
    dynamic var instagram: String? = nil { // TODO: Make into URL!
        didSet {
            instagram?.sanitizeEncodings()
        }
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
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
    
    func savedItemType() -> AnyClass {
        return SavedVenue.self
    }
    
    func savedItemDisplay() -> String {
        return self.name
    }
    
    func detailVCClass() -> AnyClass {
        return VenueDetailViewController.self
    }
}

class SavedVenue: Venue {}
