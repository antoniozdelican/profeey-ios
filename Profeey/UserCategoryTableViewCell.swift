//
//  UserCategoryTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class UserCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
