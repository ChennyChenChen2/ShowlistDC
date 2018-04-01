//
//  SLDCMoreTableViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 7/27/17.
//  Copyright © 2017 n/a. All rights reserved.
//

import Foundation

class SLDCMoreTableViewController: UITableViewController {
    
    let kCellIdentifier = "MoreCell"
    let kSavedShowsKey = "Saved Shows"
    let kSavedVenuesKey = "Saved Venues"
    let kAboutKey = "About"
    let kContactUsKey = "Contact Us"
    
    var rows : [String] = []
    var iconPairings : [String : UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "More"
        rows = [kSavedShowsKey, kSavedVenuesKey, kAboutKey, kContactUsKey]
        iconPairings  = [   kSavedShowsKey : #imageLiteral(resourceName: "Icon-SavedShows"),
                            kSavedVenuesKey : #imageLiteral(resourceName: "Icon-SavedVenues"),
                            kAboutKey : #imageLiteral(resourceName: "Icon-About"),
                            kContactUsKey : #imageLiteral(resourceName: "Icon-ContactUs")]
    }
    
    // pragma mark - UITableViewDataSource methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier)!
        let title = rows[indexPath.row]
        let image = iconPairings[title]
        cell.imageView?.image = image
        cell.textLabel?.text = title
        
        return cell
    }
    
    // pragma mark - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), let title = cell.textLabel?.text {
            if title == kAboutKey {
                self.performSegue(withIdentifier: "AboutSegue", sender: nil)
            } else if title == kContactUsKey {
                self.performSegue(withIdentifier: "ContactSegue", sender: nil)
            } else if title ==  kSavedVenuesKey {
                self.performSegue(withIdentifier: "SavedVenueSegue", sender: nil)
            } else if title == kSavedShowsKey {
                self.performSegue(withIdentifier: "SavedShowSegue", sender: nil)
            }
        }
    }
    
}
