//
//  LocationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
