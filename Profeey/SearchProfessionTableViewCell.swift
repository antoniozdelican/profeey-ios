//
//  SearchProfessionTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class SearchProfessionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var numberOfUsersLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
