//
//  HalfResizingTableViewCell.swift
//  ShowlistDC
//
//  Created by Jonathan Chen on 8/6/17.
//  Copyright © 2017 n/a. All rights reserved.
//

import Foundation

class HalfResizingTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let theTextLabel = self.textLabel {
            let halfCellWidth = self.frame.size.width / 2
            theTextLabel.frame.size.width = halfCellWidth
        }
        
        if let theDetailLabel = self.detailTextLabel, let theTextLabel = self.textLabel {
            theDetailLabel.frame.origin.x = (self.frame.size.width / 2) + 25
            theDetailLabel.frame.size.width = self.frame.size.width - theTextLabel.frame.size.width - 50
        }
    }
    
    override func prepareForReuse() {
        if let theTextLabel = self.textLabel {
            theTextLabel.text = nil
        }
        
        if let theDetailLabel = self.detailTextLabel {
            theDetailLabel.text = nil
        }
    }
    
}
