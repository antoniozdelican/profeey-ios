//
//  PostSmallTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PostSmallTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
