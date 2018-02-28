//
//  SLDCCalendarHeader.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 10/10/16.
//  Copyright © 2016 n/a. All rights reserved.
//

import UIKit
import JTAppleCalendar
import QuartzCore

class SLDCCalendarHeader : JTAppleHeaderView {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    weak var delegate: SLDCCalendarHeaderDelegate?
    var refreshButtonShouldRotate: Bool {
        get {
            return SpreadsheetReader.shared.isLoadingData
        }
    }
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector:#selector(refreshButtonStateChanged(_:)), name:ReloadConstants.kReloadDidBeginNoteName, object: NSNumber(booleanLiteral: true))

        rotateRefreshButton()
    }
    
    @IBAction func rightArrowPressed(_ sender: Any) {
        self.delegate?.didPressRightArrow()
    }
    
    @IBAction func leftArrowPressed(_ sender: Any) {
        self.delegate?.didPressLeftArrow()
    }
    
    @IBAction func todayButtonPressed(_ sender: Any) {
        self.delegate?.didPressTodayButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if ((self.refreshButton.layer.presentation()?.hitTest(touchLocation)) != nil) {
                self.delegate?.didPressRefreshButton(self.refreshButton)
                break
            }
        }
    }
    
    @objc func refreshButtonStateChanged(_ note: Notification) {
        self.rotateRefreshButton()
    }
    
    private func rotateRefreshButton() {
        if self.refreshButtonShouldRotate {
            let duration: TimeInterval = 5.0
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
                self.refreshButton.transform = self.refreshButton.transform.rotated(by: CGFloat(Float.pi))
            }) { finished in
                self.rotateRefreshButton()
            }
        } else {
            self.refreshButton.layer.removeAllAnimations()
        }
    }
}

protocol SLDCCalendarHeaderDelegate: class {
    func didPressRightArrow()
    func didPressLeftArrow()
    func didPressRefreshButton(_ button: UIButton)
    func didPressTodayButton()
}
