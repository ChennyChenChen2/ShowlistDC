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
    @IBOutlet weak var fromPicker: UIDatePicker!
    @IBOutlet weak var toPicker: UIDatePicker!
    
    var rotate: Bool = false
    @objc let reader: SpreadsheetReader = SpreadsheetReader.shared
    
    private let refreshFromDateKey = "kRefreshFromDateKey"
    private var fromDate: Date {
        get {
            if let theDate = UserDefaults.standard.object(forKey: refreshFromDateKey) as? Date {
                return theDate
            } else {
                return Date()
            }
        } set {
            UserDefaults.standard.set(newValue, forKey: refreshFromDateKey)
        }
    }
    
    private let refreshToDateKey = "kRefreshToDateKey"
    private var toDate: Date {
        get {
            if let theDate = UserDefaults.standard.object(forKey: refreshToDateKey) as? Date {
                return theDate
            } else {
                return Date()
            }
        } set {
            UserDefaults.standard.set(newValue, forKey: refreshToDateKey)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let formatter = DateFormatter()
        formatter.dateFormat = formatter.defaultDateFormat()
        let maxDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        
        self.fromPicker.date = self.fromDate
        self.fromPicker.minimumDate = Date()
        self.fromPicker.maximumDate = maxDate
        
        self.toPicker.date = self.toDate
        self.toPicker.minimumDate = Date()
        self.toPicker.maximumDate = maxDate
    }

    @IBAction func fromPickerValueChanged(_ sender: Any) {
        guard let picker = sender as? UIDatePicker else { return }
        self.fromDate = picker.date
    }
    
    @IBAction func toPickerValueChanged(_ sender: Any) {
        guard let picker = sender as? UIDatePicker else { return }
        self.toDate = picker.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingLabel.text = SpreadsheetReader.shared.downloadStatusString
        
        updateRefreshButtonToBeEnabled(!reader.isLoadingData)
        
        NotificationCenter.default.addObserver(self,     selector:#selector(refreshButtonStateChanged(_:)), name:ReloadConstants.kReloadCompleteNoteName, object:NSNumber(booleanLiteral: true))
        NotificationCenter.default.addObserver(self, selector:#selector(updateProgress), name:ReloadConstants.kUpdatedRowsNoteName, object:nil)
    }
    
    //Updating the popover size
    override var preferredContentSize: CGSize {
        get {
            let width = progressView.frame.size.width
            let height = loadingLabel.frame.size.height + progressView.frame.size.height + reloadButton.frame.size.height +
                fromPicker.frame.size.height +
                toPicker.frame.size.height + 150.0
            let size = CGSize(width:width, height:height)
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
            self.loadingLabel.text = SpreadsheetReader.shared.downloadStatusString
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
        
        /*
         TODO: implement a date picker that is surfaced when reload button is tapped.
         This button should have "All Available Dates" as its first option, but the selection itself should default to today's date up to one month from today's date.
         This way, the user is encouraged to load just a short chunk of the data rather than the whole spreadsheet at once.
         */
        
        if !self.reader.isLoadingData {
            updateRefreshButtonToBeEnabled(false)
            self.reader.loadData(startDate: self.fromDate, endDate: self.toDate, shouldRestart: true)
            NotificationCenter.default.post(name: ReloadConstants.kReloadDidBeginNoteName, object:NSNumber(booleanLiteral: false))
            
            if !rotate {
                NotificationCenter.default.post(name: ReloadConstants.kReloadDidBeginNoteName, object:NSNumber(booleanLiteral: true))
                rotate = !rotate
            }
        }
    }
}
