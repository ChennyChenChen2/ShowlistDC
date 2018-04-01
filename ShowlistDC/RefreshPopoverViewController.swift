//
//  RefreshPopoverViewController.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 11/19/17.
//  Copyright © 2017 n/a. All rights reserved.
//

import Foundation

class RefreshPopoverViewController: UIViewController {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var reloadButton: UIButton!
    var rotate: Bool = false
    let defaultLoadingLabelText = "Ready to reload shows"
    @objc let reader: SpreadsheetReader = SpreadsheetReader.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateRefreshButtonToBeEnabled(!reader.isLoadingData)
        
        NotificationCenter.default.addObserver(self, selector:#selector(refreshButtonStateChanged(_:)), name:ReloadConstants.kReloadCompleteNoteName, object:NSNumber(booleanLiteral: true))
        NotificationCenter.default.addObserver(self, selector:#selector(updateProgress), name:ReloadConstants.kUpdatedRowsNoteName, object:nil)
    }
    
    //Updating the popover size
    override var preferredContentSize: CGSize {
        get {
            let width = progressView.frame.size.width
            let height = loadingLabel.frame.size.height + progressView.frame.size.height + reloadButton.frame.size.height + 50
            let size = CGSize(width:width, height:height )
            return size
        }
        set {
            super.preferredContentSize = newValue
        }
    }
    
    func refreshButtonStateChanged(_ note: Notification) {
        guard let shouldEnable = note.object as? NSNumber else { return }
        updateRefreshButtonToBeEnabled(shouldEnable.boolValue)
        if shouldEnable.boolValue {
            self.loadingLabel.text = self.defaultLoadingLabelText
        }
    }
    
    func updateProgress() {
        DispatchQueue.main.async {
            self.progressView.progress = Float(self.reader.processedRows) / Float(self.reader.totalRows)
            self.loadingLabel.text = self.reader.downloadStatusString
        }
    }
    
    private func updateRefreshButtonToBeEnabled(_ shouldEnable: Bool) {
        self.reloadButton.isUserInteractionEnabled = shouldEnable
        self.reloadButton.isEnabled = shouldEnable
    }
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        if !self.reader.isLoadingData {
            updateRefreshButtonToBeEnabled(false)
            self.reader.generateData()
            NotificationCenter.default.post(name: ReloadConstants.kReloadDidBeginNoteName, object:NSNumber(booleanLiteral: false))
            
            if !rotate {
                NotificationCenter.default.post(name: ReloadConstants.kReloadDidBeginNoteName, object:NSNumber(booleanLiteral: true))
                rotate = !rotate
            }
        }
    }
    
    // MARK: - Key-Value Observing
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == #keyPath(reader.processedRows) {
//            // Update progress bar
//            progressView.progress = Float(reader.totalRows) / Float(reader.processedRows)
//        }
//    }
}
