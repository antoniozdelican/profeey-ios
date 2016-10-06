//
//  TopCategoryTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class TopCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var topCategoryNameLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
