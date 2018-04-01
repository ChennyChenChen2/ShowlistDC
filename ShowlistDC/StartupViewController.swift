//
//  ViewController.swift
//  ShowListDC
//
//  Created by Jonathan Chen on 2/24/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import UIKit

class StartupViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.activityIndicator.startAnimating()
        let reader = SpreadsheetReader.shared
        reader.generateData()
        
        self.activityIndicator.stopAnimating()
        
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController");
        self.present(newVC!, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
