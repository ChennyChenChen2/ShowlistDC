//
//  ShowDetailViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 6/24/17.
//  Copyright © 2017 n/a. All rights reserved.
//

import Foundation
import EventKit

class ShowDetailViewController: AdViewController {
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveShowButton: UIButton?
    @IBOutlet weak var addToCalendarButton: UIButton!
    @IBOutlet weak var seeOtherShowsButton: UIButton!
    @IBOutlet weak var viewOnTicketflyButton: UIButton!
    
    static let storyboardId = "show-detail"
    
    var show: Show!
    var shouldShowSaveButton = true
    var showIsSaved: Bool {
        return Showlist.getSavedShowWithUniqueKey(show.uniqueKey).count > 0
    }
    
    var venueIsKnown: Bool {
        return Showlist.getVenuesWithSearchQuery(show.venue).count > 0
    }
    
    var venue: Venue? {
        var result: Venue? = nil
        if venueIsKnown {
            let venues = Showlist.getVenuesWithSearchQuery(show.venue)
            result = venues[0]
        }
        
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateFormat = formatter.defaultDateFormat()
        self.navigationItem.title = "Show Details"
        
        self.artistLabel.text = "WHO: \(show.getArtistLabelText())"
        self.venueLabel.text = "WHERE: \(show.venue)"
        self.dateLabel.text = "WHEN: \(formatter.string(from:show.date as Date)) at \(show.start)"
        
        if self.show.ticketfly == nil {
            self.viewOnTicketflyButton.removeFromSuperview()
        }
        
        if let navController = self.navigationController, navController.viewControllers.count >= 4 || !venueIsKnown {
            self.seeOtherShowsButton.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldShowSaveButton {
            customizeSaveButton()
        } else {
            self.saveShowButton?.removeFromSuperview()
        }
    }
    
    private func customizeSaveButton() {
        if showIsSaved {
            self.saveShowButton?.setTitle("Unsave this show", for: .normal)
        } else {
            self.saveShowButton?.setTitle("Save this show", for: .normal)
        }
    }
    
    @IBAction func ticketflyButtonPressed(_ sender: Any) {
        
        if let ticketflyId : String = self.show.ticketfly, let url = URL(string: "https://www.ticketfly.com/event/\(ticketflyId)") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if showIsSaved {
            Showlist.unsaveShow(show: self.show)
        } else {
            Showlist.save(self.show)
        }
        customizeSaveButton()
    }
    
    private func getStartDate() -> Date? {
        let showDate = self.show.date as Date
        let showStart = self.show.start
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.hour, .minute, .day, .month, .year], from: showDate)
        
        let formatter = DateFormatter()
        if showStart.contains(":") {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "h a"
        }
        
        formatter.locale = Locale.current
        guard let showStartDate = formatter.date(from: showStart) else {
            print("HERE!")
            return nil
        }
        let showStartComponents = calendar.dateComponents([.hour, .minute], from: showStartDate)
        dateComponents.setValue(showStartComponents.value(for: .hour), for: .hour)
        dateComponents.setValue(showStartComponents.value(for: .minute), for: .minute)
        let resultDate = calendar.date(from: dateComponents)
        
        return resultDate
    }
    
    @IBAction func addToCalButtonPressed(_ sender: Any) {
        let store = EKEventStore()
        guard let startDate = getStartDate() else {
            let alertController = UIAlertController(title: "Error getting show time", message: "Something went wrong", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let title = self.show.getArtistLabelText()
        let location = self.show.venue
        
        store.requestAccess(to: .event) {(granted, error) in
            if !granted { return }
            let event = EKEvent(eventStore: store)
            event.title = title
            event.startDate = startDate
            let calendar = Calendar.current
            let endDate = calendar.date(byAdding: .minute, value: 2*60, to: startDate)
            event.endDate = endDate!
            event.location = location
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(event, span: .thisEvent, commit: true)
                let alertController = UIAlertController(title: "Event added to iCal", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } catch {
                // Display error to user
                let alertController = UIAlertController(title: "Error saving show", message: "Something went wrong", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func seeOtherShowsButtonPressed(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: VenueDetailViewController.storyboardId) as! VenueDetailViewController
        
        guard let theVenue = self.venue else { return }
        nextVC.venue = theVenue
        if let navController = self.navigationController {
            navController.show(nextVC, sender: nil)
        }
    }
}
