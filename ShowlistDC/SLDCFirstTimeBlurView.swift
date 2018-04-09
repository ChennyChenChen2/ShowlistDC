//
//  SLDCFirstTimeBlurView.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 4/5/18.
//  Copyright © 2018 n/a. All rights reserved.
//

import Foundation

class SLDCFirstTimeBlurView: UIViewController {
    
    static let kStoryboardId = "blurView"
    
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.closeButton.layer.borderWidth = 1
        self.closeButton.layer.borderColor = UIColor.black.cgColor
        self.closeButton.layer.cornerRadius = self.closeButton.frame.size.height / 2
    }
    
    @IBAction func closeBlurView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addBlurView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.contentView.addSubview(vibrancyView)
        self.view.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            ])
        
        NSLayoutConstraint.activate([
            vibrancyView.heightAnchor.constraint(equalTo: blurView.contentView.heightAnchor),
            vibrancyView.widthAnchor.constraint(equalTo: blurView.contentView.widthAnchor),
            vibrancyView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            vibrancyView.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
        ])
        
//        NSLayoutConstraint.activate([
//            .centerXAnchor.constraint(equalTo: vibrancyView.contentView.centerXAnchor),
//            subview.centerYAnchor.constraint(equalTo: vibrancyView.contentView.centerYAnchor),
//            ])
    }
    
}
