//
//  AdViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 1/9/19.
//  Copyright © 2019 n/a. All rights reserved.
//

import Foundation
import GoogleMobileAds

class AdViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerAdView: GADBannerView!
    fileprivate let bannerAdIdPlistKey = "kGoogleBannerAdUnitId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let adID = Bundle.main.infoDictionary?[bannerAdIdPlistKey] as? String {
            self.bannerAdView.rootViewController = self
            self.bannerAdView.adUnitID = adID
            self.bannerAdView.load(GADRequest())
            self.bannerAdView.delegate = self
        }
    }
}
