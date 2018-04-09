//
//  SLDCSavedShowViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 3/30/18.
//  Copyright © 2018 n/a. All rights reserved.
//

import Foundation

class SLDCSavedShowViewController: UITableViewController {
    
    var savedShows: [SavedShow] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllButtonPressed))
        rightBarButtonItem.title = "Clear All"
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func clearAllButtonPressed() {
        if savedShows.count > 0 {
            let alertController = UIAlertController(title: "Clear all saved shows?", message: "Are you sure?", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
                self.unsaveAllShows()
            }
            let noAction = UIAlertAction(title: "No", style: .destructive) { (action) in }
            alertController.addAction(alertAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func unsaveAllShows() {
        self.savedShows = []
        Showlist.unsaveAllShows()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.savedShows = Showlist.getAllSavedShows()
        
        self.tableView.reloadData()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedShows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedShowCell")!
        let show = self.savedShows[indexPath.row]
        
        cell.textLabel?.text = show.uniqueKey
        
        return cell
    }
    
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let show = self.savedShows[indexPath.row]
            
            Showlist.unsaveShow(show: show)
            self.savedShows = Showlist.getAllSavedShows()
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
}
