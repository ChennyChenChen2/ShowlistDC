//
//  VenueDetailViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 3/26/18.
//  Copyright © 2018 n/a. All rights reserved.
//

import Foundation
import MapKit

class VenueDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveVenueButton: UIButton?
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var showsAtVenueButton: UIButton!
    
    static let storyboardId = "venue-detail"
    
    var venue: Venue!
    var shouldShowSaveButton = true
    
    var venueIsSaved: Bool {
        return Showlist.getSavedVenuesWithName(self.venue.name).count > 0
    }
    
    var venueHasShows: Bool {
        return Showlist.getShowsWithSearchQuery(self.venue.name).count > 0 ||
        Showlist.getShowsWithSearchQuery(self.venue.address).count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.venue.name
        
        self.nameLabel.text = self.venue.name
        self.addressLabel.text = self.venue.address
        self.phoneLabel.text = self.venue.phone
        
        self.setupMapView()
        
        if let fbLink = self.venue.fb {
            self.fbButton.accessibilityIdentifier = fbLink
        } else {
            self.fbButton.removeFromSuperview()
        }
        
        if let twitterLink = self.venue.twitter {
            let twitterTitle = "https://twitter.com/\(twitterLink)"
            self.twitterButton.accessibilityIdentifier = twitterTitle
        } else {
            self.twitterButton.removeFromSuperview()
        }
        
        if let instagramLink = self.venue.instagram {
            let instaTitle = "https://www.instagram.com/\(instagramLink)"
            self.instagramButton.accessibilityIdentifier = instaTitle
        } else {
            self.instagramButton.removeFromSuperview()
        }
        
        if !venueHasShows {
            self.showsAtVenueButton.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldShowSaveButton {
            self.customizeSaveButton()
        } else {
            self.saveVenueButton?.removeFromSuperview()
        }
    }
    
    private func setupMapView() {
        let address = self.venue.address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let thePlacemarks = placemarks, error == nil {
                let placemark = thePlacemarks[0]
                guard let coordinate = placemark.location?.coordinate else { self.mapView.removeFromSuperview(); return }
                let pin = MKPointAnnotation()
                pin.coordinate = coordinate
                self.mapView.setRegion(MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.001, 0.001)), animated: true)
                self.mapView.addAnnotation(pin)
            } else {
                self.mapView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func socialMediaButtonPressed(_ sender: Any) {
        let button = sender as! UIButton
        if let id = button.accessibilityIdentifier, let url = URL(string: id) {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func customizeSaveButton() {
        if venueIsSaved {
            self.saveVenueButton?.setTitle("Unsave venue", for: .normal)
        } else {
            self.saveVenueButton?.setTitle("Save venue", for: .normal)
        }
    }
    
    @IBAction func savedVenueButtonPressed(_ sender: Any) {
        if venueIsSaved {
            Showlist.unsaveVenue(venue: self.venue)
        } else {
            Showlist.save(self.venue)
        }
        self.customizeSaveButton()
    }
    
    @IBAction func showsAtVenueButtonPressed(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ShowsInVenueTableViewController.storyboardId) as! ShowsInVenueTableViewController
        
        nextVC.venue = self.venue
        if let navController = self.navigationController {
            navController.show(nextVC, sender: nil)
        }
        
    }
}

extension String {
    
    func getRegion() -> MKCoordinateRegion? {
        var result: MKCoordinateRegion? = nil
        
        if self.range(of: "&sll=") != nil && self.range(of: "&sspn") != nil {
            if let coordString = self.slice(from: "&sll=", to: "&sspn") {
                guard let commaIndex = coordString.index(of: ",") else { return nil }
                guard let latCoord = CLLocationDegrees(coordString.substring(to: coordString.index(commaIndex, offsetBy: -1))) else { return nil }
                guard let longCoord = CLLocationDegrees(coordString.substring(from: coordString.index(commaIndex, offsetBy: 1))) else { return nil }
                let coord = CLLocationCoordinate2DMake(latCoord, longCoord)
                result = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(CLLocationDegrees(0.01), CLLocationDegrees(0.01)))
            }
        }
        
        return result
    }
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
    
}
