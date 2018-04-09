//
//  SLDCSavedVenueViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 3/30/18.
//  Copyright © 2018 n/a. All rights reserved.
//

import Foundation

class SLDCSavedVenueViewController: UITableViewController {
    
    var savedVenues: [SavedVenue] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllButtonPressed))
        rightBarButtonItem.title = "Clear All"
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func clearAllButtonPressed() {
        if savedVenues.count > 0 {
            let alertController = UIAlertController(title: "Clear all saved venues?", message: "Are you sure?", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
                self.unsaveAllVenues()
            }
            let noAction = UIAlertAction(title: "No", style: .destructive) { (action) in }
            alertController.addAction(alertAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func unsaveAllVenues() {
        self.savedVenues = []
        Showlist.unsaveAllVenues()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.savedVenues = Showlist.getAllSavedVenues()
        
        self.tableView.reloadData()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedVenues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedVenueCell")!
        let venue = self.savedVenues[indexPath.row]
        
        cell.textLabel?.text = venue.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let venue = self.savedVenues[indexPath.row]
        let venueDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: VenueDetailViewController.storyboardId) as! VenueDetailViewController
        venueDetailVC.venue = venue
        venueDetailVC.shouldShowSaveButton = false
        if let navController = self.navigationController {
            navController.show(venueDetailVC, sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let venue = self.savedVenues[indexPath.row]
            
            Showlist.unsaveVenue(venue: venue)
            self.savedVenues = Showlist.getAllSavedVenues()
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
}
