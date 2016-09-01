//
//  ProfileExperienceTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ProfileExperienceTableViewCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var timePeriodLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
