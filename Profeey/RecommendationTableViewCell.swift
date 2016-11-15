//
//  RecommendationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class RecommendationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var recommendationTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
