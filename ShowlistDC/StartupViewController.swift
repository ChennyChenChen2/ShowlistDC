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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.activityIndicator.startAnimating()
        let _ = SpreadsheetReader.init()
        self.activityIndicator.stopAnimating()
        
        let newVC = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController");
        self.presentViewController(newVC!, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}