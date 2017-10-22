//
//  SLDCSearchViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 7/30/17.
//  Copyright © 2017 n/a. All rights reserved.
//

import Foundation

class SLDCSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let kSearchCellID = "searchCell"
    var results: [Show] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.title = "Search"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.results = []
        } else {
            let showlist = Showlist.shared
            results = showlist.getShowsWithSearchQuery(searchText)
        }
        self.tableView.reloadData()
    }
    
    // pragma mark - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSearchCellID)!
        let show = self.results[indexPath.row]
        let title = show.uniqueKey
        cell.textLabel?.text = title
        return cell
    }
    
    // pragma mark - UITableViewDelegate

    // TODO: Refactor into some kind of navigation manager-- repeated code from SLDCShowlistViewController didSelectCell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let show = self.results[indexPath.row]
        let showDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "show-detail") as! ShowDetailViewController
        showDetailVC.show = show
        if let navController = self.navigationController {
            navController.show(showDetailVC, sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
