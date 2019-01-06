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
    @IBOutlet weak var allDatesButton: UIButton!
    
    var rotate: Bool = false
    @objc let reader: SpreadsheetReader = SpreadsheetReader.shared
    var progressObservation: NSKeyValueObservation?
    var countObservation: NSKeyValueObservation?
    var statusObservation: NSKeyValueObservation?
    
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
                let formatter = DateFormatter()
                formatter.dateFormat = formatter.defaultDateFormat()
                let maxDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
                return maxDate ?? Date()
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
        
        self.progressView.progress = self.reader.progress
        self.loadingLabel.text = self.reader.downloadStatusString
        
        self.updateUIToBeEnabled(!self.reader.isLoadingData && !self.reader.isLoadingSpreadsheet)
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
        
        updateUIToBeEnabled(!reader.isLoadingData)
        
        progressObservation = observe(\.reader.progress, changeHandler: { (object, change) in
            DispatchQueue.main.async {
                self.progressView.progress = object.reader.progress
            }
        })
        
        countObservation = observe(\.reader.processedRows, changeHandler: { (object, change) in
            DispatchQueue.main.async {
                self.loadingLabel.text = object.reader.downloadStatusString
            }
        })
        
        statusObservation = observe(\.reader.isLoadingData, changeHandler: { (object, change) in
            DispatchQueue.main.async {
                self.loadingLabel.text = object.reader.downloadStatusString
            }
        })
        
        NotificationCenter.default.addObserver(self, selector:#selector(refreshButtonStateChanged(_:)), name:ReloadConstants.kReloadCompleteNoteName, object:NSNumber(booleanLiteral: true))
//        NotificationCenter.default.addObserver(self, selector:#selector(updateProgress), name:ReloadConstants.kUpdatedRowsNoteName, object:nil)
//        NotificationCenter.default.addObserver(self, selector:#selector(updateProgress), name:ReloadConstants.kReloadCompleteNoteName, object:nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Updating the popover size
    override var preferredContentSize: CGSize {
        get {
            let width = progressView.frame.size.width + 50
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
        updateUIToBeEnabled(shouldEnable.boolValue)
        if shouldEnable.boolValue {
            self.loadingLabel.text = SpreadsheetReader.shared.downloadStatusString
        }
    }
    
    func updateProgress() {
//        DispatchQueue.main.async {
//            if self.reader.isLoadingData {
//                self.progressView.progress = self.reader.progress
//            } else {
//                self.progressView.progress = 0
//            }
//            self.loadingLabel.text = self.reader.downloadStatusString
//        }
    }
    
    private func updateUIToBeEnabled(_ shouldEnable: Bool) {
        DispatchQueue.main.async {
            self.reloadButton.isEnabled = shouldEnable
            self.allDatesButton.isEnabled = shouldEnable
            self.fromPicker.isEnabled = shouldEnable
            self.toPicker.isEnabled = shouldEnable
        }
    }
    
    @IBAction func allDatesButtonPressed(_ sender: Any) {
        self.fromDate = self.fromPicker.minimumDate!
        self.fromPicker.date = self.fromPicker.minimumDate!
        self.toDate = self.toPicker.maximumDate!
        self.toPicker.date = self.toPicker.maximumDate!
        
    }
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        
        if self.fromPicker.date.compare(self.toPicker.date) == .orderedDescending {
            let alert = UIAlertController(title: "Invalid dates chosen", message: "First date must be before second date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        /*
         TODO: implement a date picker that is surfaced when reload button is tapped.
         This button should have "All Available Dates" as its first option, but the selection itself should default to today's date up to one month from today's date.
         This way, the user is encouraged to load just a short chunk of the data rather than the whole spreadsheet at once.
         */
        
        if !self.reader.isLoadingData {
            updateUIToBeEnabled(false)
            self.reader.loadData(startDate: self.fromDate, endDate: self.toDate, shouldRestart: true)
            NotificationCenter.default.post(name: ReloadConstants.kReloadDidBeginNoteName, object:NSNumber(booleanLiteral: false))
            
            if !rotate {
                NotificationCenter.default.post(name: ReloadConstants.kReloadDidBeginNoteName, object:NSNumber(booleanLiteral: true))
                rotate = !rotate
            }
        }
    }
}
