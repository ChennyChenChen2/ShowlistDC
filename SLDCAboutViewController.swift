//
//  SLDCAboutViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 10/22/17.
//  Copyright © 2017 n/a. All rights reserved.
//

import Foundation

class SLDCAboutViewController : UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
}
