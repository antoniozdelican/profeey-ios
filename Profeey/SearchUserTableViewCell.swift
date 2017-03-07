//
//  SearchUserTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class SearchUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolStackView: UIStackView!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var numberOfPostsStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
