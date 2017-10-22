//
//  ShowDetailViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 6/24/17.
//  Copyright © 2017 n/a. All rights reserved.
//

import Foundation
import EventKit

class ShowDetailViewController: UIViewController {
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveShowButton: UIButton!
    @IBOutlet weak var addToCalendarButton: UIButton!
    @IBOutlet weak var openVenueWebsiteButton: UIButton!
    var show: Show!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateFormat = formatter.defaultDateFormat()
        self.navigationItem.title = "Show Details"
        self.artistLabel.text = "WHO: \(show.getArtistLabelText())"
        self.venueLabel.text = "WHERE: \(show.venue)"
        self.dateLabel.text = "WHEN: \(formatter.string(from:show.date as Date))"
    }
    
    @IBAction func addToCalButtonPressed(_ sender: Any) {
        let store = EKEventStore()
        let showDate = self.show.date as Date
        store.requestAccess(to: .event) {(granted, error) in
            if !granted { return }
            let event = EKEvent(eventStore: store)
            event.title = self.artistLabel.text!
            event.startDate = showDate
            let calendar = Calendar.current
            let endDate = calendar.date(byAdding: .minute, value: 3*60, to: showDate)
            event.endDate = endDate!
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(event, span: .thisEvent, commit: true)
                let alertController = UIAlertController(title: "Event added to iCal", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } catch {
                // Display error to user
            }
        }
    }
    
}
