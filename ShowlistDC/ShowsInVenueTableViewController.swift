//
//  ShowsInVenueTableViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 4/5/18.
//  Copyright © 2018 n/a. All rights reserved.
//

import Foundation

class ShowsInVenueTableViewController: UITableViewController {
    
    static let storyboardId = "showsInVenueVC"
    let cellId = "showInVenueCell"
    
    var venue: Venue!
    var shows: [Show] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Shows at \(venue.name)"
        
        self.shows = Showlist.getShowsWithSearchQuery(venue.name)
        
        self.tableView.reloadData()
    }
    
    //MARK --  UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)!
        let show = self.shows[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = formatter.defaultDateFormat()
        let dateString = formatter.string(from: show.date as Date)
        
        let title = "\(show.artist1), \(dateString)"
        
        if show.isCancelledShow {
            cell.textLabel?.attributedText = title.getStrikethrough()
        } else {
            cell.textLabel?.text = title
        }
        
        return cell
    }
    
    // MARK -- UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let show = self.shows[indexPath.row]
        let showDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ShowDetailViewController.storyboardId) as! ShowDetailViewController
        showDetailVC.show = show
        if let navController = self.navigationController {
            navController.show(showDetailVC, sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     let show = self.savedShows[indexPath.row]
     let showDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ShowDetailViewController.storyboardId) as! ShowDetailViewController
     showDetailVC.show = show
     showDetailVC.shouldShowSaveButton = false
     if let navController = self.navigationController {
     navController.show(showDetailVC, sender: nil)
     }
     tableView.deselectRow(at: indexPath, animated: true)
     }
 
 */
    
}
