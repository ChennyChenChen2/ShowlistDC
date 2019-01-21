//
//  SLDCContactUsViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 7/28/17.
//  Copyright © 2017 n/a. All rights reserved.
//

import Foundation
import MessageUI

class SLDCContactUsViewController: AdViewController, MFMailComposeViewControllerDelegate {
    
    @IBAction func socialMediaButtonPressed(_ sender: Any) {
        let button = sender as! UIButton
        if let title : String = button.title(for: .normal), let url = URL(string: title) {
            UIApplication.shared.openURL(url)
        }
    }

    @IBAction func emailPressed(_ sender: Any) {
        let button = sender as! UIButton
        if let email : String = button.title(for: .normal) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([email])
                mail.setSubject("Contact Us")
                mail.setMessageBody("<p>Sent via ShowlistDC app for iOS</p>", isHTML: true)
                present(mail, animated: true)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
