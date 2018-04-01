//
//  SLDCVenuesViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 3/24/18.
//  Copyright © 2018 n/a. All rights reserved.
//

import Foundation

class SLDCVenuesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var gestureRecognizer: UITapGestureRecognizer!
    
    private var venues: [Venue] = []
    private let cellId = "venueCell"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.venues = Showlist.getAllVenues() // TODO: Add notification observer instead of putting in viewWillAppear
        self.tableView.reloadData()
        self.view.removeGestureRecognizer(self.gestureRecognizer)
    }
    
    // MARK - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.venues = Showlist.getAllVenues()
        } else {
            self.venues = Showlist.getVenuesWithSearchQuery(searchText)
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addGestureRecognizer(self.gestureRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.removeGestureRecognizer(self.gestureRecognizer)
    }
    
    @IBAction func gestureRecognizerTriggered(_ sender: Any) {
        self.tappedToDismissKeyboard()
    }
    
    func tappedToDismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tappedToDismissKeyboard()
    }
    
    // MARK - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! VenuesTableViewCell
        let venue = venues[indexPath.row]
        
        cell.venueNameLabel.text = venue.name
        cell.addressLabel.text = venue.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let venue = self.venues[indexPath.row]
        let venueDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: VenueDetailViewController.storyboardId) as! VenueDetailViewController
        venueDetailVC.venue = venue
        if let navController = self.navigationController {
            navController.show(venueDetailVC, sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
