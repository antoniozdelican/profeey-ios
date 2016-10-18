//
//  CurrentlyDoingTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CurrentlyDoingTableViewCellDelegate {
    func switchChanged(_ isOn: Bool)
}

class CurrentlyDoingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentlyDoingSwitch: UISwitch!
    
    var currentlyDoingTableViewCellDelegate: CurrentlyDoingTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IBActions
    
    @IBAction func currentlyDoingSwitchChanged(_ sender: AnyObject) {
        self.currentlyDoingTableViewCellDelegate?.switchChanged(self.currentlyDoingSwitch.isOn)
    }
    
}
